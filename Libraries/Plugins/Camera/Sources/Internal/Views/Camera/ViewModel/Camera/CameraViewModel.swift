//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation
import Combine
internal import DI
import Foundation
internal import Telemetry
internal import TruVideoApi
internal import TruvideoSdk
import UIKit
internal import Utilities

extension ErrorReason {
    /// A collection of error reasons related to the device operations.
    ///
    /// The `CameraViewModelErrorReason` struct provides a set of static constants representing various errors that can
    /// occur during interactions with the external devices.
    struct CameraViewModelErrorReason: Sendable {
        /// The app is not authorized to use the device.
        ///
        /// Meaning:
        /// - Authorization status is `.denied` or `.restricted`
        static let deviceNotAuthorized = ErrorReason(rawValue: "DEVICE_NOT_AUTHORIZED")
    }
}

/// A global actor that serializes access to capture session operations and media services.
///
/// The `SessionActor` provides a centralized execution context for managing capture session
/// lifecycle operations, media service notifications, and related state management. This actor
/// ensures that all session-related operations occur on a single, well-defined executor,
/// preventing data races and ensuring consistent state when working with capture sessions,
/// media service resets, and session coordination.
///
/// This actor is particularly important for handling media service reset notifications and
/// ensuring that capture session operations are properly synchronized. It prevents conflicts
/// between different parts of the system that might be trying to start, stop, or configure
/// capture sessions simultaneously.
@globalActor
actor SessionActor {
    /// The shared global actor instance used to isolate session operations.
    ///
    /// This static property provides access to the singleton instance of the SessionActor,
    /// which is used throughout the application to ensure consistent execution context
    /// for all session-related operations.
    static let shared = SessionActor()
}

final class CameraViewModel: ObservableObject, OrientationMonitorSubscriber {
    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()
    private let orientationMonitor: OrientationMonitor
    private let onCompleted: (TruvideoSdkCameraResult) -> Void

    // MARK: - Internal Properties

    /// Indicates whether a photo capture operation is currently in progress.
    ///
    /// This flag prevents multiple simultaneous photo captures and is used for
    /// debouncing capture requests. It's set to `true` when capture starts and
    /// reset to `false` when the capture completes or fails.
    var isCaptureInFlight = false

    /// The system uptime timestamp of the last photo capture operation.
    ///
    /// This property is used for debouncing photo capture requests to prevent
    /// rapid successive captures, especially when flash is enabled. The value
    /// represents the system uptime in seconds when the last photo was captured.
    var lastPhotoCaptureUptime = TimeInterval.zero

    /// The total count of media items (photos and videos) captured in the current session.
    ///
    /// This counter tracks the cumulative number of media items captured and is
    /// used for enforcing maximum media count limits. It's incremented when capture
    /// starts and decremented if capture fails.
    var mediasTaken = 0

    /// The movie output processor responsible for video recording operations.
    ///
    /// This processor handles video encoding, file writing, and recording state
    /// management. It processes video and audio sample buffers and manages the
    /// recording lifecycle including pause/resume functionality.
    let movieOutputProcessor = MovieOutputProcessor()

    /// The count of photos captured in the current session.
    ///
    /// This counter tracks the number of photos taken and is used for enforcing
    /// maximum photo count limits. It's incremented when photo capture succeeds
    /// and decremented if the photo is deleted.
    var photosTaken = 0

    // MARK: - Dependencies

    @Dependency(\.telemetryManager)
    var telemetryManager: TelemetryManager

    // MARK: - Properties

    /// The audio capture device that manages microphone operations and lifecycle.
    ///
    /// This property provides access to the audio capture device responsible for
    /// microphone operations including audio recording, permission management,
    /// and audio session coordination. The device encapsulates all audio-related
    /// functionality and provides a high-level interface for audio operations.
    let audioDevice = AudioDevice()

    /// The core capture session that coordinates all media capture operations.
    ///
    /// This property provides access to the main `AVCaptureSession` that serves as
    /// the central coordinator for all media capture operations. The session manages
    /// the lifecycle of audio and video inputs/outputs, handles device configuration,
    /// and provides the foundation for synchronized media capture.
    let captureSession = AVCaptureSession()

