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
    func `if`<Content: View>(_ condition: Bool, @ViewBuilder transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Positions this view within an invisible frame with the specified size.
    ///
    /// Use this method to specify a fixed size for a view's width, height, or
    /// both. If you only specify one of the dimensions, the resulting view
    /// assumes this view's sizing behavior in the other dimension.
    ///
    /// - Parameters:
    ///   - size: A fixed size for the resulting view.
    ///   - alignment: The alignment of this view inside the resulting frame.
    ///
    /// - Returns: A view with fixed dimensions of `width` and `height`, for the
    ///   parameters that are non-`nil`.
    func frame(size: CGSize?, alignment: Alignment = .center) -> some View {
        frame(width: size?.width, height: size?.height, alignment: alignment)
    }

    /// Conditionally hides a view based on a boolean value.
    ///
    /// This `ViewBuilder` function provides a convenient way to conditionally
    /// show or hide views. When `hidden` is `true`, the view is completely
    /// removed from the view hierarchy. When `hidden` is `false`, the view
    /// is displayed normally.
    ///
    /// - Parameter hidden: A boolean value that determines whether the view should be hidden.
    /// - Returns: The view when `hidden` is `false`, or nothing when `hidden` is `true`
    @ViewBuilder
    func hidden(_ hidden: Bool = true) -> some View {
        if !hidden {
            self
        }
    }

    /// Adds a tap gesture recognizer to the view that executes the provided action.
    ///
    /// This modifier creates a tap gesture using a `DragGesture` with zero minimum distance,
    /// which effectively captures tap events. When the user taps on the view, the gesture
    /// recognizer will call the provided action closure with the tap location coordinates.
    /// The location is provided in the view's coordinate space.
    ///
    /// - Parameters action: Closure to execute when a tap gesture is detected, receiving the tap location
    /// - Returns: A view with the tap gesture recognizer attached
    func onTapGesture(perform action: @escaping (CGPoint) -> Void) -> some View {
        gesture(
            DragGesture(minimumDistance: 0)
                .onEnded { value in
                    action(value.location)
                }
        )
    }

    /// Applies selection state to the view and its child views.
    ///
    /// This function sets the selection state in the environment, allowing child views
    /// to access the selection state through the `@Environment(\.isSelected)` property.
    /// It provides a convenient way to mark views as selected or unselected.
    ///
    /// - Parameter selected: The selection state to apply. Defaults to `true` for convenience.
    /// - Returns: A view with the selection state applied to its environment.
    func selected(_ selected: Bool = true) -> some View {
        environment(\.isSelected, selected)
    }

    /// Applies the text style to the `View`.
    ///
    /// - Parameter textStyle: The text style to apply to the view
    func textStyle(_ style: TextStyle) -> some View {
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
    func theme(_ theme: Theme) -> some View {
        environment(\.theme, theme)
    }
}
