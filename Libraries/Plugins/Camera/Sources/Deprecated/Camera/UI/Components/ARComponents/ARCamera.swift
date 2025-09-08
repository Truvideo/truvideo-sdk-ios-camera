//
//  ARCamera.swift
//  TruvideoSdkCamera
//
//  Created by Luis Francisco Piura Mejia on 3/5/24.
//

import SwiftUI

/// Manages the video/audio capture session.
struct ARCamera: View {

    /// The view model handling the logic and data for camera features.
    @EnvironmentObject var viewModel: ARCameraViewModel

    /// The view model handling the logic and data for media counter
    @EnvironmentObject var mediaCounterViewModel: MediaCounterViewModel

    /// The content and behavior of the view.
    var body: some View {
        ZStack {
            layer()
                .onAppear {
                    viewModel.handleARCameraViewAppeared()
                }

            if viewModel.isShowingBlurView {
                BlurView(style: .dark)
                    .ignoresSafeArea(.all, edges: .all)
                    .onTapGesture {
                        viewModel.navigateToCameraView()
                    }

                ZStack {
                    switch viewModel.page {
                    case .camera:
                        layer()
                    case .arSettingsView:
                        ARSettingsView()
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
                        ARResolutionPickerView()
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

            if viewModel.shouldShowAROnboarding {
                AROnboardingOverlay(
                    content: viewModel.getAROnboardingContent(),
                    onDismiss: {
                        viewModel.dismissAROnboarding()
                    }
                )
                .zIndex(2000)
            }
        }
        .background(.black)
        .animation(.easeInOut, value: viewModel.isShowingBlurView)
        .alert(isPresented: $viewModel.showClearDataAlert) {
            Alert(
                title: Text("AR Objects or measurement detected"),
                message: Text("Do you want to clear all data?"),
                primaryButton: .destructive(Text("Clear Data")) {
                    viewModel.clearDataAndProceed()
                },
                secondaryButton: .cancel(Text("Keep Data")) {
                    viewModel.keepDataAndProceed()
                }
            )
        }
    }

    // MARK: Private methods
    @ViewBuilder
    private func layer() -> some View {
        VStack(spacing: 8) {
            ARConfigurationView {
                viewModel.closeCamera()
            }

            makeCamera()

            ARControlsView()
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private func makeCamera() -> some View {
        ZStack(alignment: viewModel.zoomViewAlignment) {
            ZStack(alignment: viewModel.deletionActionsAlignment) {
                ZStack(alignment: viewModel.timerViewAlignment) {
                    if let renderer = viewModel.arRenderer {
                        ZStack(alignment: viewModel.closeButtonAlignment) {
                            ZStack(alignment: viewModel.mediaCounterAlignment) {
                                if viewModel.recordStatus == .recording {
                                    actionableView {
                                        TruVideoImage.recordingScreen
                                            .resizable()
                                            .zIndex(1)
                                    }
                                }
                                actionableView {
                                    ARCameraPreview(renderer: renderer) { pixelBuffer in
                                        viewModel.handle(buffer: pixelBuffer)
                                    }
                                    .cornerRadius(10)
                                }
                                if !viewModel.isPortrait {
                                    mediaCounter
                                }
                            }
                            if !viewModel.isPortrait, viewModel.galleryCount > 0 && viewModel.recordStatus != .recording
                            {
                                ContinueButtonDeprecation(
                                    continueButtonOffset: viewModel.continueButtonOffset,
                                    stopRecording: viewModel.stopRecording
                                )
                                .rotationEffect(viewModel.rotationAngle)
                                .animation(.spring(), value: viewModel.isPortrait)
                            }
                        }
                        .animation(.spring(), value: viewModel.closeButtonAlignment)
                    }

                    TimerViewDeprecation(
                        secondsRecorded: viewModel.secondsRecorded,
                        secondsRecordedPublisher: viewModel.$secondsRecorded.eraseToAnyPublisher(),
                        timerViewOffset: viewModel.timerViewOffset,
                        recordStatus: viewModel.recordStatus,
                        maxVideoDuration: viewModel.maxVideoDuration
                    )
                    .rotationEffect(viewModel.rotationAngle)
                    .animation(.spring(), value: viewModel.rotationAngle)
                }
                .animation(.spring(), value: viewModel.timerViewAlignment)

                if viewModel.enableDeletionActions {
                    makeDeletionActionsView()
                        .animation(.spring(), value: viewModel.deletionActionsAlignment)
                }
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
    private func makeDeletionActionsView() -> some View {
        if viewModel.isPortrait {
            HStack(spacing: TruVideoSpacing.s10) {
                if viewModel.currentOrientation == .portraitUpsideDown {
                    makeCircularButton(icon: TruVideoImage.undo, action: viewModel.undo)
                    makeCircularButton(icon: TruVideoImage.clear, action: viewModel.clear)
                } else {
                    makeCircularButton(icon: TruVideoImage.clear, action: viewModel.clear)
                    makeCircularButton(icon: TruVideoImage.undo, action: viewModel.undo)
                }
            }
            .padding(8)
        } else {
            HStack {
                if viewModel.currentOrientation == .landscapeRight {
                    makeCircularButton(
                        icon: TruVideoImage.clear,
                        offset: viewModel.clearButtonOffset,
                        action: viewModel.clear
                    )
                    makeCircularButton(
                        icon: TruVideoImage.undo,
                        offset: viewModel.undoButtonOffset,
                        action: viewModel.undo
                    )
                } else {
                    makeCircularButton(
                        icon: TruVideoImage.undo,
                        offset: viewModel.clearButtonOffset,
                        action: viewModel.undo
                    )
                    makeCircularButton(
                        icon: TruVideoImage.clear,
                        offset: viewModel.undoButtonOffset,
                        action: viewModel.clear
                    )
                }
            }
            .padding(.leading, TruVideoSpacing.s10)
        }
    }

    @ViewBuilder
    private func makeCircularButton(
        icon: Image,
        offset: CGSize = .init(width: 0, height: 0),
        action: @escaping () -> Void
    ) -> some View {
        CircularButton(color: .gray.opacity(0.5), action: action) {
            icon
                .resizable()
                .withRenderingMode(.template, color: .white)
                .scaledToFit()
                .frame(minWidth: 20, minHeight: 20)
                .fixedSize()
        }
        .frame(minWidth: 40, minHeight: 40)
        .fixedSize()
        .offset(offset)
        .rotationEffect(viewModel.rotationAngle)
        .animation(.spring(), value: viewModel.rotationAngle)
    }

    @ViewBuilder
    private func actionableView(
        @ViewBuilder viewBuilder: @escaping () -> some View
    ) -> some View {
        viewBuilder()
            .gesture(
                TapGesture()
                    .onEnded {
                        viewModel.draw()
                    }
            )
    }

    private var mediaCounter: some View {
        MediaCounter(
            viewModel: mediaCounterViewModel
        ) {
            viewModel.navigateToGalleryPreview()
        }
        .padding(12)
        .rotationEffect(viewModel.rotationAngle)
        .animation(.spring(), value: viewModel.isPortrait)
        .offset(viewModel.mediaCounterOffset)
        .background(
            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        if viewModel.mediaCounterAlignment == .topTrailing {
                            viewModel.mediaCounterOffset = CGSize(
                                width: (proxy.size.width - proxy.size.height) / 2,
                                height: (proxy.size.width - proxy.size.height) / 2
                            )
                        } else if viewModel.mediaCounterAlignment == .bottomLeading {
                            viewModel.mediaCounterOffset = CGSize(
                                width: -(proxy.size.width - proxy.size.height) / 2,
                                height: -(proxy.size.width - proxy.size.height) / 2
                            )
                        }
                    }
            }
        )
    }
}

struct ARResolutionPickerView: View {
    @EnvironmentObject var viewModel: ARCameraViewModel

    var body: some View {
        ResolutionPickerView()
            .environmentObject(viewModel as CameraViewModelDeprecation)
    }
}
