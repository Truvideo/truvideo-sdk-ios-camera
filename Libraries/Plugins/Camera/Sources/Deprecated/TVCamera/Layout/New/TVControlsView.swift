//
//  TVControlsView.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 3/26/25.
//

import SwiftUI

struct TVControlsView: View {
    /// The view model handling the logic and data for camera features.
    @EnvironmentObject var viewModel: TVCameraViewModel

    /// The content and behavior of the view.
    var body: some View {
        layer()
    }

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
        HStack(spacing: 16) {
            if viewModel.isRecording {
                TVImageButton(
                    image: viewModel.recordingIsPaused ? TruVideoImage.play : TruVideoImage.pause,
                    style: .primary
                ) {
                    viewModel.pauseTapped()
                }
                .rotationEffect(viewModel.rotationAngleValue)
                .animation(.spring(), value: viewModel.rotationAngleValue)
            } else {
                TVMediaCounterImageButton {
                    viewModel.navigateToGalleryPreview()
                }
                .rotationEffect(viewModel.rotationAngleValue)
                .animation(.spring(), value: viewModel.rotationAngleValue)
            }

            TVRecordButton(
                segmendtedOption: viewModel.segmendtedOption,
                isRecording: viewModel.isRecording
            ) {
                viewModel.capture()
            }

            if viewModel.isRecording {
                TVImageButton(image: TruVideoImage.camera, style: .primary) {
                    viewModel.takePhoto()
                }
                .rotationEffect(viewModel.rotationAngleValue)
                .animation(.spring(), value: viewModel.rotationAngleValue)
            } else {
                TVImageButton(image: TruVideoImage.flipCameraIcon, style: .primary) {
                    viewModel.flipTapped()
                }
                .rotationEffect(viewModel.rotationAngleValue)
                .animation(.spring(), value: viewModel.rotationAngleValue)
            }
        }
    }

    @ViewBuilder
    private func landscapeLayer() -> some View {
        VStack(spacing: 16) {
            if viewModel.isRecording {
                TVImageButton(image: TruVideoImage.camera, style: .primary) {
                    viewModel.takePhoto()
                }
                .rotationEffect(viewModel.rotationAngleValue)
                .animation(.spring(), value: viewModel.rotationAngleValue)
            } else {
                TVImageButton(image: TruVideoImage.flipCameraIcon, style: .primary) {
                    viewModel.flipTapped()
                }
                .rotationEffect(viewModel.rotationAngleValue)
                .animation(.spring(), value: viewModel.rotationAngleValue)
            }

            TVRecordButton(
                segmendtedOption: viewModel.segmendtedOption,
                isRecording: viewModel.isRecording
            ) {
                viewModel.capture()
            }

            if viewModel.isRecording {
                TVImageButton(image: TruVideoImage.pause, style: .primary) {
                    viewModel.pauseTapped()
                }
                .rotationEffect(viewModel.rotationAngleValue)
                .animation(.spring(), value: viewModel.rotationAngleValue)
            } else {
                TVMediaCounterImageButton {
                    viewModel.navigateToGalleryPreview()
                }
                .rotationEffect(viewModel.rotationAngleValue)
                .animation(.spring(), value: viewModel.rotationAngleValue)
            }
        }
    }
}

struct TVControlsViewPreview: View {

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
        TVControlsView()
            .environmentObject(viewModel)
            .environmentObject(mediaCounterViewModel)
    }
}

#Preview {
    TVControlsViewPreview()
}
