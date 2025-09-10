//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

/// A full-screen gallery view that displays a grid of media items
/// and provides a close button to dismiss the gallery.
struct GalleryView: View {
    // MARK: - Binding Properties

    /// The collection of media items to display in the gallery.
    @Binding var medias: [Media]

    /// A Boolean value that indicates whether the gallery is currently presented.
    @Binding var isPresented: Bool

    // MARK: - Environment Properties

    @Environment(\.theme)
    var theme

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading) {
            CircleButton {
                Icon(icon: DSIcons.xmark, size: CGSize(theme.sizeTheme.lg))
            } action: {
                isPresented.toggle()
            }
            .padding(theme.spacingTheme.md)

            GalleryGrid(medias: $medias, isPresented: $isPresented, theme: theme)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            EmptyView()
                .background(style: .dark)
                .ignoresSafeArea()
        }
    }
}
