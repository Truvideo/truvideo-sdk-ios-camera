//
// Copyright © 2025 TruVideo. All rights reserved.
//

/// Represents common video resolutions with a human-readable title
/// and their corresponding width/height values.
enum VideoResolution: CaseIterable {
    /// Standard Definition (640x480)
    case sd

    /// High Definition (1280x720)
    case hd

    /// Full High Definition (1920x1080)
    case fullHD

    // MARK: - Properties

    /// Localized display name for each resolution
    var title: String {
        switch self {
        case .sd:
            return Localizations.resolutionSd
        case .hd:
            return Localizations.resolutionHd
        case .fullHD:
            return Localizations.resolutionFhd
        }
    }

    /// The pixel size (width and height) of the resolution.
    var size: (width: Int, height: Int) {
        switch self {
        case .sd:
            return (640, 480)

        case .hd:
            return (1280, 720)

        case .fullHD:
            return (1920, 1080)
        }
    }

    // MARK: - Initializer

    /// Initializes a resolution based on width and height values.
    ///
    /// - Parameters:
    ///   - width: The width in pixels.
    ///   - height: The height in pixels.
    init(width: Int, height: Int) {
        switch (width, height) {
        case (640, 480):
            self = .sd

        case (1280, 720):
            self = .hd

        case (1920, 1080):
            self = .fullHD

        default:
            self = .sd
        }
    }
}
