//
//  TruvideoSdkCameraResolutionManager.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 3/1/24.
//

import AVFoundation
import Foundation

final class TruvideoSdkCameraResolutionManager {
    var backResolutions: [TruvideoSdkCameraResolutionFormat]
    var backResolution: TruvideoSdkCameraResolutionFormat?
    var frontResolutions: [TruvideoSdkCameraResolutionFormat]
    var frontResolution: TruvideoSdkCameraResolutionFormat?

    init(
        backResolutions: [TruvideoSdkCameraResolution],
        frontResolutions: [TruvideoSdkCameraResolution],
        backResolution: TruvideoSdkCameraResolution?,
        frontResolution: TruvideoSdkCameraResolution?
    ) {
        let cameraManager = CameraManager()
        let allBackResolutions = cameraManager.getAvailableResolutions(for: .back)
        let allFrontResolutions = cameraManager.getAvailableResolutions(for: .front)

        self.backResolutions = cameraManager.filterValidResolutions(
            from: backResolutions.removeDuplicates(),
            using: allBackResolutions
        )
        self.frontResolutions = cameraManager.filterValidResolutions(
            from: frontResolutions.removeDuplicates(),
            using: allFrontResolutions
        )

        self.backResolution = cameraManager.getResolutionFormat(
            from: backResolution,
            using: self.backResolutions
        )
        self.frontResolution = cameraManager.getResolutionFormat(
            from: frontResolution,
            using: self.frontResolutions
        )
    }

    func hasMultipleResolutions(for cameraPosition: TruVideoDevicePosition) -> Bool {
        switch cameraPosition {
        case .back:
            return backResolutions.count > 1
        default:
            return frontResolutions.count > 1
        }
    }

    func setSelectedResolution(_ resolution: TruvideoSdkCameraResolutionFormat) {
        switch resolution.type {
        case .back:
            self.backResolution = resolution
        case .front:
            self.frontResolution = resolution
        }
    }

    func getSelectedResolution(for cameraPosition: TruVideoDevicePosition) -> TruvideoSdkCameraResolutionFormat? {
        switch cameraPosition {
        case .back:
            return backResolution
        default:
            return frontResolution
        }
    }
}

extension [TruvideoSdkCameraResolution] {
    fileprivate func removeDuplicates() -> [TruvideoSdkCameraResolution] {
        var uniqueResolutions: [TruvideoSdkCameraResolution] = []

        for uniqueResolution in self {
            if !uniqueResolutions.contains(where: {
                $0.width == uniqueResolution.width && $0.height == uniqueResolution.height
            }) {
                uniqueResolutions.append(uniqueResolution)
            }
        }

        return uniqueResolutions
    }
}
