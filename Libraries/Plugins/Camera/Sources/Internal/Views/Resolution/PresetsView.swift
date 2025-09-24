//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation
import SwiftUI

struct PresetsView: View {
    // MARK: - Properties

    let presets: [AVCaptureSession.Preset]

    // MARK: - Binding Properties

    @Binding var isPresented: Bool
    @Binding var selection: AVCaptureSession.Preset

    // MARK: - Environment Properties

    @Environment(\.theme)
    var theme

    // MARK: - StateObject Properties

    @StateObject var viewModel = OrientationViewModel()

    // MARK: - Body

    var body: some View {
        VStack(spacing: theme.spacingTheme.sm) {
            Text(Localizations.resolutions.uppercased())
                .style(theme.textTheme.callout.copyWith(color: .white))

            ForEach(presets, id: \.self) { preset in
                Button("\(preset.localizedLabel)") {
                    selection = preset
                }
                .buttonStyle(.primary)
                .frame(maxWidth: theme.sizeTheme.x(75))
                .selected(selection == preset)
            }
        }
        .if(viewModel.deviceOrientationSource == .sensors) { view in
            view.rotationEffect(viewModel.rotationAngle)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .topLeading) {
            CircleButton {
                Icon(icon: DSIcons.xmark, size: CGSize(theme.sizeTheme.lg))
            } action: {
                isPresented.toggle()
            }
            .padding(theme.spacingTheme.md)
        }
        .background(style: .dark)
    }
}
