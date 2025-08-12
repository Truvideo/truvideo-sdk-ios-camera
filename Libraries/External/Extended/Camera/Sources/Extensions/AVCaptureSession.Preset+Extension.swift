//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation

extension AVCaptureSession.Preset {
    /// Maps the capture preset to a corresponding export preset string.
    ///
    /// Use this to select an `AVAssetExportSession` preset that roughly matches the active
    /// capture resolution. Presets not explicitly handled fall back to 1080p.
    ///
    /// - Returns: An `AVAssetExportPreset*` string suitable for `AVAssetExportSession`.
    var exportPreset: String {
        switch self {
        case .vga640x480:
            AVAssetExportPreset640x480

        case .hd1280x720:
            AVAssetExportPreset1280x720

        default:
            AVAssetExportPreset1920x1080
        }
    }

    /// Pixel dimensions associated with the capture preset.
    ///
    /// Provides a convenient `CGSize` for layout or settings derivation based on the active
    /// session preset. Presets not explicitly handled fall back to 1080p dimensions.
    ///
    /// - Returns: The width and height in pixels for the preset.
    var size: CGSize {
        switch self {
        case .vga640x480:
            CGSize(width: 640, height: 480)

        case .hd1280x720:
            CGSize(width: 1_280, height: 720)

        default:
            CGSize(width: 1_920, height: 1_080)
        }
    }
}
