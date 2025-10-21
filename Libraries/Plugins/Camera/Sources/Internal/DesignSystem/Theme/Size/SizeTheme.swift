//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

// swiftlint:disable identifier_name
/// A comprehensive spacing system that defines consistent spacing values for UI components.
///
/// `SizeTheme` provides a scalable and customizable way to define spacing values based on a core unit (`spaceUnit`).
/// It ensures design consistency by offering predefined spacing levels, from extra-extra-small (`xxs`) to
/// quintuple-extra-large (`xxxxxl`).
///
/// This struct is designed to work with SwiftUI's layout system and provides a systematic approach to maintaining
/// consistent spacing across different screen sizes and components in your application.
///
/// ## Spacing Scale
///
/// The spacing system follows a consistent scale based on the `spaceUnit`:
/// - **xxs**: 0.5x unit (2px with default unit)
/// - **xs**: 1x unit (4px with default unit)
/// - **sm**: 2x unit (8px with default unit)
/// - **md**: 3x unit (12px with default unit)
/// - **lg**: 4x unit (16px with default unit)
/// - **xl**: 5x unit (20px with default unit)
/// - **xxl**: 6x unit (24px with default unit)
/// - **xxxl**: 7x unit (28px with default unit)
/// - **xxxxl**: 8x unit (32px with default unit)
/// - **xxxxxl**: 9x unit (36px with default unit)
///
/// ## Example Usage
///
/// ```swift
/// // Create a spacing system with default 4px unit
/// let spacing = SizeTheme()
///
/// // Use predefined spacing values
/// VStack(spacing: spacing.md) {
///     Text("Title")
///     Text("Subtitle")
/// }
/// .padding(spacing.lg)
///
/// // Use custom spacing with the x() method
/// HStack(spacing: spacing.x(2.5)) {
///     Image(systemName: "star")
///     Text("Rating")
/// }
///
/// // Create a custom spacing system with 8px unit
/// let largeSpacing = SizeTheme(spaceUnit: 8)
/// let customPadding = largeSpacing.xl // Returns 40.0 points
/// ```
///
/// ## Design System Integration
///
/// This spacing system integrates well with design systems and can be used consistently
/// across components, layouts, and themes to maintain visual harmony.
public struct SizeTheme: Sendable {
    /// The base unit of spacing used to calculate all spacing values.
    ///
    /// This value serves as the foundation for the entire spacing scale. All predefined
    /// spacing values are calculated as multiples of this unit, ensuring consistency
    /// and scalability across the design system.
    public let spaceUnit: CGFloat

    /// Extra-extra-small spacing (0.5x unit).
    ///
    /// Use for minimal spacing between tightly related elements, such as icon and text
    /// in a button or between adjacent form fields.
    public var xxs: CGFloat {
        0.5 * spaceUnit
    }

    /// Extra-small spacing (1x unit).
    ///
    /// Use for small gaps between related elements, such as between items in a list
    /// or between a label and its input field.
    public var xs: CGFloat {
        1 * spaceUnit
    }

    /// Small spacing (2x unit).
    ///
    /// Use for standard spacing between elements in a group, such as between buttons
    /// in a toolbar or between sections in a form.
    public var sm: CGFloat {
        2 * spaceUnit
    }

    /// Medium spacing (3x unit).
    ///
    /// Use for comfortable spacing between major UI elements, such as between
    /// different sections of content or around card components.
    public var md: CGFloat {
        3 * spaceUnit
    }

    /// Large spacing (4x unit).
    ///
    /// Use for generous spacing between distinct content areas, such as between
    /// different cards or between the header and main content.
    public var lg: CGFloat {
        4 * spaceUnit
    }

    /// Extra-large spacing (5x unit).
    ///
    /// Use for significant spacing between major sections, such as between different
    /// content blocks or around modal dialogs.
    public var xl: CGFloat {
        5 * spaceUnit
    }

    /// Extra-extra-large spacing (6x unit).
    ///
    /// Use for substantial spacing between major UI sections, such as between
    /// different screens or around full-screen overlays.
    public var xxl: CGFloat {
        6 * spaceUnit
    }

    /// Triple-extra-large spacing (7x unit).
    ///
    /// Use for maximum spacing between major content areas, such as between
    /// different pages or around immersive content.
    public var xxxl: CGFloat {
        7 * spaceUnit
    }

    /// Quadruple-extra-large spacing (8x unit).
    ///
    /// Use for extreme spacing between major UI sections, such as between
    /// different app sections or around full-screen experiences.
    public var xxxxl: CGFloat {
        8 * spaceUnit
    }

    /// Quintuple-extra-large spacing (9x unit).
    ///
    /// Use for maximum possible spacing between major content areas, such as
    /// between different app modules or around immersive experiences.
    public var xxxxxl: CGFloat {
        9 * spaceUnit
    }

    // MARK: - Initializer

    /// Initializes a new `SizeTheme` instance with the specified space unit.
    ///
    /// This initializer allows you to create a custom spacing system based on your
    /// design requirements. The default value of 4 points provides a good balance
    /// for most iOS applications, but you can adjust it to match your specific
    /// design system needs.
    ///
    /// - Parameter spaceUnit: The base unit value for spacing calculations. Defaults to 4.0 points.
    public init(spaceUnit: CGFloat = 4) {
        self.spaceUnit = spaceUnit
    }

    // MARK: - Public methods

    /// Creates a custom spacing value by multiplying the space unit by a specified factor.
    ///
    /// This method allows you to create spacing values that don't fit into the predefined
    /// scale, giving you flexibility for specific design requirements while maintaining
    /// consistency with your base spacing unit.
    ///
    /// - Parameter multiple: The factor by which to multiply the space unit.
    /// - Returns: A spacing value calculated as `multiple * spaceUnit`.
    public func x(_ multiple: Double) -> CGFloat {
        CGFloat(multiple) * spaceUnit
    }
}

// swiftlint:enable identifier_name
