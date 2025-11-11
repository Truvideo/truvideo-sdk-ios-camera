//
//  TVCameraManager.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 3/26/25.
//

import AVKit
import Combine
import Foundation

// - MARK: Camera Manager Implementation
class TVCameraManager: NSObject, TVCameraManagerProtocol {
    // - MARK: Class name

    let className = String(describing: TVCameraManager.self)

    // - MARK: Camera session

    private var captureSession = AVCaptureSession()
    private let processor = MovieOutputProcessorDeprecation()
    let previewLayer = AVCaptureVideoPreviewLayer()

    private let isRecordingSubject = CurrentValueSubject<Bool, Never>(false)
    var isRecordingPublisher: AnyPublisher<Bool, Never> {
        isRecordingSubject
            .eraseToAnyPublisher()
    }

    private let isVideoPausedSubject = CurrentValueSubject<Bool, Never>(false)
    var isVideoPausedPublisher: AnyPublisher<Bool, Never> {
        isVideoPausedSubject
            .eraseToAnyPublisher()
    }

    private let photosSubject = PassthroughSubject<TruVideoPhoto, Never>()
    var photosPublisher: AnyPublisher<TruVideoPhoto, Never> {
        photosSubject
            .eraseToAnyPublisher()
    }

    let videosSubject = PassthroughSubject<TruVideoClip, Never>()
    var videosPublisher: AnyPublisher<TruVideoClip, Never> {
        videosSubject
            .eraseToAnyPublisher()
    }

    private let torchSubject = PassthroughSubject<TorchStatus, Never>()
    var torchPublisher: AnyPublisher<TorchStatus, Never> {
        torchSubject
            .eraseToAnyPublisher()
    }

    private var durationTimer: Timer?
    private var secondsPassed: Double = .zero
    private var previousSecondsPassed: Double = .zero
    private let recordedDurationSubject = CurrentValueSubject<Double, Never>(.zero)
    var recordedDurationPublisher: AnyPublisher<Double, Never> {
        recordedDurationSubject
            .eraseToAnyPublisher()
    }

    private let flipCameraSubject = PassthroughSubject<Void, Never>()
    var flipCameraPublisher: AnyPublisher<Void, Never> {
        flipCameraSubject
            .eraseToAnyPublisher()
    }

    private let showLoaderSubject = CurrentValueSubject<Bool, Never>(false)
    var showLoaderPublisher: AnyPublisher<Bool, Never> {
        showLoaderSubject
            .eraseToAnyPublisher()
    }

    private let permissionStatusSubject = CurrentValueSubject<Bool, Never>(false)
    var permissionStatusPublisher: AnyPublisher<Bool, Never> {
        permissionStatusSubject
            .eraseToAnyPublisher()
    }

    var isFlashAvailable: Bool {
        guard let device = AVCaptureDevice.default(for: .video) else { return false }

        return cameraLensFacing == .back && device.hasFlash
    }

    // - MARK: Private

    private var photoOutput = AVCapturePhotoOutput()

    private var captureAudioDevice: AVCaptureDevice?
    private var captureAudioDataOutput: AVCaptureAudioDataOutput?
    private var captureAudioDeviceInput: AVCaptureDeviceInput?
    private let audioQueue = DispatchQueue(label: "com.truvideo.camera.audioQueue")

    private var captureVideoDevice: AVCaptureDevice?
    private var captureVideoDeviceInput: AVCaptureDeviceInput?
    private var captureVideoDataOutput: AVCaptureVideoDataOutput?
    private let videoQueue = DispatchQueue(label: "com.truvideo.camera.videoQueue")

    private let configurationQueue = DispatchQueue(label: "com.truvideo.camera.configurationQueue", qos: .userInitiated)
    private let writerQueue = DispatchQueue(label: "com.truvideo.camera.writerQueue", qos: .userInitiated)

    private var videoFileURL: URL?

    private var currentOrientation: UIDeviceOrientation = .currentAppOrientation()
    private var cameraLensFacing: TruvideoSdkCameraLensFacing

    private let identifier = UUID()

    private var photosCount = 0
    private var videosCount = 0

    private let outputDirectory: URL
    private let imageFormat: TruvideoSdkCameraImageFormat

    private var currentVideoInput: AVCaptureDeviceInput?
    private var currentAudioInput: AVCaptureDeviceInput?

    let resolutionsManager: TruvideoSdkCameraResolutionManager

