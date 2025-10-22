//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation
import Combine
internal import DI
import Foundation
import UIKit
internal import Utilities

/// A concrete video capture device that configures inputs/outputs and manages lifecycle.
///
/// This class owns the active `AVCaptureDevice`, its corresponding input, and a video data output.
/// It applies sensible defaults (focus, exposure, white balance, low‑light boost), handles camera
/// position changes, torch control, and connection stabilization, and tracks a simple state machine.
class VideoDevice: NSObject, Device {
    // MARK: - Private Properties

    private let identifier = UUID()
    private var captureDevice: AVCaptureDevice?
    private var captureDeviceInput: AVCaptureDeviceInput?
    private let capturePhotoController: CapturePhotoController
    private var captureSession: AVCaptureSession?
    private var captureVideoDataOutput: AVCaptureVideoDataOutput?
    private var fileNameCount = 1
    private var focusObserver = FocusObserver()
    private let frameEncoder: FrameEncoder
    private let imageExporting: ImageExporting
    private var lastVideoBuffer: VideoSampleBuffer?
    private var needsConfiguration = true
    private let notificationCenter: NotificationCenter
    private var processors: [ObjectIdentifier: any VideoOutputProcessor] = [:]
    private let queue = DispatchQueue(label: "com.video.device.queue")
    private var videoOrientation = AVCaptureVideoOrientation.portrait
    private lazy var availableDevices: [AVCaptureDevice.Position: [AVCaptureDevice]] = [
        .back: AVCaptureDevice.availableVideoDevices(for: .back),
        .front: AVCaptureDevice.availableVideoDevices(for: .front)
    ]

    // MARK: - Dependencies

    @Dependency(\.orientationMonitor)
    private var orientationMonitor: OrientationMonitor

    // MARK: - Properties

    /// The video device configuration used to initialize and update capture parameters.
    ///
    /// Holds options such as desired resolution, frame rate, color space, and other
    /// format-related preferences that guide how the device is configured. This instance
    /// is created with sensible defaults and may be updated by higher-level APIs before
    /// applying changes to the underlying `AVCaptureDevice`/session.
    var configuration = VideoDeviceConfiguration()

    /// The flash mode to use during photo capture.
    ///
    /// This property determines how the camera's flash behaves when taking a photo.
    /// It can be set to different modes such as off, on, auto, or red-eye reduction
    /// to achieve the desired lighting effect for the captured image.
    var flashMode = AVCaptureDevice.FlashMode.off

    /// Output directory for the device.
    var outputDirectory = URL(fileURLWithPath: NSTemporaryDirectory())

    /// The preferred video stabilization mode applied to the active video connection.
    ///
    /// Defaults to `.auto`. The effective mode can vary depending on device capabilities,
    /// active format, and frame rate. Apply this to the connection (e.g., from a video
    /// output) after inputs/outputs are added to the session; the system may downgrade
    /// the mode when the requested one isn’t supported.
    private(set) var stabilizationMode = AVCaptureVideoStabilizationMode.auto

    /// The current lifecycle state of the video device.
    ///
    /// Starts as `.initialized` and transitions through `running`, `finished`, or `failed`
    /// according to the component’s workflow. See `State` for the allowed transitions
    /// enforced by the state machine.
    private(set) var state = RecordingState.initialized

    /// The current torch mode of the active capture device.
    ///
    /// Reflects the device’s `torchMode` (e.g., `.on`, `.off`, `.auto`). If no device is
    /// available, `.off` is returned.
    private(set) var torchMode = AVCaptureDevice.TorchMode.off

    // MARK: - Private Computed Properties

    private var hasBuiltInUltraWideCamera: Bool {
        availableDevices[position, default: []].contains { $0.deviceType == .builtInUltraWideCamera }
    }

    private var preferredDevice: AVCaptureDevice? {
        availableDevices[position]?.first
    }

    // MARK: - Computed Properties

