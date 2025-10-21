//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

/// A representation of a color with support for dynamic member lookup.
///
/// The `DSColor` struct allows defining a primary color and an associated swatch of colors,
/// which can be accessed dynamically using an integer-based subscript. This enables easy
/// retrieval of color variants while maintaining a clean and extensible API.
///
/// ### Example Usage:
/// ```swift
/// let baseColor = Color(primary: .red, swatch: [100: .lightRed, 200: .darkRed])
/// let shade = baseColor[100] // Retrieves .lightRed if available, otherwise falls back to primary.
/// ```
///
/// - Conforms to:
///   - `Sendable`: Ensures safe usage in concurrent environments.
///   - `@dynamicMemberLookup`: Enables integer-based subscript access for swatch colors.
@dynamicMemberLookup
public struct DSColor: Sendable {
    // MARK: - Private Properties

    /// The primary color of this `Color` instance.
    private let primary: Color

    /// A dictionary containing different shades or variations of the color, mapped by intensity levels.
    private let swatch: [String: Color]

    // MARK: - Static Properties

    /// Amber Color Palette
    ///
    /// - Primary: Indigo (#416AE5)
    /// - Swatch Shades:
    public static let amber = DSColor(
        primary: Color("amber", bundle: Bundle(for: BundleLocator.self)),
        swatch: [
            "shade500": Color("amber", bundle: Bundle(for: BundleLocator.self))
        ]
    )

    /// Gray Color Palette
    ///
    /// - Primary: Dark Gray (#3C404D)
    /// - Swatch Shades:
    ///   - shade50: Mist Gray (#F4F4F6)
    ///   - shade100: Silver Slate (#9EA0A5)
    ///   - shade200: Graphite Mist (#6D7079)
    ///   - shade500: Dark Gray (#3C404D)
    public static let gray: DSColor = .init(
        primary: Color("darkGray", bundle: Bundle(for: BundleLocator.self)),
        swatch: [
            "shade50": Color("snow", bundle: Bundle(for: BundleLocator.self)),
            "shade100": Color("frost", bundle: Bundle(for: BundleLocator.self)),
            "shade200": Color("mist", bundle: Bundle(for: BundleLocator.self)),
            "shade300": Color("cloud", bundle: Bundle(for: BundleLocator.self)),
            "shade400": Color("silver", bundle: Bundle(for: BundleLocator.self)),
            "shade500": Color("storm", bundle: Bundle(for: BundleLocator.self)),
            "shade600": Color("shadow", bundle: Bundle(for: BundleLocator.self)),
            "shade700": Color("dusk", bundle: Bundle(for: BundleLocator.self)),
            "shade800": Color("night", bundle: Bundle(for: BundleLocator.self)),
            "shade850": Color("midnight", bundle: Bundle(for: BundleLocator.self)),
            "shade900": Color("void", bundle: Bundle(for: BundleLocator.self))
        ]
    )

    /// Green Color Palette
    ///
    /// - Primary: Teal (#3B8566)
    /// - Swatch Shades:
    ///   - shade200: Teal (#3B8566)
    ///   - shade500: Green (#008000)
    public static let green: DSColor = .init(
        primary: Color("teal", bundle: Bundle(for: BundleLocator.self)),
        swatch: [
            "shade200": Color("teal", bundle: Bundle(for: BundleLocator.self)),
            "shade500": .green
        ]
    )

    /// Red Color Palette
    ///
    /// - Primary: Red (#DC2626)
    /// - Swatch Shades:
    ///   - shade200: Ruby Red (#CF3049)
    ///   - shade500: Red (#DC2626)
    public static let red = DSColor(
        primary: Color("red", bundle: Bundle(for: BundleLocator.self)),
        swatch: [
            "shade500": Color("red", bundle: Bundle(for: BundleLocator.self))
        ]
    )

    // MARK: - Subscript

    /// Provides dynamic access to the color swatch based on an integer key.
    ///
    /// If the specified key exists in the swatch, it returns the corresponding color.
    /// Otherwise, it returns the primary color as a fallback.
    ///
    /// - Parameter member: An integer representing the shade intensity (e.g., 100, 200, etc.).
    /// - Returns: The `Color` corresponding to the provided key, or the `primary` color if the key is not found.
    ///
    /// ### Example Usage:
    /// ```swift
    /// let color = Color(primary: .blue, swatch: [50: .lightBlue, 100: .mediumBlue])
    /// let shade = color[100] // Retrieves .mediumBlue
    /// let defaultColor = color[300] // Defaults to .blue
    /// ```
    public subscript(dynamicMember member: String) -> Color {
        swatch[member, default: primary]
    }

    // MARK: - Initializer

    /// Creates a `Color` instance with a primary color and an optional swatch of color variations.
    ///
    /// - Parameters:
    ///   - primary: The primary color.
    ///   - swatch: A dictionary mapping integer shade levels to specific color variations.
    public init(primary: Color, swatch: [String: Color]) {
        self.primary = primary
        self.swatch = swatch
    }
}