    private var selectedResolution: TruvideoSdkCameraResolutionFormat {
        resolutionsManager.getSelectedResolution(for: cameraLensFacing == .back ? .back : .front)
            ?? .defaultResolutionFormat
    }

    private var isFlashOn: Bool

    private let isHighResolutionPhotoEnabled: Bool

    /// Shared Core Image rendering context.
    var context: CIContext? = .createDefault()

    let preset: TruvideoSdkCameraConfiguration

    private(set) var appIsActive = true

    private var pausedRecordings = [TruVideoClip]()

    private var isProcessingNewVideo = false
    private var isProcessingPhoto = false

    init(preset: TruvideoSdkCameraConfiguration) {
        dprint(className, "was [ALLOCATED]")
        self.preset = preset
        self.resolutionsManager = .init(
            backResolutions: [],
            frontResolutions: [],
            backResolution: .init(width: 1_280, height: 720),
            frontResolution: .init(width: 1_280, height: 720)
        )
        self.cameraLensFacing = preset.lensFacing
        self.isFlashOn = preset.flashMode == .on
        self.isHighResolutionPhotoEnabled = preset.isHighResolutionPhotoEnabled
        self.outputDirectory = URL(string: preset.outputPath) ?? URL(fileURLWithPath: NSTemporaryDirectory())
        self.imageFormat = preset.imageFormat

        previewLayer.videoGravity = .resizeAspect

        super.init()

        Task(priority: .userInitiated) {
            let permissionsGranted = await checkAndSendPermissions()
            guard permissionsGranted else { return }

            setupSession()

            configureSessionObservers()

            if let initialResolution = resolutionsManager.getSelectedResolution(
                for: cameraLensFacing == .front ? .front : .back
            ) {
                dprint(className, "initial resolution was [CONFIGURED]")
                setResolution(to: initialResolution)
            } else {
                dprint(className, "initial resolution is [NIL]")
            }

            startSession()
        }
    }

    private func checkAndSendPermissions() async -> Bool {
        let cameraGranted = await wasCameraPermissionGranted()
        let micGranted = await wasMicrophonePermissionGranted()
        let permissionsGranted = cameraGranted && micGranted

        self.permissionStatusSubject.send(permissionsGranted)
        return permissionsGranted
    }

    private func wasCameraPermissionGranted() async -> Bool {
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            return true
        }

