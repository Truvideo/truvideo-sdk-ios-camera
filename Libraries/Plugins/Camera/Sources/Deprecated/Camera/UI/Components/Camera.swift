//
//  Camera.swift
//
//  Created by TruVideo on 6/16/22.
//  Copyright © 2023 TruVideo. All rights reserved.
//

import SwiftUI

/// Represents the pages
enum Page: Equatable {
    case camera
    case resolutionPicker
    case galleryPreview
    case close
    case videoPreview(clip: TruVideoClip)
    case photoPreview(photo: TruVideoPhoto)
    case arSettingsView
    case confirmCodeSelection
}

/// Manages the video/audio capture session.
struct CameraDeprecation: View {

    /// The view model handling the logic and data for camera features.
    @EnvironmentObject var viewModel: CameraViewModelDeprecation

    /// The view model handling the logic and data for media counter
    @EnvironmentObject var mediaCounterViewModel: MediaCounterViewModel

    /// The content and behavior of the view.
    var body: some View {
        ZStack {
            layer()
                .animation(.none, value: viewModel.layoutOrientation)

            if viewModel.isShowingBlurView {
                BlurView(style: .dark)
                    .ignoresSafeArea(.all, edges: .all)
                    .onTapGesture {
                        viewModel.navigateToCameraView()
                    }

                ZStack {
                    switch viewModel.page {
                    case .galleryPreview:
                        GalleryPreview(
                            isPortrait: viewModel.layoutOrientation.isPortrait,
                            galleryItems: viewModel.galleryItems,
                            mediaScrollViewPadding: viewModel.mediaScrollViewPadding,
                            galleryHeight: viewModel.galleryHeight,
                            rotationAngle: viewModel.rotationAngle,
                            showPreview: viewModel.showPreview,
                            navigateToCameraView: viewModel.navigateToCameraView,
                            setupMediaSize: viewModel.setupMediaSize
                        )
                    case .photoPreview(let photo):
                        PhotoPreview(
                            photo: photo,
                            rotationAngle: viewModel.rotationAngle,
                            returnToGalleryPreview: viewModel.returnToGalleryPreview,
                            deletePhoto: viewModel.deletePhoto
                        )
                    case .videoPreview(let clip):
                        VideoPreviewDeprecation(
                            clip: clip,
                            rotationAngle: viewModel.rotationAngle,
                            returnToGalleryPreview: viewModel.returnToGalleryPreview,
                            deleteClip: viewModel.deleteClip
                        )
                    case .resolutionPicker:
                        ResolutionPickerView()
                    default:
                        CloseView(
                            isPortrait: viewModel.isPortrait,
                            closeButtonAlignment: viewModel.closeButtonAlignment,
                            rotationAngle: viewModel.rotationAngle,
                            navigateToCameraView: viewModel.navigateToCameraView,
                            closeCameraAndDeleteMedia: viewModel.closeCameraAndDeleteMedia
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .animation(.easeInOut, value: viewModel.page)
            }
        }
        .background(.black)
        .animation(.easeInOut, value: viewModel.isShowingBlurView)
    }

    // MARK: Private methods
    @ViewBuilder
    private func layer() -> some View {
        switch viewModel.layoutOrientation {
        case .landscapeRight:
            landscapeRightLayer()
        case .landscapeLeft:
            landscapeLeftLayer()
        default:
            portraitLayer()
        }
    }

    @ViewBuilder
    private func portraitLayer() -> some View {
        VStack(spacing: 8) {
            ConfigurationView {
                viewModel.closeCamera()
            }

            makeCamera()

            ControlsView()
        }
    }

    @ViewBuilder
    private func landscapeLeftLayer() -> some View {
        HStack(spacing: 8) {
            ControlsView()

            makeCamera()

            ConfigurationView {
                viewModel.closeCamera()
            }
        }
    }

    @ViewBuilder
    private func landscapeRightLayer() -> some View {
        HStack(spacing: 8) {
            ConfigurationView {
                viewModel.closeCamera()
            }

            makeCamera()

            ControlsView()
        }
    }

    private var mediaCounter: some View {
        MediaCounter(
            viewModel: mediaCounterViewModel
        ) {
            viewModel.navigateToGalleryPreview()
        }
        .padding(12)
        .rotationEffect(viewModel.rotationAngle)
        .offset(viewModel.mediaCounterOffset)
    }

    @ViewBuilder
    private func makeCamera() -> some View {
        ZStack(alignment: viewModel.zoomViewAlignment) {
            ZStack(alignment: viewModel.timerViewAlignment) {
                ZStack(alignment: viewModel.continueButtonAlignment) {
                    ZStack(alignment: viewModel.mediaCounterAlignment) {
                        CameraPreview(previewLayer: viewModel.previewLayer) {
                            viewModel.cameraPreviewDelegate = $0
                        }
                        .cornerRadius(10)

                        if !viewModel.isPortrait {
                            mediaCounter
                        }
                    }
                    if !viewModel.isPortrait, viewModel.galleryCount > 0 && viewModel.recordStatus != .recording {
                        ContinueButtonDeprecation(
                            continueButtonOffset: .zero,
                            stopRecording: viewModel.stopRecording
                        )
                        .padding(12)
                        .rotationEffect(viewModel.rotationAngle)
                        .offset(viewModel.continueButtonOffset)
                        .zIndex(2)
                    }
                }
                .animation(.spring(), value: viewModel.closeButtonAlignment)

                timer()
            }
            .animation(.spring(), value: viewModel.timerViewAlignment)

            if viewModel.recordStatus == .recording {
                TruVideoImage.recordingScreen
                    .resizable()
            }

            ZoomView(
                alignment: viewModel.zoomViewAlignment,
                zoomFactor: $viewModel.zoomFactor,
                rotationAngle: viewModel.rotationAngle,
                zoomFactorValues: viewModel.zoomFactorValues
            )
        }
        .animation(.spring(), value: viewModel.zoomViewAlignment)
        .gesture(
            TapGesture()
                .simultaneously(
                    with: DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged { value in
                        viewModel.focusPoint = value.location
                    }
                )
                .onEnded({ _ in
                    viewModel.applyFocusOnFocusPoint()
                })
        )
        .gesture(
            MagnificationGesture()
                .onChanged { value in
                    if value > 1.0 {
                        viewModel.increaseZoomFactor()
                    } else if value < 1.0 {
                        viewModel.decreaseZoomFactor()
                    }
                }
        )
        .toast(
            isShowing: $viewModel.showToast,
            message: viewModel.toastType.message,
            alignment: viewModel.zoomViewAlignment,
            rotationAngle: viewModel.rotationAngle,
            offset: viewModel.toastOffset
        )
    }

    @ViewBuilder
    private func timer() -> some View {
        TimerViewDeprecation(
            secondsRecorded: viewModel.secondsRecorded,
            secondsRecordedPublisher: viewModel.$secondsRecorded.eraseToAnyPublisher(),
            timerViewOffset: viewModel.timerViewOffset,
            recordStatus: viewModel.recordStatus,
            maxVideoDuration: viewModel.maxVideoDuration
        )
        .rotationEffect(viewModel.rotationAngle)
        .animation(.spring(), value: viewModel.rotationAngle)
        .offset(viewModel.timerViewOffset)
        .if(viewModel.isSinglePictureMode) {
            $0.hidden()
        }
    }
}
