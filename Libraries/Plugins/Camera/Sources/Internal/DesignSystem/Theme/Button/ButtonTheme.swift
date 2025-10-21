//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

/// A comprehensive theme system that defines the visual appearance and behavior of buttons.
///
/// `ButtonTheme` provides a structured approach to managing button styling across an application.
/// It defines all visual aspects of buttons including colors, typography, spacing, sizing, and layout
/// properties. The theme supports dynamic state-based styling using `DSStateProperty` for responsive
/// visual feedback based on button states (normal, pressed, disabled, etc.).
///
/// This struct is designed to work with SwiftUI's button system and provides a systematic approach
/// to maintaining consistent button styling and ensuring visual clarity and accessibility across
/// your application.
///
/// ## Theme Properties
///
/// The button theme is organized into several key styling areas:
/// - **Layout**: Alignment, content offset, and padding for positioning
/// - **Visual**: Colors, corner radius, and minimum size for appearance
/// - **Typography**: Text styling with state-based variations
/// - **Behavior**: State-based color and text style changes
///
/// ## Example Usage
///
/// ```swift
/// // Use the default button theme
/// let defaultTheme = ButtonTheme.default
///
/// // Create a custom button theme
/// let customTheme = ButtonTheme(
///     alignment: .center,
///     color: DSStateProperty(
///         normal: Color.blue,
///         pressed: Color.blue.opacity(0.8),
///         disabled: Color.gray
///     ),
///     contentOffset: CGSize(width: 0, height: 2),
///     cornerRadius: 8,
///     minimunSize: CGSize(width: 120, height: 44),
///     padding: EdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24),
///     textStyle: DSStateProperty(
///         normal: TextStyle(fontSize: 16, weight: .medium),
///         pressed: TextStyle(fontSize: 16, weight: .bold),
///         disabled: TextStyle(fontSize: 16, weight: .regular)
///     )
/// )
///
/// // Create theme variations
/// let roundedTheme = defaultTheme.copyWith(
///     cornerRadius: 20,
///     padding: EdgeInsets(top: 16, leading: 32, bottom: 16, trailing: 32)
/// )
///
/// let compactTheme = defaultTheme.copyWith(
///     minimunSize: CGSize(width: 80, height: 32),
///     padding: EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
/// )
/// ```
///
/// ## State-Based Styling
///
/// The theme supports dynamic styling based on button states:
/// - **Normal**: Default appearance when the button is idle
/// - **Pressed**: Appearance when the button is being pressed
/// - **Disabled**: Appearance when the button is not interactive
///
/// This allows for rich visual feedback and improved user experience.
public struct ButtonTheme: Sendable {
    /// Defines the alignment of the button's content within its bounds.
    ///
    /// The alignment determines how the child view (text, icon, or other content) is positioned
    /// inside the button. This affects the visual layout and can be used to create different
    /// button styles like left-aligned text, centered icons, etc.
    ///
    /// Common values include:
    /// - `.center`: Content is centered (default)
    /// - `.leading`: Content is aligned to the left edge
    /// - `.trailing`: Content is aligned to the right edge
    /// - `.top`: Content is aligned to the top edge
    /// - `.bottom`: Content is aligned to the bottom edge
    public let alignment: Alignment

    /// The dynamic color of the button, which can change based on the button's state.
    ///
    /// This property uses `DSStateProperty<Color>` to dynamically resolve the button's color
    /// depending on its current state. This allows for rich visual feedback:
    /// - Different colors for normal, pressed, and disabled states
    /// - Smooth transitions between states
    /// - Consistent color theming across the application
    ///
    /// If `nil`, the button will use default system colors or inherit from its parent view.
    public let color: DSStateProperty<Color>?

    /// The offset applied to the button's content relative to its boundary.
    ///
    /// This property defines the amount by which the content inside the button is shifted
    /// horizontally and vertically. Useful for:
    /// - Creating pressed button effects (slight downward offset)
    /// - Adjusting visual alignment of content
    /// - Fine-tuning layout positioning
    /// - Creating custom button animations
    public let contentOffset: CGSize

    /// The corner radius applied to the button's borders.
    ///
    /// This value controls the rounding of the button's corners, affecting its overall shape:
    /// - `0`: Sharp, rectangular corners
    /// - `4-8`: Slightly rounded corners (common for modern UI)
    /// - `12-20`: More rounded corners (pill-shaped buttons)
    /// - `50%`: Fully rounded corners (circular buttons)
    ///
    /// If `nil`, the button will use default corner radius or inherit from its parent view.
    public let cornerRadius: CGFloat?