        do {
            try await requestAuhorization(for: .video)

            return true
        } catch {
            return false
        }
    }

    private func wasMicrophonePermissionGranted() async -> Bool {
        if AVCaptureDevice.authorizationStatus(for: .audio) == .authorized {
            return true
        }

        do {
            try await requestAuhorization(for: .audio)

            return true
        } catch {
            return false
        }
    }

    private func requestAuhorization(for mediaType: AVMediaType) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) -> Void in
            AVCaptureDevice.requestAccess(for: mediaType) { authorized in
                guard authorized else {
                    continuation.resume(throwing: TruVideoError(kind: .accessDenied))
                    return
                }

                continuation.resume()
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        setIdleTimer(enabled: true)
        dprint(className, "initial was [DEALLOCATED]")
    }

    private func startSession() {
        configurationQueue.async { [weak self] in
            guard let self else { return }
            if !captureSession.isRunning {
                captureSession.startRunning()
                dprint(className, "captureSession was [STARTED]")
            }
        }
    }

    private func stopSession() {
        configurationQueue.async { [weak self] in
            guard let self else { return }
            if captureSession.isRunning {
                captureSession.stopRunning()
                dprint(className, "captureSession was [STOPPED]")
            }
        }
    }

    private func configureSessionObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveSessionRuntimeErrorNotification(_:)),
            name: .AVCaptureSessionRuntimeError,
            object: captureSession
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveSessionWasInterruptedNotification(_:)),
            name: .AVCaptureSessionWasInterrupted,
            object: captureSession
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveSessionInterruptionEnded(_:)),
            name: .AVCaptureSessionInterruptionEnded,
            object: captureSession
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMediaServicesWereReset(_:)),
            name: AVAudioSession.mediaServicesWereResetNotification,
            object: nil
        )
    }

    @objc private func didReceiveSessionRuntimeErrorNotification(_ notification: Notification) {
        dprint(className, "session runtine error [RECEIVED]")
        guard (notification.object as? AVCaptureSession) != nil,
            (notification.userInfo?[AVCaptureSessionErrorKey] as? NSError) != nil
        else {
            return
        }
        dprint(className, "session runtine error [PROCESSED]")
        if isRecordingSubject.value {
            // end recording
            isVideoPausedSubject.send(false)
            stopRecording { [weak self] in
                guard let self else { return }
                resumeAfterSessionRuntineError()
            }
        } else {
            resumeAfterSessionRuntineError()
        }
    }

    private func resumeAfterSessionRuntineError() {
        dprint(className, "session after runtine error was [RESUMED]")
        guard appIsActive else { return }

        restartSession()
    }

    @objc private func didReceiveSessionWasInterruptedNotification(_ notification: Notification) {
        dprint(className, "session interruption [STARTED]")

        if isRecordingSubject.value {
            isVideoPausedSubject.send(false)
            stopRecording()
        }
        stopSession()

        setIdleTimer(enabled: true)
    }

    @objc private func didReceiveSessionInterruptionEnded(_ notification: Notification) {
        dprint(className, "session interruption [ENDED]")

        startSession()
    }

    @objc private func handleAppWillResignActive() {
        dprint(className, "app going to [BACKGROUND]")

        handleAppGoingToBackground()
    }

    @objc private func handleAppDidBecomeActive() {
        dprint(className, "app becoming [ACTIVE]")

        handleAppBecomingActive()
    }

    @objc private func handleMediaServicesWereReset(_ notification: Notification) {
        dprint(className, "app media services [RESET]")

        guard isRecordingSubject.value else { return }

        restartSession()

        /// If the current orientation is portrait, we delay the orientation update slightly to ensure that
        /// the capture session and its connections have been fully restored after a reset.
        /// This ensures that the video and preview connections are valid before we attempt to set their orientation.
        /// Without this delay, the orientation update may be ignored or silently fail because the session might not yet be fully reconfigured.
        if currentOrientation == .portrait {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.updateVideoConnectionOrientation(self.currentOrientation)
                self.updateVideoPreviewOrientation(self.currentOrientation)
            }
        }
    }

    private func setupSession() {
        configurationQueue.async { [weak self] in
            guard let self else { return }
            dprint(className, "captureSession was [CONFIGURED]")
            guard
                let videoDevice = AVCaptureDevice.primaryVideoDevice(for: cameraLensFacing),
                let videoInput = try? AVCaptureDeviceInput(device: videoDevice)
            else {
                return
            }

            previewLayer.session = captureSession

            captureSession.beginConfiguration()

            captureSession.automaticallyConfiguresApplicationAudioSession = true
            captureSession.sessionPreset = .inputPriority

            // Camera Input
            if captureSession.canAddInput(videoInput) {
                currentVideoInput = videoInput
                captureSession.addInput(videoInput)
            }

            // Microphone Input
            if let audioDevice = AVCaptureDevice.default(for: .audio) {

                try? configureCaptureAudioDeviceInput(in: captureSession)
                try? configureCaptureAudioDataOutput(in: captureSession)

                captureAudioDevice = audioDevice
            }

            // Photo Output
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }

            // Movie Output
            if let captureVideoDevice = AVCaptureDevice.availableVideoDevices(for: cameraLensFacing.avCaptureDevice)
                .first
            {
                try? captureVideoDevice.configure()

                if let captureVideoDeviceInput = try? captureSession.addDeviceInput(for: captureVideoDevice) {
                    self.captureVideoDeviceInput = captureVideoDeviceInput
                    try? configureCaptureVideoDeviceOutput(in: captureSession)
                }

                self.captureVideoDevice = captureVideoDevice
            }

            captureSession.commitConfiguration()
        }
    }

    private func cleanSession() {
        configurationQueue.async { [weak self] in
            guard let self else { return }
            dprint(className, "captureSession was [CLEANED]")
            captureSession.beginConfiguration()

            for output in captureSession.outputs {
                captureSession.removeOutput(output)
            }

            for input in captureSession.inputs {
                captureSession.removeInput(input)
            }

            captureSession.commitConfiguration()

            photoOutput = AVCapturePhotoOutput()

            captureAudioDevice = nil
            captureAudioDeviceInput = nil
            captureAudioDataOutput = nil

            captureVideoDevice = nil
            captureVideoDeviceInput = nil
            captureVideoDataOutput = nil

            captureSession = AVCaptureSession()
            previewLayer.session = nil
        }
    }

    func getCurrentPermissionStatus() -> Bool {
        permissionStatusSubject.value
    }

    func toggleRecord() {
        Task { @MainActor in
            if isProcessingNewVideo {
                dprint(className, "Try to record a new video try processing the previous one")
                return
            } else if isRecordingSubject.value || isVideoPausedSubject.value {
                dprint(className, "toggleRecord - stop recording")
                isProcessingNewVideo = true
                durationTimer?.invalidate()
                durationTimer = nil

                if isVideoPausedSubject.value {
                    isVideoPausedSubject.send(false)
                    processLastTruvideoClip()
                } else {
                    stopRecording()
                }
            } else {
                dprint(className, "toggleRecord - start recording")
                startRecording()
            }
        }
    }

    func takePhoto() {
        guard !isProcessingPhoto else {
            return
        }
        let photoSettings = AVCapturePhotoSettings()

        photoSettings.isHighResolutionPhotoEnabled = isHighResolutionPhotoEnabled
        photoOutput.isHighResolutionCaptureEnabled = isHighResolutionPhotoEnabled

        let supportedFlashModes = photoOutput.supportedFlashModes

        if supportedFlashModes.contains(.on), isFlashOn, cameraLensFacing == .back {
            photoSettings.flashMode = .on
        }

        // Set custom resolution
        let previewPixelType = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
        photoSettings.previewPhotoFormat = [
            String(kCVPixelBufferPixelFormatTypeKey): previewPixelType,
            String(kCVPixelBufferWidthKey): mediaWidth,
            String(kCVPixelBufferHeightKey): mediaHeight,
        ]

        isProcessingPhoto = true
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }

    private var mediaWidth: Int32 {
        currentOrientation.isLandscape ? selectedResolution.width : selectedResolution.height
    }

    private var mediaHeight: Int32 {
        currentOrientation.isLandscape ? selectedResolution.height : selectedResolution.width
    }

    // - MARK: Private methods
    private func startRecording() {
        setIdleTimer(enabled: false)

        enableTorchIfNeeded()

        Task {
            await processor.startProcessing()

            await MainActor.run {
                isVideoPausedSubject.send(false)
                isRecordingSubject.send(true)
                secondsPassed = previousSecondsPassed

                if durationTimer == nil {
                    durationTimer = Timer.scheduledTimer(
                        withTimeInterval: 1.0,
                        repeats: true,
                        block: { [weak self] _ in
                            guard let self, isRecordingSubject.value, !isVideoPausedSubject.value else { return }

                            secondsPassed += 1.0
                            recordedDurationSubject.send(secondsPassed)
                        }
                    )
                }
            }
        }
    }

    private func stopRecording(_ completion: @escaping () -> Void = {}) {
        Task {
            dprint(className, "stop recording was [CALLED]")

            disableTorchIfNeeded()

            setIdleTimer(enabled: true)

            do {
                let url = try await processor.endProcessing()
                let clip = TruVideoClip(url: url, lastFrameImage: generateThumbnail(from: url))

                pausedRecordings.append(clip)
                processLastTruvideoClip()
            } catch {
                dprint(className, "stop recording failed to create clip")
            }

            completion()
        }

        /*if movieOutput.isRecording {
            movieOutput.stopRecording()
        } else {
            processLastTruvideoClip(completion)
        }

        completion()*/
    }

    private func getCurrentRotation() -> TruvideoSdkCameraOrientation {
        switch currentOrientation {
        case .portrait:
            return .portrait

        case .landscapeLeft:
            return .landscapeLeft

        case .landscapeRight:
            return .landscapeRight

        default:
            return .portrait
        }
    }

    func pauseRecord() {
        if isProcessingNewVideo {
            dprint(className, "Try to pause record a new video try processing the previous one")
            return
        } else if isVideoPausedSubject.value {
            startRecording()
        } else {
            isVideoPausedSubject.send(true)
            stopRecording()
        }
    }

    func flipCamera() {
        if cameraLensFacing == .back {
            dprint(className, "flip camera to [FRONT]")
            cameraLensFacing = .front
        } else {
            dprint(className, "flip camera to [BACK]")
            cameraLensFacing = .back
        }

        if isRecordingSubject.value {
            dprint(className, "recording will [RESUME]")
            isVideoPausedSubject.send(false)
            Task {
                stopRecording { [weak self] in
                    guard let self else { return }
                    stopSession()
                    cleanSession()
                    setupSession()
                    startSession()

                    resumeRecording()
                    flipCameraSubject.send(())
                }
            }
        } else {
            stopSession()
            cleanSession()
            setupSession()

            setResolution(to: selectedResolution)

            startSession()

            flipCameraSubject.send(())
        }
    }

    private func resumeRecording() {
        configurationQueue.async { [weak self] in
            guard let self else { return }
            dprint(className, "recording was [RESUMED]")
            startRecording()
            flipCameraSubject.send(())
        }
    }

    func changeResolution(to resolution: TruvideoSdkCameraResolutionFormat) {
        dprint(className, "resolution will be [CHANGED]]")

        stopSession()

        configurationQueue.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.configurationQueue.async { [weak self] in
                    self?.captureSession.beginConfiguration()
                    if let connection = self?.captureVideoDataOutput?.connection(with: .video) {
                        connection.preferredVideoStabilizationMode = .off
                    }
                    self?.captureSession.commitConfiguration()

                    self?.configurationQueue.async {
                        self?.setResolution(to: resolution)

                        DispatchQueue.main.async {
                            self?.configurationQueue.async { [weak self] in
                                self?.captureSession.beginConfiguration()

                                guard let connection = self?.captureVideoDataOutput?.connection(with: .video),
                                    connection.isVideoStabilizationSupported
                                else {
                                    self?.captureSession.commitConfiguration()
                                    self?.startSession()
                                    return
                                }

                                connection.preferredVideoStabilizationMode = .auto
                                self?.captureSession.commitConfiguration()
                                self?.startSession()
                            }
                        }
                    }
                }
            }
        }

        dprint(className, "resolution was [CHANGED]]")
    }

    private func setResolution(to resolution: TruvideoSdkCameraResolutionFormat) {
        dprint(className, "will be [SET]")
        dprint(self.className, "will be [SET - 2]")
        dprint(className, "will be [SET - 3]")

        guard
            (resolution.type == .front && cameraLensFacing == .front)
                || (resolution.type == .back && cameraLensFacing == .back)
        else {
            dprint(className, "change resolution [MISMATCHED]")
            return
        }
        dprint(className, "will be [SET - 4]")
        guard let videoDevice = AVCaptureDevice.primaryVideoDevice(for: cameraLensFacing)
        else {
            return
        }
        dprint(className, "will be [SET - 5]")
        guard let format = resolution.format
        else {
            return
        }
        dprint(className, "will be [SET - 6]")
        resolutionsManager.setSelectedResolution(resolution)

        do {
            try videoDevice.lockForConfiguration()
            if !videoDevice.activeFormat.isVideoStabilizationModeSupported(.auto) {
                dprint("TVCameraManager", "format does not support video stabilization: \(format)")
            }
            videoDevice.activeFormat = format
            videoDevice.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: 24)
            videoDevice.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: 24)
            videoDevice.unlockForConfiguration()
        } catch {
        }
    }

    func toggleFlash() {
        isFlashOn.toggle()

        if isFlashOn {
            torchSubject.send(.on)
            if isRecordingSubject.value {
                enableTorchIfNeeded()
            }
        } else {
            torchSubject.send(.off)
            if isRecordingSubject.value {
                disableTorchIfNeeded()
            }
        }
    }

    private func enableTorchIfNeeded() {
        guard
            isFlashOn,
            cameraLensFacing == .back,
            let captureVideoDevice,
            captureVideoDevice.isTorchAvailable
        else {
            return
        }

        do {
            try captureVideoDevice.lockForConfiguration()

            if captureVideoDevice.isTorchModeSupported(.on) {
                try captureVideoDevice.setTorchModeOn(level: 1.0)
            } else {
                throw TruVideoError(kind: .torchNotSupported)
            }

            captureVideoDevice.unlockForConfiguration()
        } catch {
            torchSubject.send(.notSupported)
        }
    }

    private func disableTorchIfNeeded() {
        guard
            cameraLensFacing == .back,
            let captureVideoDevice,
            captureVideoDevice.isTorchAvailable
        else {
            return
        }

        do {
            try captureVideoDevice.lockForConfiguration()

            captureVideoDevice.torchMode = .off
            captureVideoDevice.unlockForConfiguration()
        } catch {
            torchSubject.send(.notSupported)
        }
    }

    func configureZoomFactor(to zoomFactor: CGFloat) {
        guard let captureVideoDevice, let format = selectedResolution.format else {
            return
        }

        do {
            try captureVideoDevice.lockForConfiguration()
            captureVideoDevice.videoZoomFactor = min(zoomFactor, format.videoMaxZoomFactor)
            captureVideoDevice.unlockForConfiguration()
        } catch {
            Logger.logError(event: .zoom, eventMessage: .configureZoomFailed(error: error))
        }
    }

    func focus(at point: CGPoint) {
        guard let videoDevice = AVCaptureDevice.primaryVideoDevice(for: cameraLensFacing)
        else {
            return
        }

        do {
            try videoDevice.lockForConfiguration()

            if videoDevice.isFocusPointOfInterestSupported && videoDevice.isFocusModeSupported(.autoFocus) {
                videoDevice.focusPointOfInterest = point
                videoDevice.focusMode = .autoFocus
            }

            if videoDevice.isExposurePointOfInterestSupported && videoDevice.isExposureModeSupported(.autoExpose) {
                videoDevice.exposurePointOfInterest = point
                videoDevice.exposureMode = .autoExpose
            }

            videoDevice.unlockForConfiguration()
        } catch {
        }
    }

    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    // MARK: - Handle Background Task
    private func handleAppGoingToBackground() {
        appIsActive = false

        setIdleTimer(enabled: true)

        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "StopCameraSession") { [weak self] in
            guard let self else { return }
            // If time expires before we end the task, iOS will call this block.
            endBackgroundTask()
        }

        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self else { return }
            if isRecordingSubject.value, !isVideoPausedSubject.value {
                isVideoPausedSubject.send(true)
                stopRecording()
            }
            stopSession()
            endBackgroundTask()
        }
    }

    private func handleAppBecomingActive() {
        appIsActive = true
        startSession()
    }

    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }

    private func restartSession() {
        stopSession()
        cleanSession()
        setupSession()
        setResolution(to: selectedResolution)
        startSession()
    }

    private func setIdleTimer(enabled: Bool) {
        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = !enabled
        }
    }
}

