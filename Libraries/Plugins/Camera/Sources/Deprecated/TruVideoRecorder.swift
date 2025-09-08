//
//  TruVideo.swift
//
//  Created by TruVideo on 6/14/22.
//  Copyright © 2023 TruVideo. All rights reserved.
//

import ARKit
import AVFoundation
import Combine
import Foundation
import UIKit

extension AVCaptureSession {

    // MARK: Instance methods

    /// Returns the capture device input for the desired media type and capture session, otherwise nil.
    ///
    /// - Parameters:
    ///   - mediaType: Specified media type. (i.e. AVMediaTypeVideo, AVMediaTypeAudio, etc.)
    ///   - captureSession: Capture session for which to query
    /// - Returns: Desired capture device input for the associated media type, otherwise nil
    func deviceInput(for mediaType: AVMediaType) -> AVCaptureDeviceInput? {
        if let inputs = inputs as? [AVCaptureDeviceInput], !inputs.isEmpty {
            return inputs.first { $0.device.hasMediaType(mediaType) }
        }

        return nil
    }
}

extension AVCaptureDevice {
    /// Returns the primary duo camera video device, if available, else the default wide angel camera, otherwise nil.
    ///
    /// - Parameter position: Desired position of the device
    /// - Returns: Primary video capture device found, otherwise nil
    static func primaryVideoDevice(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let allDeviceTypes: [AVCaptureDevice.DeviceType] = [
            .builtInDualCamera,
            .builtInTripleCamera,  // newer iPhones
            .builtInWideAngleCamera,
            .builtInUltraWideCamera,
            .builtInTelephotoCamera,
            .builtInDualWideCamera,  // newer dual setups
            .builtInTrueDepthCamera,  // front-facing depth camera
        ]

        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: allDeviceTypes,
            mediaType: .video,
            position: position
        )

        let devices = discoverySession.devices

        // Prefer cameras in order of capability
        for preferredType in allDeviceTypes {
            if let device = devices.first(where: { $0.deviceType == preferredType }) {
                return device
            }
        }

        // As a fallback, return the first available device at all
        return devices.first
    }
}

extension UIDevice {
    /// Returns the `AVCaptureVideoOrientation`
    var captureVideoOrientation: AVCaptureVideoOrientation {
        switch orientation {
        case .landscapeLeft: return .landscapeRight
        case .landscapeRight: return .landscapeLeft
        default: return .portrait
        }
    }
}

extension UIImage {
    /// Rotates the image by the given radians.
    ///
    /// - Parameter radians: The radians angle.
    /// - Returns: The rotated image.
    func rotate(radians: CGFloat) -> UIImage? {
        var newSize = CGRect(origin: .zero, size: size).applying(CGAffineTransform(rotationAngle: radians)).size

        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        let context = UIGraphicsGetCurrentContext()!

        context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        context.rotate(by: CGFloat(radians))

        draw(in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }

    /// Returns a new image with the given orientation
    ///
    /// - Parameter orientation: The desired orientation for the image
    /// - Returns: A new image with the fixed orientation
    func withOrientation(_ orientation: UIImage.Orientation) -> UIImage? {
        guard let cgImage = cgImage else {
            return nil
        }

        return UIImage(cgImage: cgImage, scale: scale, orientation: orientation)
    }
}

typealias TruVideoAuthorizationStatus = AVAuthorizationStatus
typealias TruVideoDeviceOrientation = AVCaptureVideoOrientation
typealias TruVideoDevicePosition = AVCaptureDevice.Position
typealias TruVideoFlashMode = AVCaptureDevice.FlashMode
typealias TruVideoStabilizationMode = AVCaptureVideoStabilizationMode
typealias TruVideoTorchMode = AVCaptureDevice.TorchMode

let TruVideoMetadataTitle = "TruVideo"
let TruVideoMetadataArtist = "https://truvideo.com/"

/// Operation modes for TruVideoRecorder.
enum TruVideoRecorderCaptureMode {
    /// Whether is recording only audio.
    case audio

    /// Whether is taking photos.
    case photo

    /// Whether is recording a video.
    case video

    case scanner
}

/// 📸 TruVideoRecorder, Raw Media Capture in Swift
class TruVideoRecorder: NSObject {
    // - MARK: Class name
    let className = String(describing: TruVideoRecorder.self)

    /// Is recording paused
    private let isRecordingPausedSubject = CurrentValueSubject<Bool, Never>(false)
    var isVideoRecordingPublisher: AnyPublisher<Bool, Never> {
        isRecordingPausedSubject
            .eraseToAnyPublisher()
    }

    /// Audio input
    private var audioInput: AVCaptureDeviceInput?

    /// The audio output
    private var audioOutput: AVCaptureAudioDataOutput?

    /// The current subscription  for the recording time, if any.
    private var cancellable: AnyCancellable?

    /// Process metadata objects from an attached connection
    private var captureMetadata: AVCaptureMetadataOutput?

    /// Implements the complete file recording interface for writing media data
    private var captureMovieOutput: AVCaptureVideoDataOutput?

    /// Provides an interface for capture workflows related to still photography
    private var capturePhotoOutput: AVCapturePhotoOutput?

    /// The underlying capture session
    private var captureSession: AVCaptureSession?

    /// Current device
    private var currentDevice: AVCaptureDevice?

    /// Last audio frame recorded
    private var lastAudioFrame: CMSampleBuffer?

    /// Last video frame recorded
    private var lastVideoFrame: CMSampleBuffer?

    /// The last video frame time interval
    private var lastVideoFrameTimeInterval: TimeInterval = 0

    /// Used to mediate access between configurations
    private let lock = NSLock()

    /// Capture metadata output
    private var metadataOutput: AVCaptureMetadataOutput?

    /// Whether the configuration needs to be updated.
    private var needsUpdateConfiguration = false

    /// The current photo continuation if there is any capture in progress
    private var photoContinuation: CheckedContinuation<TruVideoPhoto?, Error>?

    /// Tracks the previous duration of the recording
    private var previousDuration: TimeInterval = 0

    /// The requested device
    private var requestedDevice: AVCaptureDevice?

    /// The session worker queue
    private let sessionQueue: DispatchQueue

    /// Video input
    private var videoInput: AVCaptureDeviceInput?

    /// Video output
    private var videoOutput: AVCaptureVideoDataOutput?

    /// Configuration for the audio.
    let audioConfiguration: TruAudioConfiguration = .init()

    /// Indicates whether the capture session automatically changes settings in the app’s shared audio session. By default, is `true`.
    var automaticallyConfiguresApplicationAudioSession = true

    /// When `true` actives device orientation updates
    var automaticallyUpdatesDeviceOrientation = true

