//
// Created by TruVideo on 18/06/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import Foundation
import TruvideoSdkFoundation

/// A mock implementation of the `TokenProvider` protocol for testing purposes.
public final class TokenProviderMock: TokenProvider {
    /// The authentication token provided by the mock.
    public var authToken: String?
    
    /// The error provided by the mock.
    public var error: Error?
    
    /// Counts the number of times the `retrieveToken` method has been called.
    public var retrieveTokenCallCount = 0

    /// Initializes a new instance of `TokenProviderMock` with the specified authentication token.
    ///
    /// - Parameter authToken: The authentication token to be provided by the mock.
    public init(authToken: String? = nil) {
        self.authToken = authToken
    }
    
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
