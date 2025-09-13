//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

/// A circular button with customizable content and consistent theming.
///
/// `CircleButton` provides a standardized circular button design that automatically
/// applies theme-based styling, sizing, and button behavior. It ensures consistent
/// appearance across the interface while allowing flexible content through generic
/// content views.
///
/// ## Example Usage
///
/// ```swift
/// // Basic usage with icon
/// CircleButton {
///     Icon(icon: DSIcons.camera)
/// } action: {
///     // Handle tap action
/// }
///
/// // With custom content
/// CircleButton {
///     VStack {
///         Icon(icon: DSIcons.play)
///         Text("Play")
///     }
/// } action: {
///     // Handle tap action
/// }
/// ```
struct CircleButton<Content: View>: View {
    // MARK: - Environment Properties

    @Environment(\.theme)
    var theme

    // MARK: - Properties

    /// The content view builder that creates the button's visual content.
    let label: @MainActor () -> Content

    /// The action to perform when the button is tapped.
    let action: @MainActor () -> Void

    // MARK: - StateObject Properties

    @StateObject var viewModel = OrientationViewModel()

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            label()
                .padding(theme.spacingTheme.xxs)
        }
        .fixedSize()
        .buttonStyle(.primary)
        .clipShape(Circle())
        .theme(theme.copyWith(buttonTheme: theme.buttonTheme.copyWith(minimunSize: CGSize(theme.sizeTheme.xl))))
        .rotationEffect(viewModel.rotationAngle)
    }

    // MARK: - Initializer

    init(label: @escaping () -> Content, action: @escaping () -> Void) {
        self.label = label
        self.action = action
    }
}