    @Published var arRenderer: ARRenderer?

    /// The current capture mode of the device
    var captureMode: TruVideoRecorderCaptureMode = .video {
        didSet {
            guard captureMode != oldValue else { return }

            /// call delegate
            sessionQueue.async { [weak self] in
                guard let self else { return }
                do {
                    try self.configureSession()
                    self.configureSessionDevices()
                    self.configureMetadataObjects()
                    /// Notify delegate
                } catch {
                    print("[TruVideoSession]: 🛑 failed to set the capture mode \(self.captureMode).")
                }
            }
        }
    }

    /// Shared Core Image rendering context.
    var context: CIContext? = .createDefault()

    /// The current device position.
    private(set) var devicePosition: TruVideoDevicePosition = .back

    /// Flash mode of the device.
    var flashMode: TruVideoFlashMode {
        get {
            photoConfiguration.flashMode
        }

        set {
            guard photoConfiguration.flashMode != newValue else { return }

            photoConfiguration.flashMode = newValue
        }
    }

    /// Checks if a flash is available.
    var isFlashAvailable: Bool {
        currentDevice?.hasFlash ?? false
    }

    /// True if the session has been interrupted
    @Published
    private(set) var isInterrupted = false

    /// Checks if the system is recording.
    private(set) var isRecording = false

    /// Checks if the system is running.
    var isRunning: Bool {
        captureSession?.isRunning == true
    }

    @Published var isRunningSessionPublisher = false

    /// Checks if a torch is available.
    var isTorchAvailable: Bool {
        (currentDevice?.hasTorch ?? false || currentDevice?.isTorchAvailable ?? false)
    }

    /// Output directory for the session.
    var outputDirectory = URL(fileURLWithPath: NSTemporaryDirectory())

    /// Configuration for photos.
    let photoConfiguration: TruPhotoConfiguration = .init()

    /// Live camera preview, add as a sublayer to the View's primary layer.
    let previewLayer: AVCaptureVideoPreviewLayer = .init()

    /// Unique identifier for the session
    let identifier = UUID()

    /// The number of photos taken
    var photosCount = 0

    /// The current orientation value
    var currentOrientation: UIDeviceOrientation = .currentAppOrientation()

    /// The current preview orientation
    var previewOrientation: UIDeviceOrientation = .currentAppOrientation()

    /// The camera's photo output file format
    var imageFormat: TruvideoSdkCameraImageFormat = .jpeg

    @Published private(set) var scannedCode: TruvideoSdkCameraScannerCode?
    var supportedCodeFormats = TruvideoSdkCameraScannerCodeFormat.allCases

    /// Amount of  seconds recorded
    @Published
    private(set) var secondsRecorded: Double = 0

    /// The current recording session, a powerful means for modifying and editing previously recorded clips.
    private(set) var session: TruVideoSession?

    /// Torch mode of the device.
    var torchMode: TruVideoTorchMode {
        currentDevice?.torchMode ?? .off
    }

    /// Configuration for  videos.
    let videoConfiguration: TruVideoConfiguration = .init()

    /// Video stabilization mode
    var videoStabilizationMode: TruVideoStabilizationMode = .auto {
        didSet {
            lock.lock()
            updateVideoOutputSettings()
            lock.unlock()
        }
    }

    private let TruVideoRecorderQueueIdentifier = "org.TruVideo.CaptureSession"
    private let TruVideoRecorderQueueSpecificKey = DispatchSpecificKey<()>()

    /// Tiff image metadata
    static var tiffMetadata: [String: Any] {
        [
            kCGImagePropertyTIFFSoftware as String: TruVideoMetadataTitle,
            kCGImagePropertyTIFFArtist as String: TruVideoMetadataArtist,
            kCGImagePropertyTIFFDateTime as String: ISO8601DateFormatter().string(from: Date()),
        ]
    }

    /// Represents all the possible errors that can be thrown.
    public enum TruVideoRecorderError: LocalizedError {
        /// Unable to get the photo data representation.
        case failedToGetPhotoDataRepresentation

        /// Video recorder has not initialized photo continuation.
        case photoCaptureInProgress
    }

    /// Method that updates the preview image
    weak var delegate: PreviewImageDelegate?

    weak var renderDestinationProvider: RenderDestinationProvider?

    // MARK: Initializers

    /// Creates a new instance of `TruVideoRecorder`
    init(capturedMode: TruVideoRecorderCaptureMode = .video) {
        self.captureMode = capturedMode
        self.previewLayer.videoGravity = .resizeAspectFill
        self.sessionQueue = DispatchQueue(label: TruVideoRecorderQueueIdentifier, qos: .userInteractive)
        self.sessionQueue.setSpecific(key: TruVideoRecorderQueueSpecificKey, value: ())

        super.init()

        configureSessionObservers()

        /// ADD Observers
    }

    // MARK: Instance methods

    /// Triggers a photo capture.
    ///
    /// - Returns: A new instance of `TruVideoPhoto` or nil otherwise
    func capturePhoto() async throws -> TruVideoPhoto? {
        guard photoContinuation == nil else {
            throw TruVideoError(
                kind: .failedToCapturePhoto,
                underlyingError: TruVideoRecorderError.photoCaptureInProgress
            )
        }

        return try await withCheckedThrowingContinuation { continuation in
            guard
                /// capturePhotoOutput
                let capturePhotoOutput = capturePhotoOutput,

                /// format dictionary
                let formatDictionary = photoConfiguration.avDictionary()
            else {

                return continuation.resume(returning: nil)
            }

            let capturePhotoSettings = AVCapturePhotoSettings(format: formatDictionary)

            capturePhotoSettings.isHighResolutionPhotoEnabled = photoConfiguration.isHighResolutionEnabled
            capturePhotoSettings.photoQualityPrioritization = .balanced
            capturePhotoOutput.isHighResolutionCaptureEnabled = photoConfiguration.isHighResolutionEnabled

            if isFlashAvailable {
                capturePhotoSettings.flashMode = photoConfiguration.flashMode
            }

            photoContinuation = continuation
            self.captureAfterExposureSettle(
                output: capturePhotoOutput,
                settings: capturePhotoSettings,
                continuation: continuation
            )
        }
    }

    private func captureAfterExposureSettle(
        output: AVCapturePhotoOutput,
        settings: AVCapturePhotoSettings,
        continuation: CheckedContinuation<TruVideoPhoto?, Error>
    ) {
        sessionQueue.async { [weak self] in
            guard let self = self else {
                continuation.resume(returning: nil)
                return
            }

            self.ensureContinuousAEAndWaitIfAdjusting()

            self.photoContinuation = continuation
            output.capturePhoto(with: settings, delegate: self)
        }
    }

