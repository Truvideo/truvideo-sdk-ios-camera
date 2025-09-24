//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation

extension CGSize {
    /// Returns the aspect ratio of the current size
    fileprivate var aspectRatio: CGFloat {
        height / width
    }
}

/// TruConfiguration, media capture configuration object
class TruConfiguration {
    /// AVFoundation configuration preset, see AVCaptureSession.h
    let preset: AVCaptureSession.Preset = .inputPriority

    /// Aspect ratio, specifies dimensions for video output
    enum AspectRatio {
        /// active preset or specified dimensions (default)
        case active

        /// 2.35:1 cinematic
        case cinematic

        /// custom aspect ratio
        case custom(size: CGSize)

        /// 1:1 square
        case square

        /// 3:4
        case standard

        /// 4:3, landscape
        case standardLandscape

        /// 9:16 HD
        case widescreen

        /// 16:9 HD landscape
        case widescreenLandscape

        /// Returns the dimension of the current aspect ratio
        var dimensions: CGSize? {
            switch self {
            case .active: return nil
            case .cinematic: return CGSize(width: 2.35, height: 1)
            case .custom(let size): return size
            case .square: return CGSize(width: 1, height: 1)
            case .standard: return CGSize(width: 3, height: 4)
            case .standardLandscape: return CGSize(width: 4, height: 3)
            case .widescreen: return CGSize(width: 9, height: 16)
            case .widescreenLandscape: return CGSize(width: 16, height: 9)
            }
        }

        /// The ratio
        var ratio: CGFloat? {
            switch self {
            case .active: return nil
            case .custom(let size): return size.width / size.height
            case .square: return 1
            default: return dimensions?.aspectRatio
            }
        }
    }

    // MARK: Instance methods

    /// Provides an AVFoundation friendly dictionary for configuring output.
    ///
    /// - Parameter sampleBuffer: Sample buffer for extracting configuration information
    /// - Returns: Configuration dictionary for AVFoundation
    func avcaptureSettingsDictionary(
        sampleBuffer: CMSampleBuffer? = nil,
        pixelBuffer: CVPixelBuffer? = nil
    ) -> [String: Any]? {

        [:]
    }
}

/// TruAudioConfiguration,  audio capture configuration object
class TruAudioConfiguration: TruConfiguration {
    /// Audio bit rate, AV dictionary key AVEncoderBitRateKey
    var bitRate = TruAudioConfiguration.AudioBitRateDefault

    /// Number of channels, AV dictionary key AVNumberOfChannelsKey
    var channelsCount: Int?

    /// Sample rate in hertz, AV dictionary key AVSampleRateKey
    var sampleRate: Float64?

    /// Audio data format identifier, AV dictionary key AVFormatIDKey
    /// https://developer.apple.com/reference/coreaudio/1613060-core_audio_data_types
    var format = kAudioFormatMPEG4AAC

    /// Default bit rate
    static let AudioBitRateDefault: Int = 128000

    /// Defailt sample rate
    static let AudioSampleRateDefault: Float64 = 44100.0

    /// Default audio channels
    static let AudioChannelsCountDefault: Int = 2

    // MARK: Overriden methods

    /// Provides an AVFoundation friendly dictionary for configuring output.
    ///
    /// - Parameter sampleBuffer: Sample buffer for extracting configuration information
    /// - Returns: Configuration dictionary for AVFoundation
    override func avcaptureSettingsDictionary(
        sampleBuffer: CMSampleBuffer? = nil,
        pixelBuffer: CVPixelBuffer? = nil
    ) -> [String: Any]? {

        var config: [String: Any] = [AVEncoderBitRateKey: NSNumber(integerLiteral: self.bitRate)]

        if /// Sample buffer
        let sampleBuffer = sampleBuffer,

            /// Sample format description
            let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer)
        {

            /// Stream basic description
            if let streamBasicDescription = CMAudioFormatDescriptionGetStreamBasicDescription(formatDescription),
                sampleRate == nil && channelsCount == nil
            {

                sampleRate = streamBasicDescription.pointee.mSampleRate
                channelsCount = Int(streamBasicDescription.pointee.mChannelsPerFrame)
            }

            var layoutSize: Int = 0
            if let currentChannelLayout = CMAudioFormatDescriptionGetChannelLayout(
                formatDescription,
                sizeOut: &layoutSize
            ) {
                config[AVChannelLayoutKey] =
                    layoutSize > 0 ? Data(bytes: currentChannelLayout, count: layoutSize) : Data()
            }
        }

        if let sampleRate = sampleRate, sampleRate > 0 {
            config[AVSampleRateKey] = sampleRate
        } else {
            config[AVSampleRateKey] = TruAudioConfiguration.AudioSampleRateDefault
        }

