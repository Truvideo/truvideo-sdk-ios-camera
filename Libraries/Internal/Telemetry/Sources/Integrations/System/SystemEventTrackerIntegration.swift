//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Network
import UIKit
import Utilities

/// A telemetry integration responsible for monitoring and reporting system-level events such as
/// app lifecycle transitions, battery state changes, connectivity updates, and memory warnings.
///
/// `SystemEventTrackerIntegration` listens for relevant `NotificationCenter` events and network path
/// changes via `NWPathMonitor`, then sends structured breadcrumbs to the `TelemetryManager`
/// for diagnostic and observability purposes.
final class SystemEventTrackerIntegration: TelemetryIntegration {
    // MARK: - Private Properties
    
    private let pathMonitor: NWPathMonitor
    private let queue = DispatchQueue(label: "com.truvideo.telemetry.systemEventTracker.queue")
    
    private weak var telemetryManager: TelemetryManager?
    
    // MARK: - Breadcrumb Categories
    
    private let appLifecycleCategory = "app.lifecycle"
    private let deviceConnectivityCategory = "device.connectivity"
    private let deviceEventCategory = "device.event"
    private let deviceOrientationCategory = "device.orientation"
    
    // MARK: - Initializer
    
    /// Initializes a new instance of the system event tracker.
    ///
    /// - Parameter pathMonitor: Optional dependency injection for the network monitor.
    init(pathMonitor: NWPathMonitor = NWPathMonitor()) {
        self.pathMonitor = pathMonitor
        
        startMonitoringAppLifecycleChanges()
        startMonitoringDeviceStateChanges()
        startMonitoringTimeZoneChanges()
        
        pathMonitor.pathUpdateHandler = { [weak self] newPath in
            guard let self = self else { return }
            
            telemetryManager?.captureBreadcrumb(
                deviceConnectivityCategory,
                severity: .info,
                metadata: [
                    "connectivityType": .string(newPath.connectivityType),
                    "status": .string(newPath.status.debugDescription)
                ]
            )
        }
        
        pathMonitor.start(queue: queue)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        pathMonitor.cancel()
    }
    
    // MARK: - Notification methods
    
    @objc
    func didReceiveBackgroundNotification(_ notification: Notification) {
        telemetryManager?.captureBreadcrumb(appLifecycleCategory, severity: .info, metadata: ["state": "background"])
    }
    
    @objc
    func didReceiveBatteryStateDidChangeNotification(_ notification: Notification) {
        if let currentDevice = notification.object as? UIDevice {
            telemetryManager?.captureBreadcrumb(
                deviceEventCategory,
                severity: .info,
                metadata: [
                    "isLowPowerModeEnabled": .bool(ProcessInfo.processInfo.isLowPowerModeEnabled),
                    "isPlugged": .bool([.charging, .full].contains(currentDevice.batteryState)),
                    "level": currentDevice.batteryState != .unknown ? "\(currentDevice.batteryLevel * 100)" : "Unknown"
                ]
            )
        }
    }
    
    @objc
    func didReceiveBecomeActiveNotification(_ notification: Notification) {
        telemetryManager?.captureBreadcrumb(appLifecycleCategory, severity: .info, metadata: ["state": "foreground"])
    }
    
    @objc
    func didReceiveMemoryWarningNotification(_ notification: Notification) {
        telemetryManager?.captureBreadcrumb(
            deviceEventCategory,
            severity: .warning,
            message: "Low memory",
            metadata: [
                "freeMemory": .string(UIDevice.current.freeMemory?.description ?? "Unknown"),
                "totalMemory": .int(Int(ProcessInfo.processInfo.physicalMemory))
            ]
        )
    }
    
    @objc
    func didReceiveOrientationDidChangeNotification(_ notification: Notification) {
        if let currentDevice = notification.object as? UIDevice, currentDevice.orientation.isValidInterfaceOrientation {
            telemetryManager?.captureBreadcrumb(
                deviceEventCategory,
                severity: .info,
                metadata: ["position": currentDevice.orientation.isLandscape ? "landscape" : "portrait"]
            )
        }
    }
    
    @objc
    func didReceiveTimeZoneDidChangeNotification(_ notification: Notification) {
        if let abbreviation = TimeZone.current.abbreviation() {
            telemetryManager?.captureBreadcrumb(
                deviceEventCategory,
                severity: .info,
                metadata: ["newTimezone": .string(abbreviation)]
            )
        }
    }
        
    // MARK: - TelemetryIntegration
    
    /// Installs the telemetry integration into the provided telemetry manager.
    ///
    /// - Parameter manager: The central `TelemetryManager` responsible for coordinating integrations.
    func install(on manager: TelemetryManager) {
        telemetryManager = manager
    }
    
    // MARK: - Private methods
    
    private func startMonitoringAppLifecycleChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveBackgroundNotification(_:)),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveBecomeActiveNotification(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveMemoryWarningNotification(_:)),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }
    
    private func startMonitoringDeviceStateChanges() {
        if !UIDevice.current.isBatteryMonitoringEnabled {
            UIDevice.current.isBatteryMonitoringEnabled = true
        }
        
        if !UIDevice.current.isGeneratingDeviceOrientationNotifications {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveBatteryStateDidChangeNotification(_:)),
            name: UIDevice.batteryLevelDidChangeNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveBatteryStateDidChangeNotification(_:)),
            name: UIDevice.batteryStateDidChangeNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveOrientationDidChangeNotification(_:)),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }
    
    private func startMonitoringTimeZoneChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveTimeZoneDidChangeNotification(_:)),
            name: NSNotification.Name.NSSystemTimeZoneDidChange,
            object: nil
        )
    }
}

private extension TelemetryManager {
    /// Captures a breadcrumb entry with the given parameters and sends it to the telemetry system.
    ///
    /// - Parameters:
    ///   - category: The event category for classification.
    ///   - severity: The severity level of the event.
    ///   - message: An optional message for context.
    ///   - metadata: Additional key-value pairs describing the event.
    func captureBreadcrumb(_ category: String, severity: Severity, message: String? = nil, metadata: Metadata = [:]) {
        let breadcrumb = Breadcrumb(
            severity: severity,
            source: "Telemetry",
            category: category,
            message: message,
            metadata: metadata
        )
        
        capture(breadcrumb)
    }
}