    /// The camera configuration containing settings and preferences for the camera session.
    ///
    /// This property holds the complete configuration for the camera module including
    /// capture modes, media limits, output paths, resolution preferences, and other
    /// settings that control camera behavior. The configuration is set during
    /// initialization and remains constant throughout the camera session lifecycle.
    let configuration: TruvideoSdkCameraConfiguration

    /// Indicates whether the camera device supports torch (flashlight) functionality.
    ///
    /// This property tracks whether the current camera device has torch capabilities.
    /// It defaults to `false` representing the initial state before torch availability
    /// has been determined. The property is updated when the camera device is configured
    /// and torch support is checked.
    var isTorchAvailable = false

    /// Localized error message for display to users. Empty string when no error.
    var localizedError = ""

    /// Collection of all available video capture presets ordered by quality (highest to lowest).
    ///
    /// This property provides access to all supported video resolution presets in order
    /// of quality, from highest to lowest resolution. It serves as the definitive list
    /// of available capture presets that can be selected by the user or applied
    /// programmatically to the capture session.
    @Published var presets = [AVCaptureSession.Preset.hd1920x1080, .hd1280x720, .vga640x480]

    /// The video preview layer that displays the camera feed in the UI.
    let previewLayer = AVCaptureVideoPreviewLayer()

    /// The video capture device that manages camera operations and lifecycle.
    ///
    /// This property provides access to the main video capture device responsible for
    /// camera operations including video recording, photo capture, torch control, zoom
    /// management, and focus handling. The device encapsulates all camera-related
    /// functionality and provides a high-level interface for camera operations.
    let videoDevice = VideoDevice()

    // MARK: - Published Properties

    /// Controls whether user interactions are enabled for camera UI components.
    ///
    /// This property manages the interactive state of camera interface elements to prevent
    /// user input during critical operations such as camera switching, recording state changes,
    /// or other asynchronous operations that could cause conflicts or unexpected behavior.
    @Published var allowsHitTesting = false

    /// The current aspect ratio of the camera preview, expressed as height divided by width.
    ///
    /// This property represents the aspect ratio of the camera preview in the format height:width.
    @Published private(set) var aspectRatio: CGFloat = 9 / 16

    /// The current orientation of the device relative to the user interface.
    ///
    /// This property tracks the device's orientation and is used to adjust the camera
    /// interface layout and behavior accordingly.
    @Published private(set) var deviceOrientation = UIDeviceOrientation.portrait

    /// Indicates whether the user is currently authenticated with the TruVideo service.
    ///
    /// This property tracks the authentication state of the user and determines whether
    /// the camera functionality should be available. When `true`, the user has been
    /// successfully authenticated and can access camera features. When `false`, the
    /// user is not authenticated and camera functionality should be restricted.
    @Published private(set) var isAuthenticated = false

    /// Combined authorization status for both audio and video devices.
    /// `true` when both camera and microphone access are granted, `false` when either is denied.
    @Published var isAuthorized = true

    /// Torch/flashlight status. `true` when torch is enabled, `false` when disabled.
    @Published var isTorchEnabled = false

    /// A boolean indicating whether the snackbar should be presented.
    @Published var isSnackbarPresented = false

    /// The last zoom factor applied to the camera preview.
    @Published var lastZoomFactor: CGFloat = 1

    /// The remaining recording time in Hours:Minutes:Seconds format.
    ///
    /// This property displays how much recording time is left based on the
    /// configured maximum video duration. It updates in real time as the
    /// recording progresses, providing a clear visual indicator of the
    /// remaining available time.
    @Published var remainingTime = 0.toHMS()

    /// Whether the user must confirm before leaving or performing a potentially
    /// destructive action.
    @Published var requiresConfirmation = false

    /// The total duration of recorded video in Hours:Minutes:Seconds format.
    ///
    /// This property displays the cumulative recording time in a human-readable format.
    @Published var timeRecorded = 0.toHMS()

    /// The currently selected video capture resolution preset.
    ///
    /// This property tracks the active video resolution setting for the camera session.
    /// It determines the capture resolution and quality level used for video recording
    /// and photo capture operations. The preset is applied to the underlying
    /// `AVCaptureSession` to configure the appropriate resolution settings.
    @Published var selectedPreset = AVCaptureSession.Preset.hd1280x720

    /// The current lifecycle state of the recording process.
    @Published var state = RecordingState.initialized

