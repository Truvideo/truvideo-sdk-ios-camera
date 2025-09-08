//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation
import CoreImage
import Foundation
import UIKit
internal import Utilities

/// A lightweight wrapper that couples a video `CMSampleBuffer` with its presentation timestamp.
///
/// Use this type to pass samples through processing pipelines with an explicit, immutable
/// timestamp, avoiding repeated queries to the buffer’s timing info. The underlying buffer
/// is not copied; this struct only stores a reference.
struct VideoSampleBuffer {
    /// The nominal frame duration for the capture source.
    ///
    /// Typically the inverse of the target FPS (e.g., 1/24, 1/30). Used to pace processing,
    /// compute scaled frame durations, and maintain continuous timestamps. For variable‑frame‑rate
    /// streams this is a baseline reference and individual samples may deviate.
    let minFrameDuration: CMTime

    /// The underlying captured/decoded media sample.
    ///
    /// Contains the pixel data and timing/format metadata for this frame.
    /// The buffer is not owned or retained beyond normal ARC semantics.
    let sampleBuffer: CMSampleBuffer

    // MARK: - Computed Properties

    /// Returns the format description of the samples in a sample buffer.
    var formatDescription: CMFormatDescription? {
        CMSampleBufferGetFormatDescription(sampleBuffer)
    }

    /// Returns an image buffer that contains the media data.
    var imageBuffer: CVImageBuffer? {
        CMSampleBufferGetImageBuffer(sampleBuffer)
    }

    /// The sample’s presentation timestamp.
    ///
    /// Use this for ordering, synchronization with audio, and writer session timing.
    var timestamp: CMTime {
        sampleBuffer.presentationTimeStamp
    }
}

/// A class‑bound contract for components that consume video samples with access
/// to the active capture/encode configuration.
///
/// Conforming types are reference types to enable stable identity Implementations should
/// keep per‑frame work lightweight and offload heavy tasks to background queues to avoid
/// blocking the capture pipeline. The provided configuration is a read‑only snapshot of the
/// current device/encoding preferences and must not be mutated by processors.
protocol VideoOutputProcessor: AnyObject {
    /// Processes a single video sample using the provided configuration.
    ///
    /// Use the configuration to guide transformations (e.g., scaling, color space,
    /// orientation/transform, target bitrate hints) while relying on the sample’s
    /// timing for ordering. This method is expected to run on the component’s serialization context
    ///
    /// - Parameters:
    ///   - buffer: The video sample to process.
    ///   - configuration: A snapshot of capture/encoding preferences to inform processing.
    func process(_ buffer: VideoSampleBuffer, with configuration: VideoDeviceConfiguration)
}

