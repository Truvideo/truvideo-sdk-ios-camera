//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

/// A modal alert view that confirms whether the user wants to exit and discard changes.
///
/// This view presents a confirmation dialog when the user attempts to exit the current
/// context, asking them to confirm whether they want to discard any unsaved changes.
/// It displays an exit message, discard confirmation text, and action buttons for
/// confirming the exit or canceling the action.
///
/// The view uses a material background with a centered content area and includes
/// a close button in the top-left corner. It features smooth animations for
/// presentation and dismissal, with scale and opacity transitions for a polished
/// user experience.
struct ExitConfirmationView: View {
    // MARK: - Environment Properties

    @Environment(\.theme)
    var theme

    // MARK: - EnvironmentObject Properties

    @EnvironmentObject var viewModel: CameraViewModel

    // MARK: - Binding Properties

    @Binding var isPresented: Bool

    // MARK: - Body

    var body: some View {
        ZStack {
            VStack(spacing: theme.spacingTheme.lg) {
                Text(Localizations.exit.uppercased())
                    .style(theme.textTheme.headline.copyWith(color: theme.colorScheme.onSurface, weight: .bold))

                Text(Localizations.discardMessage)
                    .style(theme.textTheme.headline.copyWith(color: theme.colorScheme.onSurface))
                    .multilineTextAlignment(.center)

                Button(Localizations.discard.uppercased()) {
                    viewModel.onDismiss(force: true)
                }
                .buttonStyle(.primary(backgroundColor: .red))

                Button(Localizations.cancel.uppercased()) {
                    isPresented.toggle()
                }
                .buttonStyle(.primary)
            }
            .frame(width: theme.sizeTheme.x(75))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(style: .dark)
        .animation(.easeInOut, value: isPresented)
        .transition(.scale.combined(with: .opacity))
        .overlay(alignment: .topLeading) {
            CircleButton {
                Icon(icon: DSIcons.xmark, size: .init(theme.sizeTheme.lg))
            } action: {
                isPresented.toggle()
            }
            .padding(.horizontal, theme.spacingTheme.md)
        }
    }
}
