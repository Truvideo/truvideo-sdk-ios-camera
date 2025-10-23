//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

/// A circular button that controls the device's torch/flashlight functionality.
///
/// This view displays a button with a bolt icon that toggles between on and off states
/// for the device torch. The button automatically updates its appearance based on the
/// torch state and availability, providing visual feedback for the current status.
struct TorchButton: View {
    // MARK: - Environment Properties

    @Environment(\.dismiss)
    var dismiss

    @Environment(\.theme)
    var theme

    // MARK: - EnvironmentObject Properties

    @EnvironmentObject var viewModel: CameraViewModel

    // MARK: - Computed Properties

    private var buttonSize: CGFloat {
        UIDevice.current.isPad ? theme.sizeTheme.xl : theme.sizeTheme.x(4.5)
    }

    // MARK: - Body

    var body: some View {
        CircleButton {
            Icon(
                icon: viewModel.isTorchEnabled ? DSIcons.boltFill : DSIcons.boltSlashFill,
                color: viewModel.isTorchEnabled ? theme.colorScheme.surface : theme.colorScheme.onSurface,
                size: CGSize(buttonSize)
            )
            .if(UIDevice.current.isPad) { view in
                view.padding(theme.spacingTheme.xs)
            }
        } action: {
            viewModel.switchTorch()
        }
        .disabled(!viewModel.isTorchAvailable)
        .selected(viewModel.isTorchEnabled)
        .allowsHitTesting(viewModel.allowsHitTesting)
    }
}
