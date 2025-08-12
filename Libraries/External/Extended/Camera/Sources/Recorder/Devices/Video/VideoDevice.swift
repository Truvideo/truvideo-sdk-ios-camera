//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation
import Foundation
import Utilities

extension ErrorReason {
    /// A collection of error reasons related to the video device operations.
    ///
    /// The `VideoDeviceErrorReason` struct provides a set of static constants representing various errors that can occur
    /// during interactions with the external devices.
    struct VideoDeviceErrorReason: Sendable {
        /// The capture input could not be added to the session.
        ///
        /// Typical causes:
        /// - The session preset/active device format is incompatible with the input
        /// - `canAddInput(_:)` returned `false` (e.g., too many inputs or unsupported multi‑camera)
        /// - Authorization not granted
        /// - Configuration performed outside `beginConfiguration()/commitConfiguration()`
        static let cannotAddInput = ErrorReason(rawValue: "CANNOT_ADD_VIDEO_INPUT")

        /// The capture output could not be added to the session.
        ///
        /// Typical causes:
        /// - `canAddOutput(_:)` returned `false` due to preset/format incompatibility
        /// - Conflicting outputs (e.g., multi‑camera constraints)
        /// - Output settings (pixel format, stabilization) incompatible with the active format
        static let cannotAddOutput = ErrorReason(rawValue: "CANNOT_ADD_VIDEO_OUTPUT")

        /// No matching video capture device was found.
        ///
        /// Typical causes:
        /// - Requested position/type isn’t available (e.g., telephoto on older devices)
        /// - Running in Simulator (no camera hardware)
        /// - Multi‑camera requested on an unsupported device
        static let captureDeviceNotFound = ErrorReason(rawValue: "CAPTURE_VIDEO_DEVICE_NOT_FOUND")

        /// The app is not authorized to use the video device.
        static let notAuthorized = ErrorReason(rawValue: "VIDEO_DEVICE_NOT_AUTHORIZED")

        /// Setting the torch mode failed.
        ///
        /// Typical causes:
        /// - Device does not have a torch or it’s currently unavailable
        /// - Device not locked with `lockForConfiguration()`
        /// - Requested mode not supported under current format/frame rate
        static let torchModeFailed = ErrorReason(rawValue: "TORCH_MODE_FAILED")

        /// The active device does not support a torch.
        ///
        /// Context:
        /// - Most front cameras lack a torch
        /// - Some formats/presets may disable torch availability
        static let torchNotSupported = ErrorReason(rawValue: "TORCH_NOT_SUPPORTED")

        /// The device could not be locked for configuration.
        ///
        /// Typical causes:
        /// - Another client holds the configuration lock
        /// - The device is busy (e.g., starting/stopping session)
        /// - System interruptions (backgrounding, media services reset)
        static let unableToLockDeviceForConfiguration = ErrorReason(rawValue: "UNABLE_TO_LOCK_DEVICE_FOR_CONFIGURATION")
    }
}

/// A lightweight wrapper that couples a video `CMSampleBuffer` with its presentation timestamp.
///
/// Use this type to pass samples through processing pipelines with an explicit, immutable
/// timestamp, avoiding repeated queries to the buffer’s timing info. The underlying buffer
/// is not copied; this struct only stores a reference.
struct VideoSampleBuffer {
    /// The underlying captured/decoded media sample.
    ///
    /// Contains the pixel data and timing/format metadata for this frame.
    /// The buffer is not owned or retained beyond normal ARC semantics.
    let buffer: CMSampleBuffer

    /// The nominal frame duration for the capture source.
    ///
    /// Typically the inverse of the target FPS (e.g., 1/24, 1/30). Used to pace processing,
    /// compute scaled frame durations, and maintain continuous timestamps. For variable‑frame‑rate
    /// streams this is a baseline reference and individual samples may deviate.
    let minFrameDuration: CMTime

