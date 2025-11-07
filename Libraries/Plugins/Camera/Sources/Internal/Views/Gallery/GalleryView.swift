//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

struct GalleryView: View {
    // MARK: - Binding Properties

    /// The collection of media items to display in the gallery.
    @Binding var medias: [Media]

    /// A Boolean value that indicates whether the gallery is currently presented.
    @Binding var isPresented: Bool

    // MARK: - Environment Properties

    @Environment(\.theme)
    var theme

    // MARK: - Computed Properties

    private var size: CGSize {
        UIDevice.current.isPad ? CGSize(theme.sizeTheme.xl) : CGSize(theme.sizeTheme.lg)
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading) {
            CircleButton {
                Icon(icon: DSIcons.xmark, size: size)
            } action: {
                isPresented.toggle()
            }
            .padding(theme.spacingTheme.md)

            GalleryGrid(medias: $medias, isPresented: $isPresented, theme: theme)
                .accessibilityIdentifier(GalleryView.AccessibilityLabel.galleryGrid)
        }
        .accessibilityElement(children: .contain)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            EmptyView()
                .background(style: .dark)
                .ignoresSafeArea()
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(GalleryView.AccessibilityLabel.galleryView)
    }
}
