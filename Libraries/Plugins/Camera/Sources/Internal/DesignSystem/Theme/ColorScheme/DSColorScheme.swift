//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

/// A comprehensive color scheme system that defines consistent colors for UI components.
///
/// `DSColorScheme` provides a structured approach to managing colors across an application's user interface.
/// It follows Material Design principles with a semantic color system that includes primary, secondary, tertiary,
/// error, surface, and container colors, each with their corresponding "on" colors for content.
///
/// This struct is designed to work with SwiftUI's color system and provides a systematic approach to maintaining
/// consistent theming and ensuring visual clarity and accessibility across your application.
///
/// ## Color System Structure
///
/// The color scheme is organized into semantic color groups:
/// - **Primary Colors**: Main brand colors for primary actions and key UI elements
/// - **Secondary Colors**: Supporting colors for accents and highlights
/// - **Tertiary Colors**: Additional accent colors for variety and emphasis
/// - **Error Colors**: Colors for error states and warnings
/// - **Surface Colors**: Background colors for different UI layers
/// - **Container Colors**: Colors for contained elements with less emphasis
///
/// ## Example Usage
///
/// ```swift
/// // Use the default color scheme
/// let defaultScheme = DSColorScheme.default
///
/// // Create a custom color scheme
/// let customScheme = DSColorScheme(
///     primary: Color.blue,
///     onPrimary: Color.white,
///     secondary: Color.gray,
///     onSecondary: Color.white,
///     tertiary: Color.orange,
///     onTertiary: Color.black,
///     error: Color.red,
///     onError: Color.white,
///     surface: Color.white,
///     surfaceContainer: Color.gray.opacity(0.1),
///     onSurface: Color.black,
///     tertiaryContainer: Color.orange.opacity(0.2),
///     onTertiaryContainer: Color.black
/// )
///
/// // Apply to SwiftUI views
/// Text("Hello World")
///     .foregroundColor(customScheme.onSurface)
///     .background(customScheme.surface)
///
/// // Create theme variations
/// let darkScheme = defaultScheme.copyWith(
///     surface: Color.black,
///     onSurface: Color.white
/// )
/// ```
///
/// ## Accessibility Considerations
///
/// Each color pair (e.g., `primary`/`onPrimary`) is designed to provide sufficient contrast
/// for accessibility compliance. The "on" colors are specifically chosen to ensure readable
/// text and icons when placed on their corresponding background colors.
public struct DSColorScheme: Sendable {
    // MARK: - Primary Colors

    /// The main color used for primary elements of the UI.
    ///
    /// This is typically your brand's primary color, used for main actions, primary buttons,
    /// and key UI elements that should draw the user's attention.
    public let primary: Color

    /// The color used for content displayed on top of the primary color.
    ///
    /// This color provides sufficient contrast against the `primary` color for text, icons,
    /// and other content elements. It's automatically chosen to ensure accessibility compliance.
    public let onPrimary: Color

    // MARK: - Secondary Colors

    /// The secondary color used for accent elements and highlights.
    ///
    /// This color provides visual variety and is used for secondary actions, highlights,
    /// and supporting UI elements that complement the primary color.
    public let secondary: Color

    /// The color used for content displayed on top of the secondary color.
    ///
    /// This color ensures readable content when placed on the `secondary` background,
    /// maintaining accessibility standards.
    public let onSecondary: Color

    // MARK: - Tertiary Colors

    /// The tertiary color used for additional highlights or accents.
    ///
    /// This color provides further visual variety and is used for tertiary actions,
    /// additional highlights, or when you need a third color option in your design.
    public let tertiary: Color

    /// The color used for content displayed on top of the tertiary color.
    ///
    /// This color ensures readable content when placed on the `tertiary` background,
    /// maintaining accessibility standards.
    public let onTertiary: Color

    // MARK: - Error Colors

    /// The color used to indicate error states.
    ///
    /// This color is used for error messages, validation failures, and other error-related
    /// UI elements to clearly communicate problematic states to users.
    public let error: Color

    /// The color used for content displayed on top of the error color.
    ///
    /// This color ensures readable error messages and content when placed on the `error` background.
    public let onError: Color

    // MARK: - Surface Colors

    /// The color used for the main surface of a component or background.
    ///
    /// This color represents the primary background color for your application. It's used
    /// for main content areas, cards, sheets, and other container views. This color helps
    /// establish the visual hierarchy and provides the foundation for your UI.
    public let surface: Color