// - MARK: Take photos
extension TVCameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        isProcessingPhoto = false
        guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else { return }

        var metadata = photo.metadata
        metadata[TruVideoPhoto.DeviceOrientationKey] = currentOrientation
        TruVideoRecorder.tiffMetadata.forEach { key, value in
            metadata[key] = value
        }

        let imageData = transformImageData(image: image)

        let photoURL = generateNextPhotoOutputURL()
        savePhotoToURL(imageData: imageData, url: photoURL)

        photosSubject.send(
            .init(
                imageData: imageData,
                croppedImageData: imageData,
                metadata: metadata,
                url: photoURL,
                lensFacing: cameraLensFacing,
                orientation: getCurrentRotation(),
                resolution: .init(width: Int32(image.size.width), height: Int32(image.size.height)),
                captureImage: image
            )
        )

        if isFlashOn, isRecordingSubject.value, !isVideoPausedSubject.value {
            enableTorchIfNeeded()
        }
    }

    @discardableResult
    func updateVideoPreviewOrientation(_ previewOrientation: UIDeviceOrientation) -> Bool {
        var outputWasUpdated = true

        if let previewConnection = previewLayer.connection,
            previewConnection.isVideoOrientationSupported
        {
            previewConnection.videoOrientation = getOutputOrientation(from: previewOrientation) ?? .portrait
        } else {
            outputWasUpdated = false
        }

        return outputWasUpdated
    }

    @discardableResult
    func updateVideoConnectionOrientation(_ physicalOrientation: UIDeviceOrientation) -> Bool {
        guard let outputOrientation = getOutputOrientation(from: physicalOrientation) else { return false }
        var outputWasUpdated = true

        currentOrientation = physicalOrientation

        if let photoConnection = photoOutput.connection(with: .video),
            photoConnection.isVideoOrientationSupported
        {
            photoConnection.videoOrientation = outputOrientation
        } else {
            outputWasUpdated = false
        }

        guard !isRecordingSubject.value else {
            return outputWasUpdated
        }

        if let videoConnection = captureVideoDataOutput?.connection(with: .video),
            videoConnection.isVideoOrientationSupported
        {
            videoConnection.videoOrientation = outputOrientation
        } else {
            outputWasUpdated = false
        }

        return outputWasUpdated
    }

    private func getOutputOrientation(from newOrientation: UIDeviceOrientation?) -> AVCaptureVideoOrientation? {
        guard let orientation = newOrientation else { return .portrait }
        switch orientation {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        default:
            return nil
        }
    }
}