    /// The sample’s presentation timestamp.
    ///
    /// Use this for ordering, synchronization with audio, and writer session timing.
    let timestamp: CMTime
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

/// A configurable set of video capture and encoding parameters used by the camera pipeline.
///
/// This structure centralizes the knobs that affect capture resolution/aspect, codec, bitrate,
/// key‑frame cadence, scaling behavior, orientation transform, and optional time constraints.
/// These values inform both device/session configuration (e.g., aspect ratio, dimensions) and
/// encoder configuration (e.g., codec, profile level, bitrate) via AVFoundation settings dictionaries.
struct VideoDeviceConfiguration: Sendable {
    /// The desired output aspect ratio policy.
    ///
    /// When set to `.active` (default), the pipeline respects either a preset or explicit
    /// dimensions already chosen elsewhere (e.g., by a higher‑level `TruVideoConfiguration`).
    /// Other values (e.g., `.widescreen`, `.square`, `.custom`) guide how width/height
    /// are derived when building encoder settings if explicit `dimensions` are not provided.
    var aspectRatio = AspectRatio.active

    /// Target average video bitrate, in bits per second.
    ///
    /// This maps to `AVVideoAverageBitRateKey` in the compression properties dictionary.
    /// Higher bitrates improve quality at the cost of larger files and bandwidth.
    /// Typical mobile values range from 2–8 Mbps depending on resolution and content.
    var bitRate = videoBitRateDefault

    /// The codec used to encode video frames.
    ///
    /// This maps to `AVVideoCodecKey`. Defaults to H.264 (`.h264`) for broad device compatibility.
    /// For HEVC (`.hevc`) you may achieve better efficiency on supported hardware.
    var codec = AVVideoCodecType.h264

    /// Explicit output dimensions (width × height) in pixels, if overriding.
    ///
    /// When `nil`, dimensions are inferred from an input `CMSampleBuffer`/`CVPixelBuffer`
    /// and shaped by `aspectRatio`. When set, these values take precedence.
    var dimensions: CGSize?

    /// An optional maximum capture duration.
    ///
    /// When provided, the recording session should stop automatically once this duration elapses.
    /// Represented as `CMTime` to align with AVFoundation timing semantics.
    var maximumCaptureDuration: CMTime?

    /// Maximum interval between key frames (GOP length).
    ///
    /// Maps to `AVVideoMaxKeyFrameIntervalKey`. A value of `1` produces key‑frames only,
    /// increasing compatibility at the expense of larger files. Typical values are 24–60,
    /// aligning with expected frame rates.
    var maxKeyFrameInterval = 30

    /// The H.264 profile level to use when `codec == .h264`.
    ///
    /// Maps to `AVVideoProfileLevelKey`. Defaults to `AVVideoProfileLevelH264HighAutoLevel`.
    /// Ensure the selected level is supported by the target devices and desired resolution/fps.
    var profileLevel = AVVideoProfileLevelH264HighAutoLevel

    /// The scaling mode applied by the video encoder when resizing.
    ///
    /// Maps to `AVVideoScalingModeKey`. Common values include:
    /// - `AVVideoScalingModeResizeAspectFill`
    /// - `AVVideoScalingModeResizeAspect`
    /// - `AVVideoScalingModeResize`
    /// - `AVVideoScalingModeFit`
    var scalingMode = AVVideoScalingModeResizeAspectFill

    /// A transform applied to the encoded video for display orientation or rotation correction.
    ///
    /// Defaults to identity. Use to rotate or flip the output as needed to match UI orientation
    /// or to normalize device orientation at encode time.
    var transform = CGAffineTransform.identity

    // MARK: - Static Properties

    /// The default average video bitrate (2 Mbps).
    ///
    /// A balanced mobile default suitable for 720p–1080p with moderate motion. Adjust upward
    /// for complex scenes or higher resolutions; reduce for bandwidth‑constrained scenarios.
    static let videoBitRateDefault: Int = 2_000_000

    // MARK: - Types

    /// A high‑level aspect policy used to derive or enforce output dimensions.
    ///
    /// When `dimensions` are not explicitly set, these cases guide the width/height computed
    /// from input media characteristics (e.g., a `CMSampleBuffer`’s format description).
    enum AspectRatio {
        /// Use the active preset or previously determined dimensions (default).
        case active

        /// 2.35:1 cinematic (width 2.35, height 1).
        case cinematic

