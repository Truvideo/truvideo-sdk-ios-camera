//
//  TokenProvider.swift
//
//  Created by TruVideo on 8/08/23.
//  Copyright © TruVideo. All rights reserved.
//

import Foundation

/// Provides an abstraction for access token retrieval.
public protocol TokenProvider {
    /// Fetches the current access token available in the session
    /// returns null when no session is active at the moment
    ///
    /// - Returns: The existing auth token otherwise nil.
    func retrieveToken() async -> AuthToken?
    
    /// Stores the given token.
    ///
    /// - Parameter authToken: The token to be stored.
    /// - Throws: An exception if something fails.
    func save(_ authToken: AuthToken) async throws
}