    private func ensureContinuousAEAndWaitIfAdjusting(maxWait: TimeInterval = 0.3) {
        guard let device = currentDevice else { return }

        do {
            try device.lockForConfiguration()
            if device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposureMode = .continuousAutoExposure
            }
            device.unlockForConfiguration()
        } catch {}

        // Wait up to ~300ms for AE to settle
        let start = CFAbsoluteTimeGetCurrent()
        while device.isAdjustingExposure && (CFAbsoluteTimeGetCurrent() - start) < maxWait {
            usleep(20_000)  // 20ms
        }
    }

    private func getPhotoFromLastFrame() -> UIImage? {
        guard let lastVideoFrame = lastVideoFrame, session != nil else {
            return nil
        }
        lastVideoFrame.append(metadataAdditions: TruVideoRecorder.tiffMetadata)
        return context?.image(from: lastVideoFrame)
    }

    /// Triggers a photo capture from the last video frame.
    ///
    /// - Returns: A new instance of `TruVideoPhoto` or nil otherwise
    func capturePhotoFromVideo() -> TruVideoPhoto? {
        guard let lastVideoFrame = lastVideoFrame, session != nil else {
            return nil
        }
        lastVideoFrame.append(metadataAdditions: TruVideoRecorder.tiffMetadata)
        guard let photo = context?.image(from: lastVideoFrame) else {
            return nil
        }

        let ratio = videoConfiguration.aspectRatio.ratio
        let croppedPhoto = ratio != nil ? photo.croppedImage(to: ratio!) : photo
        guard
            /// pngData photo
            let imageData = photo.pngData(),

            /// pngData cropped photo
            let croppedImageData = croppedPhoto.pngData()
        else {
            return nil
        }

        var metadata = lastVideoFrame.metadata ?? [:]
        metadata[TruVideoPhoto.DeviceOrientationKey] = currentOrientation

        let outputURL = generateNextOutputURL()
        savePhotoToURL(imageData: imageData, url: outputURL)

        return TruVideoPhoto(
            imageData: imageData,
            croppedImageData: croppedImageData,
            metadata: metadata,
            url: outputURL,
            lensFacing: getCurrentCameraLensFacing(),
            orientation: getCurrentOrientation(),
            resolution: .init(
                width: Int32(photo.size.width),
                height: Int32(photo.size.height)
            ),
            captureImage: photo
        )
    }

    private func getCurrentCameraLensFacing() -> TruvideoSdkCameraLensFacing {
        switch devicePosition {
        case .front:
            return .front
        @unknown default:
            return .back
        }
    }

    private func getCurrentOrientation() -> TruvideoSdkCameraOrientation {
        switch currentOrientation {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitReverse
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        @unknown default:
            return .portrait
        }
    }

    /// Pauses video recording, preparing 'NextLevel' to start a new clip with 'record()' with completion handler.
    func pause() async throws {
        guard let session = session, session.hasStartedRecording else {
            print("[TruVideoSession]: ⚠️ unable to pause the session. The session has not started")
            return
        }

        isRecording = false
        previousDuration = secondsRecorded

        do {
            if let clip = try await session.finishClip() {
                clip.lensFacing = getCurrentCameraLensFacing()
                clip.orientation = getCurrentOrientation()
                delegate?.addClip(clip, withPreview: getPhotoFromLastFrame())
            }
        } catch {
            print("[TruVideoSession]: 🛑 failed to pause the session error: \(error)")
            throw TruVideoError(kind: .failedToPauseRecording)
        }
        secondsRecorded = 0
    }

    /// Requests access to the underlying hardware for the media type, showing a dialog to the user if necessary.
    ///
    /// - Parameter mediaType: Specified media type (i.e. AVMediaTypeVideo, AVMediaTypeAudio, etc.)
    /// - Throws: An error if the authorization is not granted
    func requestAuhorization(for mediaType: AVMediaType) async throws {
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

    /// Initiates video recording, managed as a clip within the `TruVideoSession`
    func record() {
        sessionQueue.sync { [weak self] in
            guard let self else { return }
            self.isRecording = true
            if self.session != nil {
                self.beginNewClipIfNecessary()
            }
        }
    }

    /// Sets the capture device position
    ///
    /// - Parameter position: Indicates the physical position of an AVCaptureDevice's hardware on the system.
    func setDevicePosition(_ position: TruVideoDevicePosition, fromConfiguration: Bool = false) async {
        let resumeRecording = isRecording
        devicePosition = position

        if isRecording {
            do {
                try await pause()
            } catch {
                print("[TruVideoSession]: ⚠️ unable to pause the recording before flipping device position")
            }
        }
        guard !fromConfiguration else {
            return
        }
        cleanSession()
        try? setupAVSession()
        updateOutputVideoOrientation(to: currentOrientation)
        if resumeRecording {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.record()
            }
        }
    }

    /// Sets whether the the configuration needs to be updated
    func setNeedsUpdateConfiguration() {
        needsUpdateConfiguration = true
    }

    /// Sets the torch mode to the current device
    ///
    /// - Parameter mode: The new torch mode
    /// - Throws: An error when the torch is not available or not supported
    func setTorchMode(_ mode: TruVideoTorchMode, force: Bool = false) throws {
        guard isTorchAvailable else {
            throw TruVideoError(kind: .torchNotAvailable)
        }

        try executeSync {
            guard let currentDevice = self.currentDevice, currentDevice.hasTorch else {
                return
            }

            if !force {
                guard currentDevice.torchMode != mode else {
                    return
                }
            }

            do {
                try currentDevice.lockForConfiguration()

                if currentDevice.isTorchModeSupported(mode) {
                    currentDevice.torchMode = mode
                } else {
                    throw TruVideoError(kind: .torchNotSupported)
                }

                currentDevice.unlockForConfiguration()
            } catch {
                print("[TruVideoSession]: ⚠️ failed to set torch \(mode.rawValue).")
                throw TruVideoError(kind: .failedToSetTorch, underlyingError: error)
            }
        }
    }

    /// Starts the current recording session.
    ///
    /// - Throws: `TruVideoRecorderError.notAuthorized` when permissions are not authorized,
    ///           `TruVideoRecorderError.recordInProgress` when the session has already started.
    func start() throws {
        if let ready = session?.hasConfiguredVideo, ready {
            cleanSession()
        }

        guard authorizationStatusForCurrentCaptureMode() == .authorized else {
            throw TruVideoError(kind: .notAuthorized)
        }

        guard captureSession == nil else {
            throw TruVideoError(kind: .recordInProgress)
        }

        try setupAVSession()
    }

