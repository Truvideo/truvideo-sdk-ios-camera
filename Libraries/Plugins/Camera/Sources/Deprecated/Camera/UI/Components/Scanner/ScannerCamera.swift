//
//  ScannerCamera.swift
//  TruvideoSdkCamera
//
//  Created by Luis Francisco Piura Mejia on 30/7/24.
//

import SwiftUI

struct ScannerCamera: View {

    /// The view model handling the logic and data for camera features.
    @EnvironmentObject var viewModel: ScannerCameraViewModel
    @State private var animating = false

    /// The content and behavior of the view.
    var body: some View {
        ZStack {
            VStack(spacing: 8) {
                ScannerConfigurationView {
                    viewModel.closeCamera()
                }

                makeCamera()
            }

            if viewModel.isShowingBlurView {
                BlurView(style: .dark)
                    .ignoresSafeArea(.all, edges: .all)
                    .onTapGesture {
                        viewModel.navigateToCameraView()
                    }

                ZStack {
                    if viewModel.page == .confirmCodeSelection {
                        ConfirmCodeScanView(
                            selectedCode: viewModel.scannedCode?.data ?? "",
                            codeImage: viewModel.codeImage,
                            codeImageSize: viewModel.codeImageSize,
                            closeButtonAlignment: viewModel.closeButtonAlignment,
                            rotationAngle: viewModel.rotationAngle,
                            navigateToCameraView: viewModel.navigateToCameraView,
                            closeAndConfirmSelection: viewModel.confirmCodeSelection
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .animation(.easeInOut, value: viewModel.page)
            }
        }
        .background(.black)
    }

    // MARK: - Private methods

    @ViewBuilder
    private func makeCamera() -> some View {
        if viewModel.sessionStarted {
            ZStack {
                CameraPreview(previewLayer: viewModel.previewLayer) {
                    viewModel.cameraPreviewDelegate = $0
                }
                if viewModel.page != .confirmCodeSelection {
                    Rectangle()
                        .stroke(.white.opacity(0.5), lineWidth: 8)
                        .frame(width: 200, height: 200)
                        .cornerRadius(5)
                        .scaleEffect(animating ? 1.5 : 1)
                        .onAppear {
                            withAnimation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                                animating.toggle()
                            }
                        }
                }
            }
            .cornerRadius(10)
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
                message: viewModel.toastMessage,
                alignment: viewModel.zoomViewAlignment,
                rotationAngle: viewModel.rotationAngle,
                offset: viewModel.toastOffset
            )
        } else {
            Spacer()
        }
    }
}
