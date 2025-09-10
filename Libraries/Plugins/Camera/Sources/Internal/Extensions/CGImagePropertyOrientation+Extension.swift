//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVKit
import Foundation

extension CGImagePropertyOrientation {
    /// Creates a new instance of `CGImagePropertyOrientation` derived from an
    /// `AVCaptureVideoOrientation` and a camera `AVCaptureDevice.Position`.
    ///
    /// Use this to convert the capture orientation reported by AVFoundation into the
    /// pixel orientation you should apply when rendering/exporting frames so they appear upright.
    /// This mapping keeps photos from `AVCapturePhotoOutput` and frames from
    /// `AVCaptureVideoDataOutput` visually consistent. It mirrors **front-camera portrait**
    /// selfies by default.
    ///
    /// - Parameters:
    ///   - orientation: The orientation reported by AVFoundation.
    ///   - devicePosition: The physical camera position.
    init(from orientation: AVCaptureVideoOrientation, devicePosition: AVCaptureDevice.Position) {
        self =
            switch (orientation, devicePosition) {
            case (.portrait, .front):
                .leftMirrored

            case (.portrait, _):
                .right

            case (.portraitUpsideDown, .front):
                .rightMirrored

            case (.portraitUpsideDown, _):
                .left

            case (.landscapeLeft, .front):
                .upMirrored

            case (.landscapeLeft, _):
                .down

            case (.landscapeRight, .front):
                .downMirrored

            case (.landscapeRight, _):
                .up

            @unknown default:
                .up
            }
    }
}