    /// The minimum size for the button.
    ///
    /// Specifies the smallest possible dimensions (width and height) that the button should
    /// maintain. This ensures consistent button sizing and prevents buttons from becoming
    /// too small to interact with comfortably.
    ///
    /// Common minimum sizes:
    /// - `44x44`: Standard touch target size for accessibility
    /// - `50x48`: Default theme size
    /// - `120x44`: Standard button size with text
    ///
    /// If `nil`, the button will rely on intrinsic content size and layout constraints.
    public let minimunSize: CGSize?

    /// The padding inside the button's boundary.
    ///
    /// Defines spacing around the button's content, ensuring a consistent gap between the
    /// content and the button's edges. This affects the button's overall size and visual
    /// appearance.
    ///
    /// Common padding values:
    /// - `EdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)`: Standard button padding
    /// - `EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)`: Compact button padding
    /// - `EdgeInsets(top: 16, leading: 32, bottom: 16, trailing: 32)`: Large button padding
    ///
    /// If `nil`, default padding values should be applied.
    public let padding: EdgeInsets?

    /// The text style applied to the button's text, dynamically resolved based on state.
    ///
    /// This property uses `DSStateProperty<TextStyle>` to customize text appearance depending
    /// on the button's state. This allows for:
    /// - Different font weights for different states (normal vs pressed)
    /// - Color changes based on state
    /// - Size adjustments for visual feedback
    /// - Consistent typography across the application
    ///
    /// If `nil`, the button will use default text styling or inherit from its parent view.
    public let textStyle: DSStateProperty<TextStyle>?

    // MARK: - Static Properties

    /// The default `ButtonTheme` with standard iOS-style button appearance.
    ///
    /// This provides a complete set of button styling properties following iOS design guidelines
    /// with a minimum touch target size of 50x48 points for accessibility compliance.
    /// The theme uses system defaults for colors, text styles, and corner radius to ensure
    /// consistency with the platform.
    public static let `default` = ButtonTheme(
        alignment: .center,
        color: nil,
        contentOffset: .zero,
        cornerRadius: nil,
        minimunSize: .init(width: 50, height: 48),
        padding: nil,
        textStyle: nil
    )

    // MARK: - Initializer

    /// Initializes a new `ButtonTheme` instance with the provided styling properties.
    ///
    /// This initializer allows you to create a custom button theme that matches your
    /// application's design requirements. Each property can be customized to create
    /// unique button styles while maintaining consistency across your UI.
    ///
    /// - Parameters:
    ///   - alignment: The alignment of content within the button bounds
    ///   - color: Dynamic color property that changes based on button state
    ///   - contentOffset: Offset applied to button content relative to its boundary
    ///   - cornerRadius: Corner radius for button borders
    ///   - minimunSize: Minimum dimensions the button should maintain
    ///   - padding: Spacing around button content
    ///   - textStyle: Dynamic text style that changes based on button state
    public init(
        alignment: Alignment,
        color: DSStateProperty<Color>?,
        contentOffset: CGSize,
        cornerRadius: CGFloat?,
        minimunSize: CGSize?,
        padding: EdgeInsets?,
        textStyle: DSStateProperty<TextStyle>?
    ) {
        self.alignment = alignment
        self.color = color
        self.contentOffset = contentOffset
        self.cornerRadius = cornerRadius
        self.minimunSize = minimunSize
        self.padding = padding
        self.textStyle = textStyle
    }

    // MARK: - Public methods

    /// Returns a copy of this `ButtonTheme` with the given fields replaced with the new values.
    ///
    /// This method allows you to create a modified version of the button theme by selectively
    /// updating specific properties while keeping the rest unchanged. This is useful for creating
    /// theme variations or applying custom styling to specific button types.
    ///
    /// - Parameters:
    ///   - alignment: Optional new alignment value
    ///   - color: Optional new dynamic color property
    ///   - contentOffset: Optional new content offset value
    ///   - cornerRadius: Optional new corner radius value
    ///   - minimunSize: Optional new minimum size value
    ///   - padding: Optional new padding value
    ///   - textStyle: Optional new dynamic text style property
    /// - Returns: A new `ButtonTheme` instance with the specified properties updated
    public func copyWith(
        alignment: Alignment? = nil,
        color: DSStateProperty<Color>? = nil,
        contentOffset: CGSize? = nil,
        cornerRadius: CGFloat? = nil,
        minimunSize: CGSize? = nil,
        padding: EdgeInsets? = nil,
        textStyle: DSStateProperty<TextStyle>? = nil
    ) -> ButtonTheme {
        ButtonTheme(
            alignment: alignment ?? self.alignment,
            color: color ?? self.color,
            contentOffset: contentOffset ?? self.contentOffset,
            cornerRadius: cornerRadius ?? self.cornerRadius,
            minimunSize: minimunSize ?? self.minimunSize,
            padding: padding ?? self.padding,
            textStyle: textStyle ?? self.textStyle
        )
    }
}
