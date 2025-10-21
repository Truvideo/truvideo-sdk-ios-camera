//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A comprehensive design system theme that defines the visual appearance and behavior of UI components.
///
/// `Theme` provides a centralized configuration for all design system elements including colors,
/// typography, spacing, corner radius, icons, and component-specific themes. It ensures visual consistency
/// across the entire application by providing a single source of truth for design tokens.
///
/// ## Theme Components
///
/// The theme consists of several interconnected design systems:
/// - **Button Theme**: Configures button appearance and behavior
/// - **Color Scheme**: Defines the color palette and semantic color usage
/// - **Text Theme**: Provides typography styles and text hierarchy
/// - **Icon Theme**: Defines icon styling including color, size, and opacity
/// - **Spacing Theme**: Defines consistent spacing values and layout rules
/// - **Radius Theme**: Establishes corner radius standards for UI elements
///
/// ## Example Usage
///
/// ```swift
/// // Use the default theme
/// VStack {
///     Text("Hello World!")
///         .textStyle(theme.textTheme.headline)
///     Image(systemName: "star.fill")
///         .foregroundColor(theme.iconTheme.color)
///         .font(.system(size: theme.iconTheme.size ?? 24))
///         .opacity(theme.iconTheme.opacity)
///     Button("Primary Action") { }
///         .buttonStyle(.primary)
/// }
/// .environment(\.theme, Theme.default)
///
/// // Create a custom theme
/// let customTheme = Theme.default.copyWith(
///     colorScheme: customColorScheme,
///     iconTheme: IconTheme(color: .blue, opacity: 0.8, size: 32),
///     textTheme: customTextTheme
/// )
///
/// // Apply theme to a view hierarchy
/// ContentView()
///     .environment(\.theme, customTheme)
/// ```
///
/// ## Design System Integration
///
/// The theme integrates with SwiftUI's environment system, allowing components to automatically
/// access design tokens. This enables consistent styling across the entire application while
/// supporting theme customization and dark/light mode adaptation.
public struct Theme: Sendable {
    /// The button theme configuration defining button appearance and behavior.
    public let buttonTheme: ButtonTheme

    /// The color scheme defining the application's color palette and semantic colors.
    public let colorScheme: DSColorScheme

    /// The icon theme defining icon styling including color, size, and opacity.
    public let iconTheme: IconTheme

    /// The radius theme defining corner radius values for UI elements.
    public let radiusTheme: RadiusTheme

    /// The size theme defining consistent size values for layouts.
    public let sizeTheme: SizeTheme

    /// The snackbar theme defining the appearance including color, shadows, etc.
    public let snackbarTheme: SnackbarTheme

    /// The spacing theme defining consistent spacing values for layouts.
    public let spacingTheme: SpacingTheme

    /// The text theme defining typography styles and text hierarchy.
    public let textTheme: TextTheme

    // MARK: - Static Properties

    /// The default theme providing a complete design system configuration.
    ///
    /// This theme includes all necessary design tokens for a complete application,
    /// with carefully chosen defaults that work well together and follow modern
    /// design principles.
    public static let `default` = Theme(
        buttonTheme: ButtonTheme.default,
        colorScheme: DSColorScheme.default,
        iconTheme: IconTheme.default,
        radiusTheme: RadiusTheme(),
        sizeTheme: SizeTheme(),
        snackbarTheme: SnackbarTheme.default,
        spacingTheme: SpacingTheme(),
        textTheme: TextTheme.default
    )

    // MARK: - Initializer

    /// Creates a new theme with the specified design system components.
    ///
    /// - Parameters:
    ///   - buttonTheme: The button theme configuration.
    ///   - colorScheme: The color scheme defining the color palette.
    ///   - iconTheme: The icon theme defining icon styling.
    ///   - radiusTheme: The radius theme for corner radius values.
    ///   - sizeTheme: The size theme defining consistent size values for layouts.
    ///   - snackbarTheme: The snackbar theme configuration.
    ///   - spacingTheme: The spacing theme for layout spacing.
    ///   - textTheme: The text theme for typography styles.
    public init(
        buttonTheme: ButtonTheme,
        colorScheme: DSColorScheme,
        iconTheme: IconTheme,
        radiusTheme: RadiusTheme,
        sizeTheme: SizeTheme,
        snackbarTheme: SnackbarTheme,
        spacingTheme: SpacingTheme,
        textTheme: TextTheme
    ) {
        self.buttonTheme = buttonTheme
        self.colorScheme = colorScheme
        self.iconTheme = iconTheme
        self.radiusTheme = radiusTheme
        self.sizeTheme = sizeTheme
        self.snackbarTheme = snackbarTheme
        self.spacingTheme = spacingTheme
        self.textTheme = textTheme
    }

    // MARK: - Public methods

    /// Returns a copy of this theme with the specified fields replaced with new values.
    ///
    /// This method allows you to create theme variations by selectively overriding
    /// specific design system components while keeping the rest unchanged.
    ///
    /// - Parameters:
    ///   - buttonTheme: The new button theme, or nil to keep the current one
    ///   - colorScheme: The new color scheme, or nil to keep the current one
    ///   - iconTheme: The new icon theme, or nil to keep the current one
    ///   - radiusTheme: The new radius theme, or nil to keep the current one
    ///   - sizeTheme: The size theme defining consistent size values for layouts.
    ///   - snackbarTheme: The snackbar theme configuration.
    ///   - spacingTheme: The new spacing theme, or nil to keep the current one
    ///   - textTheme: The new text theme, or nil to keep the current one
    /// - Returns: A new theme instance with the specified changes applied
    public func copyWith(
        buttonTheme: ButtonTheme? = nil,
        colorScheme: DSColorScheme? = nil,
        iconTheme: IconTheme? = nil,
        radiusTheme: RadiusTheme? = nil,
        snackbarTheme: SnackbarTheme? = nil,
        spacingTheme: SpacingTheme? = nil,
        sizeTheme: SizeTheme? = nil,
        textTheme: TextTheme? = nil
    ) -> Theme {
        Theme(
            buttonTheme: buttonTheme ?? self.buttonTheme,
            colorScheme: colorScheme ?? self.colorScheme,
            iconTheme: iconTheme ?? self.iconTheme,
            radiusTheme: radiusTheme ?? self.radiusTheme,
            sizeTheme: sizeTheme ?? self.sizeTheme,
            snackbarTheme: snackbarTheme ?? self.snackbarTheme,
            spacingTheme: spacingTheme ?? self.spacingTheme,
            textTheme: textTheme ?? self.textTheme
        )
    }
}