    /// The current authorization status for video capture access.
    ///
    /// This computed property returns the current authorization status for video capture
    /// permissions. It provides a convenient way to check whether the app has permission
    /// to access the device's camera for video recording and preview.
    var authorizationStatus: AVAuthorizationStatus {
        AVCaptureDevice.authorizationStatus(for: .video)
    }

    /// The available zoom factor options that users can select from.
    ///
    /// This array defines the zoom levels that are available for selection in the camera
    /// interface. Each value represents a magnification factor.
    var displayVideoZoomFactors: [CGFloat] {
        guard let captureDevice else { return [] }

        let zoomFactors = stride(
            from: max(captureDevice.minAvailableVideoZoomFactor, Self.minZoomFactor),
            through: min(captureDevice.maxAvailableVideoZoomFactor, Self.maxZoomFactor),
            by: 1
        )

        return hasBuiltInUltraWideCamera ? [0.5] + Array(zoomFactors) : Array(zoomFactors)
    }

    /// Indicates whether the active capture device supports and currently exposes a usable flash.
    ///
    /// This computed property checks the device capabilities by combining `hasFlash` and `isFlashAvailable`
    /// from the underlying `AVCaptureDevice`. The flash availability can depend on several factors including
    /// the device hardware capabilities, active format settings, frame rate, and session configuration.
    ///
    /// Flash functionality is typically available on back-facing cameras but may not be present on
    /// front-facing cameras or certain device models. Even when hardware flash is present, it may
    /// become unavailable based on current camera settings or session configuration.
    var isFlashAvailable: Bool {
        captureDevice?.hasFlash == true && captureDevice?.isFlashAvailable == true
    }

    /// Indicates whether the active capture device supports and currently exposes a usable torch.
    ///
    /// This checks the device capabilities by combining `hasTorch` and `isTorchAvailable`.
    /// Some devices (e.g., most front cameras) do not have a torch. Torch availability can
    /// also depend on the active format, frame rate, and session configuration.
    ///
    /// - Returns: `true` if a torch is present and available for use; otherwise, `false`.
    var isTorchAvailable: Bool {
        captureDevice?.hasTorch == true && captureDevice?.isTorchAvailable == true
    }

    /// The physical position of the active capture device.
    ///
    /// Returns the `position` of `captureDevice` (e.g., `.back`, `.front`). If no device is
    /// currently set, `.back` is returned as a sensible default.
    ///
    /// - Returns: The current device position, or `.back` when no device is available.
    var position: AVCaptureDevice.Position {
        captureDevice?.position ?? .back
    }

    // MARK: - Static Properties

    /// The maximum supported zoom factor for video capture devices.
    ///
    /// This constant defines the upper limit of zoom magnification that can be
    /// applied to video capture devices. A zoom factor of 6.0 represents a
    /// 6x magnification, which provides significant telephoto capabilities
    /// for capturing distant subjects or detailed close-ups.
    static let maxZoomFactor: CGFloat = 6

    /// The minimum supported zoom factor for video capture devices.
    ///
    /// This constant defines the lower limit of zoom magnification that can be
    /// applied to video capture devices. A zoom factor of 0.5 represents a
    /// 0.5x magnification, which provides an ultra-wide field of view that
    /// captures more of the scene in a single frame.
    static let minZoomFactor: CGFloat = 1

    // MARK: - Notification Keys

    /// Key for accessing device position information in notification user info dictionaries.
    ///
    /// This string constant is used as a key in the user info dictionary of notifications
    /// related to device position changes. Observers can extract the current device position
    /// from the notification's user info using this key.
    nonisolated static let devicePosition = "com.truvideo.devicePosition"

    /// Notification name for when a new focus point has been set.
    ///
    /// This notification is posted when a camera device has been instructed to
    /// change its focus point to a new location. Observers can use this notification
    /// to track focus point changes and update UI elements accordingly, such as
    /// showing focus indicators or adjusting camera controls.
    nonisolated static let newFocusPoint = "com.truvideo.newFocusPoint"

