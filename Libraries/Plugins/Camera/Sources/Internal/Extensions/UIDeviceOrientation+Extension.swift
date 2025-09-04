//
// Copyright © 2025 TruVideo. All rights reserved.
//

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
}