        /// A custom, caller‑provided aspect ratio.
        case custom(size: CGSize)

        /// 1:1 square.
        case square

        /// 3:4 (portrait).
        case standard

        /// 4:3 (landscape).
        case standardLandscape

        /// 9:16 (portrait widescreen).
        case widescreen

        /// 16:9 (landscape widescreen).
        case widescreenLandscape

        // MARK: - Computed Properties

        /// The unit dimensions that describe the aspect ratio, when applicable.
        ///
        /// - Returns: A unit rectangle (e.g., 16×9) representing the aspect ratio,
        ///   or `nil` for `.active` where external dimensions/presets apply.
        var dimensions: CGSize? {
            switch self {
            case .active:
                return nil

            case .cinematic:
                return CGSize(width: 2.35, height: 1)

            case .custom(let size):
                return size

            case .square:
                return CGSize(width: 1, height: 1)

            case .standard:
                return CGSize(width: 3, height: 4)

            case .standardLandscape:
                return CGSize(width: 4, height: 3)

            case .widescreen:
                return CGSize(width: 9, height: 16)

            case .widescreenLandscape:
                return CGSize(width: 16, height: 9)
            }
        }

        /// The aspect ratio as a scalar (width/height), when determinable.
        ///
        /// - Returns: The numeric ratio, or `nil` for `.active` where no fixed ratio is implied.
        var ratio: CGFloat? {
            switch self {
            case .active:
                return nil

            case .custom(let size):
                return size.aspectRatio

            case .square:
                return 1

            default:
                return dimensions?.aspectRatio
            }
        }
    }

    // MARK: - Instance methods

    /// Builds an AVFoundation‑compatible video settings dictionary.
    ///
    /// This method assembles a dictionary suitable for `AVAssetWriterInput` or other AVFoundation
    /// consumers. If `dimensions` are not explicitly set, it infers width/height from
    /// `sampleBuffer`’s `CMFormatDescription` or from a provided `pixelBuffer`, then applies
    /// the configured `aspectRatio` policy. It also encodes codec choice, scaling mode, bitrate,
    /// key‑frame interval, and profile level into the compression properties.
    ///
    /// - Parameters:
    ///   - sampleBuffer: An optional `CMSampleBuffer` from which to infer input dimensions.
    ///   - pixelBuffer: An optional `CVPixelBuffer` fallback used to infer dimensions when no`sampleBuffer` is provided.
    /// - Returns: A dictionary of video settings keyed by `AVVideo*` constants, or `nil` if insufficient information is available to determine dimensions.
    fileprivate func makeSettingsDictionary(
        sampleBuffer: CMSampleBuffer? = nil,
        pixelBuffer: CVPixelBuffer? = nil
    ) -> [String: Any]? {

        var config: [String: Any] = [:]

        if let dimensions {
            config[AVVideoHeightKey] = dimensions.height
            config[AVVideoWidthKey] = dimensions.width
        } else if /// The sample buffer
        let sampleBuffer = sampleBuffer,

            /// The format description for the `sampleBuffer`
            let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer)
        {

            let videoDimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)

            switch aspectRatio {
            case .custom(let size):
                config[AVVideoHeightKey] = videoDimensions.width * Int32(size.height) / Int32(size.width)
                config[AVVideoWidthKey] = Int(videoDimensions.width)

            case .square:
                let min = min(videoDimensions.width, videoDimensions.height)
                config[AVVideoHeightKey] = Int(min)
                config[AVVideoWidthKey] = Int(min)

            case .standard:
                config[AVVideoHeightKey] = Int(videoDimensions.width * 3 / 4)
                config[AVVideoWidthKey] = Int(videoDimensions.width)

            case .widescreen:
                config[AVVideoHeightKey] = Int(videoDimensions.width * 9 / 16)
                config[AVVideoWidthKey] = Int(videoDimensions.width)

            default:
                config[AVVideoHeightKey] = Int(videoDimensions.height)
                config[AVVideoWidthKey] = Int(videoDimensions.width)
            }
        } else if let pixelBuffer = pixelBuffer {
            config[AVVideoWidthKey] = CVPixelBufferGetWidth(pixelBuffer)
            config[AVVideoHeightKey] = CVPixelBufferGetHeight(pixelBuffer)
        }

