//
//  TVConfigurationViewV1.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 5/20/25.
//

import SwiftUI

struct TVConfigurationViewV1: View {
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
        if UIDevice.current.userInterfaceIdiom == .pad {
            portraitLayer()
        } else {
            switch viewModel.layoutOrientation {
            case .landscapeLeft:
                landscapeLeftLayer()
            case .landscapeRight:
                landscapeRightLayer()
            default:
                portraitLayer()
            }
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

            if viewModel.currentOrientation.isPortrait {
                MediaCounter(viewModel: mediaCounterViewModel) {
                    viewModel.navigateToGalleryPreview()
                }
            }

            Spacer()

            if !viewModel.isRecording {
                makeResolutionPickerButton()
            }

            if viewModel.shouldShowFlashButton {
                makeFlashButton()
            }

            if viewModel.currentOrientation.isPortrait,
                !viewModel.galleryItems.isEmpty && !viewModel.isRecording
            {
                ContinueButtonDeprecation(continueButtonOffset: .zero) {
                    viewModel.closeCameraWithSaving()
                }
            }
        }
    }

    @ViewBuilder
    private func landscapeRightLayer() -> some View {
        VStack(spacing: 8) {
            if viewModel.currentOrientation.isPortrait,
                !viewModel.galleryItems.isEmpty && !viewModel.isRecording
            {
                ContinueButtonDeprecation(rotate: true, continueButtonOffset: .zero) {
                    viewModel.closeCameraWithSaving()
                }
                .rotationEffect(viewModel.rotationAngleValue)
            }

            if viewModel.shouldShowFlashButton {
                makeFlashButton()
            }

            if !viewModel.isRecording {
                makeResolutionPickerButton()
            }

            Spacer(minLength: 0)

            if viewModel.currentOrientation.isPortrait {
                MediaCounter(rotate: true, viewModel: mediaCounterViewModel) {
                    viewModel.navigateToGalleryPreview()
                }
                .rotationEffect(viewModel.rotationAngleValue)
            }

            TVImageButton(image: TruVideoImage.close, style: .primary) {
                viewModel.closeCameraWithoutSaving()
            }
            .disabled(viewModel.isRecording)
            .rotationEffect(viewModel.rotationAngleValue)
            .animation(.spring(), value: viewModel.rotationAngleValue)
        }
    }

    @ViewBuilder
    private func landscapeLeftLayer() -> some View {
        VStack(spacing: 8) {
            TVImageButton(image: TruVideoImage.close, style: .primary) {
                viewModel.closeCameraWithoutSaving()
            }
            .disabled(viewModel.isRecording)
            .rotationEffect(viewModel.rotationAngleValue)
            .animation(.spring(), value: viewModel.rotationAngleValue)

            if viewModel.currentOrientation.isPortrait {
                MediaCounter(rotate: true, viewModel: mediaCounterViewModel) {
                    viewModel.navigateToGalleryPreview()
                }
                .rotationEffect(viewModel.rotationAngleValue)
            }

            Spacer(minLength: 0)

            if !viewModel.isRecording {
                makeResolutionPickerButton()
            }

            if viewModel.shouldShowFlashButton {
                makeFlashButton()
            }

            if viewModel.currentOrientation.isPortrait,
                !viewModel.galleryItems.isEmpty && !viewModel.isRecording
            {
                ContinueButtonDeprecation(rotate: true, continueButtonOffset: .zero) {
                    viewModel.closeCameraWithSaving()
                }
                .rotationEffect(viewModel.rotationAngleValue)
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
                    .foregroundStyle(.gray.opacity(0.3))
                    .frame(width: 48, height: 48)

                viewModel.resolutionImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.black)
            }
        }
        .buttonStyle(SimpleButtonStyle())
        .rotationEffect(viewModel.rotationAngleValue)
        .animation(.spring(), value: viewModel.rotationAngleValue)
    }

    private func makeFlashButton() -> some View {
        PublisherListener(
            initialValue: viewModel.torchStatus,
            publisher: viewModel.$torchStatus,
            buildWhen: { previous, current in previous != current }
        ) { torchStatus in

            CircularButton(color: torchStatus == .on ? .iconFill : .gray.opacity(0.3), action: viewModel.toggleFlash) {
                (torchStatus == .on ? TruVideoImage.boltFill : TruVideoImage.boltSlashFill)
                    .resizable()
                    .withRenderingMode(.template, color: torchStatus == .on ? .black : .white)
                    .scaledToFit()
                    .frame(minWidth: 16, minHeight: 16)
                    .fixedSize()
            }
            .frame(minWidth: 48, minHeight: 48)
            .fixedSize()
            .id(torchStatus)
            .animation(.easeInOut(duration: 0.25), value: viewModel.recordStatus)
            .transition(.opacity)
        }
        .rotationEffect(viewModel.rotationAngleValue)
        .animation(.spring(), value: viewModel.rotationAngleValue)
    }
}

struct TVConfigurationViewV1Preview: View {

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
        TVConfigurationViewV1()
            .environmentObject(viewModel)
            .environmentObject(mediaCounterViewModel)
    }
}

#Preview {
    TVConfigurationViewV1Preview()
}