// - MARK: Record videos
extension TVCameraManager: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(
        _ output: AVCaptureFileOutput,
        didFinishRecordingTo outputFileURL: URL,
        from connections: [AVCaptureConnection],
        error: (any Error)?
    ) {
        dprint(className, "didFinishRecordingTo was [CALLED]")
        if let error {
            dprint(className, "didFinishRecordingTo [ERROR]: \(error)")
        }

        let newTruvideoClip = TruVideoClip(url: outputFileURL, lastFrameImage: generateThumbnail(from: outputFileURL))
        pausedRecordings.append(newTruvideoClip)

        processLastTruvideoClip()
    }

    private func generateThumbnail(from url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true  // correct orientation

        let time = CMTime(seconds: 1, preferredTimescale: 600)
        do {
            let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            print("Failed to generate thumbnail: \(error)")
            return nil
        }
    }

    private func processLastTruvideoClip(_ completion: @escaping () -> Void = {}) {
        dprint(className, "handle stop recording after moving to background [CALLED]")

        guard !isVideoPausedSubject.value else {
            previousSecondsPassed = secondsPassed
            return completion()
        }

        guard pausedRecordings.count > 1 else {
            dprint(className, "handle stop recording after moving to background [1 ITEM]")
            sendNewTruvideoClip(pausedRecordings[0])
            return completion()
        }

        let outputURL = generateNextVideoOutputURL()
        Task {
            showLoaderSubject.send(true)
            do {
                try await concatenateVideos(in: pausedRecordings.map({ $0.url }), outputURL: outputURL)
                let newTruvideoClip = TruVideoClip(
                    url: outputURL,
                    lastFrameImage: pausedRecordings.first?.firstFrameImage
                )
                sendNewTruvideoClip(newTruvideoClip)
            } catch {
                dprint(className, "concat vides finished in [ERROR] :\(error.localizedDescription)")
                sendNewTruvideoClip(nil)
            }
            showLoaderSubject.send(false)
            completion()
        }
    }

    private func sendNewTruvideoClip(_ clip: TruVideoClip?) {
        isProcessingNewVideo = false
        secondsPassed = 0
        previousSecondsPassed = 0
        recordedDurationSubject.send(0)
        pausedRecordings = []
        isVideoPausedSubject.send(false)
        isRecordingSubject.send(false)

        guard let clip else { return }
        videosSubject.send(clip)
    }
}

