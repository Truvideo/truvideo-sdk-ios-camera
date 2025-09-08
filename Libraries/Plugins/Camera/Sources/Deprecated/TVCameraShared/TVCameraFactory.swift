//
//  CameraFactory.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 3/26/25.
//

import Foundation

class TVCameraFactory {
    // - MARK: Class name
    let className = String(describing: TVCameraFactory.self)

    static let shared = TVCameraFactory()

    // - MARK: Camera
    private var cameraManager: TVCameraManager?
    private var cameraViewModel: TVCameraViewModel?
    private var mediaCounterViewModel: MediaCounterViewModel?

    func createCameraViewModels(
        for preset: TruvideoSdkCameraConfiguration,
        onComplete: @escaping (TruvideoSdkCameraResult) -> Void
    ) -> (TVCameraViewModel, MediaCounterViewModel) {
        if self.cameraManager == nil {
            dprint(className, "camera manager will be [CREATED]")
        }
        if self.cameraViewModel == nil {
            dprint(className, "camera view model will be [CREATED]")
        }
        let cameraManager = self.cameraManager ?? TVCameraManager(preset: preset)
        let viewModel: TVCameraViewModel =
            self.cameraViewModel
            ?? TVCameraViewModel(preset: preset, cameraManager: cameraManager, onComplete: onComplete)
        let mediaCounterViewModel: MediaCounterViewModel =
            self.mediaCounterViewModel ?? MediaCounterViewModel(mode: preset.mode)
        viewModel.mediaCounterDelegate = mediaCounterViewModel

        self.cameraManager = cameraManager
        self.cameraViewModel = viewModel
        self.mediaCounterViewModel = mediaCounterViewModel

        return (viewModel, mediaCounterViewModel)
    }

    func createPreviewCameraViewModels(
        for preset: TruvideoSdkCameraConfiguration,
        onComplete: @escaping (TruvideoSdkCameraResult) -> Void
    ) -> (TVCameraViewModel, MediaCounterViewModel) {
        let viewModel: TVCameraViewModel = TVCameraViewModel(
            preset: preset,
            cameraManager: MockTVCameraManager(preset: preset),
            authValidator: MockAuthValidator(),
            showPreview: false,
            onComplete: onComplete
        )
        let mediaCounterViewModel = MediaCounterViewModel(mode: preset.mode)
        viewModel.mediaCounterDelegate = mediaCounterViewModel

        return (viewModel, mediaCounterViewModel)
    }

    func releaseCameraResources() {
        dprint(className, "camera resources were [RELEASED]")
        cameraManager?.releaseResources()
        cameraManager = nil
        cameraViewModel = nil
        mediaCounterViewModel = nil

        TruvideoSdkOrientationManager.shared.appIsActive = false
    }
}
