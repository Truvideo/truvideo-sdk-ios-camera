//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit
import UniformTypeIdentifiers
internal import Utilities

extension ErrorReason {
    /// A collection of error reasons related to image exporting operations.
    ///
    /// The `ImageExportingErrorReason` struct provides a set of static constants representing various errors that can
    /// occur
    /// during image exporting operations. These error reasons help identify specific failure points in the image
    /// processing
    /// and export pipeline, making debugging and error handling more precise and informative.
    struct ImageExportingErrorReason: Sendable {
        /// Error reason indicating that image export operation failed.
        ///
        /// This error occurs when the image exporter is unable to process image data
        /// or complete the export operation. Common causes include invalid image data,
        /// missing Core Image context, format conversion failures, or file I/O errors.
        static let failedToExportImage = ErrorReason(rawValue: "FAILED_TO_EXPORT_IMAGE")
    }
}

/// A protocol that defines the interface for image export operations.
///
/// The `ImageExporting` protocol provides a standardized way to handle image export
/// operations including thumbnail generation and data export with size constraints.
/// It abstracts the export process, allowing different implementations to be used
/// while maintaining a consistent interface for image processing and export.
///
/// This protocol is typically used for creating thumbnails, resizing images,
/// format conversion, and optimizing images for different use cases.
protocol ImageExporting: Sendable {
    /// Creates a thumbnail image from a source image file.
    ///
    /// This method generates a thumbnail version of the source image with the specified
    /// maximum pixel dimension. The thumbnail is optimized for quick loading and display
    /// in UI components while maintaining aspect ratio and quality.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// try exporter.createThumbnail(
    ///     from: sourceURL,
    ///     to: thumbnailURL,
    ///     constrainedTo: 200
    /// )
    /// ```
    ///
    /// ## Thread Safety
    ///
    /// This method should be thread-safe and can be called from any thread.
    ///
    /// - Parameters:
    ///   - sourceURL: The file URL of the source image to create a thumbnail from
    ///   - destinationURL: The file URL where the thumbnail should be saved
    ///   - maxPixel: The maximum pixel dimension (width or height) for the thumbnail
    /// - Throws: `UtilityError` if thumbnail creation fails
    func createThumbnail(
        from sourceURL: URL,
        to destinationURL: URL,
        constrainedTo maxPixel: CGFloat
    ) throws(UtilityError)

    /// Exports image data to a file with size constraints and format conversion.
    ///
    /// This method takes image data and exports it to a file with the specified size
    /// constraints, format, and orientation. It handles scaling, format conversion,
    /// and quality optimization automatically.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// try exporter.export(
    ///     imageData,
    ///     to: outputURL,
    ///     constrainedTo: CGSize(width: 800, height: 600),
    ///     format: .jpeg,
    ///     preferedOrientation: .up
    /// )
    /// ```
    ///
    /// ## Thread Safety
    ///
    /// This method should be thread-safe and can be called from any thread.
    ///
    /// - Parameters:
    ///   - data: The image data to export
    ///   - url: The file URL where the exported image should be saved
    ///   - size: The maximum size constraints for the exported image
    ///   - format: The target file format for the exported image
    ///   - orientation: The preferred orientation for the exported image
    /// - Throws: `UtilityError` if export operation fails
    func export(
        _ data: Data,
        to url: URL,
        constrainedTo size: CGSize,
        format: FileFormat,
        preferedOrientation orientation: CGImagePropertyOrientation
    ) throws(UtilityError)
}

extension ImageExporting {
    /// Creates a thumbnail image from a source image file with default size constraints.
    ///
    /// This convenience method creates a thumbnail with a default maximum pixel dimension
    /// of 200 pixels, which is suitable for most UI thumbnail display scenarios.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// try exporter.createThumbnail(from: sourceURL, to: thumbnailURL)
    /// ```
    ///
    /// ## Thread Safety
    ///
    /// This method is thread-safe and can be called from any thread.
    ///
    /// - Parameters:
    ///   - sourceURL: The file URL of the source image to create a thumbnail from
    ///   - destinationURL: The file URL where the thumbnail should be saved
    /// - Throws: `UtilityError` if thumbnail creation fails
    func createThumbnail(from sourceURL: URL, to destinationURL: URL) throws(UtilityError) {
        try createThumbnail(from: sourceURL, to: destinationURL, constrainedTo: 200)
    }
}

/// A concrete implementation of `ImageExporting` that uses Core Graphics and Core Image.
///
/// The `ImageExporter` struct provides a Core Graphics and Core Image-based implementation
/// of the `ImageExporting` protocol, specifically designed to handle image export operations
/// including thumbnail generation and data export with size constraints. It uses advanced
/// image processing techniques for high-quality results.
///
/// This implementation supports JPEG, PNG, and HEIC formats with configurable quality
/// settings, automatic scaling with aspect ratio preservation, and screen scale awareness
/// for optimal thumbnail generation.
struct ImageExporter: ImageExporting, @unchecked Sendable {
    // MARK: - Private Properties

    private let context = CIContext.createDefault()

    // MARK: - ImageExporting

