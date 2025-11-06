//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

/// A view that displays authentication requirements for camera access.
///
/// This view presents users with a clear message about the need to authenticate
/// before using the camera functionality. It displays a lock icon, authentication
/// message, and provides a dismiss button for users to close the view. The view
/// is shown when the user is not authenticated and needs to sign in to access
/// camera features.
///
/// ## Usage Context
///
/// This view is displayed in the camera interface when `viewModel.isAuthorized`
/// is `false`, indicating that the user needs to authenticate before accessing
/// camera functionality. It provides a clear path forward while allowing
/// users to dismiss the view if they choose not to authenticate.
struct AuthenticationRequiredView: View {
    // MARK: - Environment Properties

    @Environment(\.theme)
    var theme

    // MARK: - EnvironmentObject Properties

    @EnvironmentObject var viewModel: CameraViewModel

    // MARK: - Computed Properties

    var width: CGFloat {
        min(UIScreen.main.bounds.width * 0.8, theme.spacingTheme.x(76))
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            VStack(spacing: theme.spacingTheme.xxxxl) {
                Icon(icon: DSIcons.lock, size: CGSize(width: theme.sizeTheme.x(30), height: theme.sizeTheme.x(40)))

                Text(Localizations.signInToContinue)
                    .style(theme.textTheme.headline.copyWith(color: theme.colorScheme.onSurface, weight: .bold))
                    .multilineTextAlignment(.center)

                Text(Localizations.signInToUseCamera)
                    .style(theme.textTheme.headline.copyWith(color: theme.colorScheme.onSurface))
                    .multilineTextAlignment(.center)
            }
            .frame(width: width)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .topLeading) {
            CircleButton {
                Icon(icon: DSIcons.xmark, size: CGSize(theme.sizeTheme.lg))
            } action: {
                viewModel.onDismiss()
            }
            .padding(.horizontal)
        }
    }
}
