//
//  TruvideoSdkCameraView.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 7/11/24.
//

import Foundation
import SwiftUI

/// The Camera View is a custom SwiftUI view designed to provide a camera interface within your iOS  app.
/// This view allows users to access their device's camera to capture photos or record videos.
/// The Camera View simplifies the process of integrating camera functionality into your app, making it easier
/// for users to interact with the camera and capture media seamlessly.
struct TruvideoSdkCameraView: View {
    private let onComplete: (TruvideoSdkCameraResult) -> Void

    /// A boolean indicating whether the preview is presented.
    @State var isPresented = false

    /// The view model handling the logic and data for camera features.
    @StateObject private var viewModel: CameraViewModelDeprecation

    /// The view model handling the logic and data for camera features.
    @ObservedObject private var mediaCounterViewModel: MediaCounterViewModel

    /// The content and behavior of the view.
    var body: some View {
        ZStack {
            if viewModel.isAuthenticated {
                CameraDeprecation()
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
        Logger.addLog(event: .openCamera, eventMessage: .cameraOpenWithConfiguration(preset: preset))
        let recorder = TruVideoRecorder()
        recorder.imageFormat = preset.imageFormat
        let cameraViewModel: CameraViewModelDeprecation = .init(recorder: recorder, preset: preset) {
            TruvideoSdkCameraEvent.events.send(.init(type: $0))
        }
        _viewModel = StateObject(wrappedValue: cameraViewModel)

        self.mediaCounterViewModel = MediaCounterViewModel(mode: preset.mode)
        self.onComplete = { result in
            TruvideoSdkOrientationManager.shared.unlockAppOrientation()
            onComplete(result)
        }
        recorder.delegate = viewModel
        self.viewModel.onStartHandler = {
            try recorder.start()
        }
        self.viewModel.onRestartHandler = {
            try recorder.restart()
        }
        self.viewModel.updateVideoCounter = { [weak mediaCounterViewModel] increment in
            mediaCounterViewModel?.updateVideoCounter(increment: increment)
        }
        self.viewModel.updatePictureCounter = { [weak mediaCounterViewModel] increment in
            mediaCounterViewModel?.updatePictureCounter(increment: increment)
        }
    }
}
