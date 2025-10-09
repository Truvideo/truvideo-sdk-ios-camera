//
// Copyright © 2025 TruVideo. All rights reserved.
//

internal import DI
import Foundation
import SwiftUICore
import UIKit

final class ZoomPickerViewModel: ObservableObject, OrientationMonitorSubscriber {
    // MARK: - Private Properties

    private var previousDeviceOrientation = UIDeviceOrientation.portrait

    // MARK: - Dependencies

    @Dependency(\.orientationMonitor)
    var orientationMonitor: OrientationMonitor

    // MARK: - Properties

    /// The base size used for layout and mask calculations.
    ///
    /// This constant defines the default dimension (44 points) applied to masks
    /// when determining their width or height in collapsed states.
    /// It serves as the minimum or fixed size whenever the mask is not expanded.
    let size: CGFloat = 44

    // MARK: - Published Properties

    /// The current rotation angle for the collapsible.
    ///
    /// This published property contains the calculated rotation angle that should
    /// be applied to the collapsible.
    @Published var collapsibleAngle = Angle.zero

    /// The current device orientation being tracked.
    ///
    /// This property stores the most recent device orientation detected by the
    /// orientation monitor.
    @Published private(set) var deviceOrientation = DeviceOrientation(orientation: .portrait, source: .system)

    /// The maximum available size for the zoom picker UI component.
    ///
    /// This property defines the largest bounding size (width and height) that the
    /// zoom picker can occupy within its container. It is typically updated in
    /// response to layout changes, such as device rotation or parent view resizing,
    /// to ensure the zoom picker scales correctly within the available space.
    @Published private(set) var maxSize = CGSize.zero

    /// The current rotation angle for the zoom value.
    ///
    /// This published property contains the calculated rotation angle that should
    /// be applied to the zoom value.
    @Published var rotationAngle = Angle.zero

    // MARK: - Initializer

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
    /// - Parameter orientation: The latest orientation information, including its
    ///   source (e.g., system or sensors) and value.
    func didReceive(_ deviceOrientation: DeviceOrientation) {
        self.previousDeviceOrientation = self.deviceOrientation.orientation
        self.deviceOrientation = deviceOrientation

        let transition = OrientationTransition(from: previousDeviceOrientation, to: deviceOrientation.orientation)

        if deviceOrientation.source == .sensors && UIDevice.current.orientation == .portrait {
            rotationAngle = transition.newAngle(from: rotationAngle)
            collapsibleAngle = deviceOrientation.orientation.isPortrait ? Angle.zero : Angle(degrees: 360)
        }

        if deviceOrientation.source == .system && UIDevice.current.orientation == .portrait {
            rotationAngle = transition.newAngle(from: rotationAngle)
        }
    }

    // MARK: - Instance methods

    /// Returns a formatted string representation of the number with conditional decimal precision.
    ///
    /// This computed property formats the number to show either no decimal places or one decimal place
    /// based on whether the number has a fractional component. If the number is a whole number (no decimal
    /// part), it displays without decimal places. If it has a fractional part, it displays with one
    /// decimal place for precision.
    ///
    /// - Returns: A formatted string that shows either "%.0f" or "%.1f" format depending on the number's value.
    func format(_ value: Double) -> String {
        let format = value.truncatingRemainder(dividingBy: 1) == 0 ? "%.0f" : "%.1f"

        return String(format: format, value)
    }

    /// Calculates the maximum size of an animatable mask based on the device orientation and expansion state.
    ///
    /// This method determines the mask's maximum width and height depending on whether:
    /// - The orientation is coming from the system or from sensors.
    /// - The device is in portrait or landscape orientation.
    /// - The mask is currently expanded or collapsed.
    ///
    /// - Parameter isExpanded: A Boolean flag indicating whether the mask should be expanded (`true`) or collapsed (`false`).
    /// - Returns: A `CGSize` representing the maximum size of the animatable mask.
    func maxSizeForAnimatableMask(isExpanded: Bool) -> CGSize {
        if deviceOrientation.orientation.isPortrait || deviceOrientation.source == .system, !UIDevice.current.isPad {
            return isExpanded ? CGSize(width: .infinity, height: size) : CGSize(width: size, height: size)
        }

        return isExpanded ? CGSize(width: size, height: .infinity) : CGSize(width: size, height: size)
    }

    /// Calculates the maximum size of a collapsible mask based on the device orientation and expansion state.
    ///
    /// Similar to `maxSizeForAnimatableMask`, this method adapts the mask dimensions
    /// based on the orientation source and whether the mask is expanded.
    /// The main difference is that when the mask is collapsed, one of its dimensions
    /// shrinks to `0` instead of keeping a fixed `size`.
    ///
    /// - Parameter isExpanded: A Boolean flag indicating whether the mask should be expanded (`true`) or collapsed (`false`).
    /// - Returns: A `CGSize` representing the maximum size of the collapsible mask.
    func maxSizeForCollapsibleMask(isExpanded: Bool) -> CGSize {
        if deviceOrientation.orientation.isPortrait, !UIDevice.current.isPad {
            return isExpanded ? CGSize(width: .infinity, height: size) : CGSize(width: 0, height: size)
        }

        guard deviceOrientation.source == .system || UIDevice.current.isPad else {
            return isExpanded ? CGSize(width: .infinity, height: size) : CGSize(width: size, height: 0)
        }

        return isExpanded ? CGSize(width: size, height: .infinity) : CGSize(width: size, height: 0)
    }
}
