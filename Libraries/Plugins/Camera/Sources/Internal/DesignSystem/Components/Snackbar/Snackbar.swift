//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI
import UIKit

/// An enumeration that specifies the alignment mode for a Snackbar.
///
/// `SnackbarPosition` defines two possible positions where the Snackbar can be displayed: at the top or at the bottom
/// of the screen.
enum SnackbarPosition {
    /// Display the Snackbar at the bottom of the screen.
    case bottom

    /// Display the Snackbar at the top of the screen.
    case top
}

/// A SwiftUI view representing a customizable snackbar notification.
///
/// Use `SnackBar` to display temporary notifications at the top or bottom of the screen.
///
/// Example usage:
/// ```swift
/// @State private var isSnackBarShowing = false
///
/// var body: some View {
///     VStack {
///         Text("Main Content")
///             .padding()
///
///         Button("Show Snackbar") {
///             isSnackBarShowing.toggle()
///         }
///     }
///     .snackBar(isPresented: $isSnackBarShowing) {
///         Text("Snackbar message here.")
///             .padding()
///             .background(Color.gray)
///             .cornerRadius(8)
///             .padding(.horizontal, 20)
///             .padding(.vertical, 10)
///     }
/// }
/// ```
///
/// This struct creates a snackbar that can display any SwiftUI view (`Content`) based on its visibility state
/// (`isShowing`).
struct Snackbar<Content: View>: View {
    // MARK: - Binding Properties

    @Binding var isPresented: Bool

    // MARK: - Environment Properties

    @Environment(\.theme)
    var theme

    // MARK: - Properties

    /// The content of the `Snackbar`.
    @ViewBuilder let content: () -> Content

    /// The time in which snackbar is presented.
    let duration: TimeInterval

    /// The alignment for the snackbar content.
    let position: SnackbarPosition

    /// The vertical shift to adjust the position of the snackbar.
    let vOffset: CGFloat?

    /// A tag that identifies the snackbar view.
    let tag = Int.random(in: 0 ... 10_000)

    // MARK: - Body

    var body: some View {
        WindowReader { window in
            Color.clear
                .fixedSize()
                .onChange(of: isPresented) { isPresented in
                    guard let window, isPresented else { return }

                    showSnackBar(in: window)
                }
        }
    }

    // MARK: - Initializer

    /// Creates new instance of the `SnackBar`.
    ///
    /// - Parameters:
    ///   - isPresented: Binding to control the visibility of the snackbar.
    ///   - duration: The time in which snackbar is presented.
    ///   - position: The position for the snackbar.
    ///   - vOffset: The vertical shift to adjust the position of the snackbar.
    ///   - content: Closure providing the content of the snackbar.
    init(
        isPresented: Binding<Bool>,
        position: SnackbarPosition = .top,
        duration: TimeInterval = 0.25,
        vOffset: CGFloat?,
        content: @escaping () -> Content
    ) {
        self._isPresented = isPresented
        self.content = content
        self.duration = duration
        self.position = position
        self.vOffset = vOffset
    }

    // MARK: - Private methods

    private func showSnackBar(in window: UIWindow) {
        let snackbarView = SnackbarView(
            isPresented: $isPresented,
            frame: CGRect(origin: .zero, size: CGSize(width: window.bounds.size.width, height: 0)),
            position: position,
            theme: theme,
            vOffset: vOffset,
            content: content
        )

        snackbarView.alpha = 0
        snackbarView.tag = tag

        window.addSubview(snackbarView)

        snackbarView.alpha = 1
        snackbarView.show()

        Task.delayed(milliseconds: duration * 1_000) { @MainActor in
            snackbarView.hide()

            Task.delayed(milliseconds: 300) { @MainActor in
                isPresented = false
                window.viewWithTag(tag)?.alpha = 0
                window.viewWithTag(tag)?.removeFromSuperview()
            }
        }
    }
}

final class SnackbarState: ObservableObject {
    @Published var isPresented = false
}

private struct SnackbarContent<Content: View>: View {
    // MARK: - Properties

    /// The position for the snackbar (top or bottom).
    let position: SnackbarPosition

    /// The vertical offset for the snackbar.
    let vOffset: CGFloat?

    /// The UIWindow in which the snackbar is presented.
    let window: UIWindow

    // MARK: - ObservedObject Properties

    @ObservedObject var state: SnackbarState

    // MARK: - ViewBuilder Properties

    /// Closure providing the content of the snackbar.
    @ViewBuilder let content: () -> Content

    // MARK: - Environment Properties

    @Environment(\.theme)
    var theme

    // MARK: - State Properties

    @State var contentSize: CGSize = .zero

    // MARK: - Computed Properties

