//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation
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

    // MARK: - Binding Properties

    var selection: Binding<AVCaptureSession.Preset> {
        Binding(
            get: { viewModel.selectedPreset },
            set: { value in
                viewModel.setPreset(value)
                Task.delayed(milliseconds: 250) {
                    isPresented.toggle()
                }
            }
        )
    }

    // MARK: - Computed Properties

    var textColor: Color {
        let textColor = theme.colorScheme.onSurface

        return [.paused, .running].contains(viewModel.state) ? textColor.opacity(0.5) : textColor
    }

    // MARK: - Body

    var body: some View {
        CircleButton {
            Text(viewModel.selectedPreset.localizedLabel)
                .style(theme.textTheme.caption1.copyWith(color: textColor))
                .padding(UIDevice.current.isPad ? theme.spacingTheme.sm : theme.spacingTheme.xxs)
                .frame(minWidth: theme.sizeTheme.xxxl)
        } action: {
            isPresented.toggle()
        }
        .allowsHitTesting(viewModel.allowsHitTesting)
        .disabled([.paused, .running].contains(viewModel.state))
        .scaledFullScreenCover(isPresented: $isPresented) {
            PresetsView(presets: viewModel.presets, isPresented: $isPresented, selection: selection)
        }
    }
}