    func startARSession(with configuration: ARWorldTrackingConfiguration? = nil) throws {
        stopARSessionIfNeeded()

        guard authorizationStatusForCurrentCaptureMode() == .authorized else {
            throw TruVideoError(kind: .notAuthorized)
        }
        let arSession = ARSession()
        let sessionConfiguration = configuration ?? ARWorldTrackingConfiguration()
        sessionConfiguration.planeDetection = [.horizontal, .vertical]

        arSession.run(sessionConfiguration, options: .resetTracking)

        guard
            let renderDestinationProvider,
            let device = MTLCreateSystemDefaultDevice(),
            let commandQueue = device.makeCommandQueue(),
            let renderer = try? ARRendererBuilder.makeARRenderer(
                arSession: arSession,
                device: device,
                commandQueue: commandQueue,
                renderDestinationProvider: renderDestinationProvider
            )
        else {
            arSession.pause()
            throw TruVideoError(kind: .failedToLoadAR)
        }
        arRenderer = renderer
        self.session = self.session ?? TruVideoSession(queue: sessionQueue)
        observeSessionDuration()
        setCurrentDevice()
    }

    func stopARSessionIfNeeded() {
        if let arRenderer = arRenderer {
            arRenderer.isRendering = false
            arRenderer.session.pause()
            arRenderer.clear()
            arRenderer.session.getCurrentWorldMap { _, _ in }
            self.arRenderer = nil
        }
        cleanSession()
    }

    func restart() throws {
        guard let captureSession = captureSession else {
            return
        }

        lock.lock()
        defer {
            captureSession.commitConfiguration()
            lock.unlock()
        }

        if captureSession.sessionPreset != videoConfiguration.preset {
            if captureSession.canSetSessionPreset(videoConfiguration.preset) {
                captureSession.sessionPreset = videoConfiguration.preset
            } else {
                print("[TruVideoSession]: ⚠️ failed to set present \(videoConfiguration.preset).")
            }
        }

        configureCaptureSession()
    }

    // MARK: Static methods

    /// Returns the client's authorization status for accessing the underlying hardware that supports a given media type.
    ///
    /// - Parameter mediaType: Specified media type (i.e. AVMediaTypeVideo, AVMediaTypeAudio, etc.)
    /// - Returns: Authorization status for the desired media type.
    static func authorizationStatus(for mediaType: AVMediaType) -> TruVideoAuthorizationStatus {
        AVCaptureDevice.authorizationStatus(for: mediaType)
    }

    // MARK: Notification methods

    @objc
    private func didReceiveSessionRuntimeErrorNotification(_ notification: Notification) {
        if let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError {
            switch error.code {
            case .deviceIsNotAvailableInBackground:
                print("[TruVideoSession]: 🛑 media services are not available in the background")
                break
            case .mediaServicesWereReset: fallthrough
            default: break
            }
        }
    }

    @objc
    private func didReceiveSessionWasInterruptedNotification(_ notification: Notification) {
        dprint(className, "session interruption [STARTED]")

        if isRecording, !(session?.currentVideoRecordingIsPaused ?? true) {
            isRecordingPausedSubject.send(true)
            session?.handlePauseVideoRecording()
        }
        sessionQueue.async { [weak self] in
            guard let self else { return }
            captureSession?.stopRunning()
        }
    }

    @objc
    private func didReceiveSessionInterruptionEnded(_ notification: Notification) {
        dprint(className, "session interruption [ENDED]")

        sessionQueue.async { [weak self] in
            guard let self else { return }
            captureSession?.startRunning()
        }
    }

    @objc
    private func handleAppWillResignActive() {
        dprint(className, "app going to [BACKGROUND]")

        handleAppGoingToBackground()
    }

    @objc
    private func handleAppDidBecomeActive() {
        dprint(className, "app becoming [ACTIVE]")

        handleAppBecomingActive()
    }

