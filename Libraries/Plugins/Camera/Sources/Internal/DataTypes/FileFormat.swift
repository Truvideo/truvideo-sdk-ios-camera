//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation
import Foundation

/// Supported file formats for photo output.
///
/// This enum defines the available output formats for captured photos.
/// Each format has specific characteristics regarding quality, file size,
/// and post-processing requirements.
enum FileFormat: String {
    /// HEIC format with high-efficiency compression.
    ///
    /// HEIC (High Efficiency Image Container) format provides excellent
    /// image quality with significantly smaller file sizes compared to
    /// JPEG. It uses the HEVC codec for compression and is the modern
    /// standard for iOS photo capture, offering better quality-to-size
    /// ratio than traditional formats.
    case heic

    /// JPEG format with lossy compression.
    ///
    /// JPEG format provides good quality with smaller file sizes through
    /// lossy compression. It's suitable for most photography needs and
    /// offers a good balance between quality and storage efficiency.
    case jpeg

    /// PNG format with lossless compression.
    ///
    /// PNG format provides maximum quality through lossless compression
    /// and supports transparency. It's ideal for applications requiring
    /// maximum quality or transparency support, though it results in
    /// larger file sizes.
    case png

    // MARK: - Computed Properties

    /// The video codec used for photo capture.
    ///
    /// This property returns the appropriate `AVVideoCodecType` for photo
    /// capture. Currently, both JPEG and PNG formats use the JPEG codec
    /// for initial capture, with PNG requiring post-capture conversion.
    ///
    /// - Returns: The video codec type for photo capture.
    var codec: AVVideoCodecType {
        switch self {
        case .heic:
            .hevc

        default:
            .jpeg
        }
    }

    /// Returns the AVFileType corresponding to the current file format.
    ///
    /// This property maps the internal FileFormat enum cases to their corresponding
    /// AVFileType values used by AVFoundation for file operations. HEIC format maps
    /// to .heic, while all other formats (JPEG, PNG) map to .jpg for compatibility
    /// with standard image file handling.
    var fileType: AVFileType {
        switch self {
        case .heic:
            .heic

        default:
            .jpg
        }
    }

    /// The quality setting for photo capture.
    ///
    /// This property defines the quality level used during photo capture.
    /// Higher quality values result in better image quality but larger
    /// file sizes and potentially slower processing.
    ///
    /// - Returns: The quality value as a Double between 0.0 and 1.0.
    var quality: Double {
        switch self {
        case .jpeg:
            0.9

        default:
            1
        }
    }
}
