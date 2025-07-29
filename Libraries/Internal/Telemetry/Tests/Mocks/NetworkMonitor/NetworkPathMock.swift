//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Network

@testable import Telemetry

struct NetworkPathMock: NetworkPath {
    // MARK: - Properties
    
    var status: NWPath.Status = .satisfied
    var type: NWInterface.InterfaceType = .cellular
    
    // MARK: - NetworkPath

    /// Checks if the network path uses an interface with the specified type.
    ///
    /// This method checks whether the current network path is using a specific interface type,
    /// such as Wi-Fi, cellular, or wired Ethernet.
    ///
    /// - Parameter type: The `NWInterface.InterfaceType` to check for, such as `.wifi` or `.cellular`.
    /// - Returns: A Boolean value indicating whether the specified interface type is in use (`true` if the interface is in use, `false` otherwise).
    func usesInterfaceType(_ type: NWInterface.InterfaceType) -> Bool {
        self.type == type
    }
}
