//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

/// A collection of custom design system images used throughout the camera interface.
///
/// `DSImages` provides centralized access to all image assets loaded from the app's bundle,
/// ensuring consistency in imagery across the camera interface and simplifying maintenance.
///
/// ## Usage
///
/// ```swift
/// // Access the camera flip icon
/// DSImages.cameraTrianglehead
///
/// // Access the viewfinder image
/// DSImages.viewFinder
/// ```
public struct DSImages {
    /// Represents the camera flip action, loaded from the app's custom image assets.
    static let cameraTrianglehead = Image("flip-camera", bundle: Bundle(for: BundleLocator.self))

    /// Represents a viewfinder image, typically used to indicate a camera focus or scanning interface.
    static let viewFinder = Image("tap-to-focus", bundle: Bundle(for: BundleLocator.self))
}
