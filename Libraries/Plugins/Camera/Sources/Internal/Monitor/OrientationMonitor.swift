//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Combine
import CoreMotion
import UIKit

/// Represents orientation data including its source of origin.
struct DeviceOrientation: Hashable {
    /// The current device orientation.
    let orientation: UIDeviceOrientation

    /// The source of the orientation update.
    let source: Source

    // MARK: - Static Properties

    /// A default unknown orientation value, typically used as a fallback.
    static let unknown = DeviceOrientation(orientation: .unknown, source: .system)

    // MARK: - Types

    /// The origin of the orientation reading.
    enum Source {
        /// Orientation derived from physical sensors (e.g., accelerometer/gyroscope).
        case sensors

        /// Orientation reported by the iOS system/device.
        case system
    }
}

/// A type that subscribes to orientation updates from an `OrientationMonitor`.
protocol OrientationMonitorSubscriber: AnyObject {
    /// Handles a new device orientation update and applies the corresponding rotation angle.
    ///
    /// This method is triggered when a new `DeviceOrientationInfo` is received.
    /// It updates the current orientation, calculates the transition between the
    /// previous and new orientations, and determines the appropriate rotation angle.
    /// If the orientation source comes from sensors while the device is physically
    /// in portrait mode, it preserves or updates the rotation angle accordingly.
    ///
    /// - Parameter deviceOrientation: The latest orientation information, including its source and value.
    func didReceive(_ deviceOrientation: DeviceOrientation)
}

/// A protocol that defines the interface for monitoring device orientation changes.
///
/// This protocol provides a standardized way to observe and respond to device orientation
/// changes across different monitoring implementations. It abstracts the complexity of
/// orientation detection and provides a clean callback-based interface for receiving
/// orientation updates.
///
/// ## Usage
///
/// ```swift
/// class MyViewController: UIViewController {
///     private let orientationMonitor: OrientationMonitor
///
///     override func viewDidLoad() {
///         super.viewDidLoad()
///
///         orientationMonitor.updateHandler = { [weak self] orientation in
///             self?.handleOrientationChange(to: orientation)
///         }
///
///         orientationMonitor.startMonitoring()
///     }
///
///     override func viewWillDisappear(_ animated: Bool) {
///         super.viewWillDisappear(animated)
///         orientationMonitor.stopMonitoring()
///     }
/// }
/// ```
protocol OrientationMonitor: AnyObject {
    /// Registers a orientation monitor subscriber to receive `UIDeviceOrientation` events.
    ///
    /// - Parameter subscriber: An object conforming to `OrientationMonitorSubscriber`.
    func add(_ subscriber: any OrientationMonitorSubscriber)

    /// Begins monitoring device orientation changes.
    ///
    /// This method starts the orientation detection process and begins calling the
    /// `updateHandler` closure whenever the device orientation changes.
    func startMonitoring()

    /// Stops monitoring device orientation changes.
    ///
    /// This method stops the orientation detection process and ceases calling the
    /// `updateHandler` closure.
    func stopMonitoring()
}

/// A concrete implementation of OrientationMonitor that tracks device orientation changes.
///
/// This class provides real-time monitoring of device orientation changes using
/// UIDevice notifications. It maintains a collection of subscribers that receive
/// orientation updates and manages the lifecycle of device orientation notifications.
final class DeviceOrientationMonitor: OrientationMonitor {
    // MARK: - Private Properties

    private var isRunning = false
    private var subscribers: [ObjectIdentifier: any OrientationMonitorSubscriber] = [:]

    // MARK: - Initializer

    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveOrientationDidChangeNotification(_:)),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Notification methods

    @objc
    func didReceiveOrientationDidChangeNotification(_ notification: Notification) {
        if UIDevice.supportedOrientations.contains(UIDevice.current.orientation) {
            let deviceOrientation = DeviceOrientation(orientation: UIDevice.current.orientation, source: .system)

            for subscriber in subscribers.values {
                subscriber.didReceive(deviceOrientation)
            }
        }
    }

    // MARK: - OrientationMonitor

    /// Registers a orientation monitor subscriber to receive `UIDeviceOrientation` events.
    ///
    /// - Parameter subscriber: An object conforming to `OrientationMonitorSubscriber`.
    func add(_ subscriber: any OrientationMonitorSubscriber) {
        let deviceOrientation = DeviceOrientation(orientation: UIDevice.current.orientation, source: .system)

        subscribers[ObjectIdentifier(subscriber)] = subscriber
        subscriber.didReceive(deviceOrientation)
    }

    /// Begins monitoring device orientation changes.
    ///
    /// This method starts the orientation detection process and begins calling the
    /// `updateHandler` closure whenever the device orientation changes.
    func startMonitoring() {
        if !isRunning {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()

            isRunning = true
        }
    }

    /// Stops monitoring device orientation changes.
    ///
    /// This method stops the orientation detection process and ceases calling the `updateHandler` closure.
    func stopMonitoring() {
        if isRunning {
            UIDevice.current.endGeneratingDeviceOrientationNotifications()
            isRunning = false
        }
    }
}

