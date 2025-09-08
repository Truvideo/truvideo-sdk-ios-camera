//
//  CoreMotionOrientationProvider.swift
//  TruvideoSdkShared
//
//  Created by Victor Arana on 12/5/24.
//

import Combine
import CoreMotion
import UIKit

class CoreMotionOrientationProvider: OrientationProvider {

    private let motionManager = CMMotionManager()

    private let subject = PassthroughSubject<UIDeviceOrientation, Never>()
    var orientationPublisher: AnyPublisher<UIDeviceOrientation, Never> {
        subject.eraseToAnyPublisher()
    }

    let isTrackingOrientationChanges: Bool

    init() {
        guard motionManager.isAccelerometerAvailable else {
            isTrackingOrientationChanges = false
            return
        }

        isTrackingOrientationChanges = true
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(
            to: .main,
            withHandler: { [weak self] data, error in
                guard let self else { return }
                handleNewAccelerometerData(data, error: error)
            }
        )
    }

    deinit {
        motionManager.stopAccelerometerUpdates()
    }

    private func handleNewAccelerometerData(_ data: CMAccelerometerData?, error: Error?) {
        guard let data = data else { return }
        let pitch = atan2(data.acceleration.y, data.acceleration.z) * 180 / .pi
        let aux = sqrt(data.acceleration.y * data.acceleration.y + data.acceleration.z * data.acceleration.z)
        let roll = atan2(-data.acceleration.x, aux) * 180 / .pi
        determineOrientation(with: pitch, and: roll, z: data.acceleration.z)
    }

    private func determineOrientation(with pitch: Double, and roll: Double, z: Double) {
        let threshold: Double = 45.0
        let flatThreshold: Double = 0.8

        if z > flatThreshold {
            subject.send(.faceUp)
        } else if z < -flatThreshold {
            subject.send(.faceDown)
        } else if roll > threshold {
            subject.send(.landscapeRight)
        } else if roll < -threshold {
            subject.send(.landscapeLeft)
        } else if pitch < -threshold {
            subject.send(.portrait)
        } else if pitch > threshold {
            subject.send(.portraitUpsideDown)
        }
    }
}
