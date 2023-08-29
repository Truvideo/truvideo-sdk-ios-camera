//
//  TokenProviderMock.swift
//
//  Created by TruVideo on 8/08/23.
//  Copyright © TruVideo. All rights reserved.
//

import Foundation

@testable import Core

final class TokenProviderMock: TokenProvider {
    var authToken: AuthToken?
    var error: Error?
    var refreshTokenCallCount = 0
    var retrieveTokenCallCount = 0

    // MARK: TokenProvider

    /// Send a request to the provider to refresh the token
    func refreshToken() async throws -> AuthToken {
        refreshTokenCallCount += 1
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        authToken = AuthToken(id: "xyz", accessToken: "1234-5678", refreshToken: "refreshToken")

        return authToken!
    }

    /// Fetches the current access token available in the session
    /// returns null when no session is active at the moment
    ///
    /// - Returns: The existing auth token otherwise nil.
    func retrieveToken() async -> AuthToken? {
        retrieveTokenCallCount += 1
        
        guard let _ = error else {
            return authToken
        }

        return nil
    }
    
    /// Fetches the current access token available in the session
    /// returns null when no session is active at the moment
    ///
    /// - Returns: The existing auth token otherwise nil.
    func save(_ authToken: Core.AuthToken) async throws {
        
    }
}