    /// Key for accessing the new device position in notification user info dictionaries.
    ///
    /// This string constant is used as a key in the user info dictionary of notifications
    /// related to device position changes. Observers can extract the target device position
    /// that the camera is switching to from the notification's user info using this key.
    nonisolated static let newPosition = "com.truvideo.newPosition"

    /// Notification name for the previous focus point before a change occurred.
    ///
    /// This notification is posted when a camera device is about to change its
    /// focus point, providing information about the previous focus location.
    /// Observers can use this notification to track focus point transitions,
    /// maintain focus history, or perform cleanup operations related to the
    /// previous focus state.
    nonisolated static let oldFocusPoint = "com.truvideo.oldFocusPoint"

    /// Key for accessing the previous device position in notification user info dictionaries.
    ///
    /// This string constant is used as a key in the user info dictionary of notifications
    /// related to device position changes. Observers can extract the previous device position
    /// that the camera was using before the change from the notification's user info using this key.
    nonisolated static let oldPosition = "com.truvideo.oldPosition"

    // MARK: - Notification Names

    /// Notification sent when a device has successfully changed its focus point.
    ///
    /// This notification is posted after a device focus point change has been completed
    /// and the new focus point is active. Observers can use this notification to
    /// update UI elements, refresh device state, or perform any necessary
    /// post-focus-change operations.
    nonisolated static let deviceDidChangeFocusPoint = Notification.Name("com.truvideo.deviceDidChangeFocusPoint")

    /// Notification sent when a device has successfully changed its position.
    ///
    /// This notification is posted after a device position change has been completed
    /// and the new position is active. Observers can use this notification to
    /// update UI elements, refresh device state, or perform any necessary
    /// post-position-change operations.
    nonisolated static let deviceDidChangePosition = Notification.Name("com.truvideo.deviceDidChangePosition")

    /// Notification sent when a device is about to change its focus point.
    ///
    /// This notification is posted before a device focus point change begins,
    /// allowing observers to prepare for the upcoming change. This can be used
    /// to show loading indicators, disable certain UI elements, or perform
    /// pre-focus-change operations.
    nonisolated static let deviceWillChangeFocusPoint = Notification.Name("com.truvideo.deviceWillChangeFocusPoint")

    /// Notification sent when a device is about to change its position.
    ///
    /// This notification is posted immediately before a device position change
    /// begins, allowing observers to prepare for the upcoming change. Observers
    /// can use this notification to show loading indicators, disable UI elements,
    /// or perform any necessary pre-position-change operations.
    nonisolated static let deviceWillChangePosition = Notification.Name("com.truvideo.deviceWillChangePosition")

    // MARK: - Initializer

    /// Creates a new video device with notification center and thumbnail exporter.
    ///
    /// This initializer sets up the video device with configurable notification
    /// center and thumbnail exporting systems. The notification center is used for handling
    /// system notifications related to video capture events, while the thumbnail exporter
    /// is responsible for generating thumbnail images from captured photos.
    ///
    /// - Parameters:
    ///   - frameEncoder: The frame encoder to use for encoding sample buffers.
    ///   - imageExporting: The image exporter to use for generating images.
    ///   - notificationCenter: The notification center to use for system notifications.
    nonisolated init(
        frameEncoder: FrameEncoder = VideoBufferFrameEncoder(),
        imageExporting: ImageExporting = ImageExporter(),
        notificationCenter: NotificationCenter = .default
    ) {
        self.capturePhotoController = CapturePhotoController(imageExporting: imageExporting)
        self.frameEncoder = frameEncoder
        self.imageExporting = imageExporting
        self.notificationCenter = notificationCenter
    }

    // MARK: - Device