    /// The current validation state of the view or operation.
    ///
    /// This property tracks the validation status using a `ValidationState` enum that
    /// represents different validation conditions. It defaults to `.initial` representing
    /// the starting state before any validation has been performed.
    @Published private(set) var validationState = ValidationState.initial

    /// The available zoom factor options that users can select from.
    ///
    /// This array defines the zoom levels that are available for selection in the camera
    /// interface. Each value represents a magnification factor.
    @Published var zoomFactors: [CGFloat] = [1]

    /// The current zoom factor applied to the camera preview.
    ///
    /// This property represents the magnification level of the camera view.
    @Published var zoomFactor: CGFloat = 1

    /// The collection of media items displayed in the gallery.
    ///
    /// This published property contains all media items (both video clips and photos)
    /// that are currently displayed in the gallery.
    @Published var medias: [Media] = [] {
        didSet {
            /// Detect media deletion when the array count decreases
            if medias.count < oldValue.count {
                let photoCount = medias.lazy.filter(\.isPhoto).count
                mediasTaken = medias.count

                if photoCount < oldValue.filter(\.isPhoto).count {
                    photosTaken = photoCount
                }
            }
        }
    }

    // MARK: - Computed Properties

    /// The default capture preset for the active camera lens.
    ///
    /// This computed property returns the most appropriate `AVCaptureSession.Preset`
    /// based on the currently active video device (`front` or `back`) and the
    /// configured resolution preferences.
    ///
    /// - For the **front camera**, it checks whether the configured `frontResolution`
    ///   exists in `frontResolutions`. If not, it falls back to the first available
    ///   preset or `.hd1280x720` if none are available.
    ///
    /// - For the **back camera**, it performs the same validation using
    ///   `backResolution` and `backResolutions`.
    ///
    /// This ensures the capture session always starts with a valid and supported
    /// preset, even if the configuration contains outdated or unsupported values.
    ///
    /// - Returns: A valid `AVCaptureSession.Preset` for the current lens configuration.
    var defaultPreset: AVCaptureSession.Preset {
        get async {
            guard await videoDevice.position == .back else {
                if configuration.frontResolutions.contains(configuration.frontResolution) {
                    return configuration.frontResolution.preset
                }

                return configuration.frontResolutions.first?.preset ?? .hd1280x720
            }

            if configuration.backResolutions.contains(configuration.backResolution) {
                return configuration.backResolution.preset
            }

            return configuration.backResolutions.first?.preset ?? .hd1280x720
        }
    }

    /// Returns a formatted string representing the current video clip count and limit.
    ///
    /// This computed property calculates the number of video clips captured and formats
    /// it according to the configuration's maximum video count. It handles different
    /// display scenarios including unlimited clips, no clips, and limited clip counts.
    var numberOfClips: String {
        let maxVideoCount = TruvideoSdkCameraMediaMode.maxVideoCount
        let numberOfClips = medias.lazy.filter(\.isClip).count

        guard configuration.mode.maxVideoDuration > 0 else {
            return ""
        }

        if configuration.mode.maxVideoCount == maxVideoCount || configuration.mode.maxVideoCount == 0 {
            return numberOfClips == 0 ? "" : "\(numberOfClips)"
        }

        return "\(numberOfClips)/\(configuration.mode.maxVideoCount)"
    }

    /// Returns a formatted string representing the current total media count and limit.
    ///
    /// This computed property calculates the total number of media items captured and
    /// formats it according to the configuration's maximum media count. It only displays
    /// the count when the mode is configured for total media limits (not individual
    /// photo or video limits).
    var numberOfMedias: String {
        let maxMediaCount = TruvideoSdkCameraMediaMode.maxMediaCount
        let isWithinRange = configuration.mode.maxMediaCount > 0 && configuration.mode.maxMediaCount < maxMediaCount

        guard configuration.mode.maxPictureCount == 0, configuration.mode.maxVideoCount == 0, isWithinRange else {
            return ""
        }

        return "\(mediasTaken)/\(configuration.mode.maxMediaCount)"
    }

