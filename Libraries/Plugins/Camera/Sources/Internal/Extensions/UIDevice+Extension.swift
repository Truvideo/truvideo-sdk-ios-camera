//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation
import UIKit

extension UIDevice {
    /// A boolean value indicating whether the device is an iPad.
    ///
    /// This computed property provides a convenient way to check if the current device
    /// is an iPad. It returns `true` if the device's user interface idiom is `.pad`,
    /// and `false` for all other device types (iPhone, iPod touch, etc.).
    ///
    /// This property is particularly useful for implementing device-specific UI layouts,
    /// camera configurations, or other iPad-specific functionality in the camera plugin.
    var isPad: Bool {
        userInterfaceIdiom == .pad
    }
}
