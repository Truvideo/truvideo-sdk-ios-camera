//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit

extension CGImage {
    func oriented(to orientation: AVCaptureVideoOrientation, devicePosition: AVCaptureDevice.Position) -> UIImage? {
        let context = CIContext(options: nil)
        let orientation = CGImagePropertyOrientation(from: orientation, devicePosition: devicePosition)
        let cIImage = CIImage(cgImage: self).oriented(orientation)

        guard let image = context.createCGImage(cIImage, from: cIImage.extent) else {
            return nil
        }

        return UIImage(cgImage: image)
    }
}