    // MARK: - Handle Background Task
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    private func handleAppGoingToBackground() {
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "StopCameraSession") { [weak self] in
            guard let self else { return }
            // If time expires before we end the task, iOS will call this block.
            endBackgroundTask()
        }

        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self else { return }
            if isRecording, !(session?.currentVideoRecordingIsPaused ?? true) {
                isRecordingPausedSubject.send(true)
                session?.handlePauseVideoRecording()
            }
            sessionQueue.async { [weak self] in
                guard let self else { return }
                captureSession?.stopRunning()
            }
            endBackgroundTask()
        }
    }

    private func handleAppBecomingActive() {
        if isRecording, session?.currentVideoRecordingIsPaused ?? false {
            isRecordingPausedSubject.send(true)
        }
        sessionQueue.async { [weak self] in
            guard let self else { return }
            captureSession?.startRunning()
        }
    }

    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }

    // MARK: Private methods

    private func addAudioOuput() throws {
        if audioOutput == nil {
            audioOutput = AVCaptureAudioDataOutput()
        }

        guard
            /// The underlying capture session
            let captureSession = captureSession,

            /// Audio output
            let audioOutput = audioOutput, captureSession.canAddOutput(audioOutput)
        else {

            throw TruVideoError(kind: .cannotAddAudioOutput)
        }

        captureSession.addOutput(audioOutput)
        audioOutput.setSampleBufferDelegate(self, queue: sessionQueue)
    }

    private func addInput(with captureDevice: AVCaptureDevice) throws {
        guard let captureSession = captureSession else {
            return
        }

        let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)

        guard captureSession.canAddInput(captureDeviceInput) else {
            throw TruVideoError(kind: .cannotAddDevice)
        }

        if captureDeviceInput.device.hasMediaType(.video) {
            /// ADD OBSERVERS
            videoInput = captureDeviceInput
        } else {
            audioInput = captureDeviceInput
        }

        captureSession.addInput(captureDeviceInput)
    }

    private func addPhotoOutput() throws {
        if capturePhotoOutput == nil {
            capturePhotoOutput = AVCapturePhotoOutput()
        }

        guard
            /// The underlying capture session
            let captureSession = captureSession,

            /// Capture photo output
            let capturePhotoOutput = capturePhotoOutput, captureSession.canAddOutput(capturePhotoOutput)
        else {

            throw TruVideoError(kind: .cannotAddAudioOutput)
        }

        captureSession.addOutput(capturePhotoOutput)
    }

    private func addVideoOutput() throws {
        if videoOutput == nil {
            videoOutput = AVCaptureVideoDataOutput()
            videoOutput?.alwaysDiscardsLateVideoFrames = false

            var videoSettings = [String(kCVPixelBufferPixelFormatTypeKey): Int(kCVPixelFormatType_32BGRA)]

            if let formatTypes = videoOutput?.availableVideoPixelFormatTypes {
                var supportsFullRange = false
                var supportsVideoRange = false

                for formatType in formatTypes {
                    if formatType == Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
                        supportsFullRange = true
                    }
                    if formatType == Int(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) {
                        supportsVideoRange = true
                    }
                }

                let settingsKey = String(kCVPixelBufferPixelFormatTypeKey)

                //                if supportsFullRange {
                //                    videoSettings[settingsKey] = Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
                //                } else if supportsVideoRange {
                //                    videoSettings[settingsKey] = Int(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)
                //                }
                videoSettings[settingsKey] = Int(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)
            }

            videoOutput?.videoSettings = videoSettings
        }

        if /// Capture session
        let captureSession = captureSession,

            /// VideoOutput
            let videoOutput = videoOutput
        {

            if captureSession.canAddOutput(videoOutput) {
                videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
                captureSession.addOutput(videoOutput)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.updateVideoOutputSettings()
                }
            } else {
                print("[TruVideoSession]: 🛑 failed to set add video output")
                throw TruVideoError(kind: .cannotAddVideoOutput)
            }
        }
    }

    private func authorizationStatusForCurrentCaptureMode() -> TruVideoAuthorizationStatus {
        switch captureMode {
        case .audio: return TruVideoRecorder.authorizationStatus(for: .audio)
        case .photo: return TruVideoRecorder.authorizationStatus(for: .video)
        case .video:
            let audioStatus = TruVideoRecorder.authorizationStatus(for: .audio)
            let videoStatus = TruVideoRecorder.authorizationStatus(for: .video)
            return (audioStatus == .authorized && videoStatus == .authorized) ? .authorized : .denied
        case .scanner: return TruVideoRecorder.authorizationStatus(for: .video)
        }
    }

    private func beginNewClipIfNecessary() {
        guard let session = session, !session.isReady else { return }

        try? session.beginNewClip()
        DispatchQueue.main.async {
            /// ntify delegate
        }
    }

    private func checkSessionDuration() async {
        guard
            /// Current session.
            let session = session,

            /// The maximun duration allowed to record.
            let maximumCaptureDuration = videoConfiguration.maximumCaptureDuration,
            maximumCaptureDuration.isValid && session.totalDuration >= maximumCaptureDuration
        else { return }

        isRecording = false
        do {
            let _ = try await session.finishClip()
            DispatchQueue.main.async {
                //self.videoDelegate?.nextLevel(self, didCompleteClip: clip, inSession: session)
            }
        } catch {
            print("[TruVideoSession]: ⚠️ failed to finish the clip that exceeds the max duration.")
        }

        DispatchQueue.main.async {
            //self.videoDelegate?.nextLevel(self, didCompleteSession: session)
        }
    }

    func cleanSession() {
        if let captureSession = captureSession, captureSession.isRunning {
            captureSession.stopRunning()
        }

        removeInputs()
        removeOutputs()

        self.captureSession = nil
        currentDevice = nil
        isRecording = false
        previewLayer.session = nil
        session?.reset()
    }

    private func configureDevice(_ captureDevice: AVCaptureDevice, for mediaType: AVMediaType) throws {
        guard let captureSession = captureSession else { return }

        if let currentDeviceInput = captureSession.deviceInput(for: mediaType),
            currentDeviceInput.device == captureDevice
        {
            return
        }

        if mediaType == .video {
            do {
                try captureDevice.lockForConfiguration()

                if captureDevice.isFocusModeSupported(.continuousAutoFocus) {
                    captureDevice.focusMode = .continuousAutoFocus

                    if captureDevice.isSmoothAutoFocusSupported {
                        captureDevice.isSmoothAutoFocusEnabled = true
                    }
                }

                if captureDevice.isExposureModeSupported(.continuousAutoExposure) {
                    captureDevice.exposureMode = .continuousAutoExposure
                }

                if captureDevice.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
                    captureDevice.whiteBalanceMode = .continuousAutoWhiteBalance
                }

                captureDevice.isSubjectAreaChangeMonitoringEnabled = true

                if captureDevice.isLowLightBoostSupported {
                    captureDevice.automaticallyEnablesLowLightBoostWhenAvailable = true
                }

                captureDevice.unlockForConfiguration()
            } catch {
                print("[TruVideoSession]: ⚠️ failed to lock device for configuration.")
            }
        }

        if let currentDeviceInput = captureSession.deviceInput(for: mediaType) {
            captureSession.removeInput(currentDeviceInput)

            if currentDeviceInput.device.hasMediaType(.video) {
                /// REMOVE OBSERVERS
            }
        }

        try addInput(with: captureDevice)
    }

    func configureMetadataObjects() {
        guard
            /// Capture session
            let captureSession = captureSession
        else {
            return
        }

        if metadataOutput == nil {
            metadataOutput = AVCaptureMetadataOutput()
        }

        guard let metadataOutput = metadataOutput else { return }

        if !captureSession.outputs.contains(metadataOutput), captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
            metadataOutput.metadataObjectTypes = supportedCodeFormats.metadataTypes
        }
    }

    private func configureSession() throws {
        guard let captureSession = captureSession else {
            return
        }

        lock.lock()
        defer {
            captureSession.commitConfiguration()
            lock.unlock()
        }

        captureSession.beginConfiguration()
        removeUnusedOuputs(for: captureSession)

        switch captureMode {
        case .audio: try addAudioOuput()
        case .photo:
            if captureSession.sessionPreset != photoConfiguration.preset {
                guard captureSession.canSetSessionPreset(photoConfiguration.preset) else {
                    throw TruVideoError(kind: .cannotSetPresset)
                }
            }

            try addPhotoOutput()

        case .video:
            if captureSession.sessionPreset != videoConfiguration.preset {
                if captureSession.canSetSessionPreset(videoConfiguration.preset) {
                    captureSession.sessionPreset = videoConfiguration.preset
                } else {
                    print("[TruVideoSession]: ⚠️ failed to set present \(videoConfiguration.preset).")
                }
            }

            try addAudioOuput()
            try addPhotoOutput()
            try addVideoOutput()
        case .scanner:
            if captureSession.sessionPreset != videoConfiguration.preset {
                if captureSession.canSetSessionPreset(videoConfiguration.preset) {
                    captureSession.sessionPreset = videoConfiguration.preset
                } else {
                    print("[TruVideoSession]: ⚠️ failed to set present \(videoConfiguration.preset).")
                }
            }
            try addVideoOutput()
        }
    }

    private func configureSessionDevices() {
        guard let captureSession = captureSession else {
            return
        }

        lock.lock()
        captureSession.beginConfiguration()

        defer {
            captureSession.commitConfiguration()
            lock.unlock()
        }

        var shouldConfigureVideo = false
        var shouldConfigureAudio = false

        switch captureMode {
        case .audio: shouldConfigureAudio = true
        case .photo: shouldConfigureVideo = true
        case .video:
            shouldConfigureVideo = true
            shouldConfigureAudio = true
        case .scanner: shouldConfigureVideo = true
        }

        if shouldConfigureVideo {
            var captureDevice: AVCaptureDevice?

            captureDevice = requestedDevice ?? AVCaptureDevice.primaryVideoDevice(for: devicePosition)

            if let captureDevice = captureDevice, captureDevice != currentDevice {
                do {
                    try configureDevice(captureDevice, for: .video)
                } catch {
                    Logger.logError(event: .configureVideo, eventMessage: .configureVideoFailed(error: error))
                    print("[TruVideoSession]: ⚠️ failed to configure the video device error: \(error).")
                }

                let changingPosition = captureDevice.position != currentDevice?.position

                if changingPosition {
                    /*DispatchQueue.main.async {
                        self.deviceDelegate?.nextLevelDevicePositionWillChange(self)
                    }*/
                }

                willChangeValue(forKey: "currentDevice")
                currentDevice = captureDevice

                didChangeValue(forKey: "currentDevice")
                requestedDevice = nil

                if changingPosition {
                    /*DispatchQueue.main.async {
                        self.deviceDelegate?.nextLevelDevicePositionDidChange(self)
                    }*/
                }

                configureCaptureSession()
            }
        }

        if shouldConfigureAudio {
            if let audioDevice = AVCaptureDevice.default(for: .audio) {
                do {
                    try configureDevice(audioDevice, for: .audio)
                } catch {
                    Logger.logError(event: .configureAudio, eventMessage: .configureAudioFailed(error: error))
                    print("[TruVideoSession]: ⚠️ failed to configure the audio device error: \(error).")
                }
            }
        }
    }

    private func configureCaptureSession() {
        guard let captureDevice = requestedDevice ?? AVCaptureDevice.primaryVideoDevice(for: devicePosition) else {
            return
        }
        guard let resolution = videoConfiguration.selectedResolution else {
            return
        }

        do {
            if let format = resolution.format {
                videoConfiguration.bitRate = resolution.bitRate
                try captureDevice.lockForConfiguration()
                captureDevice.activeFormat = format
                captureDevice.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: 24)
                captureDevice.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: 24)
                captureDevice.videoZoomFactor = videoConfiguration.zoomFactor
                captureDevice.unlockForConfiguration()
            }
        } catch {
            Logger.logError(event: .changeResolution, eventMessage: .configureResolutionFailed(error: error))
            print("[TruVideoSession]: 🛑 failed to set the resolution: \(error)")
        }
    }

    func configureZoomFactor(to zoomFactor: CGFloat) {
        guard let captureDevice = requestedDevice ?? AVCaptureDevice.primaryVideoDevice(for: devicePosition) else {
            return
        }
        guard let resolution = videoConfiguration.selectedResolution else {
            return
        }

        do {
            if let format = resolution.format {
                try captureDevice.lockForConfiguration()
                captureDevice.videoZoomFactor = min(zoomFactor, format.videoMaxZoomFactor)
                videoConfiguration.zoomFactor = captureDevice.videoZoomFactor
                captureDevice.unlockForConfiguration()
            }
        } catch {
            Logger.logError(event: .zoom, eventMessage: .configureZoomFailed(error: error))
            print("[TruVideoSession]: 🛑 failed to configure zoom factor: \(error)")
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
    }

    private func setCurrentDevice() {
        var captureDevice: AVCaptureDevice?

        captureDevice = requestedDevice ?? AVCaptureDevice.primaryVideoDevice(for: devicePosition)

        if let captureDevice = captureDevice, captureDevice != currentDevice {
            willChangeValue(forKey: "currentDevice")
            currentDevice = captureDevice

            didChangeValue(forKey: "currentDevice")
            requestedDevice = nil
        }
    }

    private func executeSync(_ closure: @escaping () throws -> Void) throws {
        if DispatchQueue.getSpecific(key: TruVideoRecorderQueueSpecificKey) != nil {
            try closure()
        } else {
            try sessionQueue.sync(execute: closure)
        }
    }

    private func handleAudioBuffer(_ sampleBuffer: CMSampleBuffer, in session: TruVideoSession) {
        if !session.hasConfiguredAudio {
            if /// Audio settings
            let settings = audioConfiguration.avcaptureSettingsDictionary(sampleBuffer: sampleBuffer),

                /// Format description
                let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer)
            {

                if !session.configureAudio(
                    with: settings,
                    configuration: audioConfiguration,
                    formatDescription: formatDescription
                ) {
                    print("[TruVideoSession]: ⚠️ Could not setup audio")
                }
            }

            /// Notify delegate
        }

        if isRecording && session.hasConfiguredVideo && session.hasStartedRecording && session.currentClipHasVideo {
            beginNewClipIfNecessary()

            if session.appendAudioBuffer(sampleBuffer) {
                Task {
                    await self.checkSessionDuration()
                }
            }
        }
    }

    func handleVideoBuffer(pixelBuffer: CVPixelBuffer) {
        guard
            let sampleBuffer = createSampleBufferFrom(pixelBuffer: pixelBuffer),
            let session
        else {
            return
        }
        let rotatedBuffer = pixelBuffer.rotate(
            orientation: currentOrientation.imageOrientation,
            swapDimensions: currentOrientation.swapDimensionsForPhoto
        )
        lastVideoFrame = rotatedBuffer.map { createSampleBufferFrom(pixelBuffer: $0) } ?? sampleBuffer
        handleVideoBuffer(pixelBuffer, sampleBuffer: sampleBuffer, in: session)

        if captureSession == nil {
            let captureSession = AVCaptureSession()
            captureSession.automaticallyConfiguresApplicationAudioSession =
                automaticallyConfiguresApplicationAudioSession

            self.captureSession = captureSession
            configureAudioDevice()
            do {
                try addAudioOuput()
            } catch {
                print("[TruVideoSession]: ⚠️ failed to add audio output: \(error).")
            }
            startAVSessionIfNeeded()
        }
    }

    private func startAVSessionIfNeeded() {
        if let captureSession, !captureSession.isRunning {
            sessionQueue.async {
                captureSession.startRunning()
            }
        }
    }

    private func observeSessionDuration() {
        if let session = session {
            cancellable?.cancel()
            cancellable = session.$totalDuration
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] totalDuration in
                    guard let self else { return }
                    if totalDuration.seconds > 0 {
                        self.secondsRecorded = totalDuration.seconds
                    }
                })
        }
    }

    private func configureAudioDevice() {
        if let audioDevice = AVCaptureDevice.default(for: .audio) {
            do {
                try configureDevice(audioDevice, for: .audio)
            } catch {
                print("[TruVideoSession]: ⚠️ failed to configure the audio device error: \(error).")
            }
        }
    }

    private func createSampleBufferFrom(pixelBuffer: CVPixelBuffer) -> CMSampleBuffer? {
        var sampleBuffer: CMSampleBuffer?

        var timimgInfo = CMSampleTimingInfo()
        var formatDescription: CMFormatDescription? = nil
        CMVideoFormatDescriptionCreateForImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: pixelBuffer,
            formatDescriptionOut: &formatDescription
        )
        CMSampleBufferCreateReadyWithImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: pixelBuffer,
            formatDescription: formatDescription!,
            sampleTiming: &timimgInfo,
            sampleBufferOut: &sampleBuffer
        )
        guard let buffer = sampleBuffer else {
            return nil
        }
        return buffer
    }

    private func handleVideoBuffer(_ sampleBuffer: CMSampleBuffer, in session: TruVideoSession) {
        if !session.hasConfiguredVideo || needsUpdateConfiguration {
            if /// Video settings
            let settings = videoConfiguration.avcaptureSettingsDictionary(sampleBuffer: sampleBuffer),

                /// Format description
                let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer)
            {

                if !session.configureVideo(
                    with: settings,
                    configuration: videoConfiguration,
                    formatDescription: formatDescription
                ) {
                    print("[TruVideoSession]: ⚠️ Could not setup video")
                } else {
                    needsUpdateConfiguration = false
                }
            }

            /// Notify delegate
        }

        if isRecording && session.hasConfiguredAudio && session.hasStartedRecording {
            beginNewClipIfNecessary()

            let minTimesBetweenFrames = 0.004
            let sleepDuration = minTimesBetweenFrames - CACurrentMediaTime() - lastVideoFrameTimeInterval
            if sleepDuration > 0 {
                Thread.sleep(forTimeInterval: sleepDuration)
            }

            lastVideoFrameTimeInterval = CACurrentMediaTime()

            if let bufferToProcess = CMSampleBufferGetImageBuffer(sampleBuffer),
                session.appendVideoBuffer(bufferToProcess)
            {
                DispatchQueue.main.async {
                    /// Notify delegate
                }

                Task {
                    await checkSessionDuration()
                }
            } else {
                DispatchQueue.main.async {
                    /// Notify delegate
                }
            }
        }
    }

    private func handleVideoBuffer(
        _ buffer: CVPixelBuffer,
        sampleBuffer: CMSampleBuffer,
        in session: TruVideoSession
    ) {
        videoConfiguration.swapDimensions = currentOrientation.swapDimensionsForVideo
        videoConfiguration.transform = currentOrientation.transform
        if !session.hasConfiguredVideo || needsUpdateConfiguration {
            if /// Video settings
            let settings = videoConfiguration.avcaptureSettingsDictionary(sampleBuffer: sampleBuffer),

                /// Format description
                let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer)
            {

                if !session.configureVideo(
                    with: settings,
                    configuration: videoConfiguration,
                    formatDescription: formatDescription
                ) {
                    print("[TruVideoSession]: ⚠️ Could not setup video")
                } else {
                    needsUpdateConfiguration = false
                }
            }
        }

        if isRecording && session.hasConfiguredAudio && session.hasStartedRecording {
            beginNewClipIfNecessary()

            if session.appendVideoBuffer(buffer) {
                Task {
                    await checkSessionDuration()
                }
            }
        }
    }

    private func removeInputs() {
        guard
            /// The current capture session
            let captureSession = captureSession,

            /// Capture device inputs
            let inputs = captureSession.inputs as? [AVCaptureDeviceInput]
        else { return }

        for input in inputs {
            captureSession.removeInput(input)
            if input.device.hasMediaType(.video) {
                /// remove observers
            }
        }

        videoInput = nil
        videoOutput = nil
    }

    private func removeOutputs() {
        guard let captureSession = captureSession else {
            return
        }

        if capturePhotoOutput != nil {
            // self.removeCaptureOutputObservers()
        }

        for output in captureSession.outputs {
            captureSession.removeOutput(output)
        }

        capturePhotoOutput = nil
        audioOutput = nil
        metadataOutput = nil
        videoOutput = nil
    }

    private func removeUnusedOuputs(for captureSession: AVCaptureSession) {
        switch captureMode {
        case .audio:
            if let audioOutput = audioOutput, captureSession.outputs.contains(audioOutput) {
                captureSession.removeOutput(audioOutput)
                self.audioOutput = nil
            }

        case .photo:
            if let audioOutput = audioOutput, captureSession.outputs.contains(audioOutput) {
                captureSession.removeOutput(audioOutput)
                self.audioOutput = nil
            }

            if let videoOutput = videoOutput, captureSession.outputs.contains(videoOutput) {
                captureSession.removeOutput(videoOutput)
                self.videoOutput = nil
            }

        case .video:
            if let capturePhotoOutput = capturePhotoOutput, captureSession.outputs.contains(capturePhotoOutput) {
                captureSession.removeOutput(capturePhotoOutput)
                self.capturePhotoOutput = nil
            }
        case .scanner:
            if let capturePhotoOutput = capturePhotoOutput, captureSession.outputs.contains(capturePhotoOutput) {
                captureSession.removeOutput(capturePhotoOutput)
                self.capturePhotoOutput = nil
            }
            if let audioOutput = audioOutput, captureSession.outputs.contains(audioOutput) {
                captureSession.removeOutput(audioOutput)
                self.audioOutput = nil
            }
        }
    }

    private func setupAVSession() throws {
        let captureSession = AVCaptureSession()
        captureSession.automaticallyConfiguresApplicationAudioSession = automaticallyConfiguresApplicationAudioSession

        self.captureSession = captureSession
        self.session = self.session ?? TruVideoSession(queue: sessionQueue)
        self.session?.outputDirectory = outputDirectory
        self.previewLayer.session = captureSession

        try configureSession()
        configureSessionDevices()
        observeSessionDuration()
        startAVSessionIfNeeded()
    }

    private func updateVideoOutputSettings() {
        guard let videoConnection = videoOutput?.connection(with: .video) else {
            return
        }

        videoConnection.automaticallyAdjustsVideoMirroring = devicePosition != .front
        if !videoConnection.automaticallyAdjustsVideoMirroring {
            videoConnection.isVideoMirrored = devicePosition == .front
        }

        if videoConnection.isVideoStabilizationSupported {
            videoConnection.preferredVideoStabilizationMode = videoStabilizationMode
        }
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

    @discardableResult
    func updateOutputVideoOrientation(to newOrientation: UIDeviceOrientation) -> Bool {
        guard let outputOrientation = getOutputOrientation(from: newOrientation) else { return false }
        var outputWasUpdated = true
        currentOrientation = newOrientation
        if let session = session,
            !session.currentClipHasAudio,
            !session.currentClipHasVideo,
            arRenderer == nil
        {
            session.reset()
        }

        if let previewConnection = previewLayer.connection,
            previewConnection.isVideoOrientationSupported
        {
            previewConnection.videoOrientation = getOutputOrientation(from: previewOrientation) ?? .portrait
        } else {
            outputWasUpdated = false
        }

        if /// The current capture photo output
        let capturePhotoOutput = capturePhotoOutput,
            /// Photo connection
            let photoConnection = capturePhotoOutput.connection(with: .video),
            photoConnection.isVideoOrientationSupported
        {
            photoConnection.videoOrientation = outputOrientation
        }

        if let videoConnection = videoOutput?.connection(with: .video),
            videoConnection.isVideoOrientationSupported
        {
            videoConnection.videoOrientation = outputOrientation
        }

        return outputWasUpdated
    }

    func focus(at point: CGPoint) {
        guard let device = requestedDevice ?? AVCaptureDevice.primaryVideoDevice(for: devicePosition) else {
            return
        }

        do {
            try device.lockForConfiguration()

            if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusPointOfInterest = point
                device.focusMode = .continuousAutoFocus
            }

            if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposurePointOfInterest = point
                device.exposureMode = .continuousAutoExposure
            }

            device.unlockForConfiguration()
        } catch {
            Logger.logError(event: .focus, eventMessage: .focusFailed(error: error))
        }
    }

    func handlePauseVideoRecording() {
        session?.handlePauseVideoRecording()
    }
}

