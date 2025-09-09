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

    /// The current theme, injected from the environment.
    @Environment(\.theme)
    var theme

    // MARK: - Body

    var body: some View {
        VStack {
            GalleryGrid(medias: medias, theme: theme)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .overlay(alignment: .topLeading) {
            CircleButton {
                Icon(icon: DSIcons.xmark, size: CGSize(theme.sizeTheme.lg))
            } action: {
                isPresented.toggle()
            }
            .padding(theme.spacingTheme.md)
        }
    }
}