extension TVCameraManager {
    private func generateNextPhotoOutputURL() -> URL {
        let imageFormatString = imageFormat.rawValue
        let filename = "\(identifier.uuidString)-TV-photo.\(photosCount).\(imageFormatString)"
        let nextOutputURL = outputDirectory.appendingPathComponent(filename)

        FileManager.default.removeFile(at: nextOutputURL)

        defer {
            photosCount += 1
        }

        return nextOutputURL
    }

    func generateNextVideoOutputURL() -> URL {
        let filename = "\(identifier.uuidString)-TV-clip.\(videosCount).mp4"
        let nextOutputURL = outputDirectory.appendingPathComponent(filename)

        videosCount += 1
        FileManager.default.removeFile(at: nextOutputURL)
        return nextOutputURL
    }

    private func transformImageData(image: UIImage) -> Data {
        switch imageFormat {
        case .jpeg:
            guard let jpegImageData = image.jpegData(compressionQuality: 0.8) else {
                print("[TruVideoCameraManager]: 🛑 Failed to create image Data as jpeg")
                return Data()
            }
            return jpegImageData
        case .png:
            guard let pngImageData = image.pngData() else {
                print("[TruVideoCameraManager]: 🛑 Failed to create image Data as png")
                return Data()
            }
            return pngImageData
        }
    }

