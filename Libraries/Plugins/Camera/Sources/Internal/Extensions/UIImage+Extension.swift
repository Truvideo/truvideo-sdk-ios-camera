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