extension TruVideoRecorder: AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {

    // MARK: AVCaptureAudioDataOutputSampleBufferDelegate & AVCaptureVideoDataOutputSampleBufferDelegate

    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let session else { return }
        switch output {
        case audioOutput:
            lastAudioFrame = sampleBuffer
            handleAudioBuffer(sampleBuffer, in: session)
        case videoOutput:
            lastVideoFrame = sampleBuffer
            handleVideoBuffer(sampleBuffer, in: session)
            if !isRunningSessionPublisher {
                isRunningSessionPublisher = true
            }
        default: break
        }
    }
}

extension TruVideoRecorder: AVCaptureMetadataOutputObjectsDelegate {

    // MARK: AVCaptureMetadataOutputObjectsDelegate

    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        let scannedCodesString = metadataObjects.compactMap { getText(from: $0) }
        guard let code = scannedCodesString.first else {
            return
        }
        scannedCode = code
    }

    private func getText(from metadataObject: AVMetadataObject) -> TruvideoSdkCameraScannerCode? {
        guard
            let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
            let stringValue = readableObject.stringValue
        else {
            return nil
        }
        switch readableObject.type {
        case .qr:
            return .init(data: stringValue, format: .codeQR)
        case .code39:
            return .init(data: stringValue, format: .code39)
        case .code93:
            return .init(data: stringValue, format: .code93)
        case .dataMatrix:
            return .init(data: stringValue, format: .dataMatrix)
        default:
            return nil
        }
    }
}

