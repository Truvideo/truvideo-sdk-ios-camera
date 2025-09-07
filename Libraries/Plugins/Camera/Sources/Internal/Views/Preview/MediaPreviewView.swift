//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVKit
import SwiftUI

struct MediaPreviewView: View {
    // MARK: - Binding Properties

    @Binding var isPresented: Bool
    @Binding var medias: [Media]

    // MARK: - Environment Properties

    @Environment(\.theme)
    var theme

    // MARK: - StateObject Properties

    @StateObject var viewModel: MediaPreviewViewModel

    // MARK: - Body

    var body: some View {
        TabView(selection: $viewModel.selection) {
            ForEach(Array(viewModel.medias.enumerated()), id: \.offset) { index, media in
                MediaView(media: media)
                    .aspectRatio(viewModel.aspectRatio, contentMode: .fit)
                    .padding(.top, theme.spacingTheme.xxxl)
                    .tag(index)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.colorScheme.surfaceContainer)
        .tabViewStyle(.page(indexDisplayMode: .never))
        .onChange(of: viewModel.medias) { newMedias in
            medias = newMedias
        }
        .overlay(alignment: .top) {
            makeTopBar()
        }
    }

    // MARK: - Initializer

    /// Creates a new media preview view with bindings and a view model.
    ///
    /// This initializer sets up a media preview view that displays a collection
    /// of media items with interactive preview capabilities.
    ///
    /// - Parameters:
    ///   - medias: A binding to the media collection that will be displayed in the preview
    ///   - isPresented: A binding that controls whether the preview is currently presented
    init(medias: Binding<[Media]>, isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        self._medias = medias
        self._viewModel = StateObject(wrappedValue: MediaPreviewViewModel(medias: medias.wrappedValue))
    }

    // MARK: - Private methods

    private func makeTopBar() -> some View {
        HStack {
            CircleButton {
                Icon(icon: DSIcons.xmark, size: CGSize(theme.sizeTheme.lg))
            } action: {
                isPresented.toggle()
            }

            Spacer()
            CircleButton {
                Icon(icon: DSIcons.trash, size: CGSize(theme.sizeTheme.lg))
            } action: {
                viewModel.delete()
            }
        }
        .padding(.horizontal, theme.spacingTheme.xl)
    }
}

private struct MediaView: View {
    // MARK: - Environment Properties

    @Environment(\.theme)
    var theme

    // MARK: - Properties

    let media: Media

    // MARK: - Body

    var body: some View {
        ZStack {
            switch media {
            case let .clip(clip):
                VideoPlayer(player: AVPlayer(url: clip.url))

            case let .photo(photo):
                AsyncRemoteImage(url: photo.url) { image in
                    image.resizable()
                        .scaledToFill()
                } placeholder: {
                    theme.colorScheme.surface
                }
            }
        }
    }
}