    /// Configures the device for use with the specified capture session.
    ///
    /// This function sets up the device with the necessary configuration to work with the given
    /// AVCaptureSession. It handles device initialization, format selection, and session integration
    /// to ensure the device is ready for capture operations.
    ///
    /// - Parameter session: The AVCaptureSession to configure the device with.
    /// - Throws: UtilityError if the device configuration fails or cannot be completed.
    @DeviceActor
    func configure(in session: AVCaptureSession) throws(UtilityError) {
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
            throw UtilityError(
                kind: .VideoDeviceErrorReason.notAuthorized,
                failureReason: "This app doesn’t have permission to use the video device."
            )
        }

        guard let videoCaptureDevice = captureDevice ?? availableDevices[position]?.first else {
            throw UtilityError(
                kind: .VideoDeviceErrorReason.captureDeviceNotFound,
                failureReason: "No video capture device was found. Ensure this device has a camera available."
            )
        }

        session.beginUpdates()

        defer { session.endUpdates() }

        do {
            captureDeviceInput = try session.addDeviceInput(for: videoCaptureDevice)
            captureVideoDataOutput = try session.addDeviceOutput()

            try capturePhotoController.configure(in: session)

            captureVideoDataOutput?.setSampleBufferDelegate(self, queue: queue)
            updateVideoOutputSettings()

            try videoCaptureDevice.configure()

            captureDevice = videoCaptureDevice
            captureSession = session
            needsConfiguration = false
        } catch {
            destroyDevice()
            state = .failed

            throw error
        }
    }

    /// Stops capture for this device and removes any installed inputs/outputs from the session.
    ///
    /// Implementations should safely detach inputs/outputs and perform any necessary cleanup.
    /// Prefer calling this while the session is inside a configuration block.
    ///
    /// - Parameter session: The `AVCaptureSession` from which to remove this device’s input/output.
    @DeviceActor
    func endCapturing(in session: AVCaptureSession) {
        if state.canTransition(to: .finished) {
            session.beginUpdates()
            defer { session.endUpdates() }

            destroyDevice()
            state = .finished
        }
    }

    /// Pauses capture for this device without removing it from the session.
    ///
    /// Implementations should temporarily stop processing or capturing data while maintaining
    /// the device's connection to the session. This allows for quick resumption of capture
    /// without the overhead of reconfiguring inputs/outputs.
    @DeviceActor
    func pause() {
        if state.canTransition(to: .paused) {
            do {
                if let captureDevice, captureDevice.torchMode != .off, captureDevice.isTorchAvailable {
                    try captureDevice.lockForConfiguration()
                    defer { captureDevice.unlockForConfiguration() }

                    captureDevice.torchMode = .off
                }
            } catch {
                // Log should be added here
                print(error)
            }

            state = .paused
        }
    }

    /// Requests permission to access the device's media capture capabilities.
    ///
    /// This asynchronous function prompts the user for permission to access the device's
    /// camera, microphone, or other media capture features. The result indicates whether
    /// access was granted or denied by the user.
    ///
    /// - Returns: `true` if access was granted, `false` if access was denied
    @discardableResult
    func requestAccess() async -> Bool {
        await AVCaptureDevice.requestAccess(for: .video)
    }

    /// Configures and starts capture for this device on the given session.
    ///
    /// Implementations typically validate authorization, resolve an `AVCaptureDevice`,
    /// install an `AVCaptureDeviceInput` and any required outputs, and update connection
    /// settings as needed. Prefer calling this while the session is inside a configuration block.
    ///
    /// - Parameter session: The `AVCaptureSession` to which inputs/outputs will be added.
    /// - Throws: An error if authorization is missing, if no suitable device is found, or if inputs/outputs cannot be
    /// added to the session due to incompatibility.
    @DeviceActor
    func startCapturing() throws(UtilityError) {
        if state.canTransition(to: .running) {
            guard !needsConfiguration else {
                throw UtilityError(
                    kind: .VideoDeviceErrorReason.needsConfiguration,
                    failureReason: "Device needs to be configured."
                )
            }

            state = .running

            if let captureDevice, captureDevice.isTorchAvailable {
                try setTorchMode(torchMode)
            }
        }
    }

    // MARK: - Instance methods

    /// Registers a processor by its reference identity.
    ///
    /// Stores the processor in the internal registry keyed by `ObjectIdentifier(processor)`,
    /// ensuring one entry per instance. Adding the same instance again replaces the existing entry.
    /// Requires `VideoOutputProcessor` to be class‑bound so it has stable reference identity.
    ///
    /// - Parameter processor: The processor instance to register.
    @DeviceActor
    func add(_ processor: any VideoOutputProcessor) {
        processors[ObjectIdentifier(processor)] = processor
    }

    /// Captures a photo using the configured camera device.
    ///
    /// This method captures a photo using the current camera configuration and settings.
    /// It first validates that the device is properly configured and running, then either
    /// captures a photo using the photo output delegate or falls back to a snapshot
    /// method if the device is not in a running state.
    ///
    /// - Returns: A `Photo` object containing the captured image data, or `nil` if capture fails
    /// - Throws: `UtilityError` with `.VideoDeviceErrorReason.failedToCapturePhoto` if the device needs configuration
    func capturePhoto() async throws -> Photo {
        guard !needsConfiguration else {
            throw UtilityError(
                kind: .VideoDeviceErrorReason.failedToCapturePhoto,
                failureReason: "Device needs to be configured."
            )
        }

        guard state == .running else {
            let configuration = CapturePhotoController.Configuration(
                deviceOrientation: AVCaptureVideoOrientation(from: orientationMonitor.currentOrientation.orientation),
                devicePosition: position,
                flashMode: flashMode,
                imageFormat: configuration.imageFormat,
                isHighResolutionEnabled: configuration.isHighResolutionEnabled,
                outputURL: nextOutputURL(),
                preset: configuration.preset
            )

            do {
                return try await capturePhotoController.capturePhoto(with: configuration)
            } catch {
                throw UtilityError(kind: .VideoDeviceErrorReason.failedToCapturePhoto, underlyingError: error)
            }
        }

        return try snapshot()
    }

    /// Unregisters a processor by its reference identity.
    ///
    /// Removes the entry keyed by `ObjectIdentifier(processor)`. If no matching instance
    /// is registered, this is a no‑op. Identity is based on the processor’s object reference,
    /// not value equality.
    ///
    /// - Parameter processor: The processor instance to remove.
    @DeviceActor
    func remove(_ processor: any VideoOutputProcessor) {
        processors.removeValue(forKey: ObjectIdentifier(processor))
    }

    /// Sets the focus and exposure point to the specified location on the camera view.
    ///
    /// This method configures both focus and exposure settings to use the same point,
    /// ensuring that the camera focuses on and meters exposure for the same area of the scene.
    /// The method automatically handles device locking and unlocking to prevent configuration
    /// conflicts during the focus and exposure adjustment process.
    ///
    /// - Parameter point: The normalized point (0.0 to 1.0) where focus and exposure should be set.
    /// - Throws: `UtilityError` with `.VideoDeviceErrorReason.setFocusPointFailed` if the
    ///   device configuration fails, including the underlying error for debugging purposes.
    @DeviceActor
    func setFocusPoint(at point: CGPoint) throws(UtilityError) {
        if let captureDevice {
            do {
                let oldFocusPoint = captureDevice.focusPointOfInterest
                notificationCenter.post(
                    Self.deviceWillChangeFocusPoint,
                    object: self,
                    userInfo: [Self.newFocusPoint: point]
                )

                try captureDevice.setFocusPoint(at: point)

                focusObserver.startObserving(captureDevice) { [weak self] captureDevice in
                    if let self {
                        self.focusObserver.stopObserving()
                        NotificationCenter.default.post(
                            Self.deviceDidChangeFocusPoint,
                            object: captureDevice,
                            userInfo: [
                                Self.oldFocusPoint: oldFocusPoint,
                                Self.newFocusPoint: captureDevice.focusPointOfInterest
                            ]
                        )
                    }
                }
            } catch {
                throw UtilityError(kind: .VideoDeviceErrorReason.setFocusPointFailed, underlyingError: error)
            }
        }
    }

    /// Switches the active camera to the specified physical position.
    ///
    /// If the position changes and a session/device are available, the current video input
    /// is removed, a new device is resolved for `newPosition`, and a fresh input is added.
    /// The video output connection settings (mirroring, stabilization) are then refreshed.
    ///
    /// - Parameter newPosition: The desired camera position (e.g., `.front`, `.back`).
    /// - Throws: An error  if the new input cannot be added.
    @DeviceActor
    func setPosition(_ newPosition: AVCaptureDevice.Position) throws(UtilityError) {
        if position != newPosition, let captureSession, let captureDevice = availableDevices[newPosition]?.first {
            self.captureDevice = captureDevice

            let oldPosition = position

            captureSession.beginUpdates()

            defer { captureSession.endUpdates() }

            notificationCenter.post(
                Self.deviceWillChangePosition,
                object: self,
                userInfo: [Self.devicePosition: oldPosition, Self.newPosition: newPosition]
            )

            captureDeviceInput = try captureSession.addDeviceInput(for: captureDevice)

            if /// The zoom factor of the next constituent device.
                let zoomFactor = captureDevice.virtualDeviceSwitchOverVideoZoomFactors.first,

                /// Whether the device is virtual and the position is back, since the back position resets the zoom
                /// factor.
                captureDevice.isVirtualDevice, position == .back {
                captureDevice.videoZoomFactor = zoomFactor.doubleValue
            }

            updateVideoOutputSettings()
            notificationCenter.post(
                Self.deviceDidChangePosition,
                object: self,
                userInfo: [Self.newPosition: newPosition, Self.oldPosition: oldPosition]
            )
        }
    }

    /// Sets the preferred video stabilization mode and applies it to the video connection.
    ///
    /// When supported by the active connection, the `preferredVideoStabilizationMode` is updated
    /// to match the requested `mode`. If not supported, the connection’s mode remains unchanged.
    ///
    /// - Parameter mode: The desired `AVCaptureVideoStabilizationMode` (e.g., `.auto`, `.standard`, `.cinematic`).
    @DeviceActor
    func setStabilizationMode(_ mode: AVCaptureVideoStabilizationMode) {
        stabilizationMode = mode
        capturePhotoController.setStabilizationMode(mode)
        updateVideoOutputSettings()
    }

    /// Changes the device torch mode.
    ///
    /// Validates support for the requested mode, locks the device for configuration, applies
    /// the new torch mode, and unlocks. If unsupported or configuration fails, an error is thrown.
    ///
    /// - Parameter mode: The desired `AVCaptureDevice.TorchMode` (e.g., `.on`, `.off`, `.auto`).
    /// - Throws:
    ///   - `UtilityError(kind: .VideoDeviceErrorReason.torchNotSupported)` if the mode is unsupported.
    ///   - `UtilityError(kind: .VideoDeviceErrorReason.torchModeFailed, underlyingError:)` on failure.
    @DeviceActor
    func setTorchMode(_ mode: AVCaptureDevice.TorchMode) throws(UtilityError) {
        if let captureDevice, captureDevice.isTorchAvailable {
            guard captureDevice.isTorchModeSupported(mode) else {
                throw UtilityError(
                    kind: .VideoDeviceErrorReason.torchNotSupported,
                    failureReason: "The torch mode selected is not supported by the device."
                )
            }

            guard state == .running else {
                torchMode = mode
                return
            }

            if captureDevice.torchMode != mode {
                do {
                    try captureDevice.lockForConfiguration()
                    defer { captureDevice.unlockForConfiguration() }

                    captureDevice.torchMode = mode
                    torchMode = mode
                } catch {
                    throw UtilityError(kind: .VideoDeviceErrorReason.torchModeFailed, underlyingError: error)
                }
            }
        }
    }

    /// Sets the video orientation for the capture session's video connection.
    ///
    /// This function configures the video orientation of the active video connection
    /// to ensure that captured video frames are properly oriented. It checks if
    /// the video connection exists and supports orientation changes before applying
    /// the new orientation setting.
    ///
    /// - Parameter orientation: The desired video orientation for the capture session
    @DeviceActor
    func setVideoOrientation(_ orientation: AVCaptureVideoOrientation) {
        videoOrientation = orientation
    }

    /// Sets the zoom factor for the video capture device.
    ///
    /// This method configures the zoom level of the video capture device by setting
    /// the `videoZoomFactor` property. The zoom factor determines how much the
    /// captured video is magnified, allowing users to zoom in on distant subjects
    /// or zoom out for wider shots.
    ///
    /// - Parameters:
    ///    - zoomFactor: The desired zoom factor to apply to the video capture.
    ///    - rate: The rate at which to transition to the new magnification factor, specified in powers of two per
    /// second.
    @DeviceActor
    func setZoomFactor(_ zoomFactor: CGFloat, rate: Float = 10) throws(UtilityError) {
        if let captureDevice, rate >= 0 {
            let minAvailableVideoZoomFactor = max(captureDevice.minAvailableVideoZoomFactor, Self.minZoomFactor)
            var maxAvailableVideoZoomFactor = min(captureDevice.maxAvailableVideoZoomFactor, Self.maxZoomFactor)

            do {
                try captureDevice.lockForConfiguration()
                defer { captureDevice.unlockForConfiguration() }

                var zoomFactor = hasBuiltInUltraWideCamera ? zoomFactor + 1 : zoomFactor

                maxAvailableVideoZoomFactor += hasBuiltInUltraWideCamera ? 1 : 0
                zoomFactor = min(max(zoomFactor, minAvailableVideoZoomFactor), maxAvailableVideoZoomFactor)

                if captureDevice.isRampingVideoZoom {
                    captureDevice.cancelVideoZoomRamp()
                }

                guard rate > 0 else {
                    captureDevice.videoZoomFactor = zoomFactor
                    return
                }

                captureDevice.ramp(toVideoZoomFactor: zoomFactor, withRate: rate)
            } catch {
                throw UtilityError(kind: .VideoDeviceErrorReason.setZoomFactorFailed, underlyingError: error)
            }
        }
    }

    // MARK: - Private methods

    private func destroyDevice() {
        if let captureSession {
            if let captureVideoDataOutput {
                captureVideoDataOutput.setSampleBufferDelegate(nil, queue: nil)
                captureSession.removeOutput(captureVideoDataOutput)

                self.captureVideoDataOutput = nil
            }

            if let captureDeviceInput {
                captureSession.removeInput(captureDeviceInput)

                self.captureDeviceInput = nil
            }

            capturePhotoController.destroy()
            captureDevice = nil
            needsConfiguration = true
        }
    }

    private func nextOutputURL() -> URL {
        let filename = "\(identifier)-TV-photo.\(fileNameCount).\(configuration.imageFormat.rawValue)"
        fileNameCount += 1

        return outputDirectory.appendingPathComponent(filename)
    }

    private func snapshot() throws(UtilityError) -> Photo {
        guard let lastVideoBuffer else {
            throw UtilityError(
                kind: .VideoDeviceErrorReason.failedToCapturePhoto,
                failureReason: "No video buffer available for photo capture"
            )
        }

        do {
            let outputURL = nextOutputURL()
            let thumbnailURL = outputURL.deletingPathExtension().appendingPathExtension("TV-photo-thumb.jpeg")
            let data = try frameEncoder.encode(lastVideoBuffer, format: configuration.imageFormat)

            try data.write(to: outputURL, options: .atomic)
            try imageExporting.createThumbnail(from: outputURL, to: thumbnailURL)

            return Photo(
                url: outputURL,
                thumbnailURL: thumbnailURL,
                format: configuration.imageFormat,
                lensPosition: position,
                orientation: UIDeviceOrientation(from: videoOrientation),
                preset: configuration.preset
            )
        } catch {
            throw UtilityError(
                kind: .VideoDeviceErrorReason.failedToCapturePhoto,
                underlyingError: error
            )
        }
    }

    private func updateVideoOutputSettings() {
        if let videoConnection = captureVideoDataOutput?.connection(with: .video) {
            videoConnection.automaticallyAdjustsVideoMirroring = false
            videoConnection.isVideoMirrored = false

            if videoConnection.isVideoStabilizationSupported {
                videoConnection.preferredVideoStabilizationMode = stabilizationMode
            }
        }
    }
}

