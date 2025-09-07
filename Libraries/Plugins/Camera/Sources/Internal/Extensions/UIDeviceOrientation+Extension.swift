//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation
import UIKit

extension UIDeviceOrientation {
    /// Determines whether the device orientation is in landscape mode.
    ///
    /// This computed property checks if the current device orientation represents
    /// a landscape orientation. It returns `true` for both left and right landscape
    /// orientations.
    var isLandscape: Bool {
        switch self {
        case .landscapeLeft, .landscapeRight:
            true

        default:
            false
        }
    }

    /// Determines whether the device orientation is in portrait mode.
    ///
    /// This computed property checks if the current device orientation represents
    /// a portrait orientation.
    var isPortrait: Bool {
        switch self {
        case .portrait, .portraitUpsideDown:
            true

        default:
            false
        }
    }

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
