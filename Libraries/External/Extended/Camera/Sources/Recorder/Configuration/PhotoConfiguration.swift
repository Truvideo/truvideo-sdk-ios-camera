//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation

final class PhotoConfiguration {
    /// Codec used to encode photo, AV dictionary key AVVideoCodecKey
    var codec = AVVideoCodecType.jpeg

    /// Change flashMode with AVCaptureDevice.FlashMode
    var flashMode = AVCaptureDevice.FlashMode.off

    /// The camera's photo output file format
    var imageFormat = Format.png

    /// Enabled high resolution capture
    var isHighResolutionEnabled = false

    // MARK: - Types

    public enum Format {
        case jpeg
        case png
    }

    // MARK: - Instance methods

    /// Provides an AVFoundation friendly dictionary for configuring output.
    ///
    /// - Returns: Configuration dictionary for AVFoundation
    func avDictionary() -> [String: Any]? {
        var config: [String: Any] = [AVVideoCodecKey: codec]

        let settings = AVCapturePhotoSettings()
        if !settings.__availablePreviewPhotoPixelFormatTypes.isEmpty {
            if let formatType = settings.__availablePreviewPhotoPixelFormatTypes.first {
                config[kCVPixelBufferPixelFormatTypeKey as String] = formatType
            }
        }

        return config
    }
}
