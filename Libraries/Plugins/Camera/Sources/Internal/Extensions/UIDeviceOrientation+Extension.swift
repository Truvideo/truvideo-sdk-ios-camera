//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation
import UIKit

extension UIDeviceOrientation {
    // MARK: - Initializer

    /// Creates an orientation instance from an `AVCaptureVideoOrientation`.
    ///
    /// This initializer converts an `AVCaptureVideoOrientation` to the corresponding
    /// orientation value, handling the landscape orientation mapping where left and right
    /// are swapped. It provides a safe conversion with a default fallback for unknown
    /// orientation values.
    ///
    /// - Parameter orientation: The `AVCaptureVideoOrientation` to convert from
    init(from orientation: AVCaptureVideoOrientation) {
        switch orientation {
        case .landscapeLeft:
            self = .landscapeRight

        case .landscapeRight:
            self = .landscapeLeft

        case .portrait:
            self = .portrait

        case .portraitUpsideDown:
            self = .portraitUpsideDown

        @unknown default:
            self = .portrait
        }
    }
}