    private func savePhotoToURL(imageData: Data, url: URL) {
        do {
            try imageData.write(to: url)
        } catch {
            print("[TruVideoCameraManager]: 🛑 failed to save image: \(error.localizedDescription)")
        }
    }
}

extension TVCameraManager {
    func releaseResources() {
        setIdleTimer(enabled: true)

        stopSession()
        configurationQueue.async { [weak self] in
            guard let self else { return }
            dprint(className, "captureSession was [CLEANED]")
            captureSession.beginConfiguration()

            for output in captureSession.outputs {
                captureSession.removeOutput(output)
            }

            for input in captureSession.inputs {
                captureSession.removeInput(input)
            }

            captureSession.commitConfiguration()

            currentVideoInput = nil
            currentAudioInput = nil

            captureSession = AVCaptureSession()
            previewLayer.session = nil
        }
    }
}

extension AVCaptureDevice {
    /// Returns the primary duo camera video device, if available, else the default wide angel camera, otherwise nil.
    ///
    /// - Parameter position: Desired position of the device
    /// - Returns: Primary video capture device found, otherwise nil
    fileprivate static func primaryVideoDevice(for cameraPosition: TruvideoSdkCameraLensFacing) -> AVCaptureDevice? {
        let position = cameraPosition.avCaptureDevice
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera],
            mediaType: .video,
            position: position
        )

        let devices = discoverySession.devices
        return devices.first(where: { $0.deviceType == .builtInDualCamera }) ?? devices.first
    }
}

