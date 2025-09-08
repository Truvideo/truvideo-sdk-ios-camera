//
// Created by TruVideo on 12/15/23.
// Copyright © 2023 TruVideo. All rights reserved.
//

import Foundation

/// `TruvideoSdkCameraInterfaceImp` protocol implementation class
final class TruvideoSdkCameraInterfaceImp: TruvideoSdkCameraInterface, TruvideoSdkCameraEventsInterface {
    /// Variable to edit preferred app orientation
    var camera: TruvideoSdkCameraDelegate { TruvideoSdkCameraOrientationImp.shared }
    /// Events observer
    var events: TruvideoSdkCameraEventObserver { TruvideoSdkCameraEvent.events.eraseToAnyPublisher() }

    func configureTruvideoSdkAppDelegate(_ appDelegate: TruvideoSdkCameraAppDelegate) {
        TruvideoSdkOrientationManager.shared.configureTruvideoSdkAppDelegate(appDelegate)
    }
}