    /// Returns a formatted string representing the current photo count and limit.
    ///
    /// This computed property calculates the number of photos captured and formats
    /// it according to the configuration's maximum picture count. It handles different
    /// display scenarios including unlimited photos, no photos, and limited photo counts.
    var numberOfPhotos: String {
        let maxPictureCount = TruvideoSdkCameraMediaMode.maxPictureCount
        let numberOfPhotos = medias.lazy.filter(\.isPhoto).count

        if configuration.mode.maxPictureCount == maxPictureCount || configuration.mode.maxPictureCount == 0 {
            return numberOfPhotos == 0 ? "" : "\(numberOfPhotos)"
        }

        return "\(numberOfPhotos)/\(configuration.mode.maxPictureCount)"
    }

    /// Determines whether the remaining recording time should be displayed.
    ///
    /// This computed property evaluates whether the remaining time indicator
    /// needs to be shown during video recording. It compares the current mode's
    /// maximum video duration against the SDK’s global maximum allowed duration,
    /// and returns `true` only when:
    /// - The configured maximum duration is smaller than the SDK limit, and
    /// - The recording state is either `.running` or `.paused`.
    ///
    /// This ensures the remaining time is shown only when the recording has
    /// a defined time limit and is currently active or paused.
    var shouldDisplayRemainingTime: Bool {
        let maxVideoDurationAllowed = TruvideoSdkCameraMediaMode.maxVideoDurationAllowed
        let maxVideoDuration = configuration.mode.maxVideoDuration

        return maxVideoDuration > 0 && maxVideoDuration != maxVideoDurationAllowed
            && [RecordingState.running, .paused].contains(state)
    }

    // MARK: - Types

    /// A set of validation states that can be combined to represent different validation conditions.
    ///
    /// `ValidationState` provides a type-safe way to manage validation states using bit flags.
    /// It conforms to `OptionSet` to allow combining multiple states and checking for specific conditions.
    struct ValidationState: OptionSet {
        // MARK: - Properties

        /// The element type of the option set.
        let rawValue: Int

        // MARK: - Static Properties

        /// The initial state when no validation has been performed.
        static let initial = ValidationState([])

        /// The state when the data fails validation.
        ///
        /// This state indicates that validation has been performed and the data
        /// does not meet the required criteria.
        static let invalid = ValidationState(rawValue: 2 << 1)

        /// The state when the data passes validation.
        ///
        /// This state indicates that validation has been performed and the data
        /// meets all required criteria.
        static let valid = ValidationState(rawValue: 2 << 2)
    }

    // MARK: - Initializer

    /// Creates a new instance with configuration, completion handler, and orientation monitoring.
    ///
    /// This initializer sets up the instance with a camera configuration, a completion
    /// callback that will be invoked when the operation completes, and an orientation
    /// monitor for tracking device orientation changes during the process.
    ///
    /// - Parameters:
    ///   - configuration: The camera configuration containing settings and preferences.
    ///   - orientationMonitor: The orientation monitor to use for tracking device orientation .
    ///   - truVideoSdk: The main entry point for the TruVideo SDK.
    ///   - onCompleted: Closure to be called when the operation completes with the result.
    init(
        configuration: TruvideoSdkCameraConfiguration,
        orientationMonitor: OrientationMonitor = DeviceOrientationMonitor(),
        truVideoSdk: TruVideoSDK = TruvideoSdk,
        onCompleted: @escaping (TruvideoSdkCameraResult) -> Void
    ) {
        let outputDirectory = URL(string: configuration.outputPath) ?? URL(fileURLWithPath: NSTemporaryDirectory())

        self.configuration = configuration
        self.onCompleted = onCompleted
        self.orientationMonitor = orientationMonitor
        self.isAuthenticated = truVideoSdk.isAuthenticated

        if isAuthenticated {
            self.previewLayer.session = captureSession
            self.previewLayer.videoGravity = .resizeAspectFill

            self.orientationMonitor.add(self)
            self.orientationMonitor.startMonitoring()

            self.isTorchEnabled = configuration.flashMode == .on

            movieOutputProcessor.delegate = self
            movieOutputProcessor.maxRecordingDuration = configuration.mode.maxVideoDuration
            movieOutputProcessor.outputDirectory = outputDirectory

            initialize()
            configureObservers()

            configureSessionObservers()
            subscribeToSecondsRecorded()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Instance methods

    /// Processes the captured media and marks the validation state as valid.
    ///
    /// This method converts all captured media items to the TruVideo SDK format
    /// and updates the validation state to indicate that the media collection
    /// is ready for further processing or submission.
    func onContinue() {
        let result = TruvideoSdkCameraResult(media: medias.map(TruvideoSdkCameraMedia.from))

        telemetryManager.captureBreadcrumb(
            severity: .info,
            category: .cameraLifecycle,
            message: "Camera operation completed",
            metadata: [
                "clipCount": .int(medias.lazy.filter(\.isClip).count),
                "photoCount": .int(medias.lazy.filter(\.isPhoto).count)
            ]
        )

        onCompleted(result)
        validationState = .valid
    }

    /// Validates clips state before dismissal and updates validation state accordingly.
    ///
    /// Sets `validationState` to `.invalid` if clips or photos are not empty (preventing dismissal),
    /// or `.valid` if clips are empty (allowing dismissal).
    func onDismiss() {
        allowsHitTesting = false

        guard medias.isEmpty, ![.paused, .running].contains(state) else {
            telemetryManager.captureBreadcrumb(
                severity: .warning,
                category: .cameraLifecycle,
                message: "Camera dismissed with unsaved media",
                metadata: [
                    "clipCount": .int(medias.lazy.filter(\.isClip).count),
                    "photoCount": .int(medias.lazy.filter(\.isPhoto).count)
                ]
            )

            allowsHitTesting = true
            requiresConfirmation = true
            validationState = .invalid
            return
        }

        validationState = .valid
    }

    /// Opens the app's settings page in the iOS Settings application.
    ///
    /// This method checks whether the system can open the app settings URL.
    /// If so, it will transition the user to the settings screen, allowing them
    /// to manually update permissions such as camera, microphone, or photo library access.
    func openAppSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }
    }

