//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVKit
import CoreImage
import CoreMedia
import UIKit

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
        let options: [CIContextOption: Any] = [
            .outputColorSpace: CGColorSpaceCreateDeviceRGB(),
            .outputPremultiplied: true,
            .useSoftwareRenderer: NSNumber(value: false),
        ]

        if let device = MTLCreateSystemDefaultDevice() {
            return CIContext(mtlDevice: device, options: options)
        }

        return nil
    }

    // MARK: - Instance methods

    /// Converts a CMSampleBuffer to a UIImage for display or processing.
    ///
    /// This function extracts image data from a Core Media sample buffer and converts
    /// it to a UIImage format suitable for UI display or further image processing.
    /// It handles the conversion from CVPixelBuffer to CIImage, then to CGImage,
    /// and finally to UIImage while preserving the original dimensions.
    ///
    /// The function performs a multi-step conversion process: first extracting the
    /// pixel buffer from the sample buffer, creating a CIImage from the pixel buffer,
    /// generating a CGImage from the CIImage using the full buffer dimensions,
    /// and finally creating a UIImage from the CGImage.
    ///
    /// - Parameters:
    ///    - sampleBuffer: The Core Media sample buffer containing image data.
    ///    - orientation: The orientation to be applied for the image.
    /// - Returns: A UIImage representation of the sample buffer, or nil if the conversion
    ///            process fails at any step
    func createImage(from sampleBuffer: CMSampleBuffer, orientation: CGImagePropertyOrientation) -> UIImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }

        var cImage = CIImage(cvPixelBuffer: pixelBuffer).oriented(orientation)
        cImage = cImage.cropped(to: cImage.extent.integral)

        var sampleBufferImage: UIImage?

        if let cgimage = createCGImage(cImage, from: cImage.extent) {
            sampleBufferImage = UIImage(cgImage: cgimage)
        }

        return sampleBufferImage
    }
}
