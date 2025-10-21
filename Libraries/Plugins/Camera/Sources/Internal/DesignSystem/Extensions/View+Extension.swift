//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

extension View {
    /// Applies a full-size blur **behind** this view.
    ///
    /// - Parameters:
    ///   - style: The `UIBlurEffect.Style` to use.
    ///   - ignoresSafeArea: Whether the blur extends under safe areas (default: true).
    /// - Returns: A view with a blur background applied.
    func background(style: UIBlurEffect.Style) -> some View {
        background(
            BlurView(style: style)
                .ignoresSafeArea()
        )
    }

    /// A conditional view modifier that allows you to take a view,
    /// and only apply a view modifier when the condition holds.
    ///
    /// - Parameters:
    ///   - condition: The boolean to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View`
    /// if the condition is `true`.
    @ViewBuilder
    func `if`(_ condition: Bool, @ViewBuilder transform: (Self) -> some View) -> some View {
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

    /// Presents content as a full-screen cover with a scale transition animation from the current view's frame.
    ///
    /// This function creates a custom presentation overlay that animates content from the current view's
    /// frame to full screen using a smooth scale transition. It uses a `ScaledTransitionView` to provide
    /// a native iOS-style presentation animation that scales from the originating view's position and size
    /// to cover the entire screen.
    ///
    /// ## Usage Example
    ///
    /// ```swift
    /// Button("Show Gallery") {
    ///     isPresented.toggle()
    /// }
    /// .scaledFullScreenCover(isPresented: $isPresented) {
    ///     GalleryView(isPresented: $isPresented)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - isPresented: A binding that controls whether the content is currently presented
    ///   - content: A view builder closure that returns the content to be presented
    /// - Returns: A modified view with the scaled full-screen cover overlay
    func scaledFullScreenCover(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        overlay {
            GeometryReader { geometryProxy in
                ScaledTransitionView(isPresented: isPresented) {
                    content()
                }
                .startingFrame(geometryProxy.frame(in: .global))
                .hidden(!isPresented.wrappedValue)
            }
        }
    }

    /// Displays a snackbar with a specified label, position, duration, and vertical offset.
    ///
    /// This method creates a snackbar with the provided label and binds its presentation state to a given
    /// `Binding<Bool>`.
    /// It allows customization of the snackbar's position, duration, and vertical offset.
    ///
    /// - Parameters:
    ///   - label: The text to display in the snackbar.
    ///   - isPresented: A binding to a Boolean value that determines whether the snackbar is presented.
    ///   - position: The position of the snackbar on the screen. Default is `.top`.
    ///   - duration: The duration for which the snackbar is displayed. Default is 3 seconds.
    ///   - lineLimit: The maximum lines to be displayed.
    ///   - vOffset: The vertical offset of the snackbar from its position. Default is 0.
    /// - Returns: A view with the snackbar added to its background.
    func snackbar(
        _ label: String,
        isPresented: Binding<Bool>,
        position: SnackbarPosition = .bottom,
        duration: TimeInterval = 3,
        lineLimit: Int = 2,
        vOffset: CGFloat? = nil
    ) -> some View {
        snackbar(isPresented: isPresented, position: position, duration: duration, vOffset: vOffset) {
            Text(label)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(lineLimit)
                .multilineTextAlignment(.center)
        }
    }

    /// Adds a snackbar overlay to the view with customizable presentation options.
    ///
    /// This modifier creates a snackbar that appears as an overlay on top of the current view.
    /// The snackbar can be positioned at different locations, configured with custom duration,
    /// and styled with custom content. It automatically handles presentation timing and
    /// dismissal based on the provided parameters.
    ///
    /// - Parameters:
    ///   - isPresented: A binding that controls whether the snackbar is currently visible
    ///   - position: The vertical position where the snackbar should appear (default: .bottom)
    ///   - duration: The time in seconds the snackbar remains visible before auto-dismissing (default: 3)
    ///   - vOffset: Optional vertical offset to adjust the snackbar's position from its default location
    ///   - content: A view builder closure that defines the content to display inside the snackbar
    /// - Returns: A view with the snackbar overlay attached
    func snackbar(
        isPresented: Binding<Bool>,
        position: SnackbarPosition = .bottom,
        duration: TimeInterval = 3,
        vOffset: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        overlay {
            Snackbar(
                isPresented: isPresented,
                position: position,
                duration: duration,
                vOffset: vOffset,
                content: content
            )
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
