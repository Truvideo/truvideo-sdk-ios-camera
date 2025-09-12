//
// Copyright © 2025 TruVideo. All rights reserved.
//

// swiftlint:disable type_body_length

import AVFoundation
import Combine
import Foundation
import UIKit
internal import Utilities

final class CameraViewModel: ObservableObject, OrientationMonitorSubscriber {
    // MARK: - Private Properties

    private let audioDevice = AudioDevice()
    private var cancellables = Set<AnyCancellable>()
    private let captureSession = AVCaptureSession()
    private let configuration: TruvideoSdkCameraConfiguration
    private let orientationMonitor: OrientationMonitor
    private let movieOutputProcessor = MovieOutputProcessor()
    private let onCompleted: (TruvideoSdkCameraResult) -> Void
    private var sessionWasRunning = false
    private let videoDevice = VideoDevice()

    // MARK: - Properties

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

    // MARK: - Published Properties

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

    /// The collection of media items displayed in the gallery.
    ///
    /// This published property contains all media items (both video clips and photos)
    /// that are currently displayed in the gallery.
    @Published var medias: [Media] = []

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

    // MARK: - Private Computed Properties

    private var maxNumberOfClips: Int {
        let mode = configuration.mode

        guard mode.maxPictureCount == 0, mode.maxVideoCount == 0, mode.maxMediaCount > 0 else {
            return mode.maxVideoCount
        }

        return mode.maxMediaCount
    }

