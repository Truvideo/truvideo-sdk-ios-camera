//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A structure representing a snapshot of the system context at a given point in time.
///
/// The `Context` provides detailed information about the device and operating system,
/// useful for telemetry, diagnostics, and analytics reporting. This includes battery
/// state, CPU architecture, memory usage, OS version, and more.
public struct Context: Codable, Sendable {
    /// Information about the current device's hardware and state.
    public let device: Device

    /// Information about the operating system running on the device.
    public let osInfo: OsInfo

    /// Contains all the registered versions of the installed sdks.
    public let sdks: [String: String]

    // MARK: - Types

    /// Represents hardware- and runtime-related details of the device.
    public struct Device: Codable, Sendable {
        /// The current battery information.
        public let battery: Battery

        /// The CPU architecture of the device (e.g., "arm64", "x86_64").
        public let cpuArchitecture: String

        /// The disk capacity and available space.
        public let disk: Disk

        /// The device manufacturer name (e.g., "Apple").
        public let manufacturer: String

        /// The memory usage statistics of the device.
        public let memory: Memory

        /// The specific device model identifier (e.g., "iPhone13,4").
        public let model: String

        /// The number of logical processor cores available.
        public let processorCount: Int

        /// A textual description of the current thermal state (e.g., "nominal", "serious").
        public let thermalState: String

        /// System uptime in seconds since the last boot.
        public let uptimeSeconds: Double

        // MARK: - Types

        /// Represents the current battery state and configuration.
        public struct Battery: Codable, Sendable {
            /// Indicates whether Low Power Mode is currently enabled.
            public let isLowPowerMode: Bool

            /// The current battery level as a float between 0.0 and 1.0.
            public let level: Float

            /// The current battery charging state (e.g., "charging", "full", "unplugged").
            public let state: String
        }

        /// Represents the device's disk usage.
        public struct Disk: Codable, Sendable {
            /// The number of bytes currently available.
            public let free: UInt64?

            /// The total disk space in bytes.
            public let total: Int
        }

        /// Represents memory usage statistics.
        public struct Memory: Codable, Sendable {
            /// The number of bytes of free memory currently available.
            public let free: UInt64?

            /// The total amount of memory in bytes.
            public let total: UInt64
        }
    }

    /// Represents the operating system details.
    public struct OsInfo: Codable, Sendable {
        /// The name of the operating system (e.g., "iOS", "macOS").
        public let name: String

        /// The version of the operating system (e.g., "17.5.1").
        public let version: String
    }
}
