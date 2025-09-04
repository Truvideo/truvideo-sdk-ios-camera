//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

/// A theme system that defines the visual appearance of icons.
///
/// `IconTheme` provides a structured approach to managing icon styling across an application.
/// It defines color, size, and opacity properties for consistent icon appearance, following
/// SwiftUI design patterns where size is optional and can be inherited from the system.
///
/// This struct is designed to work with SwiftUI's icon system and provides a systematic approach
/// to maintaining consistent icon styling and ensuring visual clarity across your application.
///
/// ## Theme Properties
///
/// The icon theme is organized into several key styling areas:
/// - **Color**: The color applied to the icon
/// - **Size**: The size of the icon (optional, follows system defaults)
/// - **Opacity**: The opacity level of the icon
///
/// ## Example Usage
///
/// ```swift
/// // Use the default icon theme
/// let defaultTheme = IconTheme.default
///
/// // Create a custom icon theme
/// let customTheme = IconTheme(
///     color: Color.blue,
///     opacity: 0.8,
///     size: 24
/// )
///
/// // Apply to SwiftUI views
/// Image(systemName: "star.fill")
///     .foregroundColor(theme.iconTheme.color)
///     .font(.system(size: theme.iconTheme.size ?? 24))
///     .opacity(theme.iconTheme.opacity)
///
/// // Create theme variations
/// let largeIconTheme = defaultTheme.copyWith(size: 32)
/// let coloredIconTheme = defaultTheme.copyWith(color: .red)
/// ```
///
/// ## Design System Integration
///
/// The icon theme integrates with SwiftUI's environment system, allowing components to automatically
/// access icon styling properties. This enables consistent icon appearance across the entire application
/// while supporting theme customization and dark/light mode adaptation.
public struct IconTheme: Sendable {
    /// The color of the icon.
    ///
    /// This property defines the color applied to the icon. If `nil`, the icon will use
    /// the default foreground color or inherit from its parent view. This allows for
    /// flexible theming where icons can adapt to different color schemes.
    public let color: Color?

    /// The opacity of the icon.
    ///
    /// This value controls the transparency of the icon, ranging from 0.0 (completely
    /// transparent) to 1.0 (fully opaque). The default value is 1.0 for full visibility.
    public let opacity: Double

    // MARK: - Static Properties

    /// The default icon theme with standard iOS-style icon appearance.
    ///
    /// This provides a complete set of icon styling properties following iOS design guidelines.
    /// The theme uses system defaults for colors and sizes to ensure consistency with the platform.
    /// Size is intentionally set to `nil` to follow SwiftUI's pattern where size is optional
    /// and can be inherited from the system or parent views.
    public static let `default` = IconTheme(color: nil, opacity: 1)

    // MARK: - Initializer

    /// Creates a new icon theme with the specified styling properties.
    ///
    /// This initializer allows you to create a custom icon theme that matches your
    /// application's design requirements. Each property can be customized to create
    /// unique icon styles while maintaining consistency across your UI.
    ///
    /// - Parameters:
    ///   - color: The color applied to the icon. Defaults to `nil` for system default.
    ///   - opacity: The opacity level of the icon. Defaults to 1.0 for full visibility.
    public init(color: Color?, opacity: Double) {
        self.color = color
        self.opacity = opacity
    }

    // MARK: - Public methods

    /// Returns a copy of this `IconTheme` with the specified fields replaced with new values.
    ///
    /// This method allows you to create a modified version of the icon theme by selectively
    /// updating specific properties while keeping the rest unchanged. This is useful for
    /// creating theme variations or applying custom styling to specific components.
    public func copyWith(color: Color? = nil, opacity: Double? = nil) -> IconTheme {
        IconTheme(color: color ?? self.color, opacity: opacity ?? self.opacity)
    }
}
