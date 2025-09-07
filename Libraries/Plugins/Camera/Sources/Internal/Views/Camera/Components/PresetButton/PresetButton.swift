//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

/// A circular button that displays the current camera preset setting with rotation animation.
///
/// This view displays a button showing the current camera preset (e.g., "FHD" for Full HD)
/// with smooth rotation animation. The button automatically rotates based on the device
/// orientation to maintain proper text alignment and visual consistency.
struct PresetButton: View {
    // MARK: - Environment Properties

    @Environment(\.theme)
    var theme

    // MARK: - EnvironmentObject Properties

    @EnvironmentObject var viewModel: CameraViewModel

    // MARK: - State Properties

    @State var isPresented = false

    // MARK: - Body

    var body: some View {
        CircleButton {
            Text(viewModel.selectedResolution.title)
                .style(theme.textTheme.caption1.copyWith(color: theme.colorScheme.onSurface))
                .padding(theme.spacingTheme.xxs)
        } action: {
            isPresented.toggle()
        }
        .overlay {
            GeometryReader { geometryProxy in
                ScaledTransitionView(isPresented: $isPresented) {
                    ResolutionsView(isPresented: $isPresented, selection: $viewModel.selectedResolution)
                }
                .startingFrame(geometryProxy.frame(in: .global))
                .hidden(!isPresented)
            }
        }
    }
}
