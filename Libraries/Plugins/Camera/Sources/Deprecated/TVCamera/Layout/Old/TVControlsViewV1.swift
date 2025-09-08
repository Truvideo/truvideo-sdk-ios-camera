//
//  TVControlsViewV1.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 5/20/25.
//

import SwiftUI

struct TVControlsViewV1: View {
    /// The view model handling the logic and data for camera features.
    @EnvironmentObject var viewModel: TVCameraViewModel

    /// The content and behavior of the view.
    var body: some View {
        layer()
    }

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
        HStack(spacing: 16) {
            if viewModel.isOneModeOnly {
                Circle()
                    .foregroundStyle(.black)
                    .modifiedButton()
            } else {
                TVImageButton(image: TruVideoImage.camera, style: .primary) {
                    viewModel.takePhoto()
                }
                .rotationEffect(viewModel.rotationAngleValue)
                .animation(.spring(), value: viewModel.rotationAngleValue)
            }

            RecordButtonDeprecation(
                recordStatus: viewModel.recordStatus,
                recordStatusPublisher: viewModel.$recordStatus.eraseToAnyPublisher(),
                allowRecordingVideos: viewModel.preset.mode.canRecordVideos,
                record: viewModel.capture,
                pause: viewModel.capture,
                takePhoto: viewModel.capture
            )

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
                TVImageButton(image: TruVideoImage.flipCameraIcon, style: .primary) {
                    viewModel.flipTapped()
                }
                .rotationEffect(viewModel.rotationAngleValue)
                .animation(.spring(), value: viewModel.rotationAngleValue)
            }
        }
    }

    @ViewBuilder
    private func landscapeRightLayer() -> some View {
        VStack(spacing: 16) {
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
                TVImageButton(image: TruVideoImage.flipCameraIcon, style: .primary) {
                    viewModel.flipTapped()
                }
                .rotationEffect(viewModel.rotationAngleValue)
                .animation(.spring(), value: viewModel.rotationAngleValue)
            }

            RecordButtonDeprecation(
                recordStatus: viewModel.recordStatus,
                recordStatusPublisher: viewModel.$recordStatus.eraseToAnyPublisher(),
                allowRecordingVideos: viewModel.preset.mode.canRecordVideos,
                record: viewModel.capture,
                pause: viewModel.capture,
                takePhoto: viewModel.capture
            )

            if viewModel.isOneModeOnly {
                Circle()
                    .foregroundStyle(.black)
                    .modifiedButton()
            } else {
                TVImageButton(image: TruVideoImage.camera, style: .primary) {
                    viewModel.takePhoto()
                }
                .rotationEffect(viewModel.rotationAngleValue)
                .animation(.spring(), value: viewModel.rotationAngleValue)
            }
        }
    }

    @ViewBuilder
    private func landscapeLeftLayer() -> some View {
        VStack(spacing: 16) {
            if viewModel.isOneModeOnly {
                Circle()
                    .foregroundStyle(.black)
                    .modifiedButton()
            } else {
                TVImageButton(image: TruVideoImage.camera, style: .primary) {
                    viewModel.takePhoto()
                }
                .rotationEffect(viewModel.rotationAngleValue)
                .animation(.spring(), value: viewModel.rotationAngleValue)
            }

            RecordButtonDeprecation(
                recordStatus: viewModel.recordStatus,
                recordStatusPublisher: viewModel.$recordStatus.eraseToAnyPublisher(),
                allowRecordingVideos: viewModel.preset.mode.canRecordVideos,
                record: viewModel.capture,
                pause: viewModel.capture,
                takePhoto: viewModel.capture
            )

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
                TVImageButton(image: TruVideoImage.flipCameraIcon, style: .primary) {
                    viewModel.flipTapped()
                }
                .rotationEffect(viewModel.rotationAngleValue)
                .animation(.spring(), value: viewModel.rotationAngleValue)
            }
        }
    }
}

struct TVControlsViewV1Preview: View {

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
        TVControlsViewV1()
            .environmentObject(viewModel)
            .environmentObject(mediaCounterViewModel)
    }
}

#Preview {
    TVControlsViewV1Preview()
}
