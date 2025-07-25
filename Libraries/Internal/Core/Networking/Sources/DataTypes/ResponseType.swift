//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// An enumeration representing the source of a response in a networking operation.
///
/// `ResponseType` is used to distinguish whether a response was retrieved from a local cache
/// or fetched from the network.
public enum ResponseType: Sendable {
    /// Indicates that the response was served from a local cache.
    case localCache

    /// Indicates that the response was fetched from the network.
    case networkLoad
}