extension VideoDevice: AVCaptureVideoDataOutputSampleBufferDelegate {
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        if let captureDevice, state == .running {
            let sampleBuffer = VideoSampleBuffer(
                bitRate: configuration.preset.bitRate,
                isMirrored: position == .front,
                orientation: videoOrientation,
                minFrameDuration: captureDevice.activeVideoMinFrameDuration,
                sampleBuffer: sampleBuffer
            )

            lastVideoBuffer = sampleBuffer

            Task {
                let processors = Array(processors.values)
                processors.forEach { $0.process(sampleBuffer, with: configuration) }
            }
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
    /// - Parameter captureDevice: The AVCaptureDevice to create an input for.
    /// - Returns: The newly created and configured AVCaptureDeviceInput.
    /// - Throws: An Error if the device input cannot be created or added to the session.
    fileprivate func addDeviceInput(for captureDevice: AVCaptureDevice) throws(UtilityError) -> AVCaptureDeviceInput {
        if let currentCaptureDeviceInput = captureDeviceInput(for: .video) {
            removeInput(currentCaptureDeviceInput)
        }

        let captureDeviceInput: AVCaptureDeviceInput

        do {
            captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
        } catch {
            throw UtilityError(kind: .VideoDeviceErrorReason.cannotAddInput, underlyingError: error)
        }

        guard canAddInput(captureDeviceInput) else {
            throw UtilityError(
                kind: .VideoDeviceErrorReason.cannotAddInput,
                failureReason: "Unable to add \(captureDeviceInput.debugDescription) to the session"
            )
        }

        addInput(captureDeviceInput)

        return captureDeviceInput
    }

    /// Creates and adds a video data output to the capture session.
    ///
    /// This function creates a default video data output using the system's recommended
    /// configuration and adds it to the current capture session. The function performs
    /// validation to ensure the output can be successfully added to the session before
    /// attempting the addition. If the output cannot be added, the function throws an
    /// appropriate error with detailed failure information for debugging purposes.
    ///
    /// - Returns: An `AVCaptureVideoDataOutput` instance that has been successfully
    ///            added to the capture session and is ready for video data processing.
    ///            The returned output is configured with default settings and can be
    ///            further customized for specific video processing requirements.
    ///
    /// - Throws: A `UtilityError` with `.VideoDeviceErrorReason.cannotAddOutput` kind
    ///           if the video data output cannot be added to the session, including
    ///           a detailed failure reason for debugging and error handling.
    fileprivate func addDeviceOutput() throws(UtilityError) -> AVCaptureVideoDataOutput {
        let captureVideoDataOutput = AVCaptureVideoDataOutput.createDefault()

        guard canAddOutput(captureVideoDataOutput) else {
            throw UtilityError(
                kind: .VideoDeviceErrorReason.cannotAddOutput,
                failureReason: "Unable to add \(captureVideoDataOutput.debugDescription) to the session"
            )
        }

        addOutput(captureVideoDataOutput)

        return captureVideoDataOutput
    }
}
