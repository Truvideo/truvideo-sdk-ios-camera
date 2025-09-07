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

    // MARK: - Computed Properties

    var isHidden: Bool {
        viewModel.numberOfClips.isEmpty && viewModel.numberOfPhotos.isEmpty && viewModel.numberOfMedias.isEmpty
    }

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
        .clipShape(.rect(cornerRadius: theme.radiusTheme.xs))
        .hidden(isHidden)
    }

    // MARK: - Private methods

    @ViewBuilder
    private func makeContent() -> some View {
        Text(viewModel.numberOfMedias)
            .style(theme.textTheme.footnote.copyWith(color: theme.colorScheme.onSurface, kerning: 1.3))
            .padding(.bottom, theme.spacingTheme.xs)
            .hidden(viewModel.numberOfMedias.isEmpty)

        VStack(spacing: theme.spacingTheme.xxs) {
            Icon(icon: DSIcons.video, size: CGSize(width: theme.spacingTheme.lg, height: theme.spacingTheme.md))
            Text(viewModel.numberOfClips)
                .style(theme.textTheme.footnote.copyWith(color: theme.colorScheme.onSurface, kerning: 1.3))
        }
        .hidden(viewModel.numberOfClips.isEmpty)

        VStack(spacing: theme.spacingTheme.xxs) {
            Icon(icon: DSIcons.photo, size: CGSize(width: theme.spacingTheme.lg, height: theme.spacingTheme.md))
            Text(viewModel.numberOfPhotos)
                .style(theme.textTheme.footnote.copyWith(color: theme.colorScheme.onSurface, kerning: 1.3))
        }
        .hidden(viewModel.numberOfPhotos.isEmpty)
    }
}
