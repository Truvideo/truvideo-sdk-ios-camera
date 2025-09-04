//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVKit
import SwiftUI

struct GalleryView: View {
    // MARK: - Binding Properties

    @Binding var isPresented: Bool
    @Binding var medias: [Media]

    // MARK: - Environment Properties

    @Environment(\.theme)
    var theme

    // MARK: - State Properties

    @State var isPreviewPresented = false

    // MARK: - Computed Properties

    var columns: [GridItem] {
        [
            GridItem(.flexible(), spacing: theme.spacingTheme.xxs),
            GridItem(.flexible(), spacing: theme.spacingTheme.xxs),
            GridItem(.flexible(), spacing: theme.spacingTheme.xxs),
        ]
    }

    // MARK: - Body

    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: columns, spacing: theme.spacingTheme.xxs) {
                ForEach(medias, id: \.createdAt) { media in
                    MediaView(media: media)
                        .overlay {
                            GeometryReader { geometryProxy in
                                ScaledTransitionView(isPresented: $isPreviewPresented) {
                                    MediaPreviewView(medias: $medias, isPresented: $isPreviewPresented)
                                        .hidden(!isPreviewPresented)
                                }
                                .startingFrame(geometryProxy.frame(in: .global))
                            }
                        }
                        .onTapGesture {
                            isPreviewPresented.toggle()
                        }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .overlay(alignment: .topLeading) {
            CircleButton {
                Icon(icon: DSIcons.xmark, size: CGSize(theme.sizeTheme.lg))
            } action: {
                isPresented.toggle()
            }
            .padding(.leading, theme.spacingTheme.md)
        }
    }

    // MARK: - Initializer

    /// Creates a new instance with bindings to control media content and presentation state.
    ///
    /// - Parameters:
    ///   - medias: A binding to the media collection that will be displayed in the gallery
    ///   - isPresented: A binding that controls whether the gallery is currently presented
    init(medias: Binding<[Media]>, isPresented: Binding<Bool>) {
        _isPresented = isPresented
        _medias = medias
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
        GeometryReader { geometryProxy in
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
            .aspectRatio(1, contentMode: .fit)
            .frame(height: geometryProxy.size.width)
            .clipped()
            .clipShape(.rect(cornerRadius: theme.radiusTheme.xs))
        }
    }
}
