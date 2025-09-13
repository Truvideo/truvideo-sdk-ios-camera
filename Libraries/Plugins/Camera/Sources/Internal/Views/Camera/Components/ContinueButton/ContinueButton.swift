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

    // MARK: - StateObject Properties

    @StateObject var viewModel = OrientationViewModel()

    // MARK: - Properties

    let onTap: () -> Void

    // MARK: - Computed Properties

    var alignment: Alignment {
        switch viewModel.deviceOrientation {
        case .landscapeLeft where viewModel.deviceOrientationSource == .sensors:
            .bottomTrailing

        case .landscapeRight where viewModel.deviceOrientationSource == .sensors:
            .topLeading

        default:
            .topTrailing
        }
    }

    var buttonTheme: ButtonTheme {
        theme.buttonTheme.copyWith(minimunSize: CGSize(width: theme.sizeTheme.x(30), height: theme.sizeTheme.xxxl))
    }

    var offset: CGPoint {
        switch viewModel.deviceOrientation {
        case .landscapeLeft where viewModel.deviceOrientationSource == .sensors:
            CGPoint(x: theme.spacingTheme.x(10), y: -theme.spacingTheme.x(12))

        case .landscapeRight where viewModel.deviceOrientationSource == .sensors:
            CGPoint(x: -theme.spacingTheme.x(10), y: theme.spacingTheme.x(12))

        default:
            .zero
        }
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Button(Localizations.continueText, action: onTap)
                .buttonStyle(.primary)
                .fixedSize()
                .theme(theme.copyWith(buttonTheme: buttonTheme))
                .overlay(
                    RoundedRectangle(cornerRadius: theme.radiusTheme.xs)
                        .stroke(theme.colorScheme.onPrimary, lineWidth: 1)
                )
                .padding(.trailing, theme.spacingTheme.xs)
                .if(viewModel.deviceOrientationSource == .sensors) { view in
                    view
                        .rotationEffect(viewModel.rotationAngle)
                        .offset(x: offset.x, y: offset.y)
                }
                .id(viewModel.deviceOrientation)
                .transition(.opacity.animation(.linear(duration: 0.25)))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
    }
}
