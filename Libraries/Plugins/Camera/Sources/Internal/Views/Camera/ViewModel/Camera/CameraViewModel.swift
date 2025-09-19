//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit
internal import Utilities

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

    private let configuration: TruvideoSdkCameraConfiguration
    private var isCaptureInFlight = false
    private var lastPhotoCaptureUptime = TimeInterval.zero
    private let orientationMonitor: OrientationMonitor
    private var mediasTaken = 0
    private let movieOutputProcessor = MovieOutputProcessor()
    private let onCompleted: (TruvideoSdkCameraResult) -> Void
    private var photosTaken = 0

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

    /// Indicates whether the camera device supports torch (flashlight) functionality.
    ///
    /// This property tracks whether the current camera device has torch capabilities.
    /// It defaults to `false` representing the initial state before torch availability
    /// has been determined. The property is updated when the camera device is configured
    /// and torch support is checked.
    private(set) var isTorchAvailable = false

    /// Localized error message for display to users. Empty string when no error.
    private(set) var localizedError = ""

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
    @Published private(set) var allowsHitTesting = false

    /// The current aspect ratio of the camera preview, expressed as height divided by width.
    ///
    /// This property represents the aspect ratio of the camera preview in the format height:width.
    @Published private(set) var aspectRatio: CGFloat = 9 / 16

    /// The current orientation of the device relative to the user interface.
    ///
    /// This property tracks the device's orientation and is used to adjust the camera
    /// interface layout and behavior accordingly.
    @Published private(set) var deviceOrientation = UIDeviceOrientation.portrait

    /// Combined authorization status for both audio and video devices.
    /// `true` when both camera and microphone access are granted, `false` when either is denied.
    @Published private(set) var isAuthorized = true

    /// Torch/flashlight status. `true` when torch is enabled, `false` when disabled.
    @Published private(set) var isTorchEnabled = false

    /// A boolean indicating whether the snackbar should be presented.
    @Published var isSnackbarPresented = false

    /// The last zoom factor applied to the camera preview.
    @Published var lastZoomFactor: CGFloat = 1

    /// Whether the user must confirm before leaving or performing a potentially
    /// destructive action.
    @Published var requiresConfirmation = false

    /// The total duration of recorded video in Hours:Minutes:Seconds format.
    ///
    /// This property displays the cumulative recording time in a human-readable format.
    @Published var secondsRecorded = 0.toHMS()

    /// The currently selected video resolution.
    ///
    /// Defaults to `.sd` (Standard Definition).
    /// Use this property to track or update the active resolution
    /// chosen by the user or the application.
    @Published var selectedResolution = VideoResolution.highDefinition

    /// The current lifecycle state of the recording process.
    @Published private(set) var state = RecordingState.initialized

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
    @Published private(set) var zoomFactors: [CGFloat] = [1]

    /// The current zoom factor applied to the camera preview.
    ///
    /// This property represents the magnification level of the camera view.
    @Published private(set) var zoomFactor: CGFloat = 1

    /// The collection of media items displayed in the gallery.
    ///
    /// This published property contains all media items (both video clips and photos)
    /// that are currently displayed in the gallery.
    @Published var medias: [Media] = [] {
        didSet {
            /// If the new array is less than the previous one we assume that medias
            /// were deleted
            if medias.count < oldValue.count {
                let photoCount = medias.filter(\.isPhoto).count
                mediasTaken = medias.count

                if photoCount < oldValue.filter(\.isPhoto).count {
                    photosTaken = photoCount
                }
            }
        }
    }

    // MARK: - Private Computed Properties

    private var canTakeMoreClips: Bool {
        let mode = configuration.mode

        guard mode.maxPictureCount == 0, mode.maxVideoCount == 0, mode.maxMediaCount > 0 else {
            return medias.lazy.filter(\.isClip).count < mode.maxVideoCount
        }

        return mediasTaken < mode.maxMediaCount
    }

    private var canTakeMorePhotos: Bool {
        let mode = configuration.mode

        guard mode.maxPictureCount == 0, mode.maxVideoCount == 0, mode.maxMediaCount > 0 else {
            return photosTaken < mode.maxPictureCount
        }

        return mediasTaken < mode.maxMediaCount
    }

    // MARK: - Computed Properties

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

        guard configuration.mode.maxPictureCount == 0 && configuration.mode.maxVideoCount == 0, isWithinRange else {
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
    ///   - onCompleted: Closure to be called when the operation completes with the result.
    init(
        configuration: TruvideoSdkCameraConfiguration,
        orientationMonitor: OrientationMonitor = DeviceOrientationMonitor(),
        onCompleted: @escaping (TruvideoSdkCameraResult) -> Void
    ) {

        let outputDirectory = URL(string: configuration.outputPath) ?? URL(fileURLWithPath: NSTemporaryDirectory())

        self.configuration = configuration
        self.onCompleted = onCompleted
        self.orientationMonitor = orientationMonitor

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

        if captureSession.canSetSessionPreset(.hd4K3840x2160) {
            captureSession.sessionPreset = .hd4K3840x2160
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Instance methods

    /// Captures a photo using the photo device and adds it to the photos collection.
    ///
    /// This function initiates an asynchronous photo capture operation on the main actor.
    /// If the capture is successful, the captured photo is appended to the photos array.
    /// If an error occurs during capture, the error's localized description is stored
    /// in the localizedError property for user feedback.
    func capturePhoto() {
        Task { @MainActor in
            guard canTakeMorePhotos else {
                didReceiveError(Localizations.maxNumberOfPicturesReached)
                return
            }

            let debounceWindow = configuration.flashMode != .off ? 0.45 : 0
            let systemUptime = ProcessInfo.processInfo.systemUptime

            if systemUptime - lastPhotoCaptureUptime < debounceWindow || isTorchEnabled, isCaptureInFlight {
                return
            }

            isCaptureInFlight = true
            lastPhotoCaptureUptime = systemUptime
            mediasTaken += 1
            photosTaken += 1

            defer { isCaptureInFlight = false }

            do {
                let photo = try await videoDevice.capturePhoto()

                medias.insert(.photo(photo), at: 0)
                validate()
            } catch {
                mediasTaken -= 1
                photosTaken -= 1
                didReceiveError(error.localizedDescription)
            }
        }
    }

    /// Adjusts the current zoom level based on a magnification value.
    ///
    /// This method applies a magnification factor to the last known zoom factor
    /// and clamps the result to the valid range of `zoomFactors`.
    ///
    /// - The zoom factor is always kept within the minimum and maximum supported values.
    /// - If the calculated factor is below the minimum, the minimum zoom is applied.
    /// - If the factor is between the first two levels, the raw factor is used.
    /// - If the factor exceeds the second level, it is clamped to the maximum zoom.
    ///
    /// - Parameter value: The magnification multiplier from a gesture
    func magnify(by value: CGFloat) {
        if zoomFactors.count > 1 {
            let rawFactor = max(lastZoomFactor * value, zoomFactors[0])

            guard rawFactor <= zoomFactors[1] else {
                let zoomFactor = min(rawFactor, zoomFactors[zoomFactors.count - 1])
                rampZoomFactor(to: zoomFactor, rate: 0)

                return
            }

            rampZoomFactor(to: rawFactor)
        }
    }

    /// Processes the captured media and marks the validation state as valid.
    ///
    /// This method converts all captured media items to the TruVideo SDK format
    /// and updates the validation state to indicate that the media collection
    /// is ready for further processing or submission.
    func onContinue() {
        let result = TruvideoSdkCameraResult(media: medias.map(TruvideoSdkCameraMedia.from))

        onCompleted(result)
        validationState = .valid
    }

    /// Validates clips state before dismissal and updates validation state accordingly.
    ///
    /// Sets `validationState` to `.invalid` if clips or photos are not empty (preventing dismissal),
    /// or `.valid` if clips are empty (allowing dismissal).
    func onDismiss() {
        guard medias.isEmpty, ![.paused, .running].contains(state) else {
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

    /// Smoothly animates the camera to a target zoom factor.
    ///
    /// This method updates the published `zoomFactor` and requests the underlying
    /// `VideoDevice` to ramp the zoom to the specified level. The zoom transition
    /// can be performed at a configurable rate, or using the device’s default rate
    /// if none is provided. Execution is dispatched to the main actor for UI safety,
    /// and any errors encountered are forwarded through `didReceiveError(_:)`.
    ///
    /// - Parameters:
    ///   - zoomFactor: The target zoom factor to apply to the camera.
    ///   - rate: The optional speed of the zoom ramp, in device-specific units.
    func rampZoomFactor(to newZoomFactor: CGFloat, rate: Float = 10) {
        Task { @MainActor in
            do {
                zoomFactor = newZoomFactor
                try await videoDevice.setZoomFactor(zoomFactor, rate: rate)
            } catch {
                didReceiveError(error.localizedDescription)
            }
        }
    }

    /// Sets the camera focus point to the specified location asynchronously.
    ///
    /// This method sets the focus point of the video device to the provided coordinates
    /// and handles any errors that may occur during the operation. The focus point
    /// change is performed on the main actor to ensure thread safety for UI updates.
    /// If an error occurs during the focus point setting, the localized error is
    /// cleared to prevent displaying stale error messages.
    ///
    /// - Parameter point: The normalized point (0.0 to 1.0) where focus should be set
    func setFocusPoint(at point: CGPoint) {
        Task { @MainActor in
            do {
                let point = previewLayer.captureDevicePointConverted(fromLayerPoint: point)
                try await videoDevice.setFocusPoint(at: point)
            } catch {
                didReceiveError(error.localizedDescription)
            }
        }
    }

    /// Switches between the front and back camera positions.
    ///
    /// This function toggles the camera position between the front-facing camera (selfie camera)
    /// and the back-facing camera (main camera). It attempts to change the camera position
    /// and updates the error state if the operation fails.
    func switchCamera() {
        Task { @MainActor in
            allowsHitTesting = false

            do {
                let position = await videoDevice.position == .back ? AVCaptureDevice.Position.front : .back

                try await videoDevice.setPosition(position)

                isTorchAvailable = await videoDevice.isTorchAvailable
                zoomFactors = await videoDevice.displayVideoZoomFactors.sorted()

                zoomFactor = 1
                Task.delayed(milliseconds: 600) {
                    allowsHitTesting = true
                }
            } catch {
                didReceiveError(error.localizedDescription)
                allowsHitTesting = true
            }
        }
    }

    /// Toggles the camera's torch on or off with error handling.
    ///
    /// This function switches the torch state between enabled and disabled modes.
    /// It optimistically updates the UI state first, then attempts to change the
    /// actual torch mode. If the torch operation fails, it reverts the UI state
    /// to maintain consistency between the visual state and the actual hardware state.
    func switchTorch() {
        Task { @MainActor in
            isTorchEnabled.toggle()

            let torchMode = isTorchEnabled ? AVCaptureDevice.TorchMode.on : .off

            do {
                if await videoDevice.isTorchAvailable {
                    try await videoDevice.setTorchMode(torchMode)
                }

                Task { @DeviceActor in
                    videoDevice.flashMode = isTorchEnabled ? .on : .off
                }
            } catch {
                isTorchEnabled.toggle()
                didReceiveError(error.localizedDescription)
            }
        }
    }

    /// Toggles the recording state between pause and record.
    ///
    /// This function manages the recording lifecycle by checking the current state
    /// of the video device and performing the appropriate action. If the device
    /// is currently running, it pauses the recording by pausing the movie processing.
    func togglePause() {
        Task { @MainActor in
            switch movieOutputProcessor.state {
            case .paused:
                do {
                    guard await audioDevice.isAvailable else {
                        localizedError = Localizations.anotherAppIsUsingMicrophone
                        isSnackbarPresented = true
                        return
                    }

                    await ensureTorchCompatibility()

                    try await audioDevice.startCapturing()
                    try await videoDevice.startCapturing()

                    await movieOutputProcessor.startProcessing()

                    state = .running
                } catch {
                    didReceiveError(error.localizedDescription)
                }

            case .writing:
                pauseSession()

            default:
                break
            }
        }
    }

    /// Toggles the recording state between start and stop.
    ///
    /// This function manages the recording lifecycle by checking the current state
    /// of the video device and performing the appropriate action. If the device
    /// is currently running, it stops the recording by ending movie processing
    /// and stopping the recorder. If the device is not running, it starts
    /// recording by calling the recorder's record method.
    ///
    /// The function operates on the main actor to ensure UI updates are performed
    /// safely and handles errors by setting the localized error description
    /// for user feedback. It uses async/await for proper coordination between
    /// the video device state and recorder operations.
    func toggleRecord() {
        Task { @MainActor in
            do {
                switch movieOutputProcessor.state {
                case .initialized, .finished, .failed:
                    guard canTakeMoreClips else {
                        didReceiveError(Localizations.maxNumberOfClipsReached)
                        return
                    }

                    guard await audioDevice.isAvailable else {
                        localizedError = Localizations.anotherAppIsUsingMicrophone
                        isSnackbarPresented = true
                        return
                    }

                    mediasTaken += 1

                    await ensureTorchCompatibility()

                    try await videoDevice.startCapturing()
                    try await audioDevice.startCapturing()

                    await movieOutputProcessor.startProcessing()

                    state = .running

                case .paused where state.canTransition(to: .finished),
                    .writing where state.canTransition(to: .finished):

                    try await endRecording()

                default:
                    break
                }
            } catch {
                mediasTaken -= 1
                didReceiveError(error.localizedDescription)
            }
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
    @MainActor
    func didReceiveError(_ error: String) {
        localizedError = error
        isSnackbarPresented = true
    }

    /// Pauses the current recording session and all associated capture devices.
    ///
    /// This function safely pauses an active recording session by stopping the movie
    /// output processor and pausing both audio and video capture devices. It performs
    /// the pause operation asynchronously and handles any errors that occur during
    /// the process by displaying them to the user through the error handling system.
    ///
    /// ## Error Handling
    ///
    /// Any errors that occur during the pause operation are automatically caught
    /// and displayed to the user through the snackbar interface via `didReceiveError(_:)`,
    /// ensuring that users are informed of any issues that prevent proper session pausing.
    @MainActor
    func pauseSession() {
        Task {
            do {
                try await movieOutputProcessor.pause()

                await audioDevice.pause()
                await videoDevice.pause()

                state = .paused
            } catch {
                didReceiveError(error.localizedDescription)
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

    // MARK: - Private methods

    @MainActor
    private func endRecording() async throws {
        state = .finished

        let clip = try await movieOutputProcessor.endProcessing()

        medias.insert(.clip(clip), at: 0)

        await videoDevice.pause()
        await audioDevice.pause()

        validate()
    }

    @DeviceActor
    private func ensureTorchCompatibility() {
        if videoDevice.position == .front, videoDevice.flashMode == .on {
            switchTorch()
        }
    }

    private func initialize() {
        Task(priority: .userInitiated) { @DeviceActor in
            if audioDevice.authorizationStatus == .notDetermined, videoDevice.authorizationStatus == .notDetermined {
                await requestDeviceAccess()
            }

            guard audioDevice.authorizationStatus == .authorized, videoDevice.authorizationStatus == .authorized else {
                await MainActor.run { isAuthorized = false }
                return
            }

            do {
                try videoDevice.configure(in: captureSession)
                if audioDevice.isAvailable {
                    try audioDevice.configure(in: captureSession)
                }

                audioDevice.add(movieOutputProcessor)
                videoDevice.add(movieOutputProcessor)

                let position = configuration.lensFacing == .front ? AVCaptureDevice.Position.front : .back
                let torchMode = configuration.flashMode == .on ? AVCaptureDevice.TorchMode.on : .off
                let videoOrientation = AVCaptureVideoOrientation(from: deviceOrientation)
                let zoomFactors = videoDevice.displayVideoZoomFactors

                isTorchAvailable = videoDevice.isTorchAvailable

                videoDevice.configuration.isHighResolutionEnabled = configuration.isHighResolutionPhotoEnabled
                videoDevice.configuration.imageFormat = configuration.imageFormat.value

                videoDevice.flashMode = configuration.flashMode.value

                try videoDevice.setPosition(position)
                try videoDevice.setTorchMode(torchMode)

                videoDevice.setVideoOrientation(videoOrientation)
                updatePreviewOrientation()

                captureSession.startRunning()

                Task.delayed(milliseconds: 1_200) { @MainActor in
                    allowsHitTesting = true
                }

                await MainActor.run { self.zoomFactors = zoomFactors }
            } catch {
                await MainActor.run { allowsHitTesting = true }
                await didReceiveError(error.localizedDescription)
            }
        }
    }

    private func orientationDidUpdate(to orientation: UIDeviceOrientation) {
        switch orientation {
        case .landscapeLeft,
            .landscapeRight:

            aspectRatio = 16 / 9
            deviceOrientation = orientation

        case .portrait, .portraitUpsideDown:
            aspectRatio = 9 / 16
            deviceOrientation = orientation

        default:
            break
        }

        updatePreviewOrientation()
    }

    @MainActor
    private func requestDeviceAccess() async {
        await audioDevice.requestAccess()
        await videoDevice.requestAccess()
    }

    private func subscribeToSecondsRecorded() {
        movieOutputProcessor.$recordingDuration
            .filter(\.isValid)
            .receive(on: RunLoop.main)
            .map { $0.seconds.toHMS() }
            .assign(to: &$secondsRecorded)
    }

    private func validate() {
        Task.delayed(milliseconds: 500) { @MainActor in
            if medias.count == configuration.mode.maxMediaCount {
                let medias = medias.map(TruvideoSdkCameraMedia.from)
                let result = TruvideoSdkCameraResult(media: medias)

                onCompleted(result)
                validationState = .valid
            }
        }
    }

    private func updatePreviewOrientation() {
        if [.landscapeLeft, .landscapeRight, .portrait].contains(deviceOrientation) {
            Task { @MainActor in
                let videoOrientation = AVCaptureVideoOrientation(from: deviceOrientation)

                previewLayer.connection?.videoOrientation = videoOrientation
                await videoDevice.setVideoOrientation(videoOrientation)
            }
        }
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
            case .failure(let error):
                mediasTaken -= 1
                didReceiveError(error.localizedDescription)

            case .success(let clip):
                medias.insert(.clip(clip), at: 0)
                didReceiveError(Localizations.maxClipDurationReached)
            }
        }
    }
}
