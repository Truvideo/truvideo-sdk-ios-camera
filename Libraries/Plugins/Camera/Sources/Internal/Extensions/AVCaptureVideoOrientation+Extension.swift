//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation
import UIKit

extension AVCaptureVideoOrientation {
    /// Creates a video orientation instance from a device orientation.
    ///
    /// This initializer converts a UIDeviceOrientation value to the corresponding
    /// AVCaptureVideoOrientation value for use with camera capture sessions.
    /// It provides a convenient way to map device orientation detection
    /// to video capture orientation settings.
    ///
    /// The initializer handles the most common device orientations used in video
    /// capture scenarios. Landscape orientations are mapped directly to their
    /// corresponding video orientations, while all other orientations (including
    /// portrait, portrait upside down, face up, face down, and unknown) default
    /// to portrait orientation for consistent behavior.
    ///
    /// - Parameter orientation: The device orientation to convert to video orientation
    init(from orientation: UIDeviceOrientation) {
        self =
            switch orientation {
            case .landscapeLeft:
                .landscapeRight

            case .landscapeRight:
                .landscapeLeft

            default:
                .portrait
            }
    }
}
