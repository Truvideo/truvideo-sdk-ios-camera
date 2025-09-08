//
//  TVCameraPreviewV1.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 5/20/25.
//

import SwiftUI

struct TVCameraPreviewV1: View {
    /// The view model handling the logic and data for camera features.
    @EnvironmentObject var viewModel: TVCameraViewModel

    @EnvironmentObject var mediaCounterViewModel: MediaCounterViewModel

    var body: some View {
        ZStack(alignment: viewModel.zoomViewAlignment) {
            ZStack(alignment: viewModel.timerViewAlignment) {
                ZStack(alignment: viewModel.continueButtonAlignment) {
                    ZStack(alignment: viewModel.mediaCounterAlignment) {
                        CameraPreview(previewLayer: viewModel.previewLayer) {
                            viewModel.cameraPreviewDelegate = $0
                        }
                        .cornerRadius(10)

                        if !viewModel.currentOrientation.isPortrait {
                            mediaCounter()
                        }
                    }
                    if !viewModel.currentOrientation.isPortrait, !viewModel.galleryItems.isEmpty, !viewModel.isRecording
                    {
                        ContinueButtonDeprecation(
                            rotate: viewModel.layoutOrientation.isPortrait,
                            continueButtonOffset: .zero
                        ) {
                            viewModel.closeCameraWithSaving()
                        }
                        .rotationEffect(viewModel.rotationAngleValue)
                        .padding(12)
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
                rotationAngle: viewModel.rotationAngleValue,
                zoomFactorValues: viewModel.zoomFactorValues
            )
        }
        .aspectRatio(viewModel.cameraPreviewAspectRatio, contentMode: .fit)
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
                        viewModel.increaseZoomFactor(useDiscrete: false)
                    } else if value < 1.0 {
                        viewModel.decreaseZoomFactor(useDiscrete: false)
                    }
                }
        )
        .toast(
            isShowing: $viewModel.showToast,
            message: viewModel.toastType.message,
            alignment: .bottom,
            rotationAngle: viewModel.rotationAngleValue,
            offset: .zero
        )
    }

    @ViewBuilder
    private func mediaCounter() -> some View {
        MediaCounter(
            rotate: viewModel.layoutOrientation.isPortrait,
            viewModel: mediaCounterViewModel
        ) {
            viewModel.navigateToGalleryPreview()
        }
        .rotationEffect(viewModel.rotationAngleValue)
        .padding(12)
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
        .rotationEffect(viewModel.rotationAngleValue)
        .animation(.spring(), value: viewModel.rotationAngleValue)
        .offset(viewModel.timerViewOffset)
        .if(viewModel.isSinglePictureMode) {
            $0.hidden()
        }
    }
}

struct TVCameraPreviewV1Preview: View {

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
        TVCameraPreviewV1()
            .environmentObject(viewModel)
            .environmentObject(mediaCounterViewModel)
    }
}

#Preview {
    TVCameraPreviewV1Preview()
}
