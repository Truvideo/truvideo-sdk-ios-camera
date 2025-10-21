//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

/// A comprehensive text theme that defines typography styles for various UI elements.
///
/// `TextTheme` provides a structured approach to managing typography across an application by defining
/// specific text styles for different use cases. It follows iOS design principles and provides consistent
/// text styling for titles, body text, captions, and other typographic elements.
///
/// This struct is designed to work with SwiftUI's text system and ensures visual consistency and
/// accessibility across the application's user interface.
///
/// ## Text Hierarchy
///
/// The text styles are organized in a hierarchical structure:
/// - **Large Title**: Most prominent text for main screen headers
/// - **Title 1-3**: Decreasing levels of title importance
/// - **Headline**: Emphasized text for section headers
/// - **Body**: Standard content text
/// - **Callout**: Highlighted information
/// - **Subheadline**: Supporting text below headlines
/// - **Footnote**: Supplementary information
/// - **Caption 1-2**: Small descriptive text
///
/// ## Example Usage
///
/// ```swift
/// let customTheme = TextTheme(
///     largeTitle: TextStyle(
///         color: .primary,
///         fontFamily: .sanfrancisco,
///         fontSize: 34,
///         weight: .bold
///     ),
///     body: TextStyle(
///         color: .secondary,
///         fontFamily: .sanfrancisco,
///         fontSize: 17,
///         weight: .regular
///     )
///     // ... other styles
/// )
///
/// // Apply to a view
/// Text("Hello World")
///     .textStyle(theme.textTheme.headline)
/// ```
///
/// ## Accessibility
///
/// Each text style is designed with accessibility in mind, providing appropriate contrast ratios
/// and readable font sizes that work well with Dynamic Type and VoiceOver.
public struct TextTheme: Sendable {
    /// Large Title 1 Text Style.
    ///
    /// Use for prominent titles that require significant emphasis, such as on main screens or headers for large
    /// sections.
    public let largeTitle: TextStyle

    /// Title 1 Text Style.
    ///
    /// Ideal for large section headers or screen titles where strong visual hierarchy is needed.
    public let title1: TextStyle

    /// Title 2 Text Style.
    ///
    /// Suitable for subsection headers or smaller screen titles that follow a primary title.
    public let title2: TextStyle

    /// Title 3 Text Style.
    ///
    /// Use for tertiary headings, such as smaller subsections or important labels.
    public let title3: TextStyle

    /// Headline Text Style.
    ///
    /// Best used for short, emphasized text like section headings or call-to-action prompts.
    public let headline: TextStyle

    /// Body Text Style.
    ///
    /// The default text style for most content, including paragraphs and descriptive text.
    public let body: TextStyle

    /// Callout Text Style.
    ///
    /// Intended for highlighted information, such as quotes or key points that need visual separation from body text.
    public let callout: TextStyle

    /// Subheadline Text Style.
    ///
    /// Used for secondary content that supports the main body text, like subtitles or brief explanations.
    public let subheadline: TextStyle

    /// Footnote Text Style.
    ///
    /// Best for supplementary information, such as disclaimers, legal notes, or fine print.
    public let footnote: TextStyle

    /// Caption 1 Text Style.
    ///
    /// Use for image captions, chart labels, or other small descriptive texts.
    public let caption1: TextStyle

    /// Caption 2 Text Style.
    ///
    /// Ideal for secondary captions or very small informational text, such as timestamps or auxiliary labels.
    public let caption2: TextStyle

    // MARK: - Static Properties

    /// The default `TextTheme` with iOS-style typography.
    ///
    /// This provides a complete set of text styles following iOS design guidelines with San Francisco font,
    /// appropriate font sizes, and weights for each text category.
    public static let `default` = TextTheme(
        largeTitle: TextStyle(
            color: .black,
            decoration: nil,
            design: nil,
            fontFamily: .sanfrancisco,
            fontSize: 34,
            kerning: 0,
            lineSpacing: 1,
            weight: .regular,
            width: nil
        ),
        title1: TextStyle(
            color: .black,
            decoration: nil,
            design: nil,
            fontFamily: .sanfrancisco,
            fontSize: 28,
            kerning: 0,
            lineSpacing: 1,
            weight: .regular,
            width: nil
        ),
        title2: TextStyle(
            color: .black,
            decoration: nil,
            design: nil,
            fontFamily: .sanfrancisco,
            fontSize: 22,
            kerning: 0,
            lineSpacing: 5,
            weight: .regular,
            width: nil
        ),
        title3: TextStyle(
            color: .black,
            decoration: nil,
            design: nil,
            fontFamily: .sanfrancisco,
            fontSize: 20,
            kerning: 0,
            lineSpacing: 1,
            weight: .regular,
            width: nil
        ),
        headline: TextStyle(
            color: .black,
            decoration: nil,
            design: nil,
            fontFamily: .sanfrancisco,
            fontSize: 17,
            kerning: 0,
            lineSpacing: 1,
            weight: .semiBold,
            width: nil
        ),
        body: TextStyle(
            color: .black,
            decoration: nil,
            design: nil,
            fontFamily: .sanfrancisco,
            fontSize: 17,
            kerning: 0,
            lineSpacing: 1,
            weight: .regular,
            width: nil
        ),
        callout: TextStyle(
            color: .black,
            decoration: nil,
            design: nil,
            fontFamily: .sanfrancisco,
            fontSize: 16,
            kerning: 0,
            lineSpacing: 1,
            weight: .regular,
            width: nil
        ),
        subheadline: TextStyle(
            color: .black,
            decoration: nil,
            design: nil,
            fontFamily: .sanfrancisco,
            fontSize: 15,
            kerning: 0,
            lineSpacing: 1,
            weight: .regular,
            width: nil
        ),
        footnote: TextStyle(
            color: .black,
            decoration: nil,
            design: nil,
            fontFamily: .sanfrancisco,
            fontSize: 13,
            kerning: 0,
            lineSpacing: 1,
            weight: .regular,
            width: nil
        ),
        caption1: TextStyle(
            color: .black,
            decoration: nil,
            design: nil,
            fontFamily: .sanfrancisco,
            fontSize: 12,
            kerning: 0,
            lineSpacing: 1,
            weight: .regular,
            width: nil
        ),
        caption2: TextStyle(
            color: .black,
            decoration: nil,
            design: nil,
            fontFamily: .sanfrancisco,
            fontSize: 11,
            kerning: 0,
            lineSpacing: 1,
            weight: .regular,
            width: nil
        )
    )

