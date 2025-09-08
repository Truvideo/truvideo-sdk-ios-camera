//
//  TruvideoOrientationInterface.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 1/2/25.
//

import Combine
import UIKit

protocol TruvideoOrientationInterface {
    var physicalOrientationPublisher: AnyPublisher<UIDeviceOrientation, Never> { get }

    var appOrientationPublisher: AnyPublisher<UIDeviceOrientation, Never> { get }

    func lockToOrientation(_ orientation: UIInterfaceOrientationMask) -> Bool

    func unlockAppOrientation()

    func configureTruvideoSdkAppDelegate(_ appDelegate: TruvideoSdkCameraAppDelegate)
}
