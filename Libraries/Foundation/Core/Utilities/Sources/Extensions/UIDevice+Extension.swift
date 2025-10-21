//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import UIKit

extension UIDevice {
    /// Returns the CPU architecture of the current device or simulator.
    ///
    /// This property evaluates the architecture at compile time and returns a human-readable string
    /// indicating the architecture in use:
    /// - `"arm64"`: Indicates the app is running on a physical device or Apple Silicon Mac.
    /// - `"x86_64"`: Indicates the app is running on an Intel-based Mac or simulator.
    /// - `"unknown"`: Used as a fallback if the architecture is unrecognized.
    ///
    /// - Returns: A string representing the CPU architecture.
    public var cpuArchitecture: String {
        #if arch(arm64)
            return "arm64"
        #elseif arch(x86_64)
            return "x86_64"
        #else
            return "unknown"
        #endif
    }

    /// Returns the estimated amount of free memory available on the device, in bytes.
    ///
    /// This includes both **free** and **inactive** memory pages, which are considered
    /// reclaimable by the operating system.
    ///
    /// Internally, this method uses `host_statistics64` to query memory statistics from
    /// the kernel and multiplies the total number of free and inactive pages by the system's page size.
    ///
    /// - Returns: The amount of free memory in bytes, or `nil` if the memory statistics could not be retrieved.
    public var freeMemory: UInt64? {
        var pageSize: vm_size_t = 0
        host_page_size(mach_host_self(), &pageSize)

        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)

        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }

        guard result == KERN_SUCCESS else {
            return nil
        }

        let freePages = stats.free_count + stats.inactive_count
        return UInt64(freePages) * UInt64(pageSize)
    }

    /// Returns the device model identifier string that uniquely identifies the hardware model.
    ///
    /// This property provides access to the device's machine identifier, which is a string
    /// that uniquely identifies the specific hardware model of the device. Unlike `model`
    /// which returns a generic type (e.g., "iPhone"), this identifier provides the exact
    /// model specification (e.g., "iPhone16,2" for iPhone 15 Pro).
    public var modelIdentifier: String {
        var systemInfo = utsname()
        uname(&systemInfo)

        let machineMirror = Mirror(reflecting: systemInfo.machine)
        return machineMirror.children.reduce(into: "") { identifier, element in
            if let value = element.value as? Int8, value != 0 {
                identifier += String(UnicodeScalar(UInt8(value)))
            }
        }
    }

    /// Retrieves the total disk capacity of the device in bytes.
    ///
    /// This includes all system, user, and reserved space. It is useful for determining
    /// device storage tiers, capacity planning, or warning thresholds.
    ///
    /// - Returns: The total disk space in bytes, or `0` if the value could not be determined.
    public var totalDiskSpace: Int {
        let attributtes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
        let total = attributtes?[.systemSize] as? NSNumber

        return total?.intValue ?? 0
    }
}

extension UIDevice.BatteryState: @retroactive CustomDebugStringConvertible {
    /// A textual representation of this instance, suitable for debugging.
    public var debugDescription: String {
        switch self {
        case .charging:
            "charging"

        case .full:
            "full"

        case .unplugged:
            "unplugged"

        default:
            "unknown"
        }
    }
}
