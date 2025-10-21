//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A caching policy that defines how network requests should interact with local cache data.
///
/// The `URLCachePolicy` enum provides different strategies for fetching data while considering cache behavior.
/// It allows control over whether a request should ignore cached data, use cached data if available, or avoid fetching
/// new data.
public enum URLCachePolicy: Sendable {
    /// Always fetches new data from the network, ignoring any locally cached data.
    case reloadIgnoringLocalCacheData

    /// Uses cached data if available; otherwise, does not fetch new data from the network.
    case returnCacheDataDontLoad

    /// Uses cached data if available; otherwise, fetches new data from the network.
    case returnCacheDataElseLoad
}
