//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// Provides an abstraction for access token retrieval.
public protocol TokenProvider: Sendable {
    /// Send a request to the provider to refresh the token.
    ///
    /// - Returns: A new auth token otherwise nil.
    func refreshToken() async throws -> String

    /// Fetches the current access token available in the session
    /// returns null when no session is active at the moment
    ///
    /// - Returns: The existing auth token otherwise nil.
    func retrieveToken() async throws -> String?
}
