//
//  OrientationProvider.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 1/2/25.
//

import Combine
import UIKit

protocol OrientationProvider {
    var orientationPublisher: AnyPublisher<UIDeviceOrientation, Never> { get }

    var isTrackingOrientationChanges: Bool { get }
}
