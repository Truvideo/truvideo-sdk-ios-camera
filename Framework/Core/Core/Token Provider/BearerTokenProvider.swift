//
//  BearerTokenProvider.swift
//
//  Created by TruVideo on 8/08/23.
//  Copyright © TruVideo. All rights reserved.
//

import Foundation

/// A contrete implementation of the `TokenProvider`  in charge of storing, retrieving and refreshing
/// the existing access token.
public actor BearerTokenProvider: TokenProvider {
    private let storage: Storage
    private var task: Task<AuthToken, Error>?
    
    private static var authTokenKey = "org.tru-video.auth-token"
    
    // MARK: Initializers
    
    /// Creates a new instance of the `BearerTokenProvider`.
    ///
    /// - Parameter storage: The key/value pair storage to use.
    public init(storage: Storage = KeychainStorage(accessGroup: Bundle.main.bundleIdentifier ?? "")) {
        self.storage = storage
    }
    
    // MARK: TokenProvider

    /// Fetches the current access token available in the session
    /// returns null when no session is active at the moment
    ///
    /// - Returns: The existing auth token otherwise nil.
    public func retrieveToken() async -> AuthToken? {
        do {
            return try storage.readValue(AuthToken.self, forKey: Self.authTokenKey)
        } catch {
            return nil
        }
    }
    
    /// Stores the given token.
    ///
    /// - Parameter authToken: The token to be stored.
    /// - Throws: An exception if something fails.
    public func save(_ authToken: AuthToken) async throws {
        try storage.write(authToken, forKey: Self.authTokenKey) // TODO: FIX ME! need entitlements
    }
}
