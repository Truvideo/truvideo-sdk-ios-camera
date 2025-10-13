//
//  TruvideoSdkCameraARView.swift
//  TruvideoSdkCamera
//
//  Created by Luis Francisco Piura Mejia on 3/5/24.
//

import AVFoundation
import AVKit
import MetalKit
import SwiftUI
import UIKit

/// The Camera View is a custom SwiftUI view designed to provide a camera interface within your iOS  app.
/// This view allows users to access their device's camera to capture photos or record videos.
/// The Camera View simplifies the process of integrating camera functionality into your app, making it easier
/// for users to interact with the camera and capture media seamlessly.
struct TruvideoSdkARCameraView: View {
    private let onComplete: (TruvideoSdkCameraResult) -> Void

    /// A boolean indicating whether the preview is presented.
    @State var isPresented = false

    /// The view model handling the logic and data for camera features.
    @StateObject private var viewModel: ARCameraViewModel
    private var renderDestination: RenderDestinationProvider

    /// The view model handling the logic and data for camera features.
    @ObservedObject private var mediaCounterViewModel: MediaCounterViewModel

    /// The content and behavior of the view.
    var body: some View {
        ZStack {
            if viewModel.isAuthenticated {
                if viewModel.arRenderer != nil {
                    ARCamera()
                }
            } else {
                UnauthenticatedView {
                    onComplete(.init(media: []))
                }
            }
        }
        .environmentObject(viewModel)
        .environmentObject(mediaCounterViewModel)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarHidden(true)
        .statusBar(hidden: true)
        .onAppear(perform: viewModel.beginConfiguration)
        .onChange(of: viewModel.recordStatus) { status in
            UIApplication.shared.isIdleTimerDisabled = status == .recording

            guard status == .finished else { return }
            viewModel.recorder.configureZoomFactor(to: 1)
            viewModel.recorder.stopARSessionIfNeeded()

            Task { @MainActor in
                await onComplete(viewModel.getMediaResult())
            }
        }
    }

    // MARK: Initializers

    /// Creates a new instance of the `TruvideoSdkCameraView`.
    ///
    /// - Parameter onComplete: A callback to invoke when the recording session has finished.
    init(preset: TruvideoSdkCameraConfiguration, onComplete: @escaping (TruvideoSdkCameraResult) -> Void) {
        let recorder = TruVideoRecorder()
        let viewModel = ARCameraViewModel(recorder: recorder, preset: preset) { _ in }
        self.onComplete = onComplete
        let metalView = MTKView()
        metalView.framebufferOnly = false
        metalView.depthStencilPixelFormat = .depth32Float_stencil8
        metalView.colorPixelFormat = .bgra8Unorm
        metalView.sampleCount = 1
        renderDestination = metalView
        recorder.delegate = viewModel
        recorder.renderDestinationProvider = renderDestination
        let mediaCounterViewModel = MediaCounterViewModel(mode: preset.mode)
        viewModel.onStartHandler = { [weak recorder, weak viewModel] in
            guard let recorder = recorder,
                let viewModel = viewModel
            else { return }

            let configuration = viewModel.createARConfiguration()
            try recorder.startARSession(with: configuration)
        }
        viewModel.updateVideoCounter = { [weak mediaCounterViewModel] increment in
            mediaCounterViewModel?.updateVideoCounter(increment: increment)
        }
        viewModel.updatePictureCounter = { [weak mediaCounterViewModel] increment in
            mediaCounterViewModel?.updatePictureCounter(increment: increment)
        }

        _viewModel = StateObject(wrappedValue: viewModel)
        self.mediaCounterViewModel = mediaCounterViewModel
    }
}