    // MARK: - OrientationMonitorSubscriber

    /// Handles a new device orientation update and applies the corresponding rotation angle.
    ///
    /// This method is triggered when a new `DeviceOrientationInfo` is received.
    /// It updates the current orientation, calculates the transition between the
    /// previous and new orientations, and determines the appropriate rotation angle.
    /// If the orientation source comes from sensors while the device is physically
    /// in portrait mode, it preserves or updates the rotation angle accordingly.
    ///
    /// - Parameter deviceOrientation: The latest orientation information, including its source and value.
    func didReceive(_ deviceOrientation: DeviceOrientation) {
        if deviceOrientation.orientation != .portraitUpsideDown {
            orientationDidUpdate(to: deviceOrientation.orientation)
        }
    }

    // MARK: - Internal methods

    /// Displays an error message to the user through the snackbar interface.
    ///
    /// This function provides a centralized way to handle and display error messages
    /// to users in the camera interface. It sets the localized error message and
    /// triggers the presentation of a snackbar to inform the user about the error
    /// condition. This ensures consistent error handling and user feedback across
    /// the camera application.
    ///
    /// The function operates on the main actor to ensure UI updates are performed
    /// safely and synchronously. It updates both the error message and the snackbar
    /// presentation state, providing immediate visual feedback to the user about
    /// any issues that occur during camera operations.
    ///
    /// - Parameter error: The localized error message to display to the user
    @MainActor
    func didReceiveError(_ error: String) {
        localizedError = error
        isSnackbarPresented = true
    }

    /// Updates the camera preview and video output orientation to match the device orientation.
    ///
    /// This method synchronizes the camera preview layer and video capture output with
    /// the current device orientation. It ensures that the camera feed displays correctly
    /// regardless of how the user is holding the device. The method only processes valid
    /// orientations (landscape left/right and portrait) and ignores unsupported orientations
    /// like portrait upside down.
    func updatePreviewOrientation() {
        if [.landscapeLeft, .landscapeRight, .portrait].contains(deviceOrientation) {
            Task { @MainActor in
                let videoOrientation = AVCaptureVideoOrientation(from: deviceOrientation)

                previewLayer.connection?.videoOrientation = videoOrientation
                await videoDevice.setVideoOrientation(videoOrientation)

                telemetryManager.captureBreadcrumb(
                    severity: .info,
                    category: .cameraUI,
                    message: "Preview orientation updated",
                    metadata: [
                        "orientation": .string("\(deviceOrientation)"),
                        "videoOrientation": .string("\(videoOrientation)")
                    ]
                )
            }
        }
    }

    // MARK: - Private methods

