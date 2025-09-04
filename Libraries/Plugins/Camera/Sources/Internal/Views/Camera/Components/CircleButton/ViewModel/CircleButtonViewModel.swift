//
// Copyright © 2025 TruVideo. All rights reserved.
//

internal import DI
import Foundation
import SwiftUICore
import UIKit

final class CircleButtonViewModel: ObservableObject, OrientationMonitorSubscriber {
    // MARK: - Dependencies

    @Dependency(\.orientationMonitor)
    private var orientationMonitor: OrientationMonitor

    // MARK: - Private Properties

    private let validTransitions: [OrientationTransition: Angle] = [
        OrientationTransition(from: .portrait, to: .landscapeRight): .degrees(-90),
        OrientationTransition(from: .portrait, to: .landscapeLeft): .degrees(90),
        OrientationTransition(from: .portrait, to: .portraitUpsideDown): .degrees(180),
        OrientationTransition(from: .landscapeLeft, to: .landscapeRight): .degrees(-90),
        OrientationTransition(from: .landscapeRight, to: .landscapeLeft): .degrees(90),
        OrientationTransition(from: .portraitUpsideDown, to: .portrait): .degrees(0),
    ]

    // MARK: - Properties

    /// The current device orientation being tracked.
    ///
    /// This property stores the most recent device orientation detected by the
    /// orientation monitor.
    private(set) var deviceOrientation = UIDeviceOrientation.portrait

    /// The previous device orientation before the current change.
    ///
    /// This property tracks the orientation state before the most recent change,
    /// allowing the view model to calculate the transition from the previous
    /// orientation to the new one.
    private(set) var previousDeviceOrientation: UIDeviceOrientation = .portrait

    // MARK: - Published Properties

    /// The current rotation angle for the circular button.
    ///
    /// This published property contains the calculated rotation angle that should
    /// be applied to the circular button.
    @Published var rotationAngle = Angle.zero

    // MARK: - Initializer

    /// Creates a new circle button view model with the specified orientation monitor.
    ///
    /// This initializer sets up the orientation monitoring system and configures
    /// the update handler to respond to device orientation changes. It starts
    /// monitoring immediately upon initialization.
    ///
    /// - Parameter orientationMonitor: The orientation monitoring service to use.
    init() {
        orientationMonitor.add(self)

        self.orientationMonitor.startMonitoring()
    }

    /// Handles a new device orientation update and applies the corresponding rotation angle.
    ///
    /// This method is triggered when a new `DeviceOrientationInfo` is received.
    /// It updates the current orientation, calculates the transition between the
    /// previous and new orientations, and determines the appropriate rotation angle.
    /// If the orientation source comes from sensors while the device is physically
    /// in portrait mode, it preserves or updates the rotation angle accordingly.
    ///
    /// - Parameter deviceOrientation: The latest orientation information, including its
    ///   source (e.g., system or sensors) and value.
    func didReceive(_ deviceOrientation: DeviceOrientation) {
        self.previousDeviceOrientation = self.deviceOrientation
        self.deviceOrientation = deviceOrientation.orientation

        let transition = OrientationTransition(from: previousDeviceOrientation, to: deviceOrientation.orientation)
        let angle = validTransitions[transition] ?? transition.newAngle(from: rotationAngle)

        if deviceOrientation.source == .sensors && UIDevice.current.orientation == .portrait {
            rotationAngle = transition.from == transition.to ? rotationAngle : angle
        }
    }
}

private struct OrientationTransition: Hashable {
    /// The starting orientation of the device
    let from: UIDeviceOrientation

    //swiftlint:disable identifier_name
    /// The target orientation of the device
    let to: UIDeviceOrientation
    //swiftlint:enable identifier_name

    // MARK: - Instance methods

    /// Calculates the adjusted angle when transitioning between different device orientations.
    ///
    /// This function maps angles from one device orientation to another, ensuring smooth
    /// transitions during device rotation. It handles the conversion of angle values
    /// based on the source and target orientations, taking into account the direction
    /// of rotation (positive or negative radians).
    ///
    /// The function uses a switch statement with tuple pattern matching to handle
    /// all possible orientation transitions. Each case considers whether the original
    /// angle is positive or negative to determine the appropriate mapped angle.
    ///
    /// - Parameter angle: The current angle to be converted. This should be the angle
    /// - Returns: A new `Angle` value that represents the equivalent angle in the target orientation coordinate system.
    func newAngle(from angle: Angle) -> Angle {

        switch (from, to) {
        case (.landscapeLeft, .portrait):
            return angle.radians > 0 ? .degrees(0) : .degrees(-360)

        case (.landscapeLeft, .portraitUpsideDown):
            return angle.radians > 0 ? .degrees(180) : .degrees(-180)

        case (.landscapeRight, .portrait):
            return angle.radians > 0 ? .degrees(360) : .degrees(0)

        case (.landscapeRight, .portraitUpsideDown):
            return angle.radians < 0 ? .degrees(-180) : .degrees(180)

        case (.portraitUpsideDown, .landscapeRight):
            return angle.radians > 0 ? .degrees(270) : .degrees(-90)

        case (.portraitUpsideDown, .landscapeLeft):
            return angle.radians > 0 ? .degrees(90) : .degrees(-270)

        default:
            return .degrees(0)
        }
    }
}
