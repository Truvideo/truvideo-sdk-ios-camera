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

    @Environment(\.theme)
    var theme

    // MARK: - EnvironmentObject Properties

    @EnvironmentObject var viewModel: CameraViewModel

    // MARK: - Computed Properties

    var buttonTheme: ButtonTheme {
        theme.buttonTheme.copyWith(minimunSize: CGSize(width: theme.sizeTheme.x(30), height: theme.sizeTheme.xxxl))
    }

    // MARK: - Body

    var body: some View {
        Button(Localizations.continueText, action: viewModel.onContinue)
            .buttonStyle(.primary)
            .fixedSize()
            .theme(theme.copyWith(buttonTheme: buttonTheme))
            .overlay(
                RoundedRectangle(cornerRadius: theme.radiusTheme.xs)
                    .stroke(theme.colorScheme.onPrimary, lineWidth: 1)
            )
            .padding(.trailing, theme.spacingTheme.xs)
    }
}
