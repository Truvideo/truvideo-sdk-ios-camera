//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation
import Combine
import Foundation
import UIKit

final class CameraViewModel: ObservableObject, OrientationMonitorSubscriber {
    // MARK: - Private Properties

    private let audioDevice = AudioDevice()
    private var cancellables = Set<AnyCancellable>()
    private let captureSession = AVCaptureSession()
    private let orientationMonitor: OrientationMonitor
    private let movieOutputProcessor = MovieOutputProcessor()
    private let photoDevice = PhotoDevice()
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

    /// The video preview layer that displays the camera feed in the UI.
    let previewLayer = AVCaptureVideoPreviewLayer()

    /// The available zoom factor options that users can select from.
    ///
    /// This array defines the zoom levels that are available for selection in the camera
    /// interface. Each value represents a magnification factor.
    let zoomFactors = [0.5, 1, 2, 3, 4, 5, 6]

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

    /// Localized error message for display to users. Empty string when no error.
    @Published private(set) var localizedError = ""

    /// The collection of media items displayed in the gallery.
    ///
    /// This published property contains all media items (both video clips and photos)
    /// that are currently displayed in the gallery.
    @Published var medias: [Media] = []

    /// The total duration of recorded video in Hours:Minutes:Seconds format.
    ///
    /// This property displays the cumulative recording time in a human-readable format.
    @Published private(set) var secondsRecorded = 0.toHMS()

    /// The current lifecycle state of the recording process.
    @Published private(set) var state = RecordingState.initialized

    /// The current validation state of the view or operation.
    ///
    /// This property tracks the validation status using a `ValidationState` enum that
    /// represents different validation conditions. It defaults to `.initial` representing
    /// the starting state before any validation has been performed.
    @Published private(set) var validationState = ValidationState.initial

    /// The current zoom factor applied to the camera preview.
    ///
    /// This property represents the magnification level of the camera view.
    @Published var zoomFactor: Double = 1 {
        didSet {
            updateZoomFactor()
        }
    }

    @Published private(set) var availableFormats: [VideoDevice.Format] = []
    @Published var selectedFormat: VideoDevice.Format?

    // MARK: - Computed Properties

    /// The total number of video clips in the media collection.
    var numberOfClips: Int {
        medias.filter(\.isClip).count
    }

