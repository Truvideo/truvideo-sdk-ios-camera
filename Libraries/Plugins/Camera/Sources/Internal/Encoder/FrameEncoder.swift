//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation
import CoreImage
import Foundation
internal import Utilities

/// Frame encoding utilities for converting video sample buffers to image data.
///
/// This module provides a comprehensive framework for encoding video sample buffers into
/// various image formats using Core Image. It includes protocols, implementations, and
/// extensions that handle the complete pipeline from video buffer extraction to final
/// image encoding with quality optimizations.
///
/// ## Key Components
///
/// ### FrameEncoder Protocol
/// Defines the interface for encoding video sample buffers to image data with support
/// for multiple formats (JPEG, PNG, HEIC) and configurable quality settings.
///
/// ### VideoBufferFrameEncoder
/// A concrete implementation that uses Core Image for high-quality video buffer encoding.
/// Includes automatic metadata attachment, orientation correction, and advanced image
/// processing features.
///
/// ### CIContext Extensions
/// Extends Core Image context with optimized data representation methods that handle
/// format-specific encoding with quality and color optimization settings.
///
/// ## Features
///
/// - **Multi-Format Support**: JPEG, PNG, and HEIC encoding
/// - **Quality Optimization**: Lanczos scaling and color optimization
/// - **Metadata Preservation**: Automatic TIFF metadata attachment
/// - **Orientation Handling**: Device-aware orientation correction
/// - **Thread Safety**: Concurrent access support
/// - **Error Handling**: Comprehensive error reporting with specific failure reasons
///
/// ## Usage
///
/// ```swift
/// let encoder = VideoBufferFrameEncoder()
/// let imageData = try encoder.encode(
///     videoBuffer,
///     to: outputURL,
///     format: .jpeg
/// )
/// ```
///
/// ## Thread Safety
///
/// All components in this module are thread-safe and can be used concurrently across
/// multiple threads without additional synchronization.
extension ErrorReason {
    /// A collection of error reasons related to the frame encoder operations.
    ///
    /// The `FrameEncoderErrorReason` struct provides a set of static constants representing various errors that can
    /// occur
    /// during frame encoder operations. These error reasons help identify specific failure points in the frame encoder
    /// generation
    /// process, making debugging and error handling more precise and informative.
    struct FrameEncoderErrorReason: Sendable {
        /// Error reason indicating that frame buffer encoding failed.
        ///
        /// This error occurs when the frame encoder is unable to process a video sample buffer
        /// and convert it to the requested image format. Common causes include invalid buffer
        /// data, missing image context, or format conversion failures.
        static let failedToEncodeBuffer = ErrorReason(rawValue: "FAILED_TO_ENCODE_BUFFER")
    }
}

/// A protocol that defines the interface for encoding video sample buffers to image data.
///
/// The `FrameEncoder` protocol provides a standardized way to convert video sample buffers
/// into various image formats (JPEG, PNG, HEIC). It abstracts the encoding process, allowing
/// different implementations to be used while maintaining a consistent interface for frame
/// capture and image generation from video data.
///
/// This protocol is typically used for capturing still frames from video streams, generating
/// thumbnails, or creating image snapshots from live camera feeds.
protocol FrameEncoder: Sendable {
    /// Encodes a video sample buffer to image data in the specified format.
    ///
    /// This method takes a video sample buffer and converts it to image data using the
    /// specified file format. The encoding process handles orientation correction, color
    /// space conversion, and format-specific compression settings.
    ///
    /// ## Supported Formats
    ///
    /// - JPEG: Lossy compression with configurable quality
    /// - PNG: Lossless compression with transparency support
    /// - HEIC: Modern format with superior compression and quality
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let frameEncoder = VideoBufferFrameEncoder()
    /// let imageData = try frameEncoder.encode(
    ///     buffer,
    ///     format: .jpeg
    /// )
    /// ```
    ///
    /// ## Thread Safety
    ///
    /// This method should be thread-safe and can be called from any thread.
    /// Implementations should handle concurrent access appropriately.
    ///
    /// - Parameters:
    ///   - buffer: The video sample buffer to encode
    ///   - format: The target image format for encoding
    /// - Returns: The encoded image data
    /// - Throws: `UtilityError` if encoding fails
    func encode(_ buffer: VideoSampleBuffer, format: FileFormat) throws(UtilityError) -> Data
}

/// A concrete implementation of `FrameEncoder` that uses Core Image for video buffer encoding.
///
/// The `VideoBufferFrameEncoder` struct provides a Core Image-based implementation of the
/// `FrameEncoder` protocol, specifically designed to convert video sample buffers into
/// various image formats. It handles orientation correction, color space management,
/// and format-specific encoding using Core Image's powerful image processing capabilities.
///
/// This implementation supports JPEG, PNG, and HEIC formats with configurable quality
/// settings and includes automatic metadata attachment for generated images.
struct VideoBufferFrameEncoder: FrameEncoder, @unchecked Sendable {
    // MARK: - Private Properties

    private let context = CIContext.createDefault()

    // MARK: - Static Properties

