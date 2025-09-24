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
}