    /// Exports image data to a file with size constraints and format conversion.
    ///
    /// This method takes image data and exports it to a file with the specified size
    /// constraints, format, and orientation. It handles scaling, format conversion,
    /// and quality optimization automatically.
    ///
    /// - Parameters:
    ///   - data: The image data to export
    ///   - url: The file URL where the exported image should be saved
    ///   - size: The maximum size constraints for the exported image
    ///   - format: The target file format for the exported image
    ///   - orientation: The preferred orientation for the exported image
    /// - Throws: `UtilityError` if export operation fails
    func createThumbnail(
        from sourceURL: URL,
        to destinationURL: URL,
        constrainedTo maxPixel: CGFloat
    ) throws(UtilityError) {
        let options = [kCGImageSourceShouldCache: false]
        let maxPixelSize = Int(ceil(maxPixel * UIScreen.main.scale))
        let thumbnailOptions: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: false,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
        ]

        guard
            /// Creates an image source that reads from a location specified by a URL.
            let imageSource = CGImageSourceCreateWithURL(sourceURL as CFURL, options as CFDictionary),

            /// The thumbnail version of the image at the specified index in an image source.
            let cgImageThumbnail = CGImageSourceCreateThumbnailAtIndex(
                imageSource,
                0,
                thumbnailOptions as CFDictionary
            ),

            /// The image destination that writes image data to the specified URL.
            let imageDestination = CGImageDestinationCreateWithURL(
                destinationURL as CFURL,
                UTType.png.identifier as CFString,
                1,
                nil
            )
        else {
            throw UtilityError(
                kind: .ImageExportingErrorReason.failedToExportImage,
                failureReason: "Unable to create source image."
            )
        }

        let properties: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: 1,
            kCGImageDestinationOptimizeColorForSharing: true
        ]

        CGImageDestinationAddImage(imageDestination, cgImageThumbnail, properties as CFDictionary)

        guard CGImageDestinationFinalize(imageDestination) else {
            throw UtilityError(
                kind: .ImageExportingErrorReason.failedToExportImage,
                failureReason: "Failed to create thumbnail image."
            )
        }
    }

    /// Creates a thumbnail image from a source image file.
    ///
    /// This method generates a thumbnail version of the source image with the specified
    /// maximum pixel dimension. The thumbnail is optimized for quick loading and display
    /// in UI components while maintaining aspect ratio and quality.
    ///
    /// - Parameters:
    ///   - sourceURL: The file URL of the source image to create a thumbnail from
    ///   - destinationURL: The file URL where the thumbnail should be saved
    ///   - maxPixel: The maximum pixel dimension (width or height) for the thumbnail
    /// - Throws: `UtilityError` if thumbnail creation fails
    func export(
        _ data: Data,
        to url: URL,
        constrainedTo size: CGSize,
        format: FileFormat,
        preferedOrientation orientation: CGImagePropertyOrientation
    ) throws(UtilityError) {
        guard
            /// The current worker context.
            let context,

            /// Creates an image source that reads from a data object.
            let imageSource = CGImageSourceCreateWithData(data as CFData, nil),

            /// The image object from the data at the specified index.
            let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
        else {
            throw UtilityError(
                kind: .ImageExportingErrorReason.failedToExportImage,
                failureReason: "Unable to create image source from data or extract Core Graphics image"
            )
        }

        var cIImage = CIImage(cgImage: cgImage).oriented(orientation)
        let scale = min(size.width / cIImage.extent.width, size.height / cIImage.extent.height)

        /// Avoids near-1.0 resamples
        if scale < 1.0 - 0.001 {
            let parameters = [kCIInputAspectRatioKey: 1, kCIInputScaleKey: scale]

            cIImage = cIImage.applyingFilter("CILanczosScaleTransform", parameters: parameters)
        }

        guard
            /// The image data.
            let data = CFDataCreateMutable(nil, 0),

            /// Creates a 2D image from a region.
            let cgImage = context.createCGImage(cIImage, from: cIImage.extent),

            /// The image destination from the mutable data object.
            let image = CGImageDestinationCreateWithData(data, format.type.identifier as CFString, 1, nil)
        else {
            throw UtilityError(
                kind: .ImageExportingErrorReason.failedToExportImage,
                failureReason: "Unable to create mutable data, Core Graphics image, or image destination"
            )
        }

        let properties: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: format.quality,
            kCGImageDestinationOptimizeColorForSharing: true
        ]

        CGImageDestinationAddImage(image, cgImage, properties as CFDictionary)

        guard CGImageDestinationFinalize(image) else {
            throw UtilityError(kind: .ImageExportingErrorReason.failedToExportImage, failureReason: "Finalize Failed")
        }

        do {
            try (data as Data).write(to: url, options: .atomic)
        } catch {
            throw UtilityError(kind: .ImageExportingErrorReason.failedToExportImage, underlyingError: error)
        }
    }
}

extension FileFormat {
    /// Returns the corresponding UTType for the file format.
    ///
    /// This computed property provides a mapping between the internal `FileFormat` enum
    /// and the system's `UTType` identifiers. It's used internally by the image export
    /// system to create Core Graphics image destinations with the correct format type.
    ///
    /// ## Format Mappings
    ///
    /// - **HEIC**: Maps to `UTType.heic` for modern HEIF format support
    /// - **JPEG**: Maps to `UTType.jpeg` for standard JPEG format
    /// - **PNG**: Maps to `UTType.png` for PNG format with transparency support
    ///
    /// ## Usage
    ///
    /// This property is used internally by `ImageExporter` when creating Core Graphics
    /// image destinations to ensure the correct format identifier is passed to the
    /// system APIs.
    ///
    /// ## Thread Safety
    ///
    /// This computed property is thread-safe and can be called from any thread.
    fileprivate var type: UTType {
        switch self {
        case .heic:
            .heic

        case .jpeg:
            .jpeg

        case .png:
            .png
        }
    }
}