    /// Default TIFF metadata attached to photos and frame snapshots.
    ///
    /// This metadata dictionary provides essential information about the image generation
    /// process and is automatically attached to all encoded images. It includes standard
    /// TIFF tags that help identify the source software, creator, and timestamp of the
    /// generated images.
    ///
    /// ## Metadata Fields
    ///
    /// - **Software**: `kCGImagePropertyTIFFSoftware` - A human-readable app identifier (e.g., `truVideoMetadataTitle`)
    /// - **Artist**: `kCGImagePropertyTIFFArtist` - The creator/author tag (e.g., `truVideoMetadataArtist`)
    /// - **DateTime**: `kCGImagePropertyTIFFDateTime` - An ISO-8601 timestamp string indicating when the image was
    /// created
    ///
    /// ## Usage
    ///
    /// This metadata is automatically applied to all images generated by the encoder,
    /// providing traceability and identification information for debugging and
    /// administrative purposes.
    ///
    /// ## Thread Safety
    ///
    /// This static property is thread-safe and can be accessed from any thread.
    static let imageMetadata = [
        kCGImagePropertyTIFFSoftware as String: truVideoMetadataTitle,
        kCGImagePropertyTIFFArtist as String: truVideoMetadataArtist,
        kCGImagePropertyTIFFDateTime as String: ISO8601DateFormatter().string(from: Date())
    ]

    // MARK: - FrameEncoder

    /// Encodes a video sample buffer to image data using Core Image processing.
    ///
    /// This method converts a video sample buffer into image data by extracting the image
    /// buffer, applying orientation correction based on device position, and encoding it
    /// to the specified format using Core Image's encoding capabilities.
    ///
    /// ## Processing Steps
    ///
    /// 1. Determines device position (front/back) from buffer mirroring
    /// 2. Appends metadata to the sample buffer for image identification
    /// 3. Extracts image buffer from the sample buffer
    /// 4. Applies orientation correction based on device position
    /// 5. Converts to Core Image representation
    /// 6. Handles color space management (defaults to sRGB)
    /// 7. Crops to integral bounds and applies Lanczos scaling for quality
    /// 8. Encodes to requested format with optimized settings
    ///
    /// ## Image Quality Enhancements
    ///
    /// The encoding process includes several quality improvements:
    /// - **Lanczos Scaling**: Applies `CILanczosScaleTransform` filter for superior image quality
    /// - **Color Optimization**: Uses `kCGImageDestinationOptimizeColorForSharing` for better color reproduction
    /// - **Integral Cropping**: Ensures clean pixel boundaries by cropping to integral bounds
    /// - **Metadata Preservation**: Maintains image metadata including software, artist, and timestamp information
    ///
    /// ## Format Support
    ///
    /// - **HEIC**: Modern format with superior compression and quality using RGBA8 format
    /// - **JPEG**: Lossy compression with configurable quality settings
    /// - **PNG**: Lossless compression with transparency support using RGBA8 format
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let encoder = VideoBufferFrameEncoder()
    /// let imageData = try encoder.encode(
    ///     videoBuffer,
    ///     format: .jpeg
    /// )
    /// ```
    ///
    /// ## Error Handling
    ///
    /// This method throws `UtilityError` with `FrameEncoderErrorReason.failedToEncodeBuffer`
    /// when:
    /// - Core Image context is unavailable
    /// - Image buffer cannot be extracted from sample buffer
    /// - Color space conversion fails
    /// - Format-specific encoding fails
    ///
    /// ## Thread Safety
    ///
    /// This method is thread-safe and can be called from any thread. Core Image contexts
    /// are designed to be used concurrently.
    ///
    /// - Parameters:
    ///   - buffer: The video sample buffer containing the image data to encode
    ///   - format: The target image format (JPEG, PNG, or HEIC)
    /// - Returns: The encoded image data as a `Data` object
    /// - Throws: `UtilityError` if any step of the encoding process fails
    func encode(_ buffer: VideoSampleBuffer, format: FileFormat) throws(UtilityError) -> Data {
        let devicePosition = buffer.isMirrored ? AVCaptureDevice.Position.front : .back
        let sampleBuffer = buffer.sampleBuffer

        sampleBuffer.append(metadataAdditions: Self.imageMetadata)

        if let context, let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            let orientation = CGImagePropertyOrientation(from: buffer.orientation, devicePosition: devicePosition)
            var cIImage = CIImage(cvPixelBuffer: imageBuffer).oriented(orientation)

            guard let colorSpace = cIImage.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB) else {
                throw UtilityError(
                    kind: .FrameEncoderErrorReason.failedToEncodeBuffer,
                    failureReason: "Unable to determine color space for image processing"
                )
            }

            cIImage =
                cIImage
                    .cropped(to: cIImage.extent.integral)
                    .applyingFilter("CILanczosScaleTransform", parameters: [kCIInputAspectRatioKey: 1])

            return try context.dataRepresentation(of: cIImage, for: format, colorSpace: colorSpace)
        }

        throw UtilityError(
            kind: .FrameEncoderErrorReason.failedToEncodeBuffer,
            failureReason: "Unable to extract image buffer from sample buffer or Core Image context is unavailable"
        )
    }
}
