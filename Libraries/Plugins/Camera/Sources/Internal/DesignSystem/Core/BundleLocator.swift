//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A utility class for locating the correct bundle within a framework context.
///
/// `BundleLocator` provides a centralized way to access the framework's bundle,
/// ensuring that resources like color assets, images, and other bundled files
/// are loaded from the correct location rather than the main app bundle.
///
/// ## Purpose
///
/// When working within a framework, using `Bundle.main` will reference the main
/// app's bundle, not the framework's bundle. This can cause issues when trying
/// to access framework-specific resources like:
/// - Color assets (`.xcassets`)
/// - Image resources
/// - Localized strings
/// - Other bundled files
///
/// ## Usage
///
/// ```swift
/// // Access the framework's bundle
/// let bundle = Bundle(for: BundleLocator.self)
///
/// // Use with color assets
/// Color("amber", bundle: Bundle(for: BundleLocator.self))
///
/// // Use with image resources
/// Image("icon", bundle: Bundle(for: BundleLocator.self))
///
/// // Use with localized strings
/// String(localized: "key", bundle: Bundle(for: BundleLocator.self))
/// ```
///
/// ## Framework Integration
///
/// This class is designed to be used throughout the framework to ensure consistent
/// bundle access. It's particularly useful in design system components that need
/// to load theme-specific resources like colors and images.
///
/// ## Example in Design System
///
/// ```swift
/// public static let `default` = DSColorScheme(
///     primary: Color("amber", bundle: Bundle(for: BundleLocator.self)),
///     onPrimary: Color.white,
///     // ... other colors
/// )
/// ```
///
/// - Note: This class is intentionally empty as it serves only as a bundle reference.
///   The actual bundle access is done through `Bundle(for: BundleLocator.self)`.
final class BundleLocator {}
