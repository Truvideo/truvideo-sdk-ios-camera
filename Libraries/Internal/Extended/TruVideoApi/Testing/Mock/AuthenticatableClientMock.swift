//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Utilities

@testable import TruVideoApi

/// Mock implementation of `AuthenticatableClient` for use in unit tests.
public final class AuthenticatableClientMock: AuthenticatableClient {
    // MARK: - Properties

    /// Records whether `authenticate(apiKey:context:signature:externalId:)` was called.
    public private(set) var authenticateCalled = false

    /// Error to throw from `authenticate`, if set.
    public var authenticateError: UtilityError?

    /// The currently stored authentication session, if any.
    public var currentSession: TruVideoApi.AuthSession?

    /// Captures the parameters passed to `authenticate(...)`.
    public private(set) var lastAuthenticateParams:
        (
            apiKey: String,
            context: Context,
            signature: String,
            externalId: String?
        )?

    /// Records whether `signOut()` was called.
    public private(set) var signOutCalled = false

    /// Error to throw from `signOut()`, if set.
    public var signOutError: UtilityError?

    // MARK: - AuthenticatableClient

    /// The currently stored authentication session, if any.
    public var currentSession: AuthSession?

    // MARK: - Initializer

    /// Creates a new instance of the `AuthenticatableClientMock`.
    public init() {}

    // MARK: - AuthenticatableClient

    /// Authenticates the client with the TruVideo API.
    ///
    /// This method performs device authentication by sending device context information
    /// along with a cryptographic signature to verify the client's identity. Upon successful
    /// authentication, an access token is received and stored for future API requests.
    ///
    /// - Parameters:
    ///    - apiKey: The API key that identifies your application
    ///    - context: Device and system information for authentication
    ///    - signature: Cryptographic signature of the context data
    ///    - externalId: Optional identifier for multi-tenant scenarios
    /// - Throws: An error if the authentication process fails.
    public func authenticate(
        apiKey: String,
        context: TruVideoApi.Context,
        signature: String,
        externalId: String?
    ) async throws(UtilityError) {
        authenticateCalled = true
        lastAuthenticateParams = (apiKey, context, signature, externalId)

        if let authenticateError {
            throw authenticateError
        }

        currentSession = AuthSession(
            apiKey: "apiKey",
            authToken: AuthToken(
                id: UUID(),
                accessToken: "mock-access-token",
                refreshToken: "mock-refresh-token"
            )
        )
    }

    /// Signs out the current authenticated session.
    ///
    /// This method clears the stored authentication session from secure storage,
    /// effectively logging out the current user or device. After sign-out, the
    /// `currentToken` property will return `nil`, and any operations requiring
    /// authentication must perform a new login.
    ///
    /// - Throws: An error if the session cannot be deleted from storage.
    public func signOut() throws(UtilityError) {
        signOutCalled = true

        if let signOutError {
            throw UtilityError(kind: .unknown, underlyingError: signOutError)
        }

        currentSession = nil
    }
}