        config[AVVideoCodecKey] = codec
        config[AVVideoScalingModeKey] = scalingMode

        var compressionDict: [String: Any] = [:]
        compressionDict[AVVideoAverageBitRateKey] = bitRate
        compressionDict[AVVideoAllowFrameReorderingKey] = false
        compressionDict[AVVideoMaxKeyFrameIntervalKey] = maxKeyFrameInterval
        compressionDict[AVVideoProfileLevelKey] = profileLevel

        config[AVVideoCompressionPropertiesKey] = compressionDict
        return config
    }
}

/// A concrete video capture device that configures inputs/outputs and manages lifecycle.
///
/// This class owns the active `AVCaptureDevice`, its corresponding input, and a video data output.
/// It applies sensible defaults (focus, exposure, white balance, low‑light boost), handles camera
/// position changes, torch control, and connection stabilization, and tracks a simple state machine.
final class VideoDevice: NSObject, Device {
    // MARK: - Private Properties

    private var captureDevice = AVCaptureDevice.defaultVideoDevice(for: .back)
    private var captureDeviceInput: AVCaptureDeviceInput?
    private var captureSession: AVCaptureSession?
    private var captureVideoDataOutput: AVCaptureVideoDataOutput?
    private var lastVideoTimestamp = CMTime.invalid
    private var processors: [ObjectIdentifier: any VideoOutputProcessor] = [:]
    private let queue = DispatchQueue(label: "com.video.device.queue")

    // MARK: - Properties

    /// The video device configuration used to initialize and update capture parameters.
    ///
    /// Holds options such as desired resolution, frame rate, color space, and other
    /// format-related preferences that guide how the device is configured. This instance
    /// is created with sensible defaults and may be updated by higher-level APIs before
    /// applying changes to the underlying `AVCaptureDevice`/session.
    let configuration = VideoDeviceConfiguration()

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

    // MARK: - Computed Properties

