//
//  TVCameraPreview.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 3/26/25.
//

import SwiftUI

struct TVCameraPreview: View {
    /// The view model handling the logic and data for camera features.
    @EnvironmentObject var viewModel: TVCameraViewModel

    @EnvironmentObject var mediaCounterViewModel: MediaCounterViewModel

    var body: some View {
        ZStack {
            ZStack(alignment: .trailing) {
                CameraPreview(previewLayer: viewModel.previewLayer) {
                    viewModel.cameraPreviewDelegate = $0
                }
                .if(!viewModel.showPreview) {
                    $0.overlay {
                        Color.red
                    }
                }

                if !viewModel.layoutOrientation.isPortrait {
                    TVZoomView(
                        zoomFactor: $viewModel.zoomFactor,
                        rotationAngle: viewModel.rotationAngleValue,
                        zoomFactorValues: viewModel.zoomFactorValues,
                        isPortrait: false
                    )
                    .padding(.trailing, 8)
                }
            }

            VStack(spacing: 8) {
                if !viewModel.isOneModeOnly && !viewModel.isRecording {
                    TVMediaCounterPickerButton(selectedOption: $viewModel.segmendtedOption)
                }

                if viewModel.segmendtedOption == .videos {
                    TimerViewDeprecation(
                        secondsRecorded: viewModel.secondsRecorded,
                        secondsRecordedPublisher: viewModel.$secondsRecorded.eraseToAnyPublisher(),
                        timerViewOffset: .zero,
                        recordStatus: viewModel.recordStatus,
                        maxVideoDuration: viewModel.maxVideoDuration
                    )
                }

                Spacer()

                if viewModel.layoutOrientation.isPortrait {
                    TVZoomView(
                        zoomFactor: $viewModel.zoomFactor,
                        rotationAngle: viewModel.rotationAngleValue,
                        zoomFactorValues: viewModel.zoomFactorValues,
                        isPortrait: true
                    )
                }
            }
            .padding(.vertical, 8)
        }
        .aspectRatio(viewModel.cameraPreviewAspectRatio, contentMode: .fit)
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
}

struct TVCameraPreviewPreview: View {

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
        TVCameraPreview()
            .environmentObject(viewModel)
            .environmentObject(mediaCounterViewModel)
    }
}

#Preview {
    TVCameraPreviewPreview()
}