    private var maxNumberOfPhotos: Int {
        let mode = configuration.mode

        guard mode.maxPictureCount == 0, mode.maxVideoCount == 0, mode.maxMediaCount > 0 else {
            return mode.maxPictureCount
        }

        return mode.maxMediaCount
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
        let maxPictureCount = configuration.mode.maxPictureCount
        let maxVideoCount = configuration.mode.maxVideoCount

        guard configuration.mode.maxMediaCount > 0, maxPictureCount == 0, maxVideoCount == 0 else {
            return ""
        }

        return "\(medias.count)/\(configuration.mode.maxMediaCount)"
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

        // MARK: - Private Properties

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
        let photos = medias.filter(\.isPhoto)

        guard photos.count < maxNumberOfPhotos else {
            localizedError = Localizations.maxNumberOfPicturesReached
            isSnackbarPresented = true
            return
        }

        Task { @MainActor in
            do {
                if let photo = try await videoDevice.capturePhoto() {
                    medias.insert(.photo(photo), at: 0)
                    validate()
                }
            } catch {
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
            do {
                let position = await videoDevice.position == .back ? AVCaptureDevice.Position.front : .back

                try await videoDevice.setPosition(position)

                isTorchAvailable = await videoDevice.isTorchAvailable
                zoomFactors = await videoDevice.displayVideoZoomFactors.sorted()
                zoomFactor = 1
            } catch {
                didReceiveError(error.localizedDescription)
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
            do {
                switch movieOutputProcessor.state {
                case .paused:
                    await ensureTorchCompatibility()

                    try await audioDevice.startCapturing()
                    try await videoDevice.startCapturing()

                    await movieOutputProcessor.startProcessing()

                    state = .running

                case .writing:
                    await audioDevice.pause()
                    await videoDevice.pause()

                    try await movieOutputProcessor.pause()

                    state = .paused

                default:
                    break
                }
            } catch {
                didReceiveError(error.localizedDescription)
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
                    let clips = medias.filter(\.isClip)

                    guard clips.count < maxNumberOfClips else {
                        localizedError = Localizations.maxNumberOfClipsReached
                        isSnackbarPresented = true
                        return
                    }

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
                didReceiveError(error.localizedDescription)
            }
        }
    }

    // MARK: - Notification methods

    @MainActor
    @objc
    func didReceiveDidEnterBackgroundNotification(_ notification: Notification) {
        sessionWasRunning = state == .running

        if state == .running {
            pauseSession()
        }
    }

    @MainActor
    @objc
    func didReceiveMediaServicesWereResetNotification(_ notification: Notification) {
        receivedMediaServicesWereResetNotification()
    }

    @MainActor
    @objc
    func didReceiveSessionInterruptionEnded(_ notification: Notification) {
        if sessionWasRunning {
            resumeSession()
        }
    }

    @MainActor
    @objc
    func didReceiveRuntimeErrorNotification(_ notification: Notification) {
        if let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError {
            receivedRuntimeError(error)
        }
    }

    @MainActor
    @objc
    func didReceiveSessionWasInterruptedNotification(_ notification: Notification) {
        sessionWasRunning = state == .running
        if state == .running {
            pauseSession()
        }
    }

    @objc
    func didReceiveWillEnterForegroundNotification(_ notification: Notification) {
        if sessionWasRunning {
            Task {
                captureSession.startRunning()
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

    private func configureObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveDidEnterBackgroundNotification(_:)),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveWillEnterForegroundNotification(_:)),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    private func configureSessionObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveMediaServicesWereResetNotification(_:)),
            name: AVAudioSession.mediaServicesWereResetNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveSessionInterruptionEnded(_:)),
            name: AVCaptureSession.interruptionEndedNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveRuntimeErrorNotification(_:)),
            name: AVCaptureSession.runtimeErrorNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveSessionWasInterruptedNotification(_:)),
            name: AVCaptureSession.wasInterruptedNotification,
            object: nil
        )
    }

    @MainActor
    private func didReceiveError(_ localizedError: String) {
        self.localizedError = localizedError
        isSnackbarPresented = true
    }

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
                await MainActor.run {
                    isAuthorized = false
                }

                return
            }

            do {
                try videoDevice.configure(in: captureSession)
                try audioDevice.configure(in: captureSession)

                audioDevice.add(movieOutputProcessor)
                videoDevice.add(movieOutputProcessor)

                let torchMode = configuration.flashMode == .on ? AVCaptureDevice.TorchMode.on : .off
                let videoOrientation = AVCaptureVideoOrientation(from: deviceOrientation)
                let zoomFactors = videoDevice.displayVideoZoomFactors

                isTorchAvailable = videoDevice.isTorchAvailable

                try videoDevice.setTorchMode(torchMode)

                videoDevice.configuration.isHighResolutionEnabled = configuration.isHighResolutionPhotoEnabled
                videoDevice.configuration.imageFormat = configuration.imageFormat.value
                videoDevice.flashMode = configuration.flashMode.value

                if configuration.lensFacing == .front {
                    try videoDevice.setPosition(.front)
                }

                videoDevice.setVideoOrientation(videoOrientation)
                updatePreviewOrientation()

                captureSession.startRunning()

                await MainActor.run {
                    self.zoomFactors = zoomFactors
                }
            } catch {
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

    private func pauseSession() {
        Task { @DeviceActor in
            audioDevice.pause()
            videoDevice.pause()

            do {
                try await movieOutputProcessor.pause()

                await MainActor.run {
                    state = .paused
                }
            } catch {
                await didReceiveError(error.localizedDescription)
            }
        }
    }

    private func receivedMediaServicesWereResetNotification() {
        if !captureSession.isRunning {
            captureSession.startRunning()
        }

        if state == .running {
            Task { @DeviceActor in
                videoDevice.endCapturing(in: captureSession)
                audioDevice.endCapturing(in: captureSession)

                do {
                    try audioDevice.startCapturing()
                    try videoDevice.startCapturing()
                } catch {
                    await didReceiveError(error.localizedDescription)
                }
            }
        }
    }

    private func receivedRuntimeError(_ error: AVError) {
        if [.sessionConfigurationChanged, .sessionNotRunning].contains(error.code), state == .running {
            if !captureSession.isRunning {
                captureSession.startRunning()
            }
        }
    }

    private func receivedSessionWasInterrupted(_ reason: AVCaptureSession.InterruptionReason) async {
        if [
            .audioDeviceInUseByAnotherClient,
            .videoDeviceInUseByAnotherClient,
            .videoDeviceNotAvailableDueToSystemPressure,
            .videoDeviceNotAvailableWithMultipleForegroundApps,
        ].contains(reason) {
            pauseSession()
        }
    }

    @MainActor
    private func requestDeviceAccess() async {
        await audioDevice.requestAccess()
        await videoDevice.requestAccess()
    }

    private func resumeSession() {
        Task { @DeviceActor in
            if state.canTransition(to: .running) {
                do {
                    try audioDevice.startCapturing()
                    try videoDevice.startCapturing()

                    captureSession.startRunning()

                    await MainActor.run {
                        state = .running
                    }
                } catch {
                    await didReceiveError(error.localizedDescription)
                }
            }
        }
    }

    private func subscribeToSecondsRecorded() {
        let maxVideoDuration = configuration.mode.maxVideoDuration

        movieOutputProcessor.$recordingDuration
            .filter(\.isValid)
            .receive(on: RunLoop.main)
            .prefix { [weak self] recordingDuration in
                if let self, recordingDuration.seconds > maxVideoDuration {
                    Task {
                        await self.didReceiveError(Localizations.maxClipDurationReached)
                        try await self.endRecording()
                    }

                    return false
                }

                return true
            }
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
// swiftlint:enable type_body_length
