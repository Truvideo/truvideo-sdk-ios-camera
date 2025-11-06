//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

/// A view that adapts its layout and rotation based on the device’s orientation.
///
/// `AdaptiveOrientationLayoutView` automatically adjusts the rotation and alignment
/// of its child content when the device orientation changes. This provides a seamless
/// transition experience for views that need to adapt dynamically between portrait
/// and landscape modes.
struct AdaptiveOrientationLayoutView<Content: View>: View {
    // MARK: - Environment Properties

    @Environment(\.theme)
    var theme

    // MARK: - StateObject Properties

    @StateObject var viewModel = AdaptiveOrientationLayoutViewModel()

    // MARK: - Properties

    let content: () -> Content

    // MARK: - Body

    var body: some View {
        content()
            .rotationEffect(viewModel.rotationAngle)
            .id(viewModel.rotationAngle)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: viewModel.alignment)
            .animation(.easeInOut(duration: 0.8), value: viewModel.alignment)
    }

    // MARK: - Initializer

    /// Creates a new adaptive orientation layout with the given content.
    ///
    /// - Parameter content: A view builder that provides the content to display.
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
}
