//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

/// A view that displays counters for captured video clips and photos.
///
/// This view presents a horizontal layout showing the count of recorded video
/// clips and captured photos with their respective icons. It uses the theme
/// system for consistent styling and spacing, displaying video and photo
/// counts side by side with appropriate visual indicators.
///
/// The view automatically updates when the view model's clips or photos
/// collections change, providing real-time feedback on the user's capture
/// activity. The counters are displayed with icons above the count numbers
/// for clear visual identification of media types.
struct MediaCounterView: View {
    // MARK: - Environment Properties

    @Environment(\.theme)
    var theme

    // MARK: - EnvironmentObject Properties

    @EnvironmentObject var viewModel: CameraViewModel

    // MARK: - Body

    var body: some View {
        Group {
            if viewModel.deviceOrientation.isPortrait {
                HStack(spacing: theme.spacingTheme.md) {
                    makeContent()
                }
            } else if viewModel.deviceOrientation.isLandscape {
                VStack(spacing: theme.spacingTheme.md) {
                    makeContent()
                }
            }
        }
        .padding([.horizontal, .top], theme.spacingTheme.sm)
        .padding(.bottom, theme.spacingTheme.xs)
        .background(theme.colorScheme.primary)
        .clipShape(.rect(cornerRadius: theme.radiusTheme.sm))
        .hidden(viewModel.medias.isEmpty)
    }

    // MARK: - Private methods

    @ViewBuilder
    private func makeContent() -> some View {
        VStack(spacing: theme.spacingTheme.xxs) {
            Icon(icon: DSIcons.video, size: CGSize(width: theme.spacingTheme.lg, height: theme.spacingTheme.md))
            Text(viewModel.numberOfClips.description)
                .style(theme.textTheme.footnote.copyWith(color: theme.colorScheme.onSurface))
        }
        .hidden(viewModel.numberOfClips == 0)

        VStack(spacing: theme.spacingTheme.xxs) {
            Icon(icon: DSIcons.photo, size: CGSize(width: theme.spacingTheme.lg, height: theme.spacingTheme.md))
            Text(viewModel.numberOfPhotos.description)
                .style(theme.textTheme.footnote.copyWith(color: theme.colorScheme.onSurface))
        }
        .hidden(viewModel.numberOfPhotos == 0)
    }
}
