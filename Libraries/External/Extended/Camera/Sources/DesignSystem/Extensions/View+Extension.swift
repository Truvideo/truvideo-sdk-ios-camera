//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

extension View {
    /// A conditional view modifier that allows you to take a view,
    /// and only apply a view modifier when the condition holds.
    ///
    /// - Parameters:
    ///   - condition: The boolean to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View`
    /// if the condition is `true`.
    @ViewBuilder
    public func `if`<Content: View>(_ condition: Bool, @ViewBuilder transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Applies the text style to the `View`.
    ///
    /// - Parameter textStyle: The text style to apply to the view
    @ViewBuilder
    public func textStyle(_ style: TextStyle) -> some View {
        font(.custom(style.fontName, size: style.fontSize))
            .foregroundColor(style.color)
            .lineSpacing(style.lineSpacing)
    }

    /// A SwiftUI view modifier that applies a specific theme to the view hierarchy.
    ///
    /// This view modifier sets the `theme` environment value for the view hierarchy,
    /// allowing you to apply a consistent visual theme throughout the entire view hierarchy.
    ///
    /// - Parameter theme: The theme to be applied to the view hierarchy.
    /// - Returns: A modified view with the specified theme applied.
    public func theme(_ theme: Theme) -> some View {
        environment(\.theme, theme)
    }
}
