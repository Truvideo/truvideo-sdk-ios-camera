//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Network

@testable import Utilities

/// A mock implementation of NetworkPath for testing network connectivity scenarios.
///
/// This struct provides a testable implementation of the NetworkPath protocol
/// that allows developers to simulate different network conditions during
/// testing. It can be configured to represent various network states such
/// as satisfied, unsatisfied, or requiring connection, and different
/// interface types like Wi-Fi, cellular, or Ethernet.
public struct NetworkPathMock: NetworkPath {
    // MARK: - Properties

    /// The simulated network status. Defaults to `.satisfied`.
    public var status: NWPath.Status = .satisfied

    /// The simulated network interface type, such as `.wifi` or `.cellular`. Defaults to `.cellular`.
    public var type: NWInterface.InterfaceType = .cellular

    /// A string description of the connectivity type (e.g., "WiFi", "Cellular").
    public var connectivityType = "Cellular"

    // MARK: - Initializer

    /// Creates a new instance of the `NetworkPathMock`.
    ///
    /// - Parameters:
    ///   - status: The simulated network status. Defaults to `.satisfied`.
    ///   - type: The simulated network interface type, such as `.wifi` or `.cellular`. Defaults to `.cellular`.
    ///   - connectivityType: A string description of the connectivity type (e.g., "WiFi", "Cellular").
    public init(
        status: NWPath.Status,
        type: NWInterface.InterfaceType = .cellular,
        connectivityType: String? = nil
    ) {
        self.status = status
        self.type = type
        self.connectivityType = connectivityType ?? (type == .wifi ? "WiFi" : "Cellular")
    }

    // MARK: - NetworkPath

    /// Checks if the network path uses an interface with the specified type.
    ///
    /// This method checks whether the current network path is using a specific interface type,
    /// such as Wi-Fi, cellular, or wired Ethernet.
    ///
    /// - Parameter type: The `NWInterface.InterfaceType` to check for, such as `.wifi` or `.cellular`.
    /// - Returns: A Boolean value indicating whether the specified interface type is in use (`true` if the interface is
    /// in use, `false` otherwise).
    public func usesInterfaceType(_ type: NWInterface.InterfaceType) -> Bool {
        self.type == type
    }
}