    @MainActor
    private func endRecording() async throws {
        state = .finished

        let clip = try await movieOutputProcessor.endProcessing()

        await telemetryManager.captureBreadcrumb(
            severity: .info,
            category: .videoRecording,
            message: "Video recording stopped",
            metadata: [
                "devicePosition": .int(videoDevice.position.rawValue),
                "duration": .double(clip.duration),
                "clipCount": .int(medias.lazy.filter(\.isClip).count + 1),
                "zoomFactor": .double(zoomFactor)
            ]
        )

        medias.insert(.clip(clip), at: 0)

        await videoDevice.pause()
        await audioDevice.pause()
    }

    private func orientationDidUpdate(to orientation: UIDeviceOrientation) {
        defer { updatePreviewOrientation() }

        deviceOrientation = orientation

        guard !UIDevice.current.isPad else {
            aspectRatio = 1
            return
        }

        switch orientation {
        case .landscapeLeft, .landscapeRight:
            aspectRatio = 16 / 9

        case .portrait, .portraitUpsideDown:
            aspectRatio = 9 / 16

        default:
            break
        }
    }

    private func subscribeToSecondsRecorded() {
        movieOutputProcessor.$recordingDuration
            .filter(\.isValid)
            .receive(on: RunLoop.main)
            .sink { [weak self] duration in
                guard let self = self else { return }

                let seconds = duration.seconds
                self.timeRecorded = seconds.toHMS()
                self.remainingTime = max(self.configuration.mode.maxVideoDuration - seconds, 0).toHMS()
            }
            .store(in: &cancellables)
    }
}

extension CameraViewModel: MovieOutputProcessorDelegate {
    // MARK: - MovieOutputProcessorDelegate

    /// Notifies the delegate when the movie output processor reaches the maximum recording duration.
    ///
    /// This method is called when the `MovieOutputProcessor` has reached its configured
    /// maximum recording duration and has completed processing the current video segment.
    /// The processor automatically stops recording and finalizes the video clip before
    /// calling this delegate method.
    ///
    /// The result parameter contains either a successfully created `VideoClip` object
    /// with metadata about the recorded video, or an `Error` if the processing failed.
    /// The delegate should handle both cases appropriately, such as updating the UI
    /// or managing the application's state.
    ///
    /// - Parameters:
    ///   - output: The movie output processor that reached the maximum duration
    ///   - result: A result containing either a `VideoClip` on success or an `Error` on failure
    func movieOutputProcessor(_ output: MovieOutputProcessor, didReachMaxDuration result: Result<VideoClip, Error>) {
        Task { @MainActor in
            state = .finished

            switch result {
            case let .failure(error):
                mediasTaken = max(0, mediasTaken - 1)
                didReceiveError(error.localizedDescription)

            case let .success(clip):
                await telemetryManager.captureBreadcrumb(
                    severity: .warning,
                    category: .videoRecording,
                    message: "Maximum recording duration reached",
                    metadata: [
                        "devicePosition": .int(videoDevice.position.rawValue),
                        "duration": .double(clip.duration),
                        "maxDuration": .double(configuration.mode.maxVideoDuration),
                        "clipCount": .int(medias.lazy.filter(\.isClip).count + 1)
                    ]
                )

                medias.insert(.clip(clip), at: 0)
                didReceiveError(Localizations.maxClipDurationReached)
            }
        }
    }
}

extension TruvideoSdkCameraConfiguration {
    /// A dictionary of telemetry metadata representing the camera configuration settings.
    ///
    /// This computed property provides a structured collection of all key camera configuration
    /// values in a format suitable for telemetry reporting. It converts configuration settings
    /// into typed metadata values that can be tracked, logged, and analyzed for debugging,
    /// analytics, and user behavior insights.
    ///
    /// - Returns: A dictionary mapping configuration keys to their typed metadata values
    var metadata: [String: MetadataValue] {
        [
            "flashMode": .string(flashMode.rawValue),
            "lensFacing": .string(lensFacing.rawValue),
            "imageFormat": .string(imageFormat.rawValue),
            "isHighResolutionEnabled": .bool(isHighResolutionPhotoEnabled),
            "maxPictureCount": .int(mode.maxPictureCount),
            "maxVideoCount": .int(mode.maxVideoCount),
            "maxMediaCount": .int(mode.maxMediaCount),
            "maxVideoDuration": .double(mode.maxVideoDuration)
        ]
    }
}
