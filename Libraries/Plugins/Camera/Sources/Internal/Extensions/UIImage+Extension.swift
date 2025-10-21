//
// Copyright © 2025 TruVideo. All rights reserved.
//

import UIKit

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
    func data(with fileFormat: FileFormat) -> Data? {
        switch fileFormat {
        case .heic:
            if #available(iOS 17.0, *) {
                heicData()
            } else {
                jpegData(compressionQuality: fileFormat.quality)
            }

        case .jpeg:
            jpegData(compressionQuality: fileFormat.quality)

        case .png:
            pngData()
        }
    }

    /// Returns a resized and compressed version of the image optimized for UI thumbnails.
    ///
    /// This function creates a thumbnail version of the image by resizing it to fit within
    /// the specified maximum dimensions while maintaining the original aspect ratio, then
    /// compressing it using JPEG encoding. The function is designed to create lightweight
    /// images suitable for display in lists, grids, or preview interfaces.
    ///
    /// ## Resizing Algorithm
    ///
    /// The function calculates the new dimensions based on the image's aspect ratio:
    /// - **Landscape images** (width > height): Width is set to `maxSize`, height is calculated proportionally
    /// - **Portrait images** (height > width): Height is set to `maxSize`, width is calculated proportionally
    /// - **Square images**: Both dimensions are set to `maxSize`
    ///
    /// - Parameters:
    ///   - maxSize: The maximum size (in points) for width or height. Defaults to 200.
    ///   - compressionQuality: The JPEG compression quality (0.0 - 1.0). Defaults to 0.9.
    /// - Returns: A resized and compressed `UIImage` suitable for thumbnails, or `nil` if compression fails.
    func thumbnail(maxSize: CGFloat = 200, compressionQuality: CGFloat = 0.9) -> UIImage? {
        let aspectRatio = size.width / size.height
        var newSize = if aspectRatio > 1 {
            CGSize(width: maxSize, height: (maxSize / aspectRatio).rounded(.down))
        } else {
            CGSize(width: (maxSize * aspectRatio).rounded(.down), height: maxSize)
        }

        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resized = renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }

        guard let data = resized.jpegData(compressionQuality: compressionQuality) else {
            return nil
        }

        return UIImage(data: data)
    }
}