extension TruVideoRecorder: AVCapturePhotoCaptureDelegate {

    // MARK: AVCapturePhotoCaptureDelegate

    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {

        defer {
            photoContinuation = nil
        }

        if let error = error {
            photoContinuation?.resume(throwing: TruVideoError(kind: .failedToCapturePhoto, underlyingError: error))
            return
        }

        guard let data = photo.fileDataRepresentation() else {
            photoContinuation?.resume(
                throwing: TruVideoError(
                    kind: .failedToCapturePhoto,
                    underlyingError: TruVideoRecorderError.failedToGetPhotoDataRepresentation
                )
            )

            return
        }

        var metadata = photo.metadata
        metadata[TruVideoPhoto.DeviceOrientationKey] = currentOrientation
        TruVideoRecorder.tiffMetadata.forEach { key, value in
            metadata[key] = value
        }

        /// TODO: FIX ME this should not be here check for a way to fix rotations for front camera
        guard let image = UIImage(data: data) else { return }
        let outputURL = generateNextOutputURL()

        let imageData = transformImageData(image: image)
        savePhotoToURL(imageData: imageData, url: outputURL)

        let photo = TruVideoPhoto(
            imageData: imageData,
            croppedImageData: imageData,
            metadata: metadata,
            url: outputURL,
            lensFacing: getCurrentCameraLensFacing(),
            orientation: getCurrentOrientation(),
            resolution: image.resolution(for: currentOrientation),
            captureImage: image
        )

        photoContinuation?.resume(returning: photo)
    }