/// A concrete implementation of `OrientationMonitor` that uses `CMMotionManager` for
/// physical device orientation detection.
///
/// This class provides real-time orientation monitoring by combining device motion data
/// with system orientation notifications. It offers more accurate and responsive
/// orientation detection compared to relying solely on system notifications, especially
/// for edge cases like face-down orientations.
final class PhysicalOrientationMonitor: OrientationMonitor {
    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()
    private let deviceOrientation = CurrentValueSubject<DeviceOrientation, Never>(.unknown)
    private var isRunning = false
    private let motionManager = CMMotionManager()
    private let operationQueue = OperationQueue()
    private var subscribers: [ObjectIdentifier: any OrientationMonitorSubscriber] = [:]

    // MARK: - Initializer

    init() {
        motionManager.deviceMotionUpdateInterval = 1 / 30

        if [.landscapeLeft, .landscapeRight, .portraitUpsideDown].contains(UIDevice.current.orientation) {
            deviceOrientation.value = DeviceOrientation(orientation: UIDevice.current.orientation, source: .system)
        }

        startObserving()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Notification methods

    @objc
    func didReceiveOrientationDidChangeNotification(_ notification: Notification) {
        if isRunning, UIDevice.supportedOrientations.contains(UIDevice.current.orientation) {
            let deviceOrientation = DeviceOrientation(orientation: UIDevice.current.orientation, source: .system)

            self.deviceOrientation.send(deviceOrientation)
        }
    }

    // MARK: - OrientationMonitor

    /// Registers a orientation monitor subscriber to receive `UIDeviceOrientation` events.
    ///
    /// - Parameter subscriber: An object conforming to `OrientationMonitorSubscriber`.
    func add(_ subscriber: any OrientationMonitorSubscriber) {
        subscribers[ObjectIdentifier(subscriber)] = subscriber
        subscriber.didReceive(deviceOrientation.value)
    }

    /// Begins monitoring device orientation changes.
    ///
    /// This method starts the orientation detection process and begins calling the
    /// `updateHandler` closure whenever the device orientation changes.
    func startMonitoring() {
        if !isRunning {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
            isRunning = true

            motionManager.startDeviceMotionUpdates(
                using: .xArbitraryZVertical,
                to: operationQueue
            ) { [weak self] deviceMotion, error in
                if let self {
                    guard let error else {
                        if /// The new orientation.
                        let orientation = deviceMotion?.gravity.orientation,

                            /// Whether the orientations are different.
                            orientation != deviceOrientation.value.orientation
                        {

                            let deviceOrientation = DeviceOrientation(orientation: orientation, source: .sensors)

                            self.deviceOrientation.send(deviceOrientation)
                        }

                        return
                    }

                    print(error)
                    // Log Error
                }
            }
        }
    }

    /// Stops monitoring device orientation changes.
    ///
    /// This method stops the orientation detection process and ceases calling the
    /// `updateHandler` closure.
    func stopMonitoring() {
        if isRunning {
            UIDevice.current.endGeneratingDeviceOrientationNotifications()
            motionManager.stopDeviceMotionUpdates()
            isRunning = false
        }
    }

    // MARK: - Private methods

    private func startObserving() {
        deviceOrientation.removeDuplicates()
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .receive(on: RunLoop.main)
            .filter { _ in UIApplication.shared.applicationState == .active }
            .filter { UIDevice.supportedOrientations.contains($0.orientation) }
            .collect(.byTime(RunLoop.main, .milliseconds(10)))
            .compactMap { $0.first { $0.source == .system } ?? $0.first }
            .sink { [weak self] orientation in
                if let self {
                    for subscriber in subscribers.values {
                        subscriber.didReceive(orientation)
                    }
                }
            }
            .store(in: &cancellables)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveOrientationDidChangeNotification(_:)),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }
}

extension CMAcceleration {
    /// Calculates the device orientation based on acceleration data.
    ///
    /// This computed property determines the current device orientation by analyzing
    /// the acceleration values from the device's accelerometer. It compares the
    /// magnitude of acceleration along each axis (X, Y, Z) to determine which
    /// orientation the device is currently in.
    ///
    /// - Returns: The calculated `UIDeviceOrientation` based on accelerometer data analysis.
    fileprivate var orientation: UIDeviceOrientation {
        let threshold = 0.82

        if z < -0.7 {
            guard abs(x) > abs(y), abs(x) > abs(z), abs(x) > threshold else {
                switch y {
                case let value where value > 0.6:
                    return .portraitUpsideDown

                case let value where value < -0.6:
                    return .portrait

                default:
                    return .unknown
                }
            }

            return x > 0 ? .landscapeRight : .landscapeLeft
        }

        if abs(x) > abs(y), abs(x) > abs(z), abs(x) > threshold {
            return x > 0 ? .landscapeRight : .landscapeLeft
        }

        if abs(y) > abs(x), abs(y) > abs(z), abs(y) > threshold {
            return y > 0 ? .portraitUpsideDown : .portrait
        }

        return .unknown
    }
}

extension UIDevice {
    /// The collection of device orientations that are supported by the application.
    ///
    /// This static property defines the set of device orientations that the app
    /// can handle and display content in. It includes all four primary orientations:
    /// landscape left, landscape right, portrait, and portrait upside down.
    fileprivate static var supportedOrientations: [UIDeviceOrientation] = [
        .landscapeLeft,
        .landscapeRight,
        .portrait,
        .portraitUpsideDown,
    ]
}
