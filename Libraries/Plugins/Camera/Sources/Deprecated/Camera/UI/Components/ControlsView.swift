//
//  ControlsView.swift
//  TruvideoSdkCamera
//
//  Created by Luis Francisco Piura Mejia on 3/5/24.
//

import SwiftUI

struct ControlsView: View {
    /// The view model handling the logic and data for camera features.
    @EnvironmentObject var viewModel: CameraViewModelDeprecation

    /// The content and behavior of the view.
    var body: some View {
        PublisherListener(
            initialValue: viewModel.recordStatus,
            publisher: viewModel.$recordStatus,
            buildWhen: { previous, current in previous != current }
        ) { state in
            layer()
                .animation(.easeInOut(duration: 0.25), value: state)
        }
    }

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
                CircularButton(action: {
                    viewModel.flipCamera()
                }) {
                    TruVideoImage.flipCamera
                        .modifiedIcon()
                }
                .modifiedButton()
                .rotationEffect(viewModel.rotationAngle)
                .animation(.spring(), value: viewModel.rotationAngle)
            }
        }
    }

    @ViewBuilder
    private func landscapeRightLayer() -> some View {
        VStack(spacing: TruVideoSpacing.lg) {
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
                CircularButton(action: {
                    viewModel.flipCamera()
                }) {
                    TruVideoImage.flipCamera
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
        }
    }

    @ViewBuilder
    private func landscapeLeftLayer() -> some View {
        VStack(spacing: TruVideoSpacing.lg) {
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
                CircularButton(action: {
                    viewModel.flipCamera()
                }) {
                    TruVideoImage.flipCamera
                        .modifiedIcon()
                }
                .modifiedButton()
                .rotationEffect(viewModel.rotationAngle)
                .animation(.spring(), value: viewModel.rotationAngle)
            }
        }
    }
}
