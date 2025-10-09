//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUICore
import UIKit

/// A model that represents a transition between two device orientations.
///
/// `OrientationTransition` encapsulates the mapping from a starting orientation (`from`)
/// to a target orientation (`to`). It is primarily used to calculate the correct
/// rotation angle when animating between different device orientations.
///
/// The type also provides a set of predefined valid transitions, with their corresponding
/// `Angle` values, ensuring that only supported rotations are handled.
///
/// Typical usage includes:
/// - Validating whether a transition is supported.
/// - Mapping an input angle to its equivalent angle in the target orientation.
/// - Ensuring smooth icon and interface rotations during device orientation changes.
struct OrientationTransition: Hashable {
    /// The starting orientation of the device
    let from: UIDeviceOrientation

    //swiftlint:disable identifier_name
    /// The target orientation of the device
    let to: UIDeviceOrientation
    //swiftlint:enable identifier_name

    // MARK: - Private Properties

    private static let validTransitions: [OrientationTransition: Angle] = [
        OrientationTransition(from: .portrait, to: .landscapeRight): .degrees(-90),
        OrientationTransition(from: .portrait, to: .landscapeLeft): .degrees(90),
        OrientationTransition(from: .portrait, to: .portraitUpsideDown): .degrees(180),
        OrientationTransition(from: .landscapeLeft, to: .landscapeRight): .degrees(-90),
        OrientationTransition(from: .landscapeRight, to: .landscapeLeft): .degrees(90),
        OrientationTransition(from: .portraitUpsideDown, to: .portrait): .degrees(0),
    ]

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
        guard let angle = Self.validTransitions[self] else {
            guard from != to else {
                return angle
            }

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

        return angle
    }
}
