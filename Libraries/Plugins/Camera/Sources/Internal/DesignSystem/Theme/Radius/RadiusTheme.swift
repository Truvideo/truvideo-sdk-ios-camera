//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

// swiftlint:disable identifier_name
/// A comprehensive radius system that defines consistent corner radius values for UI components.
///
/// `Radius` provides a scalable and customizable way to define corner radius values based on a core unit
/// (`radiusUnit`).
/// It ensures design consistency by offering predefined radius levels, from extra-extra-small (`xxs`) to extra-large
/// (`xl`).
///
/// This struct is designed to work with SwiftUI's corner radius modifiers and provides a systematic approach to
/// maintaining
/// consistent rounded corners across different UI components in your application.
///
/// ## Radius Scale
///
/// The radius system follows a consistent scale based on the `radiusUnit`:
/// - **xxs**: 0.5x unit (2px with default unit)
/// - **xs**: 1x unit (4px with default unit)
/// - **sm**: 2x unit (8px with default unit)
/// - **md**: 3x unit (12px with default unit)
/// - **lg**: 4x unit (16px with default unit)
/// - **xl**: 5x unit (20px with default unit)
///
/// ## Example Usage
///
/// ```swift
/// // Create a radius system with default 4px unit
/// let radius = Radius()
///
/// // Use predefined radius values
/// RoundedRectangle(cornerRadius: radius.md)
///     .fill(Color.blue)
///     .frame(width: 100, height: 50)
///
/// // Apply to SwiftUI views
/// Text("Hello World")
///     .padding()
///     .background(Color.gray)
///     .cornerRadius(radius.sm)
///
/// // Use custom radius with the x() method
/// Button("Custom Radius") {
///     // Action
/// }
/// .cornerRadius(radius.x(2.5)) // Returns 10.0 points
///
/// // Create a custom radius system with 8px unit
/// let largeRadius = Radius(radiusUnit: 8)
/// let customRadius = largeRadius.xl // Returns 40.0 points
/// ```
///
/// ## Design System Integration
///
/// This radius system integrates well with design systems and can be used consistently
/// across components, cards, buttons, and other UI elements to maintain visual harmony.
/// It works particularly well with the `Spacing` system for creating balanced layouts.
public struct RadiusTheme: Sendable {
    /// The base unit of radius used to calculate all corner radius values.
    ///
    /// This value serves as the foundation for the entire radius scale. All predefined
    /// radius values are calculated as multiples of this unit, ensuring consistency
    /// and scalability across the design system.
    public let radiusUnit: CGFloat

    /// Extra-extra-small radius (0.5x unit).
    ///
    /// Use for subtle rounding on small elements, such as tiny badges, small icons,
    /// or minimal input fields that need just a hint of softening.
    public var xxs: CGFloat {
        0.5 * radiusUnit
    }

    /// Extra-small radius (1x unit).
    ///
    /// Use for small UI elements that need gentle rounding, such as small buttons,
    /// compact cards, or minor decorative elements.
    public var xs: CGFloat {
        1 * radiusUnit
    }

    /// Small radius (2x unit).
    ///
    /// Use for standard UI elements that benefit from moderate rounding, such as
    /// regular buttons, form inputs, or content cards.
    public var sm: CGFloat {
        2 * radiusUnit
    }

    /// Medium radius (3x unit).
    ///
    /// Use for prominent UI elements that need comfortable rounding, such as
    /// primary buttons, main content cards, or modal dialogs.
    public var md: CGFloat {
        3 * radiusUnit
    }

    /// Large radius (4x unit).
    ///
    /// Use for large UI elements that need generous rounding, such as large cards,
    /// full-width containers, or prominent content areas.
    public var lg: CGFloat {
        4 * radiusUnit
    }

    /// Extra-large radius (5x unit).
    ///
    /// Use for very large UI elements that need substantial rounding, such as
    /// full-screen overlays, large modal dialogs, or immersive content containers.
    public var xl: CGFloat {
        5 * radiusUnit
    }

    /// Extra-extra-large radius (6x unit).
    ///
    /// Use for very large UI elements that need substantial rounding, such as
    /// full-screen overlays, large modal dialogs, or immersive content containers.
    public var xxl: CGFloat {
        6 * radiusUnit
    }

    // MARK: - Initializer

    /// Initializes a new `Radius` instance with the specified radius unit.
    ///
    /// This initializer allows you to create a custom radius system based on your
    /// design requirements. The default value of 4 points provides a good balance
    /// for most iOS applications, but you can adjust it to match your specific
    /// design system needs.
    ///
    /// - Parameter radiusUnit: The base unit value for radius calculations. Defaults to 4.0 points.
    public init(radiusUnit: CGFloat = 4) {
        self.radiusUnit = radiusUnit
    }

    // MARK: - Public methods

    /// Creates a custom radius value by multiplying the radius unit by a specified factor.
    ///
    /// This method allows you to create radius values that don't fit into the predefined
    /// scale, giving you flexibility for specific design requirements while maintaining
    /// consistency with your base radius unit.
    ///
    /// - Parameter multiple: The factor by which to multiply the radius unit.
    /// - Returns: A radius value calculated as `multiple * radiusUnit`.
    public func x(_ multiple: Double) -> CGFloat {
        CGFloat(multiple) * radiusUnit
    }
}

// swiftlint:enable identifier_name
