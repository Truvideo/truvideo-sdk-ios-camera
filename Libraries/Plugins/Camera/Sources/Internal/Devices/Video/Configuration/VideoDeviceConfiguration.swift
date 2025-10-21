//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation
import Foundation

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

    /// The preferred video capture resolution preset for the video device.
    ///
    /// This property specifies the default resolution setting used when configuring
    /// the video capture device. It determines the capture resolution and quality
    /// level for video recording operations. The preset is applied to the underlying
    /// `AVCaptureSession` to configure the appropriate resolution settings.
    ///
    /// ## Supported Presets
    ///
    /// The property supports standard AVFoundation presets:
    /// - `.hd1280x720`: High Definition 720p (1280×720, 16:9 aspect ratio) - Default
    /// - `.hd1920x1080`: Full High Definition 1080p (1920×1080, 16:9 aspect ratio)
    /// - `.vga640x480`: Standard Definition (640×480, 4:3 aspect ratio)
    var preset = AVCaptureSession.Preset.hd1280x720

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

    /// The desired output format for captured photos.
    ///
    /// This property specifies whether photos should be captured as JPEG or PNG
    /// format. The choice affects both the capture quality settings and the
    /// post-processing steps required to achieve the desired output format.
    var imageFormat = FileFormat.jpeg

    /// Whether high-resolution photo capture is enabled.
    ///
    /// When enabled, this property allows the camera to capture photos at the
    /// device's maximum available resolution, which may be higher than the
    /// standard capture resolution. This is useful for applications requiring
    /// maximum detail and quality.
    var isHighResolutionEnabled = false

    /// Maximum interval between key frames (GOP length).
    ///
    /// Maps to `AVVideoMaxKeyFrameIntervalKey`. A value of `1` produces key‑frames only,
    /// increasing compatibility at the expense of larger files. Typical values are 24–60,
    /// aligning with expected frame rates.
    var maxKeyFrameInterval = 30

    /// The maximum duration between keyframes in seconds.
    ///
    /// This property controls the maximum time interval between keyframes (I-frames)
    /// in the video encoding process. Keyframes are reference frames that contain
    /// complete image information and are used for seeking and error recovery.
    /// Setting this value too high can make seeking less precise, while setting
    /// it too low can increase file size and encoding time.
    var maxKeyFrameIntervalDuration = 1

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
                nil

            case .cinematic:
                CGSize(width: 2.35, height: 1)

            case let .custom(size):
                size

            case .square:
                CGSize(width: 1, height: 1)

            case .standard:
                CGSize(width: 3, height: 4)

            case .standardLandscape:
                CGSize(width: 4, height: 3)

            case .widescreen:
                CGSize(width: 9, height: 16)

            case .widescreenLandscape:
                CGSize(width: 16, height: 9)
            }
        }

        /// The aspect ratio as a scalar (width/height), when determinable.
        ///
        /// - Returns: The numeric ratio, or `nil` for `.active` where no fixed ratio is implied.
        var ratio: CGFloat? {
            switch self {
            case .active:
                nil

            case let .custom(size):
                size.aspectRatio

            case .square:
                1

            default:
                dimensions?.aspectRatio
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
    /// - Parameter sampleBuffer: An optional `CMSampleBuffer` from which to infer input dimensions.
    /// - Returns: A dictionary of video settings keyed by `AVVideo*` constants, or `nil` if insufficient information is
    /// available to determine dimensions.
    func makeSettingsDictionary(sampleBuffer: CMSampleBuffer? = nil) -> [String: Any]? {
        var config: [String: Any] = [:]

        if let dimensions {
            config[AVVideoHeightKey] = dimensions.height
            config[AVVideoWidthKey] = dimensions.width
        } else if /// The sample buffer
            let sampleBuffer,

            /// The format description for the `sampleBuffer`
            let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) {
            let videoDimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)

            switch aspectRatio {
            case let .custom(size):
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
        }

        config[AVVideoCodecKey] = codec
        config[AVVideoScalingModeKey] = scalingMode

        var compressionDict: [String: Any] = [:]
        compressionDict[AVVideoAverageBitRateKey] = preset.bitRate
        compressionDict[AVVideoAllowFrameReorderingKey] = false
        compressionDict[AVVideoMaxKeyFrameIntervalKey] = maxKeyFrameInterval
        compressionDict[AVVideoMaxKeyFrameIntervalDurationKey] = maxKeyFrameIntervalDuration
        compressionDict[AVVideoProfileLevelKey] = profileLevel

        config[AVVideoCompressionPropertiesKey] = compressionDict
        return config
    }
}

extension CGSize {
    /// Returns the aspect ratio of the current size
    fileprivate var aspectRatio: CGFloat {
        width / height
    }
}