    private func generateNextOutputURL() -> URL {
        let imageFormatString = imageFormat.rawValue
        let filename = "\(identifier.uuidString)-TV-photo.\(photosCount).\(imageFormatString)"
        let nextOutputURL = outputDirectory.appendingPathComponent(filename)

        photosCount += 1
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
            print("[TruVideoSession]: 🛑 failed to save image: \(error.localizedDescription)")
        }
    }
}

extension UIImage {
    /// Determines the resolution of the camera output based on the specified device orientation.
    ///
    /// This function returns a `TruvideoSdkCameraResolution` instance, adjusting the resolution
    /// to match the orientation of the device. If the device is in landscape orientation,
    /// the width and height are swapped to ensure the resolution aligns with the landscape layout.
    /// For other orientations, the resolution reflects the default portrait layout.
    ///
    /// - Parameter orientation: The current orientation of the device as a `UIDeviceOrientation`.
    ///   - `.landscapeLeft`, `.landscapeRight`: The resolution is adjusted for landscape orientation.
    ///   - Other orientations (e.g., `.portrait`, `.portraitUpsideDown`): The resolution remains in portrait.
    /// - Returns: A `TruvideoSdkCameraResolution` instance representing the resolution in pixels.
    fileprivate func resolution(for orientation: UIDeviceOrientation) -> TruvideoSdkCameraResolution {
        let size = CGSize(width: size.width * scale, height: size.height * scale)

        switch orientation {
        case .landscapeLeft, .landscapeRight:
            return TruvideoSdkCameraResolution(width: Int32(size.height), height: Int32(size.width))

        default:
            return TruvideoSdkCameraResolution(width: Int32(size.width), height: Int32(size.height))
        }
    }
}
