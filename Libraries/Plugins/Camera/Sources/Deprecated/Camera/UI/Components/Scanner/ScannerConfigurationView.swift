//
//  ScannerConfigurationView.swift
//  TruvideoSdkCamera
//
//  Created by Luis Francisco Piura Mejia on 31/7/24.
//

import SwiftUI

struct ScannerConfigurationView: View {
    /// An action that dismisses the view.
    let dismiss: (() -> Void)?

    /// The view model handling the logic and data for camera features.
    @EnvironmentObject var viewModel: ScannerCameraViewModel

    /// The content and behavior of the view.
    var body: some View {
        HStack(spacing: 8) {
            makeCircularButton(icon: TruVideoImage.close, isSelected: false) {
                dismiss?()
            }
            .disabled(viewModel.status == .loading)
            .animation(.spring(), value: viewModel.rotationAngle)

            Spacer()

            if viewModel.shouldShowFlashButton {
                makeFlashButton()
                    .rotationEffect(viewModel.rotationAngle)
                    .animation(.spring(), value: viewModel.rotationAngle)
            }
        }
        .padding(.horizontal, 8)
    }

    @ViewBuilder
    private func makeCircularButton(icon: Image, isSelected: Bool, action: @escaping () -> Void) -> some View {
        CircularButton(color: isSelected ? .iconFill : .gray.opacity(0.3), action: action) {
            icon
                .resizable()
                .withRenderingMode(.template, color: isSelected ? .black : .white)
                .scaledToFit()
                .frame(minWidth: 16, minHeight: 16)
                .fixedSize()
        }
        .frame(minWidth: 36, minHeight: 36)
        .fixedSize()
    }

    @ViewBuilder
    private func makeFlashButton() -> some View {
        PublisherListener(
            initialValue: viewModel.torchStatus,
            publisher: viewModel.$torchStatus,
            buildWhen: { previous, current in previous != current }
        ) { torchStatus in

            CircularButton(color: torchStatus == .on ? .iconFill : .gray.opacity(0.3), action: viewModel.toggleTorch) {
                (torchStatus == .on ? TruVideoImage.boltFill : TruVideoImage.boltSlashFill)
                    .resizable()
                    .withRenderingMode(.template, color: torchStatus == .on ? .black : .white)
                    .scaledToFit()
                    .frame(minWidth: 16, minHeight: 16)
                    .fixedSize()
            }
            .frame(minWidth: 36, minHeight: 36)
            .fixedSize()
            .id(torchStatus)
            .animation(.easeInOut(duration: 0.25), value: viewModel.recordStatus)
            .transition(.opacity)
        }
    }
}
