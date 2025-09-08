//
//  TruvideoSdkCameraConfiguration+fixture.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 3/26/25.
//

import Foundation

extension TruvideoSdkCameraConfiguration {
    static func fixture() -> TruvideoSdkCameraConfiguration {
        TruvideoSdkCameraConfiguration(
            backResolution: nil,
            backResolutions: [],
            flashMode: .off,
            frontResolution: nil,
            frontResolutions: [],
            lensFacing: .back,
            mode: .videoAndPicture(),
            outputPath: ""
        )
    }
}
