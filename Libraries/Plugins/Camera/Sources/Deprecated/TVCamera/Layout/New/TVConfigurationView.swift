//
//  TVConfigurationView.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 3/26/25.
//

import SwiftUI

struct TVConfigurationView: View {
    /// The view model handling the logic and data for camera features.
    @EnvironmentObject var viewModel: TVCameraViewModel

    /// The view model handling the logic and data for media counter
    @EnvironmentObject var mediaCounterViewModel: MediaCounterViewModel

    var body: some View {
        layer()
            .padding(.horizontal, 8)
    }

    // MARK: Private methods
    @ViewBuilder
    private func layer() -> some View {
        switch viewModel.layoutOrientation {
        case .landscapeRight, .landscapeLeft:
            landscapeLayer()
        default:
            portraitLayer()
        }
    }

    @ViewBuilder
    private func portraitLayer() -> some View {
        HStack(spacing: 8) {
            TVImageButton(image: TruVideoImage.close, style: .primary) {
                viewModel.closeCameraWithoutSaving()
            }
            .disabled(viewModel.isRecording)
            .rotationEffect(viewModel.rotationAngleValue)
            .animation(.spring(), value: viewModel.rotationAngleValue)

            Spacer()

            if viewModel.shouldShowFlashButton {
                TVImageButton(
                    image: TruVideoImage.flash,
                    style: viewModel.torchStatus == .on ? .secondary : .primary
                ) {
                    viewModel.toggleFlash()
                }
                .rotationEffect(viewModel.rotationAngleValue)
                .animation(.spring(), value: viewModel.rotationAngleValue)
            }

            if !viewModel.isRecording {
                TVImageButton(image: viewModel.resolutionImage, style: .primary) {
                    viewModel.navigateToResolutionPickerView()
                }
                .rotationEffect(viewModel.rotationAngleValue)
                .animation(.spring(), value: viewModel.rotationAngleValue)
            }

            if !viewModel.galleryItems.isEmpty && !viewModel.isRecording {
                TVImageButton(image: TruVideoImage.chevronRight, style: .primary) {
                    viewModel.closeCameraWithSaving()
                }
                .rotationEffect(viewModel.rotationAngleValue)
                .animation(.spring(), value: viewModel.rotationAngleValue)
            }
        }
    }

    @ViewBuilder
    private func landscapeLayer() -> some View {
        VStack(spacing: 8) {
            if viewModel.shouldShowFlashButton {
                TVImageButton(
                    image: TruVideoImage.flash,
                    style: viewModel.torchStatus == .on ? .secondary : .primary
                ) {
                    viewModel.toggleFlash()
                }
                .rotationEffect(viewModel.rotationAngleValue)
                .animation(.spring(), value: viewModel.rotationAngleValue)
            }

            if !viewModel.isRecording {
                TVImageButton(image: viewModel.resolutionImage, style: .primary) {
                    viewModel.navigateToResolutionPickerView()
                }
                .rotationEffect(viewModel.rotationAngleValue)
                .animation(.spring(), value: viewModel.rotationAngleValue)
            }

            if !viewModel.galleryItems.isEmpty && !viewModel.isRecording {
                TVImageButton(image: TruVideoImage.chevronRight, style: .primary) {
                    viewModel.closeCameraWithSaving()
                }
                .rotationEffect(viewModel.rotationAngleValue)
                .animation(.spring(), value: viewModel.rotationAngleValue)
            }

            Spacer()

            TVImageButton(image: TruVideoImage.close, style: .primary) {
                viewModel.closeCameraWithoutSaving()
            }
            .disabled(viewModel.isRecording)
            .rotationEffect(viewModel.rotationAngleValue)
            .animation(.spring(), value: viewModel.rotationAngleValue)
        }
    }
}

struct TVConfigurationViewPreview: View {

    @ObservedObject var viewModel: TVCameraViewModel
    @ObservedObject var mediaCounterViewModel: MediaCounterViewModel

    init() {
        let (viewModel, mediaCounterViewModel) = TVCameraFactory.shared.createPreviewCameraViewModels(for: .fixture()) {
            _ in
        }

        self.viewModel = viewModel
        self.mediaCounterViewModel = mediaCounterViewModel
    }

    var body: some View {
        TVConfigurationView()
            .environmentObject(viewModel)
            .environmentObject(mediaCounterViewModel)
    }
}

#Preview {
    TVConfigurationViewPreview()
}
