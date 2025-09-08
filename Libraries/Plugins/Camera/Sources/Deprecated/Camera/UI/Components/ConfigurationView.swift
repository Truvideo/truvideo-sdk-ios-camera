//
//  ConfigurationButtonsView.swift
//
//  Created by TruVideo on 6/16/22.
//  Copyright © 2023 TruVideo. All rights reserved.
//

import SwiftUI

extension Color {
    /// The fill color when the button is selected.
    ///
    /// - Note: Move this to color struct.
    static var iconFill: Color {
        Color(red: 245 / 255, green: 189 / 255, blue: 65 / 255)
    }
}

/// A custom SwiftUI view designed to provide buttons for various camera configuration options.
/// This view is useful when you want to offer users the ability to control different camera settings,
/// such as flash, HDR, timer, or grid.
struct ConfigurationView: View {
    /// An action that dismisses the view.
    let dismiss: (() -> Void)?

    /// The view model handling the logic and data for camera features.
    @EnvironmentObject var viewModel: CameraViewModelDeprecation

    /// The view model handling the logic and data for media counter
    @EnvironmentObject var mediaCounterViewModel: MediaCounterViewModel

    /// The content and behavior of the view.
    var body: some View {
        layer()
            .padding(.horizontal, 8)
    }

    // MARK: Private methods

    @ViewBuilder
    private func layer() -> some View {
        switch viewModel.layoutOrientation {
        case .landscapeLeft:
            landscapeLeftLayer()
        case .landscapeRight:
            landscapeRightLayer()
        default:
            portraitLayer()
        }
    }

    @ViewBuilder
    private func portraitLayer() -> some View {
        HStack(spacing: 8) {
            makeCircularButton(icon: TruVideoImage.close, isSelected: false) {
                dismiss?()
            }
            .disabled(viewModel.status == .loading)
            .rotationEffect(viewModel.rotationAngle)
            .animation(.spring(), value: viewModel.rotationAngle)

            if viewModel.isPortrait {
                MediaCounter(viewModel: mediaCounterViewModel) {
                    viewModel.navigateToGalleryPreview()
                }
            }

            Spacer()

            if viewModel.showResolutionPickerButton {
                makeResolutionPickerButton()
                    .rotationEffect(viewModel.rotationAngle)
                    .animation(.spring(), value: viewModel.rotationAngle)
            }

            if viewModel.shouldShowFlashButton {
                makeFlashButton()
                    .rotationEffect(viewModel.rotationAngle)
                    .animation(.spring(), value: viewModel.rotationAngle)
            }

            if viewModel.isPortrait, viewModel.galleryCount > 0 && viewModel.recordStatus != .recording {
                ContinueButtonDeprecation(
                    continueButtonOffset: .zero,
                    stopRecording: viewModel.stopRecording
                )
            }
        }
    }

    @ViewBuilder
    private func landscapeRightLayer() -> some View {
        VStack(spacing: 8) {
            if viewModel.isPortrait, viewModel.galleryCount > 0 && viewModel.recordStatus != .recording {
                ContinueButtonDeprecation(
                    rotate: true,
                    continueButtonOffset: .zero,
                    stopRecording: viewModel.stopRecording
                )
                .rotationEffect(viewModel.rotationAngle)
            }

            if viewModel.shouldShowFlashButton {
                makeFlashButton()
                    .rotationEffect(viewModel.rotationAngle)
                    .animation(.spring(), value: viewModel.rotationAngle)
            }

            if viewModel.showResolutionPickerButton {
                makeResolutionPickerButton()
                    .rotationEffect(viewModel.rotationAngle)
                    .animation(.spring(), value: viewModel.rotationAngle)
            }

            Spacer()

            if viewModel.isPortrait {
                MediaCounter(viewModel: mediaCounterViewModel) {
                    viewModel.navigateToGalleryPreview()
                }
                .rotationEffect(viewModel.rotationAngle)
            }

            makeCircularButton(icon: TruVideoImage.close, isSelected: false) {
                dismiss?()
            }
            .disabled(viewModel.status == .loading)
            .rotationEffect(viewModel.rotationAngle)
            .animation(.spring(), value: viewModel.rotationAngle)
        }
    }

    @ViewBuilder
    private func landscapeLeftLayer() -> some View {
        VStack(spacing: 8) {
            makeCircularButton(icon: TruVideoImage.close, isSelected: false) {
                dismiss?()
            }
            .disabled(viewModel.status == .loading)
            .rotationEffect(viewModel.rotationAngle)
            .animation(.spring(), value: viewModel.rotationAngle)

            if viewModel.isPortrait {
                MediaCounter(viewModel: mediaCounterViewModel) {
                    viewModel.navigateToGalleryPreview()
                }
                .rotationEffect(viewModel.rotationAngle)
            }

            Spacer()

            if viewModel.showResolutionPickerButton {
                makeResolutionPickerButton()
                    .rotationEffect(viewModel.rotationAngle)
                    .animation(.spring(), value: viewModel.rotationAngle)
            }

            if viewModel.shouldShowFlashButton {
                makeFlashButton()
                    .rotationEffect(viewModel.rotationAngle)
                    .animation(.spring(), value: viewModel.rotationAngle)
            }

            if viewModel.isPortrait, viewModel.galleryCount > 0 && viewModel.recordStatus != .recording {
                ContinueButtonDeprecation(
                    rotate: true,
                    continueButtonOffset: .zero,
                    stopRecording: viewModel.stopRecording
                )
                .rotationEffect(viewModel.rotationAngle)
            }
        }
    }

    private func makeResolutionPickerButton() -> some View {
        Button {
            guard viewModel.recordStatus != .recording else { return }

            viewModel.navigateToResolutionPickerView()
        } label: {
            ZStack {
                Circle()
                    .foregroundStyle(Color.iconFill)
                    .frame(width: 36, height: 36)

                TruVideoImage.highDefinition
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.black)
            }
        }.buttonStyle(SimpleButtonStyle())
    }

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