    /// A color role for a distinct area within the surface.
    ///
    /// This color is used for elevated or distinct areas within the main surface, such as
    /// cards, dialogs, or other contained elements that need to stand out from the background.
    public let surfaceContainer: Color

    /// The color applied to content that appears on top of the surface.
    ///
    /// This color is used for text, icons, and other foreground elements that appear on
    /// the main surface. It's chosen to provide sufficient contrast against the `surface`
    /// color for optimal readability and accessibility.
    public let onSurface: Color

    // MARK: - Static Properties

    /// The default `DSColorScheme` with a dark theme aesthetic.
    ///
    /// This provides a complete set of colors following Material Design principles with
    /// a dark theme that works well for modern applications. The colors are carefully
    /// chosen to provide good contrast and accessibility.
    public static let `default` = DSColorScheme(
        primary: DSColor.gray.shade800,
        onPrimary: .white,
        secondary: .white,
        onSecondary: .black,
        tertiary: DSColor.amber.shadow500,
        onTertiary: .gray,
        error: DSColor.red.shade500,
        onError: .white,
        surface: DSColor.gray.shade900,
        surfaceContainer: .black,
        onSurface: .white
    )

    // MARK: - Initializer

    /// Initializes a new `DSColorScheme` instance with the provided color values.
    ///
    /// This initializer allows you to create a custom color scheme that matches your
    /// application's design requirements. Each color pair should provide sufficient
    /// contrast for accessibility compliance.
    ///
    /// - Parameters:
    ///   - primary: The main color used for primary UI elements.
    ///   - onPrimary: The color used for content displayed on the primary color.
    ///   - secondary: The secondary color used for accents and highlights.
    ///   - onSecondary: The color used for content displayed on the secondary color.
    ///   - error: The color used for error states.
    ///   - onError: The color used for content displayed on the error color.
    ///   - surface: The color used for the main surface of a component or background.
    ///   - surfaceContainer: A color role for a distinct area within the surface.
    ///   - onSurface: The color applied to content that appears on top of the surface.
    public init(
        primary: Color,
        onPrimary: Color,
        secondary: Color,
        onSecondary: Color,
        tertiary: Color,
        onTertiary: Color,
        error: Color,
        onError: Color,
        surface: Color,
        surfaceContainer: Color,
        onSurface: Color
    ) {
        self.primary = primary
        self.onPrimary = onPrimary
        self.secondary = secondary
        self.onSecondary = onSecondary
        self.tertiary = tertiary
        self.onTertiary = onTertiary
        self.error = error
        self.onError = onError
        self.surface = surface
        self.surfaceContainer = surfaceContainer
        self.onSurface = onSurface
    }

    // MARK: - Public methods

    /// Returns a copy of this `DSColorScheme` with the given fields replaced with the new values.
    ///
    /// This method allows you to create a modified version of the color scheme by selectively
    /// updating specific colors while keeping the rest unchanged. This is useful for creating
    /// theme variations or applying custom styling to specific components.
    ///
    /// - Parameters:
    ///   - primary: Optional new primary color
    ///   - onPrimary: Optional new onPrimary color
    ///   - secondary: Optional new secondary color
    ///   - onSecondary: Optional new onSecondary color
    ///   - tertiary: Optional new tertiary color
    ///   - onTertiary: Optional new onTertiary color
    ///   - error: Optional new error color
    ///   - onError: Optional new onError color
    ///   - surface: Optional new surface color
    ///   - surfaceContainer: Optional new surfaceContainer color
    ///   - onSurface: Optional new onSurface color
    /// - Returns: A new `DSColorScheme` instance with the specified colors updated
    public func copyWith(
        primary: Color? = nil,
        onPrimary: Color? = nil,
        secondary: Color? = nil,
        onSecondary: Color? = nil,
        tertiary: Color? = nil,
        onTertiary: Color? = nil,
        error: Color? = nil,
        onError: Color? = nil,
        surface: Color? = nil,
        surfaceContainer: Color? = nil,
        onSurface: Color? = nil
    ) -> DSColorScheme {
        DSColorScheme(
            primary: primary ?? self.primary,
            onPrimary: onPrimary ?? self.onPrimary,
            secondary: secondary ?? self.secondary,
            onSecondary: onSecondary ?? self.onSecondary,
            tertiary: tertiary ?? self.tertiary,
            onTertiary: onTertiary ?? self.onTertiary,
            error: error ?? self.error,
            onError: onError ?? self.onError,
            surface: surface ?? self.surface,
            surfaceContainer: surfaceContainer ?? self.surfaceContainer,
            onSurface: onSurface ?? self.onSurface
        )
    }
}
