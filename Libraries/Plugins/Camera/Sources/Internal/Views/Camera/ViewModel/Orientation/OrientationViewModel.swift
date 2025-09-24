//
// Copyright © 2025 TruVideo. All rights reserved.
//

internal import DI
import Foundation
import SwiftUICore
import UIKit

final class OrientationViewModel: ObservableObject, OrientationMonitorSubscriber {
    // MARK: - Dependencies

    @Dependency(\.orientationMonitor)
    private var orientationMonitor: OrientationMonitor

    // MARK: - Properties

    /// The current device orientation being tracked.
    ///
    /// This property stores the most recent device orientation detected by the
    /// orientation monitor.
    private(set) var deviceOrientation = UIDeviceOrientation.portrait

    /// The current origin of the orientation.
    ///
    /// This property stores the most recent source of the orientation detected by the
    /// orientation monitor.
    private(set) var deviceOrientationSource: DeviceOrientation.Source = .system

    /// The previous device orientation before the current change.
    ///
    /// This property tracks the orientation state before the most recent change,
    /// allowing the view model to calculate the transition from the previous
    /// orientation to the new one.
    private(set) var previousDeviceOrientation = UIDeviceOrientation.portrait

    // MARK: - Published Properties

    /// The current rotation angle for the circular button.
    ///
    /// This published property contains the calculated rotation angle that should
    /// be applied to the circular button.
    @Published var rotationAngle = Angle.zero

    // MARK: - Initializer

    /// Creates a new instance of the `OrientationViewModel`.
    init() {
        orientationMonitor.add(self)
        orientationMonitor.startMonitoring()
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
        previousDeviceOrientation = self.deviceOrientation
        deviceOrientationSource = deviceOrientation.source

        self.deviceOrientation = deviceOrientation.orientation

        if UIDevice.current.userInterfaceIdiom != .pad {
            let transition = OrientationTransition(from: previousDeviceOrientation, to: deviceOrientation.orientation)

            if UIDevice.current.orientation == .portrait {
                withAnimation(.spring(duration: 0.3)) {
                    rotationAngle = transition.newAngle(from: rotationAngle)
                }
            }

            if deviceOrientation.orientation == UIDeviceOrientation.portrait {
                self.rotationAngle = .degrees(0)
            }
        }
    }
}
