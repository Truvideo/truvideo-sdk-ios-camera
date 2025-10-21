//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import SwiftUI

/// A comprehensive theme system that defines the visual appearance and behavior of snackbars.
///
/// `SnackbarTheme` provides a structured approach to managing snackbar styling across an application.
/// It defines all visual aspects of snackbars including colors, typography, spacing, sizing, and shadow
/// properties. The theme supports customization of background colors, corner radius, content padding,
/// shadow effects, and text styling to create consistent and visually appealing snackbar components.
///
/// This struct is designed to work with SwiftUI's snackbar system and provides a systematic approach
/// to maintaining consistent snackbar styling and ensuring visual clarity and accessibility across
/// your application.
///
/// ## Theme Properties
///
/// The snackbar theme is organized into several key styling areas:
/// - **Visual**: Background color and corner radius for appearance
/// - **Layout**: Content padding for internal spacing
/// - **Shadow**: Color, offset, and radius for depth and elevation
/// - **Typography**: Text styling for message content
///
/// ## Example Usage
///
/// ```swift
/// // Use the default snackbar theme
/// let defaultTheme = SnackbarTheme.default
///
/// // Create a custom snackbar theme
/// let customTheme = SnackbarTheme(
///     backgroundColor: Color.black.opacity(0.8),
///     contentPadding: EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20),
///     cornerRadius: 8,
///     shadowColor: Color.black.opacity(0.3),
///     shadowOffset: CGPoint(x: 0, y: 2),
///     shadowRadius: 4,
///     textStyle: TextStyle(fontSize: 14, weight: .medium, color: .white)
/// )
/// ```
///
/// ## Customization Guidelines
///
/// The theme supports flexible customization for different use cases:
/// - **Background**: Use semi-transparent colors for overlay effects
/// - **Corner Radius**: Apply consistent rounding for modern appearance
/// - **Padding**: Adjust internal spacing for content density
/// - **Shadow**: Create depth and elevation for better visual hierarchy
/// - **Typography**: Ensure readability with appropriate font sizes and weights
///
/// This allows for rich visual feedback and improved user experience across different
/// snackbar implementations and contexts.
public struct SnackbarTheme: Sendable {
    /// The background color of the snackbar.
    ///
    /// This property defines the background color that will be applied to the snackbar container.
    /// It affects the overall appearance and can be used to create different visual styles:
    /// - Semi-transparent colors for overlay effects
    /// - Solid colors for prominent notifications
    /// - Theme-based colors for consistency
    ///
    /// Common values include:
    /// - `Color.black.opacity(0.8)`: Dark overlay for light text
    /// - `Color.white.opacity(0.9)`: Light overlay for dark text
    /// - `Color.blue.opacity(0.8)`: Branded color for specific notifications
    ///
    /// If `nil`, the snackbar will use default system colors or inherit from its parent view.
    public let backgroundColor: Color?

    /// The corner radius applied to the snackbar's borders.
    ///
    /// This value controls the rounding of the snackbar's corners, affecting its overall shape:
    /// - `0`: Sharp, rectangular corners
    /// - `4-8`: Slightly rounded corners (common for modern UI)
    /// - `12-20`: More rounded corners (pill-shaped snackbars)
    /// - `50%`: Fully rounded corners (circular snackbars)
    ///
    /// If `nil`, the snackbar will use default corner radius or inherit from its parent view.
    public let cornerRadius: CGFloat?

    /// The padding inside the snackbar's boundary.
    ///
    /// Defines spacing around the snackbar's content, ensuring a consistent gap between the
    /// content and the snackbar's edges. This affects the snackbar's overall size and visual
    /// appearance.
    ///
    /// If `nil`, default padding values should be applied.
    public let contentPadding: EdgeInsets?

    /// The shadow color applied to the snackbar.
    ///
    /// This property defines the color of the shadow effect that creates depth and elevation
    /// for the snackbar. It helps distinguish the snackbar from the background content.
    ///
    /// The shadow color works in combination with `shadowOffset` and `shadowRadius` to create
    /// the complete shadow effect.
    public let shadowColor: Color

