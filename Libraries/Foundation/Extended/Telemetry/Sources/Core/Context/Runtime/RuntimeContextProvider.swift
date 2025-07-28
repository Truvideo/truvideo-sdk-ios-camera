//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Registry
import UIKit
import Utilities

/// A concrete implementation of `ContextProvider` that generates a snapshot of
/// the current runtime environment at the moment it's invoked.
///
/// The `RuntimeContextProvider` gathers system and device metrics such as battery state,
/// memory usage, CPU architecture, disk space, thermal state, and OS version,
/// and encapsulates them in a `Context` object suitable for telemetry reporting.
///
/// This context is used to enrich telemetry events with diagnostic metadata about
/// the host device, helping developers analyze and debug issues in production or testing environments.
struct RuntimeContextProvider: ContextProvider {

    // MARK: - ContextProvider

    /// Creates and returns a `Context` object representing the current system and environment state.
    ///
    /// - Returns: A `Context` instance containing up-to-date device and OS information.
    func makeContext() -> Context {
        let currentDevice = UIDevice.current
        let processInfo = ProcessInfo.processInfo

        if !currentDevice.isBatteryMonitoringEnabled {
            currentDevice.isBatteryMonitoringEnabled = true
        }

        return Context(
            device: Context.Device(
                battery: Context.Device.Battery(
                    isLowPowerMode: processInfo.isLowPowerModeEnabled,
                    level: currentDevice.batteryLevel * 100,
                    state: currentDevice.batteryState.debugDescription
                ),
                cpuArchitecture: currentDevice.cpuArchitecture,
                disk: Context.Device.Disk(
                    free: currentDevice.freeMemory,
                    total: currentDevice.totalDiskSpace
                ),
                manufacturer: "Apple",
                memory: Context.Device.Memory(
                    free: currentDevice.freeMemory,
                    total: processInfo.physicalMemory
                ),
                model: currentDevice.modelIdentifier,
                processorCount: processInfo.processorCount,
                thermalState: processInfo.thermalState.debugDescription,
                uptimeSeconds: processInfo.systemUptime
            ),
            osInfo: Context.OsInfo(
                name: currentDevice.systemName,
                version: currentDevice.systemVersion
            ),
            sdks: LibraryRegistry.registeredLibraries()
        )
    }
}
