//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

/// A styled continue button that dismisses the current view when tapped.
///
/// This view displays a primary-styled button with the text "Continue" that
/// automatically dismisses the current view presentation context when tapped.
/// The button features a rounded border overlay that provides visual emphasis
/// and maintains consistent theming with the app's design system.
struct ContinueButton: View {
    // MARK: - Environment Properties

    @Environment(\.dismiss)
    var dismiss

    @Environment(\.theme)
    var theme

    // MARK: - EnvironmentObject Properties

    @EnvironmentObject var viewModel: CameraViewModel

    // MARK: - Body

    var body: some View {
        Button("Continue", action: dismiss.callAsFunction)
            .buttonStyle(.primary)
            .overlay(
                RoundedRectangle(cornerRadius: theme.radiusTheme.xs)
                    .stroke(theme.colorScheme.onPrimary, lineWidth: 1)
            )
            .padding(.trailing, theme.spacingTheme.xs)
    }
}