    /// The offset for the snackbar's shadow effect.
    ///
    /// This property defines the horizontal and vertical displacement of the shadow relative
    /// to the snackbar's position. It creates the illusion of depth and elevation.
    ///
    /// The shadow offset works in combination with `shadowColor` and `shadowRadius` to create
    /// the complete shadow effect.
    public let shadowOffset: CGPoint

    /// The radius for the snackbar's shadow effect.
    ///
    /// This property controls the blur radius of the shadow, affecting how soft or sharp
    /// the shadow appears. Larger values create softer, more diffused shadows.
    ///
    /// The shadow radius works in combination with `shadowColor` and `shadowOffset` to create
    /// the complete shadow effect.
    public let shadowRadius: CGFloat

    /// The text style applied to the snackbar's message content.
    ///
    /// This property defines the typography for the snackbar's text, including font size,
    /// weight, color, and other text styling properties. It ensures consistent and readable
    /// text appearance across different snackbar implementations.
    ///
    /// If `nil`, the snackbar will use default text styling or inherit from its parent view.
    public let textStyle: TextStyle?

    // MARK: - Static Properties

    /// The default `SnackbarTheme` with minimal styling for system integration.
    ///
    /// This provides a basic set of snackbar styling properties that integrate well with
    /// the system appearance. The theme uses clear shadows and nil values for colors,
    /// padding, corner radius, and text style to allow for system defaults and inheritance.
    public static let `default` = SnackbarTheme(
        backgroundColor: nil,
        contentPadding: nil,
        cornerRadius: nil,
        shadowColor: .clear,
        shadowOffset: .zero,
        shadowRadius: 0,
        textStyle: nil
    )

    // MARK: - Initializer

    /// Creates an instance of this `SnackbarTheme`.
    ///
    /// - Parameters:
    ///   - backgroundColor: The background color to be applied.
    ///   - cornerRadius: The radius of the corners for rounding.
    ///   - contentPadding: The padding to apply to the content inside the view.
    ///   - shadowColor: The shadow color to be applied.
    ///   - shadowOffset: The offset for the shadow.
    ///   - shadowRadius: The radius for the shadow.
    ///   - textStyle: The style to be applied to the text.
    public init(
        backgroundColor: Color?,
        contentPadding: EdgeInsets?,
        cornerRadius: CGFloat?,
        shadowColor: Color,
        shadowOffset: CGPoint,
        shadowRadius: CGFloat,
        textStyle: TextStyle?
    ) {
        self.backgroundColor = backgroundColor
        self.contentPadding = contentPadding
        self.cornerRadius = cornerRadius
        self.shadowColor = shadowColor
        self.shadowOffset = shadowOffset
        self.shadowRadius = shadowRadius
        self.textStyle = textStyle
    }

    // MARK: - Instance methods

    /// Returns a copy of this `SnackbarTheme` with the given fields replaced with
    /// the new values.
    public func copyWith(
        backgroundColor: Color? = nil,
        contentPadding: EdgeInsets? = nil,
        cornerRadius: CGFloat? = nil,
        shadowColor: Color? = nil,
        shadowOffset: CGPoint? = nil,
        shadowRadius: CGFloat? = nil,
        textStyle: TextStyle? = nil
    ) -> SnackbarTheme {
        SnackbarTheme(
            backgroundColor: backgroundColor ?? self.backgroundColor,
            contentPadding: contentPadding ?? self.contentPadding,
            cornerRadius: cornerRadius ?? self.cornerRadius,
            shadowColor: shadowColor ?? self.shadowColor,
            shadowOffset: shadowOffset ?? self.shadowOffset,
            shadowRadius: shadowRadius ?? self.shadowRadius,
            textStyle: textStyle ?? self.textStyle
        )
    }
}
