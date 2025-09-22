//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

/// A view that displays camera permission requirements and provides access to app settings.
///
/// This view presents users with information about camera permissions and guides them
/// to enable camera access through the device's Settings app. It displays an icon,
/// permission message, disclaimer text, and a button to open app settings. The view
/// also includes a disabled record button to show the camera interface when permissions
/// are granted.
///
/// The view automatically adapts its layout based on device orientation, using
/// different spacing values for portrait and landscape orientations to ensure
/// optimal visual presentation across all device orientations.
struct PermissionsView: View {
    // MARK: - Environment Properties

    @Environment(\.theme)
    var theme

    @Environment(\.dismiss)
    var dismiss

    // MARK: - EnvironmentObject Properties

    @EnvironmentObject var viewModel: CameraViewModel

    // MARK: - Computed Properties

    var width: CGFloat {
        guard viewModel.deviceOrientation.isPortrait else {
            return theme.spacingTheme.x(100)
        }

        return min(UIScreen.main.bounds.width * 0.8, theme.spacingTheme.x(76))
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            VStack(spacing: viewModel.deviceOrientation.isPortrait ? theme.spacingTheme.x(15) : theme.spacingTheme.lg) {
                MessageView()
                Button(action: viewModel.openAppSettings) {
                    Text(Localizations.openSettings)
                        .style(theme.textTheme.headline.copyWith(color: theme.colorScheme.onSurface, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, theme.spacingTheme.xl)
                }

                RecordButton()
                    .allowsHitTesting(false)
                    .hidden(!viewModel.deviceOrientation.isPortrait)
                    .opacity(0.5)
            }
            .frame(width: width)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .topLeading) {
            CircleButton {
                Icon(icon: DSIcons.xmark, size: CGSize(theme.sizeTheme.lg))
            } action: {
                dismiss()
            }
            .padding(.horizontal)
            .padding(.top, viewModel.deviceOrientation.isLandscape ? theme.spacingTheme.lg : 0)
        }
    }
}

private struct MessageView: View {
    // MARK: - Environment Properties

    @Environment(\.theme)
    var theme

    // MARK: - EnvironmentObject Properties

    @EnvironmentObject var viewModel: CameraViewModel

    // MARK: - Body

    var body: some View {
        VStack(spacing: viewModel.deviceOrientation.isPortrait ? theme.spacingTheme.xxxxl : theme.spacingTheme.lg) {
            Icon(icon: DSIcons.iphoneCamera, size: CGSize(width: theme.sizeTheme.x(30), height: theme.sizeTheme.x(40)))

            Text(Localizations.permissionMessage)
                .style(theme.textTheme.headline.copyWith(color: theme.colorScheme.onSurface, weight: .bold))
                .multilineTextAlignment(.center)

            Text(Localizations.permissionDisclaimer)
                .style(theme.textTheme.headline.copyWith(color: theme.colorScheme.onSurface))
                .multilineTextAlignment(.center)
        }
    }
}
