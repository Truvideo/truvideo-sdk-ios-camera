//
//  CameraView.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 3/26/25.
//

import SwiftUI

/// The camera screen with the previous design.
/// It's shown by setting `isNewLayoutEnabled = true`
/// in the camera preset `TruvideoSdkCameraConfiguration`
struct TVCameraViewV1: View {
    // - MARK: View Models
    @ObservedObject var viewModel: TVCameraViewModel

    @ObservedObject var mediaCounterViewModel: MediaCounterViewModel

    // - MARK: Environment Properties
    @Environment(\.dismiss) var dismiss

    // - MARK: On Complete Method
    let onComplete: (TruvideoSdkCameraResult) -> Void

    var body: some View {
        if viewModel.isAuthenticated {
            ZStack {
                layer()
                if let overlayPage = viewModel.overlayPage {
                    BlurView(style: .dark)
                        .ignoresSafeArea(.all, edges: .all)
                        .onTapGesture {
                            viewModel.navigateToCameraView()
                        }
                    CameraOverlay(overlayPage: overlayPage)
                }
            }
            .background(Color.black)
            .environmentObject(viewModel)
            .environmentObject(mediaCounterViewModel)
            .onAppear {
                viewModel.setupInitialCameraPreview()
                viewModel.onDismiss = {
                    dismiss()
                }
            }
            .alert(isPresented: $viewModel.showPermissionDeniedAlert) {
                Alert(
                    title: Text("Permissions Denied"),
                    message: Text("Please enable camera and microphone access in Settings."),
                    primaryButton: .default(Text("Settings")) {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                        viewModel.closeCameraWithoutSaving()
                    },
                    secondaryButton: .cancel(Text("Cancel")) {
                        viewModel.closeCameraWithoutSaving()
                    }
                )
            }
        } else {
            UnauthenticatedView {
                TruvideoSdkOrientationManager.shared.unlockAppOrientation()
                onComplete(.init(media: []))
            }
        }
    }

    // MARK: Private methods
    @ViewBuilder
    private func layer() -> some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            VStack(alignment: .center, spacing: 0) {
                TVConfigurationViewV1()
                Spacer(minLength: 8)
                TVCameraPreviewV1()
                Spacer(minLength: 8)
                TVControlsViewV1()
            }
        } else {
            switch viewModel.layoutOrientation {
            case .landscapeRight:
                landscapeRightLayer()
            case .landscapeLeft:
                landscapeLeftLayer()
            default:
                portraitLayer()
            }
        }
    }

    @ViewBuilder
    private func portraitLayer() -> some View {
        VStack(alignment: .center, spacing: 0) {
            TVConfigurationViewV1()

            Spacer(minLength: 8)

            TVCameraPreviewV1()

            Spacer(minLength: 8)

            TVControlsViewV1()
        }
    }

    @ViewBuilder
    private func landscapeLeftLayer() -> some View {
        HStack(alignment: .center, spacing: 0) {
            TVControlsViewV1()

            Spacer(minLength: 8)

            TVCameraPreviewV1()

            Spacer(minLength: 8)

            TVConfigurationViewV1()
        }
    }

    @ViewBuilder
    private func landscapeRightLayer() -> some View {
        HStack(alignment: .center, spacing: 0) {
            TVConfigurationViewV1()

            Spacer(minLength: 8)

            TVCameraPreviewV1()

            Spacer(minLength: 8)

            TVControlsViewV1()
        }
    }

    init(preset: TruvideoSdkCameraConfiguration, onComplete: @escaping (TruvideoSdkCameraResult) -> Void) {
        self.onComplete = onComplete

        let (viewModel, mediaCounterViewModel) = TVCameraFactory.shared.createCameraViewModels(
            for: preset,
            onComplete: onComplete
        )
        self.viewModel = viewModel
        self.mediaCounterViewModel = mediaCounterViewModel
    }
}

#Preview {
    TVCameraViewV1(preset: .fixture()) { _ in }
}