    private var contentYPosition: CGFloat {
        let vOffset = vOffset ?? 50

        guard position == .bottom else {
            return contentSize.height + window.safeAreaInsets.top + vOffset
        }

        return (window.frame.height - window.safeAreaInsets.bottom) - vOffset
    }

    private var effectiveContentPadding: EdgeInsets {
        theme.snackbarTheme.contentPadding ?? .all(theme.spacingTheme.md)
    }

    private var effectiveTextStyle: TextStyle {
        theme.snackbarTheme.textStyle ?? theme.textTheme.caption1.copyWith(color: theme.colorScheme.onSurface)
    }

    private var transition: AnyTransition {
        guard position == .bottom else {
            return .move(edge: .top).combined(with: .opacity)
        }

        let insertion = AnyTransition.move(edge: .top).combined(with: .offset(y: 100))
        let removal = AnyTransition.move(edge: .bottom).combined(with: .offset(y: 100))
        return .asymmetric(insertion: insertion, removal: removal)
    }

    // MARK: - Body

    var body: some View {
        Group {
            if state.isPresented {
                content()
                    .textStyle(effectiveTextStyle)
                    .frame(minWidth: 100, maxWidth: window.bounds.width - theme.spacingTheme.x(20))
                    .fixedSize()
                    .padding(effectiveContentPadding)
                    .background(theme.snackbarTheme.backgroundColor ?? theme.colorScheme.surface.opacity(0.7))
                    .cornerRadius(theme.snackbarTheme.cornerRadius ?? theme.radiusTheme.sm)
                    .shadow(
                        color: theme.snackbarTheme.shadowColor,
                        radius: theme.snackbarTheme.cornerRadius ?? theme.radiusTheme.sm,
                        x: theme.snackbarTheme.shadowOffset.x,
                        y: theme.snackbarTheme.shadowOffset.y
                    )
                    .transition(transition)
                    .offset(y: contentYPosition)
                    .background {
                        GeometryReader { geometry in
                            Color.clear
                                .onAppear {
                                    contentSize = .init(width: 0, height: geometry.size.height)
                                }
                        }
                    }
            }
        }
    }
}

private class SnackbarView<Content: View>: UIView {
    // MARK: - Properties

    let content: () -> Content
    let isPresented: Binding<Bool>
    let position: SnackbarPosition
    let snackbarState = SnackbarState()
    let theme: Theme
    let vOffset: CGFloat?

    // MARK: - Initializer

    /// Creates a new instance of the `SnackBarView`.
    ///
    /// - Parameters:
    ///   - isPresented: Binding to control the visibility of the snackbar.
    ///   - frame: The initial frame for the snackbar view.
    ///   - position: The position for the snackbar.
    ///   - theme: The default theme of the JCrew components library.
    ///   - vOffset: The vertical offset for the snackbar.
    ///   - content: Closure providing the content of the snackbar.
    init(
        isPresented: Binding<Bool>,
        frame: CGRect,
        position: SnackbarPosition,
        theme: Theme,
        vOffset: CGFloat?,
        content: @escaping () -> Content
    ) {
        self.position = position
        self.content = content
        self.theme = theme
        self.vOffset = vOffset
        self.isPresented = isPresented

        super.init(frame: frame)

        autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("Unsupported")
    }

    // MARK: - Overridden methods

    override func didMoveToWindow() {
        super.didMoveToWindow()

        guard let window else { return }

        let snackbarContent = SnackbarContent(
            position: position,
            vOffset: vOffset,
            window: window,
            state: snackbarState,
            content: content
        )
        .environment(\.theme, theme)

        let hostingController = UIHostingController(rootView: snackbarContent)

        hostingController.view.frame = bounds
        hostingController.view.backgroundColor = .clear
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        addSubview(hostingController.view)

        setNeedsLayout()
        layoutIfNeeded()
    }

    // MARK: - Instance methods

    /// Hides the snackbar with a smooth animation.
    ///
    /// This method animates the snackbar's dismissal by setting the presentation state
    /// to false with a smooth transition. The animation provides visual feedback for
    /// the user and ensures a polished user experience when the snackbar disappears.
    func hide() {
        withAnimation {
            snackbarState.isPresented = false
        }
    }

    /// Shows the snackbar with a smooth animation and haptic feedback.
    ///
    /// This method animates the snackbar's appearance by setting the presentation state
    /// to true with a smooth transition. It also provides haptic feedback using a light
    /// impact generator to enhance the user experience and draw attention to the notification.
    func show() {
        withAnimation {
            snackbarState.isPresented = true
        }

        UIImpactFeedbackGenerator(style: .light)
            .impactOccurred()
    }
}
