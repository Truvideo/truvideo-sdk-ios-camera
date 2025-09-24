//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation

extension AVCaptureSession.Preset {
    /// The aspect ratio of the video resolution.
    ///
    /// Returns the width-to-height ratio as a CGFloat. SD preset uses 4:3 ratio,
    /// while HD and FHD presets use 16:9 ratio.
    var aspectRatio: CGFloat {
        guard size.height > 0 else {
            return 0
        }

        return size.width / size.height
    }

    /// The recommended bit rate for video encoding in bits per second.
    ///
    /// Returns the optimal bit rate for each preset based on resolution and quality requirements.
    /// Higher resolutions require higher bit rates to maintain quality.
    var bitRate: Int {
        switch self {
        case .vga640x480:
            1_000_000

        case .hd1280x720:
            2_500_000

        case .hd1920x1080:
            4_000_000

        default:
            0
        }
    }

    /// The resolution name in "width x height" format.
    ///
    /// Returns the technical resolution specification as a string in the format
    /// "widthxheight", suitable for technical documentation or detailed UI displays.
    var description: String {
        switch self {
        case .vga640x480:
            "640x480"

        case .hd1280x720:
            "1280x720"

        case .hd1920x1080:
            "1920x1080"

        default:
            Localizations.unknown
        }
    }

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

    /// The user-facing display name for the preset.
    ///
    /// Returns a short, user-friendly name suitable for display in UI components
    /// such as buttons, labels, or selection menus.
    var localizedLabel: String {
        switch self {
        case .vga640x480:
            Localizations.sd

        case .hd1280x720:
            Localizations.hd

        case .hd1920x1080:
            Localizations.fhd

        default:
            Localizations.unknown
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
