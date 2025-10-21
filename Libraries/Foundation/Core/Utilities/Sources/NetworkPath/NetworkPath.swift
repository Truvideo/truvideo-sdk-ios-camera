//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Network

/// A protocol that abstracts the functionality of checking network interface types in a network path.
///
/// The `NetworkPath` protocol provides a way to check whether a network path is using a specific interface type,
/// such as Wi-Fi, cellular, or wired Ethernet. Implementing types should provide logic to determine if a particular
/// interface type is being used in the current network path.
///
/// This protocol is useful for detecting and responding to changes in the type of network connection.
public protocol NetworkPath: Sendable {
    /// Returns the current network connectivity type as a string representation.
    var connectivityType: String { get }

    /// An NWPath status indicates if there is a usable route available upon which to send and receive data.
    var status: NWPath.Status { get }

    /// Checks if the network path uses an interface with the specified type.
    ///
    /// This method checks whether the current network path is using a specific interface type,
    /// such as Wi-Fi, cellular, or wired Ethernet.
    ///
    /// - Parameter type: The `NWInterface.InterfaceType` to check for, such as `.wifi` or `.cellular`.
    /// - Returns: A Boolean value indicating whether the specified interface type is in use (`true` if the interface is
    /// in use, `false` otherwise).
    func usesInterfaceType(_ type: NWInterface.InterfaceType) -> Bool
}
