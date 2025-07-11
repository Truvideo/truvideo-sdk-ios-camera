//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

@testable import CommonUtilities

/// A mock implementation of the `TokenProvider` protocol for testing purposes.
public final class TokenProviderMock: TokenProvider {
    /// The authentication token provided by the mock.
    public var authToken: String?
    
    /// The error provided by the mock.
    public var error: Error?
    
    /// Counts the number of times the `retrieveToken` method has been called.
    public var retrieveTokenCallCount = 0
    
    // MARK: - Initializer

    /// Initializes a new instance of `TokenProviderMock` with the specified authentication token.
    ///
    /// - Parameter authToken: The authentication token to be provided by the mock.
    public init(authToken: String? = nil) {
        self.authToken = authToken
    }
    
    // MARK: - TokenProvider
    
    /// Simulates the retrieval of the authentication token.
    ///
    /// - Returns: The authentication token if no error is set, otherwise `nil`.
    public func retrieveToken() -> String? {
        retrieveTokenCallCount += 1
        guard error == nil else {
            return nil
        }
        return authToken
    }
}