    // MARK: - Initializer

    /// Initializes a new instance with the provided text styles for various typographic elements.
    ///
    /// This initializer allows defining custom `TextStyle` configurations for different text categories used in UI
    /// elements.
    /// Each parameter represents a specific text role commonly used in user interfaces, ensuring consistent typography
    /// across the application.
    ///
    /// - Parameters:
    ///   - largeTitle: A `TextStyle` for prominent titles, typically used for large headings.
    ///   - title1: A `TextStyle` for first-level titles, commonly used for primary headers.
    ///   - title2: A `TextStyle` for second-level titles, often used for subheaders or sections.
    ///   - title3: A `TextStyle` for third-level titles, generally for smaller subheadings.
    ///   - headline: A `TextStyle` intended for headlines that need to stand out.
    ///   - body: A `TextStyle` used for standard body text in the UI.
    ///   - callout: A `TextStyle` for callout text, which highlights important information.
    ///   - subheadline: A `TextStyle` for secondary text that appears below headlines.
    ///   - footnote: A `TextStyle` for footnotes, typically used for additional information.
    ///   - caption1: A `TextStyle` for the primary caption, usually used for brief annotations or labels.
    ///   - caption2: A `TextStyle` for secondary captions, intended for minor annotations or supplementary information.
    public init(
        largeTitle: TextStyle,
        title1: TextStyle,
        title2: TextStyle,
        title3: TextStyle,
        headline: TextStyle,
        body: TextStyle,
        callout: TextStyle,
        subheadline: TextStyle,
        footnote: TextStyle,
        caption1: TextStyle,
        caption2: TextStyle
    ) {
        self.largeTitle = largeTitle
        self.title1 = title1
        self.title2 = title2
        self.title3 = title3
        self.headline = headline
        self.body = body
        self.callout = callout
        self.subheadline = subheadline
        self.footnote = footnote
        self.caption1 = caption1
        self.caption2 = caption2
    }

    // MARK: - Public methods

    /// Returns a copy of this `TextTheme` with the given fields replaced with the new values.
    ///
    /// This method allows you to create a modified version of the text theme by selectively
    /// updating specific text styles while keeping the rest unchanged. This is useful for
    /// creating theme variations or applying custom styling to specific components.
    ///
    /// - Parameters:
    ///   - largeTitle: Optional new large title style
    ///   - title1: Optional new title1 style
    ///   - title2: Optional new title2 style
    ///   - title3: Optional new title3 style
    ///   - headline: Optional new headline style
    ///   - body: Optional new body style
    ///   - callout: Optional new callout style
    ///   - subheadline: Optional new subheadline style
    ///   - footnote: Optional new footnote style
    ///   - caption1: Optional new caption1 style
    ///   - caption2: Optional new caption2 style
    /// - Returns: A new `TextTheme` instance with the specified styles updated
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// let darkTheme = theme.textTheme.copyWith(
    ///     body: TextStyle(color: .white, fontSize: 16),
    ///     headline: TextStyle(color: .white, weight: .bold)
    /// )
    /// ```
    public func copyWith(
        largeTitle: TextStyle? = nil,
        title1: TextStyle? = nil,
        title2: TextStyle? = nil,
        title3: TextStyle? = nil,
        headline: TextStyle? = nil,
        body: TextStyle? = nil,
        callout: TextStyle? = nil,
        subheadline: TextStyle? = nil,
        footnote: TextStyle? = nil,
        caption1: TextStyle? = nil,
        caption2: TextStyle? = nil
    ) -> TextTheme {
        TextTheme(
            largeTitle: largeTitle ?? self.largeTitle,
            title1: title1 ?? self.title1,
            title2: title2 ?? self.title2,
            title3: title3 ?? self.title3,
            headline: headline ?? self.headline,
            body: body ?? self.body,
            callout: callout ?? self.callout,
            subheadline: subheadline ?? self.subheadline,
            footnote: footnote ?? self.footnote,
            caption1: caption1 ?? self.caption1,
            caption2: caption2 ?? self.caption2
        )
    }
}
