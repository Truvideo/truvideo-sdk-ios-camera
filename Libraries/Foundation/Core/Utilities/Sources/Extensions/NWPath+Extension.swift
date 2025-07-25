//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Network

extension NWPath {
    /// A computed property that returns the current network connectivity type as a string representation.
    ///
    /// The value is determined by checking the active network interface type in the following order:
    /// - `"cellular"`: If the connection uses a cellular interface (e.g., LTE, 5G).
    /// - `"wifi"`: If the connection uses Wi-Fi.
    /// - `"loopback"`: If the connection is via a loopback interface (typically used for local networking).
    /// - `"wiredEthernet"`: If the connection uses a wired Ethernet interface.
    /// - `"other"`: Returned when none of the known types are detected.
    ///
    /// This property is useful for telemetry, diagnostics, or adapting functionality based on the network type.
    public var connectivityType: String {
        if usesInterfaceType(.cellular) {
            return "cellular"
        }

        if usesInterfaceType(.wifi) {
            return "wifi"
        }

        if usesInterfaceType(.loopback) {
            return "loopback"
        }

        if usesInterfaceType(.wiredEthernet) {
            return "wiredEthernet"
        }

        return "other"
    }
}

extension NWPath.Status: @retroactive CustomDebugStringConvertible {
    /// A textual representation of this instance, suitable for debugging.
    public var debugDescription: String {
        switch self {
        case .requiresConnection:
            return "requiresConnection"

        case .satisfied:
            return "satisfied"

        case .unsatisfied:
            return "unsatisfied"

        @unknown default:
            return "unknown"
        }
    }
}