extension TVCameraManager {

    private func configureCaptureAudioDeviceInput(in session: AVCaptureSession) throws {
        guard let captureDevice = AVCaptureDevice.default(for: .audio) else {
            throw TruVideoError(kind: .cannotAddDevice)
        }

        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)

            guard session.canAddInput(captureDeviceInput) else {
                throw TruVideoError(kind: .cannotAddDevice)
            }

            session.addInput(captureDeviceInput)

            self.captureVideoDeviceInput = captureDeviceInput
        } catch {
            throw TruVideoError(kind: .cannotAddDevice)
        }
    }

    private func configureCaptureAudioDataOutput(in session: AVCaptureSession) throws {
        let captureAudioDataOutput = AVCaptureAudioDataOutput()

        guard session.canAddOutput(captureAudioDataOutput) else {
            throw TruVideoError(kind: .cannotAddAudioOutput)
        }

        session.addOutput(captureAudioDataOutput)
        captureAudioDataOutput.setSampleBufferDelegate(self, queue: audioQueue)

        self.captureAudioDataOutput = captureAudioDataOutput
    }

    private func configureCaptureVideoDeviceOutput(in session: AVCaptureSession) throws {
        let captureVideoDataOutput = AVCaptureVideoDataOutput.createDefault()

        guard session.canAddOutput(captureVideoDataOutput) else {
            throw TruVideoError(kind: .cannotAddVideoOutput)
        }

        session.addOutput(captureVideoDataOutput)

        captureVideoDataOutput.setSampleBufferDelegate(self, queue: videoQueue)
        self.captureVideoDataOutput = captureVideoDataOutput
    }
}

extension TVCameraManager: AVCaptureAudioDataOutputSampleBufferDelegate & AVCaptureVideoDataOutputSampleBufferDelegate {

    // MARK: - AVCaptureAudioDataOutputSampleBufferDelegate & AVCaptureVideoDataOutputSampleBufferDelegate

    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {

        guard !isVideoPausedSubject.value, isRecordingSubject.value else { return }

        guard let captureVideoDataOutput, captureVideoDataOutput == output else {
            let sampleBuffer = AudioSampleBufferDeprecation(
                duration: CMSampleBufferGetDuration(sampleBuffer),
                sampleBuffer: sampleBuffer,
                timestamp: CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            )

            Task {
                self.processor.processAudio(buffer: sampleBuffer, with: TruAudioConfiguration())
            }

            return
        }

        let sampleBuffer = VideoSampleBufferDeprecation(
            minFrameDuration: captureVideoDevice?.activeVideoMinFrameDuration ?? .zero,
            sampleBuffer: sampleBuffer,
            timestamp: CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        )

        Task {
            self.processor.processVideo(buffer: sampleBuffer, with: TruVideoConfiguration())
        }
    }
}

extension AVCaptureSession {
    /// Adds a new video capture device input to the session, replacing any existing video input.
    ///
    /// This method safely switches between different camera devices by first removing the current
    /// video input (if any) and then adding the new device input. It ensures proper cleanup
    /// and prevents conflicts when switching between cameras during zoom operations.
    ///
    /// The method performs the following steps:
    /// 1. Removes any existing video input to prevent conflicts
    /// 2. Creates a new device input for the specified capture device
    /// 3. Validates that the input can be added to the session
    /// 4. Adds the new input and returns it for further configuration
    ///
    /// - Parameter captureDevice: The AVCaptureDevice to create an input for.
    /// - Returns: The newly created and configured AVCaptureDeviceInput.
    /// - Throws: An Error if the device input cannot be created or added to the session.
    fileprivate func addDeviceInput(for captureDevice: AVCaptureDevice) throws -> AVCaptureDeviceInput {
        if let currentCaptureDeviceInput = deviceInput(for: .video) {
            removeInput(currentCaptureDeviceInput)
        }

        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)

            guard canAddInput(captureDeviceInput) else {
                throw TruVideoError(kind: .unknown)
            }

            addInput(captureDeviceInput)

            return captureDeviceInput
        } catch {
            throw TruVideoError(kind: .unknown)
        }
    }
}

extension TruvideoSdkCameraLensFacing {
    fileprivate var avCaptureDevice: AVCaptureDevice.Position {
        switch self {
        case .back:
            .back

        case .front:
            .front
        }
    }
}
