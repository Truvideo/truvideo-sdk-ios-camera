//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// Represents common video resolutions with a human-readable title
/// and their corresponding width/height values.
enum VideoResolution: CaseIterable {
    /// Full High Definition (1920x1080)
    case fullHD

    /// High Definition (1280x720)
    case highDefinition

    /// Standard Definition (640x480)
    case standard

    // MARK: - Properties

    /// Localized display name for each resolution
    var title: String {
        switch self {
        case .standard:
            Localizations.resolutionSd

        case .highDefinition:
            Localizations.resolutionHd

        case .fullHD:
            Localizations.resolutionFhd
        }
    }

    /// The pixel size (width and height) of the resolution.
    var size: CGSize {
        switch self {
        case .standard:
            CGSize(width: 640, height: 480)

        case .highDefinition:
            CGSize(width: 1_280, height: 720)

        case .fullHD:
            CGSize(width: 1_920, height: 1_080)
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
            self = .standard

        case (1280, 720):
            self = .highDefinition

        case (1920, 1080):
            self = .fullHD

        default:
            self = .standard
        }
    }
}