    /// The total number of photos in the media collection.
    var numberOfPhotos: Int {
        medias.filter(\.isPhoto).count
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

    init(orientationMonitor: OrientationMonitor = DeviceOrientationMonitor()) {
        self.orientationMonitor = orientationMonitor

        self.previewLayer.session = captureSession
        self.previewLayer.videoGravity = .resizeAspectFill

        self.orientationMonitor.add(self)
        self.orientationMonitor.startMonitoring()

        initialize()
        configureObservers()
        configureSessionObservers()
        observeStateUpdates()

        if captureSession.canSetSessionPreset(.hd4K3840x2160) {
            captureSession.sessionPreset = .hd4K3840x2160
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Instance methods

    func didReceive(_ deviceOrientation: DeviceOrientation) {
        if deviceOrientation.orientation != .portraitUpsideDown {
            orientationDidUpdate(to: deviceOrientation.orientation)
        }
    }

    /// Captures a photo using the photo device and adds it to the photos collection.
    ///
    /// This function initiates an asynchronous photo capture operation on the main actor.
    /// If the capture is successful, the captured photo is appended to the photos array.
    /// If an error occurs during capture, the error's localized description is stored
    /// in the localizedError property for user feedback.
    func capturePhoto() {
        Task { @MainActor in
            do {
                let isRecording = await videoDevice.state == .running
                let photo = try await isRecording ? videoDevice.capturePhoto() : photoDevice.capturePhoto()

                if let photo {
                    medias.append(.photo(photo))
                }
            } catch {
                localizedError = error.localizedDescription
            }
        }
    }

    /// Validates clips state before dismissal and updates validation state accordingly.
    ///
    /// Sets `validationState` to `.invalid` if clips or photos are not empty (preventing dismissal),
    /// or `.valid` if clips are empty (allowing dismissal).
    func onDismiss() {
        guard medias.isEmpty else {
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

    func setFormat(_ format: VideoDevice.Format) {
        Task { @MainActor in
            let currentFormat = selectedFormat

            do {
                selectedFormat = format
                try await videoDevice.setFormat(format)
            } catch {
                selectedFormat = currentFormat
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
                try await videoDevice.setPosition(videoDevice.position == .back ? .front : .back)
            } catch {
                localizedError = error.localizedDescription
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
            do {
                isTorchEnabled.toggle()

                try await videoDevice.setTorchMode(isTorchEnabled ? .off : .on)
            } catch {
                isTorchEnabled.toggle()
                localizedError = error.localizedDescription
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
                switch await videoDevice.state {
                case .running:
                    let videoClip = try await movieOutputProcessor.endProcessing()

                    medias.append(.clip(videoClip))
                    await endRecording()

                case .initialized, .finished, .failed:
                    await movieOutputProcessor.startProcessing()
                    try await record()

                default:
                    break
                }
            } catch {
                localizedError = error.localizedDescription
            }
        }
    }

    // MARK: - Notification methods

    @objc
    func didReceiveBecomeActiveNotification(_ notification: Notification) {
        if sessionWasRunning {
            resumeSession()
        }
    }

    @objc
    func didReceiveMediaServicesWereResetNotification(_ notification: Notification) {
        receivedMediaServicesWereResetNotification()
    }

    @objc
    func didReceiveSessionInterruptionEnded(_ notification: Notification) {
        if sessionWasRunning {
            resumeSession()
        }
    }

    @objc
    func didReceiveRuntimeErrorNotification(_ notification: Notification) {
        if let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError {
            receivedRuntimeError(error)
        }
    }

    @objc
    func didReceiveSessionWasInterruptedNotification(_ notification: Notification) {
        if sessionWasRunning {
            resumeSession()
        }
    }

    @objc
    func didReceiveWillResignActiveNotification(_ notification: Notification) {
        sessionWasRunning = state == .running
        pauseSession()
    }

    // MARK: - Private methods

    private func configureObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveBecomeActiveNotification(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveWillResignActiveNotification(_:)),
            name: UIApplication.willResignActiveNotification,
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

    @DeviceActor
    private func endRecording() async {
        if state.canTransition(to: .finished) {
            videoDevice.endCapturing(in: captureSession)
            audioDevice.endCapturing(in: captureSession)
            captureSession.stopRunning()

            await MainActor.run {
                state = .finished
            }
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
                try audioDevice.configure(in: captureSession)
                try videoDevice.configure(in: captureSession)
                try photoDevice.configure(in: captureSession)

                audioDevice.add(movieOutputProcessor)
                videoDevice.add(movieOutputProcessor)

                let isTorchEnabled = videoDevice.torchMode == .on

                isTorchAvailable = videoDevice.isTorchAvailable

                await MainActor.run {
                    self.isTorchEnabled = isTorchEnabled
                }

                updatePreviewOrientation()
                captureSession.startRunning()
            } catch {
                localizedError = error.localizedDescription
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

    private func observeStateUpdates() {
        movieOutputProcessor.$totalDuration
            .filter(\.isValid)
            .map { $0.seconds.toHMS() }
            .receive(on: RunLoop.main)
            .assign(to: \.secondsRecorded, on: self)
            .store(in: &cancellables)
    }

    private func pauseSession() {
        if state.canTransition(to: .paused) {
            Task { @DeviceActor in
                audioDevice.pause()
                videoDevice.pause()

                captureSession.stopRunning()

                do {
                    try await movieOutputProcessor.pause()
                    state = .paused
                } catch {
                    localizedError = ""
                    state = .failed
                }
            }
        }
    }

    private func receivedMediaServicesWereResetNotification() {
        if state == .running, !captureSession.isRunning {
            Task { @DeviceActor in

                await endRecording()

                do {
                    try audioDevice.startCapturing()
                    try videoDevice.startCapturing()

                    captureSession.startRunning()
                } catch {
                    state = .failed
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

    @DeviceActor
    private func record() async throws {
        if state.canTransition(to: .running) {
            try audioDevice.startCapturing()
            try videoDevice.startCapturing()

            await MainActor.run {
                state = .running
            }
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
                    state = .running
                } catch {
                    localizedError = ""
                    state = .failed
                }
            }
        }
    }

    private func updatePreviewOrientation() {
        if [.landscapeLeft, .landscapeRight, .portrait].contains(deviceOrientation) {
            previewLayer.connection?.videoOrientation = deviceOrientation.captureVideoOrientation
        }
    }

    private func updateZoomFactor() {
        Task { @DeviceActor in
            do {
                try videoDevice.setZoomFactor(zoomFactor)
            } catch {

            }
        }
    }
}

extension UIDeviceOrientation {
    /// Converts `UIDeviceOrientation` to the corresponding `AVCaptureVideoOrientation`.
    ///
    /// Falls back to `.portrait` when the orientation is not supported.
    fileprivate var captureVideoOrientation: AVCaptureVideoOrientation {
        switch self {
        case .landscapeLeft:
            .landscapeRight

        case .landscapeRight:
            .landscapeLeft

        default:
            .portrait
        }
    }
}