        if let channelsCount = channelsCount, channelsCount > 0 {
            config[AVNumberOfChannelsKey] = channelsCount
        } else {
            config[AVNumberOfChannelsKey] = TruAudioConfiguration.AudioChannelsCountDefault
        }

        config[AVFormatIDKey] = format
        return config
    }
}

/// TruPhotoConfiguration,  photo capture configuration object
class TruPhotoConfiguration: TruConfiguration {
    /// Codec used to encode photo, AV dictionary key AVVideoCodecKey
    var codec: AVVideoCodecType = .jpeg

    /// When true, It should generate a thumbnail for the photo
    var generateThumbnail = false

    /// Enabled high resolution capture
    var isHighResolutionEnabled = false

    /// Change flashMode with TruVideoRecorder.flashMode
    var flashMode: AVCaptureDevice.FlashMode = .off

    // MARK: Overriden methods

    /// Provides an AVFoundation friendly dictionary for configuring output.
    ///
    /// - Returns: Configuration dictionary for AVFoundation
    func avDictionary() -> [String: Any]? {
        var config: [String: Any] = [AVVideoCodecKey: codec]

        if generateThumbnail {
            let settings = AVCapturePhotoSettings()
            if settings.__availablePreviewPhotoPixelFormatTypes.count > 0 {
                if let formatType = settings.__availablePreviewPhotoPixelFormatTypes.first {
                    config[kCVPixelBufferPixelFormatTypeKey as String] = formatType
                }
            }
        }

        return config
    }
}

/// TruVideoConfiguration,  video capture configuration object
class TruVideoConfiguration: TruConfiguration {
    /// Output aspect ratio automatically sizes output dimensions, `active` indicates TruVideoConfiguration.preset or TruVideoConfiguration.dimensions
    var aspectRatio: AspectRatio = .active

    /// Average video bit rate (bits per second), AV dictionary key AVVideoAverageBitRateKey
    var bitRate = TruVideoConfiguration.VideoBitRateDefault

    /// Codec used to encode video, AV dictionary key AVVideoCodecKey
    var codec: AVVideoCodecType = AVVideoCodecType.h264

    /// Dimensions for video output, AV dictionary keys AVVideoWidthKey, AVVideoHeightKey
    var dimensions: CGSize?

    /// Maximum recording duration, when set, session finishes automatically
    var maximumCaptureDuration: CMTime?

    /// Maximum interval between key frames, 1 meaning key frames only, AV dictionary key AVVideoMaxKeyFrameIntervalKey
    var maxKeyFrameInterval: Int = 30

    /// Profile level for the configuration, AV dictionary key AVVideoProfileLevelKey (H.264 codec only)
    var profileLevel: String = AVVideoProfileLevelH264HighAutoLevel

    /// Video scaling mode, AV dictionary key AVVideoScalingModeKey
    /// (AVVideoScalingModeResizeAspectFill, AVVideoScalingModeResizeAspect, AVVideoScalingModeResize, AVVideoScalingModeFit)
    var scalingMode: String = AVVideoScalingModeResizeAspectFill

    /// Video output transform for display
    var transform: CGAffineTransform = .identity

    /// Video time scale, value/timescale = seconds
    var timescale: Float64?

    /// Default video bit rate
    static let VideoBitRateDefault: Int = 2_000_000

    /// Selected camera resolution for front and back camera
    var selectedResolution: TruvideoSdkCameraResolutionFormat?

    /// Selected zoom factor for the camera
    var zoomFactor: CGFloat = 1.0

    var swapDimensions = false

    // MARK: Overriden methods

    /// Provides an AVFoundation friendly dictionary for configuring output.
    ///
    /// - Parameter sampleBuffer: Sample buffer for extracting configuration information
    /// - Returns: Configuration dictionary for AVFoundation
    override func avcaptureSettingsDictionary(
        sampleBuffer: CMSampleBuffer? = nil,
        pixelBuffer: CVPixelBuffer? = nil
    ) -> [String: Any]? {

        var config: [String: Any] = [:]
        if let dimensions = dimensions {
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
                break

            case .standard:
                config[AVVideoHeightKey] = Int(videoDimensions.width * 3 / 4)
                config[AVVideoWidthKey] = Int(videoDimensions.width)
                break

            case .widescreen:
                config[AVVideoHeightKey] = Int(videoDimensions.width * 9 / 16)
                config[AVVideoWidthKey] = Int(videoDimensions.width)
                break

            default:
                config[AVVideoHeightKey] = Int(videoDimensions.height)
                config[AVVideoWidthKey] = Int(videoDimensions.width)
                break
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
        compressionDict[AVVideoMaxKeyFrameIntervalKey] = NSNumber(integerLiteral: maxKeyFrameInterval)
        compressionDict[AVVideoProfileLevelKey] = profileLevel

        config[AVVideoCompressionPropertiesKey] = compressionDict
        return config
    }
}
