//
// Copyright © 2025 TruVideo. All rights reserved.
//

internal import DI
import SwiftUI

final class AdaptiveOrientationLayoutViewModel: ObservableObject, OrientationMonitorSubscriber {
    // MARK: - Dependencies

    @Dependency(\.orientationMonitor)
    private var orientationMonitor: OrientationMonitor

    // MARK: - Published Properties

    @Published private(set) var alignment = Alignment.top
    @Published private(set) var padding = 0
    @Published private(set) var rotationAngle = Angle.zero

    // MARK: - Initializer

    /// Creates a new instance of the `AdaptiveOrientationLayoutViewModel`.
    init() {
        orientationMonitor.add(self)
    }

    // MARK: - OrientationMonitor

    /// Handles a new device orientation update and applies the corresponding rotation angle.
    ///
    /// This method is triggered when a new `DeviceOrientationInfo` is received.
    /// It updates the current orientation, calculates the transition between the
    /// previous and new orientations, and determines the appropriate rotation angle.
    /// If the orientation source comes from sensors while the device is physically
    /// in portrait mode, it preserves or updates the rotation angle accordingly.
    ///
    /// - Parameter deviceOrientation: The latest orientation information, including its source and value.
    func didReceive(_ deviceOrientation: DeviceOrientation) {
        if deviceOrientation.source == .sensors {
            switch deviceOrientation.orientation {
            case .landscapeLeft:
                alignment = .trailing
                rotationAngle = Angle(degrees: 90)

            case .landscapeRight:
                alignment = .leading
                rotationAngle = Angle(degrees: -90)

            default:
                alignment = .top
                rotationAngle = Angle.zero
            }
        }
    }
}