// TODO:
// 1. We should be setting session presset instead
// 2. Reset focus on move

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
    private var captureSession: AVCaptureSession?
    private var captureVideoDataOutput: AVCaptureVideoDataOutput?
    private let context = CIContext.createDefault()
    private var continuation: CheckedContinuation<Photo?, Error>?
    private var fileNameCount = 1
    private var focusObserver = FocusObserver()
    private var lastVideoBuffer: VideoSampleBuffer?
    private var needsConfiguration = true
    private let notificationCenter: NotificationCenter
    private var capturePhotoOutput: AVCapturePhotoOutput?
    private var processors: [ObjectIdentifier: any VideoOutputProcessor] = [:]
    private var supportedFormats: [AVCaptureDevice.Position: [Format]] = [:]
    private let queue = DispatchQueue(label: "com.video.device.queue")
    private lazy var availableDevices: [AVCaptureDevice.Position: [AVCaptureDevice]] = {
        [
            .back: AVCaptureDevice.availableVideoDevices(for: .back),
            .front: AVCaptureDevice.availableVideoDevices(for: .front),
        ]
    }()

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

    /// The currently active video format for this device.
    ///
    /// This property stores the `VideoDevice.Format` instance that is currently
    /// configured and active on the video capture device. It represents the
    /// resolution, frame rate capabilities, HDR support, and other format-specific
    /// properties that are currently in use.
    private(set) var format: VideoDevice.Format?

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
        guard let captureDevice else {
            return []
        }

        let zoomFactors = stride(
            from: max(captureDevice.minAvailableVideoZoomFactor, Self.minZoomFactor),
            through: min(captureDevice.maxAvailableVideoZoomFactor, Self.maxZoomFactor),
            by: 1
        )

        return hasBuiltInUltraWideCamera ? [0.5] + Array(zoomFactors) : Array(zoomFactors)
    }

    /// Returns an array of supported video formats for the current device position.
    ///
    /// This computed property provides access to all available video formats that
    /// the capture device supports at the specified position (front or back camera).
    var formats: [Format] {
        guard let captureDevice else {
            return []
        }

        let formats = supportedFormats[position] ?? captureDevice.formats.map(Format.from)

        if supportedFormats[position] == nil {
            supportedFormats[position] = formats
        }

        return formats
    }

    /// Indicates whether the active capture device supports and currently exposes a usable torch.
    ///
    /// This checks the device capabilities by combining `hasTorch` and `isTorchAvailable`.
    /// Some devices (e.g., most front cameras) do not have a torch. Torch availability can
    /// also depend on the active format, frame rate, and session configuration.
    ///
    /// - Returns: `true` if a torch is present and available for use; otherwise, `false`.
    var isTorchAvailable: Bool {
        captureDevice?.hasTorch == true || captureDevice?.isTorchAvailable == true
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

    // MARK: - Types

    /// Represents a camera format with its capabilities and supported features.
    ///
    /// This struct encapsulates all the important properties of an `AVCaptureDevice.Format`
    /// in a more accessible and type-safe manner. It provides easy access to resolution,
    /// frame rates, HDR support, and various camera capabilities.
    struct Format: Equatable {
        /// The underlying `AVCaptureDevice.Format` that this struct represents.
        ///
        /// This is the original format object from AVFoundation that contains all the
        /// low-level configuration details.
        let format: AVCaptureDevice.Format

        /// Indicates whether this format supports High Dynamic Range (HDR) recording.
        ///
        /// HDR formats provide better color reproduction and dynamic range compared to
        /// standard formats. This is especially beneficial in high-contrast scenes.
        let isVideoHDRSupported: Bool

        /// The maximum frame rate supported by this format.
        ///
        /// This represents the highest number of frames per second that can be captured
        /// using this format. Higher frame rates provide smoother motion but require
        /// more processing power.
        let maxFrameRate: Double

        /// The minimum frame rate supported by this format.
        ///
        /// This represents the lowest number of frames per second that can be captured
        /// using this format. Lower frame rates can help save battery and reduce
        /// processing load.
        let minFrameRate: Double

        /// The maximum zoom factor supported by this format.
        ///
        /// This represents how much the camera can zoom in while maintaining quality.
        /// Higher zoom factors allow for closer shots but may reduce image quality.
        let maxZoomFactor: Double

        /// The dimensions of this format in points.
        ///
        /// This represents the width and height of the video frames that will be
        /// captured using this format. Larger sizes provide higher resolution but
        /// require more storage and processing power.
        let size: CGSize

        // MARK: - Static methods

        /// Creates a `Format` instance from an `AVCaptureDevice.Format`.
        ///
        /// This factory method extracts all the relevant properties from an AVFoundation
        /// format and creates a `Format` instance with the extracted values. It provides
        /// a convenient way to convert AVFoundation formats into the custom `Format` type
        /// without needing to manually extract each property.
        ///
        /// - Parameter format: The `AVCaptureDevice.Format` to convert.
        /// - Returns: A new `Format` instance containing the extracted properties.
        static func from(_ format: AVCaptureDevice.Format) -> Format {
            let dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)

            return Format(
                format: format,
                isVideoHDRSupported: format.isVideoHDRSupported,
                maxFrameRate: format.videoSupportedFrameRateRanges.map(\.maxFrameRate).max() ?? 30,
                minFrameRate: format.videoSupportedFrameRateRanges.map(\.minFrameRate).min() ?? 1,
                maxZoomFactor: format.videoMaxZoomFactor,
                size: CGSize(width: Int(dimensions.width), height: Int(dimensions.height))
            )
        }
    }

    // MARK: - Initializer

    /// Creates a new instance of the `VideoDevice`.
    nonisolated init(notificationCenter: NotificationCenter = .default) {
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

        session.beginConfiguration()

        defer { session.commitConfiguration() }

        do {
            captureDeviceInput = try session.addDeviceInput(for: videoCaptureDevice)
            captureVideoDataOutput = try session.addDeviceOutput()
            capturePhotoOutput = try session.addPhotoOutput()

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
        session.beginConfiguration()
        defer { session.commitConfiguration() }

        if state.canTransition(to: .finished) {
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
    /// - Throws: An error if authorization is missing, if no suitable device is found, or if inputs/outputs cannot be added to the session due to incompatibility.
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
    func capturePhoto() async throws -> Photo? {
        guard !needsConfiguration else {
            throw UtilityError(
                kind: .VideoDeviceErrorReason.failedToCapturePhoto,
                failureReason: "Device needs to be configured."
            )
        }

        guard state == .running else {
            return try await withCheckedThrowingContinuation { continuation in
                Task {
                    guard let capturePhotoOutput else {
                        return continuation.resume(returning: nil)
                    }

                    let capturePhotoSettings = AVCapturePhotoSettings.from(configuration)

                    capturePhotoOutput.isHighResolutionCaptureEnabled = configuration.isHighResolutionEnabled
                    capturePhotoSettings.flashMode = flashMode

                    self.continuation = continuation
                    await MainActor.run {
                        capturePhotoOutput.capturePhoto(with: capturePhotoSettings, delegate: self)
                    }
                }
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
                                Self.newFocusPoint: captureDevice.focusPointOfInterest,
                            ]
                        )
                    }
                }
            } catch {
                throw UtilityError(kind: .VideoDeviceErrorReason.setFocusPointFailed, underlyingError: error)
            }
        }
    }

    /// Sets the active format and frame rate for the video capture device.
    ///
    /// This method configures the device to use a specific video format with a consistent
    /// frame rate. It validates that the format is supported by the device before applying
    /// the configuration, ensuring compatibility and preventing runtime errors.
    ///
    /// - Parameter format: The `Format` instance containing the desired video format and frame rate capabilities.
    /// - Throws: `UtilityError` with `.VideoDeviceErrorReason.setFormatFailed` if the
    ///           format is not supported by the device or if the configuration fails.
    @DeviceActor
    func setFormat(_ format: Format) throws(UtilityError) {
        // TODO: We should be setting session presset instead
        if let captureDevice {
            guard captureDevice.formats.contains(format.format) else {
                throw UtilityError(
                    kind: .VideoDeviceErrorReason.setFormatFailed,
                    failureReason: "Format not supported by device."
                )
            }

            do {
                try captureDevice.lockForConfiguration()

                defer { captureDevice.unlockForConfiguration() }

                let frameDuration = CMTime(value: 1, timescale: Int32(format.maxFrameRate))

                captureDevice.activeFormat = format.format
                captureDevice.activeVideoMinFrameDuration = frameDuration
                captureDevice.activeVideoMaxFrameDuration = frameDuration

                self.format = format
            } catch {
                throw UtilityError(kind: .VideoDeviceErrorReason.setFormatFailed, underlyingError: error)
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
        if position != newPosition {
            captureDevice = availableDevices[newPosition]?.first

            if /// The active session.
            let captureSession,

                /// The active device.
                let captureDevice
            {

                let oldPosition = position

                notificationCenter.post(
                    Self.deviceWillChangePosition,
                    object: self,
                    userInfo: [Self.devicePosition: oldPosition, Self.newPosition: newPosition]
                )

                captureSession.beginConfiguration()

                defer { captureSession.commitConfiguration() }

                captureDeviceInput = try captureSession.addDeviceInput(for: captureDevice)

                if /// The zoom factor of the next constituent device.
                let zoomFactor = captureDevice.virtualDeviceSwitchOverVideoZoomFactors.first,

                    /// Whether the device is virtual and the position is back, since the back position resets the zoom factor.
                    captureDevice.isVirtualDevice, position == .back
                {

                    if let zoomFactor = captureDevice.virtualDeviceSwitchOverVideoZoomFactors.first {
                        captureDevice.videoZoomFactor = zoomFactor.doubleValue
                    }
                }

                updateVideoOutputSettings()
                notificationCenter.post(
                    Self.deviceDidChangePosition,
                    object: self,
                    userInfo: [Self.newPosition: newPosition, Self.oldPosition: oldPosition]
                )
            }
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
        if /// The current video connection.
        let videoConnection = captureVideoDataOutput?.connection(with: .video),

            /// Whether the connection supports orientation.
            videoConnection.isVideoOrientationSupported
        {

            videoConnection.videoOrientation = orientation
        }
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
    ///    - rate: The rate at which to transition to the new magnification factor, specified in powers of two per second.
    @DeviceActor
    func setZoomFactor(_ zoomFactor: CGFloat, rate: Float = 200) throws(UtilityError) {
        if let captureDevice {
            var adjustedZoomFactor = zoomFactor
            let minAvailableVideoZoomFactor = max(captureDevice.minAvailableVideoZoomFactor, Self.minZoomFactor)
            let maxAvailableVideoZoomFactor = min(captureDevice.maxAvailableVideoZoomFactor, Self.maxZoomFactor)

            if adjustedZoomFactor < 0 {
                adjustedZoomFactor = minAvailableVideoZoomFactor
            } else {
                adjustedZoomFactor += hasBuiltInUltraWideCamera ? 1 : 0
            }

            do {
                try captureDevice.lockForConfiguration()
                defer { captureDevice.unlockForConfiguration() }

                let clampedZoomFactor = min(
                    max(adjustedZoomFactor, minAvailableVideoZoomFactor),
                    maxAvailableVideoZoomFactor
                )

                captureDevice.ramp(toVideoZoomFactor: clampedZoomFactor, withRate: rate)
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

            if let capturePhotoOutput {
                captureSession.removeOutput(capturePhotoOutput)

                self.capturePhotoOutput = nil
            }

            captureDevice = nil
        }
    }

    private func nextOutputURL() -> URL {
        let filename = "\(identifier)-TV-photo.\(fileNameCount).\(configuration.imageFormat.rawValue)"
        fileNameCount += 1

        return outputDirectory.appendingPathComponent(filename)
    }

    private func snapshot() throws(UtilityError) -> Photo? {
        guard
            /// The Image context to use when capturing the photo.
            let context,

            /// The current capture device.
            let captureDevice,

            /// The last captured video buffer.
            let sampleBuffer = lastVideoBuffer?.sampleBuffer
        else {

            throw UtilityError(
                kind: .VideoDeviceErrorReason.failedToCapturePhoto,
                failureReason: "Unable to get data representation of the photo."
            )
        }

        let metadata = [
            kCGImagePropertyTIFFSoftware as String: truVideoMetadataTitle,
            kCGImagePropertyTIFFArtist as String: truVideoMetadataArtist,
            kCGImagePropertyTIFFDateTime as String: ISO8601DateFormatter().string(from: Date()),
        ]

        sampleBuffer.append(metadataAdditions: metadata)

        guard
            /// The image extracted from the buffer.
            let image = context.createImage(from: sampleBuffer),

            /// The data representation of the image in the specified format.
            let data = image.data(with: configuration.imageFormat)
        else {

            throw UtilityError(
                kind: .VideoDeviceErrorReason.failedToCapturePhoto,
                failureReason: "Unable to get data representation of the photo."
            )
        }

        do {
            let outputURL = nextOutputURL()
            let videoConnection = captureVideoDataOutput?.connection(with: .video)

            try data.write(to: outputURL, options: .atomic)

            return Photo(
                url: outputURL,
                format: configuration.imageFormat,
                lensPosition: position,
                orientation: UIDeviceOrientation(from: videoConnection?.videoOrientation ?? .portrait)
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
            videoConnection.automaticallyAdjustsVideoMirroring = position != .front

            if !videoConnection.automaticallyAdjustsVideoMirroring {
                videoConnection.isVideoMirrored = position == .front
            }

            if videoConnection.isVideoStabilizationSupported {
                videoConnection.preferredVideoStabilizationMode = stabilizationMode
            }
        }
    }
}

extension VideoDevice: AVCapturePhotoCaptureDelegate {

    // MARK: - AVCapturePhotoCaptureDelegate

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        defer {
            continuation = nil
        }

        if let continuation, let captureDevice {
            if let error {
                let error = UtilityError(kind: .VideoDeviceErrorReason.failedToCapturePhoto, underlyingError: error)

                continuation.resume(throwing: error)
                return
            }

            do {
                let data = try photo.imageData(with: configuration.imageFormat)
                let outputURL = nextOutputURL()
                let videoConnection = captureVideoDataOutput?.connection(with: .video)
                let photo = Photo(
                    url: outputURL,
                    format: configuration.imageFormat,
                    lensPosition: captureDevice.position,
                    orientation: UIDeviceOrientation(from: videoConnection?.videoOrientation ?? .portrait)
                )

                try data.write(to: outputURL, options: .atomic)

                continuation.resume(returning: photo)
            } catch {
                let error = UtilityError(kind: .VideoDeviceErrorReason.failedToCapturePhoto, underlyingError: error)
                continuation.resume(throwing: error)
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

extension AVCapturePhoto {
    /// Converts the photo to the specified file format and returns the data representation.
    ///
    /// This function processes the captured photo data according to the requested file format.
    /// For HEIC and JPEG formats, it returns the original data representation directly.
    /// For PNG format, it converts the data to a UIImage and then generates PNG data,
    /// which may involve format conversion and re-encoding.
    ///
    /// The function handles format-specific processing requirements, ensuring that
    /// the output data is properly encoded for the target format. PNG conversion
    /// requires additional processing steps compared to the other formats.
    ///
    /// - Parameter fileFormat: The desired output format for the photo data
    /// - Returns: The photo data encoded in the specified format
    /// - Throws: A UtilityError if the data representation cannot be obtained or if PNG conversion fails
    fileprivate func imageData(with fileFormat: FileFormat) throws(UtilityError) -> Data {
        guard let data = fileDataRepresentation() else {
            throw UtilityError(
                kind: .VideoDeviceErrorReason.failedToCapturePhoto,
                failureReason: "Unable to get data representation of the photo."
            )
        }

        guard fileFormat == .png else {
            return data
        }

        guard let data = UIImage(data: data)?.pngData() else {
            throw UtilityError(
                kind: .VideoDeviceErrorReason.failedToCapturePhoto,
                failureReason: "Unable to get data representation of the photo."
            )
        }

        return data
    }
}

extension AVCapturePhotoSettings {
    /// Creates an `AVCapturePhotoSettings` instance from a video device configuration.
    ///
    /// This method converts a `VideoDeviceConfiguration` into the corresponding
    /// `AVCapturePhotoSettings` object used by the camera capture system. It configures
    /// the photo settings with the specified image format, quality settings, and
    /// resolution options from the configuration object.
    ///
    /// - Parameter configuration: The video device configuration containing image format and quality settings
    /// - Returns: A configured `AVCapturePhotoSettings` instance ready for photo capture
    fileprivate static func from(_ configuration: VideoDeviceConfiguration) -> AVCapturePhotoSettings {
        let capturePhotoSettings = AVCapturePhotoSettings(
            rawPixelFormatType: 0,
            rawFileType: nil,
            processedFormat: [
                AVVideoCodecKey: configuration.imageFormat.codec,
                AVVideoCompressionPropertiesKey: [
                    AVVideoQualityKey: NSNumber(value: configuration.imageFormat.quality)
                ],
            ],
            processedFileType: configuration.imageFormat.fileType
        )

        capturePhotoSettings.isHighResolutionPhotoEnabled = configuration.isHighResolutionEnabled
        capturePhotoSettings.photoQualityPrioritization = .balanced

        return capturePhotoSettings
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

    /// Adds a photo output to the capture session for photo capture functionality.
    ///
    /// This method creates and adds an `AVCapturePhotoOutput` to the capture session,
    /// enabling photo capture capabilities. It validates that the output can be added
    /// to the session before attempting to add it, throwing an error if the addition
    /// fails due to session constraints or configuration issues.
    ///
    /// - Returns: An `AVCapturePhotoOutput` instance that has been successfully
    ///            added to the capture session and is ready for video data processing.
    /// - Throws: `UtilityError` with `.PhotoDeviceErrorReason.cannotAddOutput` if the photo output cannot be added to the session
    fileprivate func addPhotoOutput() throws(UtilityError) -> AVCapturePhotoOutput {
        let capturePhotoOutput = AVCapturePhotoOutput()

        if canAddOutput(capturePhotoOutput) {
            addOutput(capturePhotoOutput)
        } else {
            throw UtilityError(
                kind: .VideoDeviceErrorReason.cannotAddOutput,
                failureReason: "Unable to add \(capturePhotoOutput.debugDescription) to the session."
            )
        }

        return capturePhotoOutput
    }
}

extension UIImage {
    /// Converts the image to the specified file format and returns the data representation.
    ///
    /// This function converts the UIImage to the requested file format using the
    /// appropriate encoding method. For HEIC format, it uses the native heicData()
    /// method on iOS 17+ and falls back to JPEG compression on older iOS versions.
    /// JPEG format uses configurable compression quality, while PNG format uses
    /// lossless compression without quality settings.
    ///
    /// - Parameter fileFormat: The desired output format for the image data
    /// - Returns: The image data encoded in the specified format, or nil if
    ///           the conversion process fails
    fileprivate func data(with fileFormat: FileFormat) -> Data? {
        switch fileFormat {
        case .heic:
            if #available(iOS 17.0, *) {
                return heicData()
            } else {
                return jpegData(compressionQuality: fileFormat.quality)
            }

        case .jpeg:
            return jpegData(compressionQuality: fileFormat.quality)

        case .png:
            return pngData()
        }
    }
}