    /// Indicates whether the app is authorized to access the video capture.
    ///
    /// Evaluates the current authorization status for `.video` and returns `true` only when
    /// the status is `.authorized`. Use this to gate camera-dependent features.
    ///
    /// - Returns: `true` if video capture is authorized; otherwise, `false`.
    var isAuthorized: Bool {
        AVCaptureDevice.authorizationStatus(for: .video) == .authorized
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

    /// The current torch mode of the active capture device.
    ///
    /// Reflects the device’s `torchMode` (e.g., `.on`, `.off`, `.auto`). If no device is
    /// available, `.off` is returned.
    ///
    /// - Returns: The current `AVCaptureDevice.TorchMode`, or `.off` when no device is available.
    var torchMode: AVCaptureDevice.TorchMode {
        captureDevice?.torchMode ?? .off
    }

    // MARK: - Initializer

    /// Creates a new instance of the `VideoDevice`.
    nonisolated override init() {}

    // MARK: - Device

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
            // TODO: Revert to previous preset
            destroySession()
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
            state = .paused
        }
    }

    /// Resets the device to a clean state, clearing any corrupted internal state.
    ///
    /// This method should be called when the device needs to recover from errors or when
    /// performing a complete session reset. It clears any corrupted buffers, resets internal
    /// configuration, and prepares the device for a fresh start without attempting to finalize
    /// any recordings to avoid corruption.
    @DeviceActor
    func reset() {
        if state.canTransition(to: .initialized) {
            destroySession()
        }
    }

    /// Resumes capture for this device after it has been paused.
    ///
    /// This method restarts data capture for a previously paused device. The device
    /// should return to the same state it was in before `pause()` was called.
    ///
    /// Implementations should:
    /// - Restart data processing
    /// - Resume any recording or streaming operations
    /// - Restore previous device settings if needed
    /// - Handle any state changes that occurred during the pause
    @DeviceActor
    func resume() {
        if state.canTransition(to: .paused) {
            state = .running
        }
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
    func startCapturing(in session: AVCaptureSession) throws {
        if state.canTransition(to: .running) {
            do {
                guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
                    throw UtilityError(
                        kind: .VideoDeviceErrorReason.notAuthorized,
                        failureReason: "This app doesn’t have permission to use the video device."
                    )
                }

                guard let captureDevice = captureDevice ?? AVCaptureDevice.defaultVideoDevice(for: position) else {
                    throw UtilityError(
                        kind: .VideoDeviceErrorReason.captureDeviceNotFound,
                        failureReason: "No video capture device was found. Ensure this device has a camera available."
                    )
                }

                session.beginConfiguration()

                defer { session.commitConfiguration() }

                if captureDevice.uniqueID != session.captureDeviceInput(for: .video)?.device.uniqueID {
                    captureSession = session

                    try captureDevice.configure()
                    try configureDeviceInput(for: captureDevice, in: session)
                    try configureDeviceOutput(in: session)

                    state = .running
                }
            } catch {
                destroySession()
                state = .failed
                throw error
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

    /// Requests camera (video) permission from the user.
    ///
    /// Presents the system authorization dialog if the status is `.notDetermined`.
    @discardableResult
    func requestAccess() async -> Bool {
        await AVCaptureDevice.requestAccess(for: .video)
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
    func setPosition(_ newPosition: AVCaptureDevice.Position) throws {
        if position != newPosition {
            let currentDeviceInput = captureDeviceInput

            captureDevice = AVCaptureDevice.defaultVideoDevice(for: newPosition)

            if /// The active session.
            let captureSession,

                /// The active device.
                let captureDevice
            {

                captureSession.beginConfiguration()
                defer { captureSession.commitConfiguration() }

                if let currentDeviceInput {
                    captureSession.removeInput(currentDeviceInput)
                }

                try configureDeviceInput(for: captureDevice, in: captureSession)
                updateVideoOutputSettings()
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
    func setTorchMode(_ mode: AVCaptureDevice.TorchMode) throws {
        if let captureDevice, torchMode != mode {
            guard captureDevice.isTorchModeSupported(mode) else {
                throw UtilityError(
                    kind: .VideoDeviceErrorReason.torchNotSupported,
                    failureReason: "The torch mode \(mode) is not supported by the device."
                )
            }

            do {
                try captureDevice.lockForConfiguration()
                defer { captureDevice.unlockForConfiguration() }

                captureDevice.torchMode = mode
            } catch {
                throw UtilityError(kind: .VideoDeviceErrorReason.torchModeFailed, underlyingError: error)
            }
        }
    }

    // MARK: - Private methods

    private func configureDeviceInput(for captureDevice: AVCaptureDevice, in session: AVCaptureSession) throws {
        if let currentCaptureDeviceInput = session.captureDeviceInput(for: .video) {
            session.removeInput(currentCaptureDeviceInput)
        }

        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)

            guard session.canAddInput(captureDeviceInput) else {
                throw UtilityError(
                    kind: .VideoDeviceErrorReason.cannotAddInput,
                    failureReason: "Unable to add \(captureDeviceInput.debugDescription) to the session"
                )
            }

            session.addInput(captureDeviceInput)

            self.captureDeviceInput = captureDeviceInput
        } catch let error as UtilityError {
            throw error
        } catch {
            throw UtilityError(kind: .VideoDeviceErrorReason.cannotAddInput, underlyingError: error)
        }
    }

    private func configureDeviceOutput(in session: AVCaptureSession) throws {
        let captureVideoDataOutput = AVCaptureVideoDataOutput.createDefault()

        guard session.canAddOutput(captureVideoDataOutput) else {
            throw UtilityError(
                kind: .VideoDeviceErrorReason.cannotAddOutput,
                failureReason: "Unable to add \(captureVideoDataOutput.debugDescription) to the session"
            )
        }

        captureVideoDataOutput.setSampleBufferDelegate(self, queue: queue)
        session.addOutput(captureVideoDataOutput)

        self.captureVideoDataOutput = captureVideoDataOutput
    }

    private func destroySession() {
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

            captureDevice = nil
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

extension VideoDevice: AVCaptureVideoDataOutputSampleBufferDelegate {

    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {

        if let captureDevice = captureDevice, state == .running {
            let sampleBuffer = VideoSampleBuffer(
                buffer: sampleBuffer,
                minFrameDuration: captureDevice.activeVideoMinFrameDuration,
                timestamp: CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            )

            Task { @DeviceActor in
                let processors = Array(processors.values)
                processors.forEach { $0.process(sampleBuffer, with: configuration) }
            }
        }
    }
}

extension AVCaptureDevice {
    /// Configures the capture device with recommended real‑time defaults for video capture.
    ///
    /// Applies continuous autofocus (enabling smooth autofocus when supported), continuous auto exposure,
    /// continuous auto white balance, automatic low‑light boost (when available), and subject‑area change
    /// monitoring. It also sets a fixed frame rate of 24 fps by assigning both `activeVideoMinFrameDuration`
    /// and `activeVideoMaxFrameDuration` to 1/24. The device is locked for configuration at the start and
    /// is always unlocked before returning, regardless of success.
    ///
    /// - Important: Prefer invoking this while the associated `AVCaptureSession` is wrapped in
    ///   `beginConfiguration()` / `commitConfiguration()` to avoid intermediate reconfigurations.
    fileprivate func configure() throws {
        do {
            try lockForConfiguration()
            defer { unlockForConfiguration() }

            if isFocusModeSupported(.continuousAutoFocus) {
                focusMode = .continuousAutoFocus

                if isSmoothAutoFocusSupported {
                    isSmoothAutoFocusEnabled = true
                }
            }

            if isExposureModeSupported(.continuousAutoExposure) {
                exposureMode = .continuousAutoExposure
            }

            if isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
                whiteBalanceMode = .continuousAutoWhiteBalance
            }

            if isLowLightBoostSupported {
                automaticallyEnablesLowLightBoostWhenAvailable = true
            }

            isSubjectAreaChangeMonitoringEnabled = true

            let fps = 24.0
            let videoSupportedFrameRatesRanges = activeFormat.videoSupportedFrameRateRanges

            if videoSupportedFrameRatesRanges.contains(where: { ($0.minFrameRate ... $0.maxFrameRate).contains(fps) }) {
                let frameDuration = CMTimeMake(value: 1, timescale: Int32(fps))

                activeVideoMinFrameDuration = frameDuration
                activeVideoMaxFrameDuration = frameDuration
            }
        } catch {
            throw UtilityError(kind: .VideoDeviceErrorReason.unableToLockDeviceForConfiguration, underlyingError: error)
        }
    }
}

extension AVCaptureVideoDataOutput {
    /// Creates a preconfigured `AVCaptureVideoDataOutput` optimized for real-time camera capture.
    ///
    /// This method selects the best available pixel format supported by the current device:
    /// it prefers 4:2:0 bi-planar full-range (`kCVPixelFormatType_420YpCbCr8BiPlanarFullRange`),
    /// then falls back to 4:2:0 bi-planar video-range (`kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange`),
    /// and finally to 32-bit BGRA (`kCVPixelFormatType_32BGRA`) if neither YUV format is available.
    /// It also sets `alwaysDiscardsLateVideoFrames` to `false` to preserve frame continuity under load.
    /// Callers must set a sample buffer delegate and provide an appropriate serial dispatch queue.
    fileprivate static func createDefault() -> AVCaptureVideoDataOutput {
        let captureVideoDataOutput = AVCaptureVideoDataOutput()
        let pixelFormatKey = String(kCVPixelBufferPixelFormatTypeKey)
        var settings = [String(kCVPixelBufferPixelFormatTypeKey): Int(kCVPixelFormatType_32BGRA)]

        for formatType in captureVideoDataOutput.availableVideoPixelFormatTypes {
            if formatType == Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
                settings[pixelFormatKey] = Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
            }

            if formatType == Int(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) && settings[pixelFormatKey] == nil {
                settings[pixelFormatKey] = Int(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)
            }
        }

        captureVideoDataOutput.alwaysDiscardsLateVideoFrames = false
        captureVideoDataOutput.videoSettings = settings

        return captureVideoDataOutput
    }
}

extension CGSize {
    /// Returns the aspect ratio of the current size
    fileprivate var aspectRatio: CGFloat {
        width / height
    }
}
