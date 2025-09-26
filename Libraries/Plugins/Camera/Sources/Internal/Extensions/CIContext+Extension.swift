//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVKit
import CoreImage
import CoreMedia
import UIKit
internal import Utilities

extension ErrorReason {
    /// A collection of error reasons related to Core Image context operations.
    ///
    /// The `CIContextErrorReason` struct provides a set of static constants representing
    /// various errors that can occur during Core Image context operations. These error
    /// reasons help identify specific failure points in image processing workflows,
    /// making debugging and error handling more precise and informative.
    struct CIContextErrorReason: Sendable {
        /// Indicates that data representation conversion failed during Core Image processing.
        ///
        /// This error occurs when Core Image context operations fail to convert
        /// image data to the requested representation format. Common causes include:
        ///
        /// - Unsupported image format or color space
        /// - Insufficient memory for the conversion operation
        /// - Invalid or corrupted input image data
        /// - Hardware acceleration unavailable or failed
        ///
        /// ## Error Context
        ///
        /// This error is typically thrown during:
        /// - `heifRepresentation()` operations
        /// - `jpegRepresentation()` operations
        /// - `pngRepresentation()` operations
        /// - Custom data format conversions
        static let dataRepresentationFailed = ErrorReason(rawValue: "DATA_REPRESENTATION_FAILED")
    }
}

extension CIContext {
    /// Creates a default CIContext configured for optimal performance.
    ///
    /// This function initializes a CIContext with Metal GPU acceleration and optimized
    /// settings for image processing operations. It uses the system's default Metal
    /// device for hardware acceleration and configures color space and rendering
    /// options for best performance and compatibility.
    ///
    /// The context is configured with device RGB color space, premultiplied alpha
    /// for proper blending, and hardware rendering enabled. If Metal is not available
    /// on the device, the function returns nil to allow fallback to software rendering.
    ///
    /// - Returns: A configured CIContext instance optimized for performance, or nil
    ///           if Metal device is not available
    static func createDefault() -> CIContext? {
        guard
            /// The output color space.
            let outputColorSpace = CGColorSpace(name: CGColorSpace.sRGB),

            /// The working color space.
            let workingColorSpace = CGColorSpace(name: CGColorSpace.linearSRGB)
        else {

            return nil
        }

        let options: [CIContextOption: Any] = [
            .cacheIntermediates: true,
            .outputColorSpace: outputColorSpace,
            .outputPremultiplied: true,
            .highQualityDownsample: true,
            .useSoftwareRenderer: false,
            .workingColorSpace: workingColorSpace,
        ]

        if let device = MTLCreateSystemDefaultDevice() {
            return CIContext(mtlDevice: device, options: options)
        }

        return nil
    }

    /// Converts a Core Image representation to data in the specified format.
    ///
    /// This method takes a `CIImage` and converts it to binary data using the specified
    /// file format and color space. It handles format-specific encoding options including
    /// compression quality settings, color optimization, and ensures the image is cropped
    /// to integral bounds for clean output.
    ///
    /// ## Processing Steps
    ///
    /// 1. Crops the image to integral bounds to eliminate fractional pixels
    /// 2. Applies format-specific quality and optimization settings
    /// 3. Encodes the image using the appropriate Core Image representation method
    /// 4. Returns the encoded data or throws an error if encoding fails
    ///
    /// ## Encoding Options
    ///
    /// The method applies several optimization options:
    /// - **Quality Control**: Uses `kCGImageDestinationLossyCompressionQuality` for lossy formats
    /// - **Color Optimization**: Uses `kCGImageDestinationOptimizeColorForSharing` for better color reproduction
    /// - **Format-Specific Settings**: Applies appropriate options for each format type
    ///
    /// ## Format Support
    ///
    /// - **HEIC**: Uses HEIF representation with RGBA8 format and configurable quality
    /// - **JPEG**: Uses JPEG representation with configurable compression quality
    /// - **PNG**: Uses PNG representation with RGBA8 format (lossless compression)
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let context = CIContext.createDefault()
    /// let imageData = try context.dataRepresentation(
    ///     of: cIImage,
    ///     format: .jpeg,
    ///     colorSpace: sRGBColorSpace
    /// )
    /// ```
    ///
    /// ## Error Handling
    ///
    /// This method throws `UtilityError` with `FrameEncoderErrorReason.failedToEncodeBuffer`
    /// when the format-specific encoding operation fails. The error message includes
    /// the specific format that failed to help identify the exact failure point.
    ///
    /// ## Thread Safety
    ///
    /// This method is thread-safe and can be called from any thread. Core Image contexts
    /// are designed to be used concurrently.
    ///
    /// - Parameters:
    ///   - cIImage: The Core Image representation to convert to data
    ///   - format: The target file format (HEIC, JPEG, or PNG)
    ///   - colorSpace: The color space to use for encoding
    /// - Returns: The encoded image data as a `Data` object
    /// - Throws: `UtilityError` if the encoding operation fails for the specified format
    func dataRepresentation(
        of cIImage: CIImage,
        for format: FileFormat,
        colorSpace: CGColorSpace
    ) throws(UtilityError) -> Data {

        let cIImage = cIImage.cropped(to: cIImage.extent.integral)
        let options: [CIImageRepresentationOption: Any] = [
            kCGImageDestinationLossyCompressionQuality as CIImageRepresentationOption: format.quality,
            kCGImageDestinationOptimizeColorForSharing as CIImageRepresentationOption: true,
        ]

        let data: Data?

        switch format {
        case .heic:
            data = heifRepresentation(of: cIImage, format: .RGBA8, colorSpace: colorSpace, options: options)

        case .jpeg:
            data = jpegRepresentation(of: cIImage, colorSpace: colorSpace, options: options)

        case .png:
            data = pngRepresentation(of: cIImage, format: .RGBA8, colorSpace: colorSpace)
        }

        guard let data else {
            throw UtilityError(
                kind: .CIContextErrorReason.dataRepresentationFailed,
                failureReason: "Failed to encode image data to format \(format)"
            )
        }

        return data
    }

    /// Creates a `UIImage` from a Core Media sample buffer with optional orientation correction.
    ///
    /// This method converts a `CMSampleBuffer` (typically from a video capture session) into a
    /// `UIImage` object suitable for display in UIKit interfaces. It handles the complete
    /// conversion pipeline from Core Video pixel buffer to Core Image, applies orientation
    /// correction, and creates a Core Graphics image for UIKit consumption.
    ///
    /// - Parameters:
    ///   - sampleBuffer: The Core Media sample buffer containing video frame data
    ///   - preferredOrientation: The desired orientation for the resulting image.
    /// - Returns: A `UIImage` created from the sample buffer, or `nil` if conversion fails.
    func image(from sampleBuffer: CMSampleBuffer, preferredOrientation: CGImagePropertyOrientation) -> UIImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }

        let cIImage = CIImage(cvPixelBuffer: pixelBuffer, options: [.applyOrientationProperty: false])
            .oriented(preferredOrientation)

        let normalized = cIImage.transformed(
            by: CGAffineTransform(
                translationX: -cIImage.extent.origin.x.rounded(.toNearestOrAwayFromZero),
                y: -cIImage.extent.origin.y.rounded(.toNearestOrAwayFromZero)
            )
        )

        guard let cgImage = createCGImage(normalized, from: normalized.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}
