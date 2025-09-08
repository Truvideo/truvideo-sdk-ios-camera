//
//  TruvideoSdkCameraOrientationImp.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 12/15/23.
//

import Foundation
import SwiftUI

final class TruvideoSdkCameraOrientationImp: TruvideoSdkCameraDelegate {
    /// Shared instance used to apply orientation updates from `CameraViewFullScreenPresenter`
    static let shared = TruvideoSdkCameraOrientationImp()

    func getTruvideoSdkCameraInformation() -> TruvideoSdkCameraInformation {
        Logger.addLog(event: .getCameraInformation, eventMessage: .getCameraInformation)
        let cameraManager = CameraManager()
        return TruvideoSdkCameraInformation(
            frontCamera: TruvideoSdkCameraDevice(
                id: "0",
                lensFacing: .front,
                resolutions: cameraManager.getAvailableResolutions(for: .front),
                withFlash: false,
                isTapToFocusEnabled: cameraManager.isTapToFocusEnabled(for: .front),
                sensorOrientation: 0
            ),
            backCamera: TruvideoSdkCameraDevice(
                id: "1",
                lensFacing: .back,
                resolutions: cameraManager.getAvailableResolutions(for: .back),
                withFlash: true,
                isTapToFocusEnabled: cameraManager.isTapToFocusEnabled(for: .back),
                sensorOrientation: 1
            )
        )
    }
}
