//
//  ARControlsView.swift
//  TruvideoSdkCamera
//
//  Created by Luis Francisco Piura Mejia on 15/5/24.
//

import SwiftUI

struct ARControlsView: View {
    /// The view model handling the logic and data for camera features.
    @EnvironmentObject var viewModel: ARCameraViewModel

    /// The content and behavior of the view.
    var body: some View {
        PublisherListener(
            initialValue: viewModel.recordStatus,
            publisher: viewModel.$recordStatus,
            buildWhen: { previous, current in previous != current }
        ) { state in
            layer()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .animation(.easeInOut(duration: 0.25), value: state)
                .padding(.vertical, TruVideoSpacing.lg)
        }
    }

    @ViewBuilder
    private func layer() -> some View {
        HStack(spacing: TruVideoSpacing.lg) {
            if viewModel.isOneModeOnly {
                Circle()
                    .foregroundStyle(.black)
                    .modifiedButton()
            } else {
                CircularButton(action: viewModel.takePhoto) {
                    TruVideoImage.camera
                        .modifiedIcon()
                }
                .modifiedButton()
                .rotationEffect(viewModel.rotationAngle)
                .animation(.spring(), value: viewModel.rotationAngle)
            }

            RecordButtonDeprecation(
                recordStatus: viewModel.recordStatus,
                recordStatusPublisher: viewModel.$recordStatus.eraseToAnyPublisher(),
                allowRecordingVideos: viewModel.allowRecordingVideos,
                record: viewModel.record,
                pause: viewModel.pause,
                takePhoto: viewModel.takePhoto
            )
            if viewModel.recordStatus == .recording {
                CircularButton(action: {
                    viewModel.handlePauseVideoRecording()
                }) {
                    viewModel.recordingIsPaused
                        ? TruVideoImage.play
                            .modifiedIcon()
                        : TruVideoImage.pause
                            .modifiedIcon()
                }
                .modifiedButton()
                .rotationEffect(viewModel.rotationAngle)
                .animation(.spring(), value: viewModel.rotationAngle)
            } else {
                Spacer()
                    .modifiedButton()
            }
        }
    }
}
