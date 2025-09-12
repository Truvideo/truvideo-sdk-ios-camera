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

    public private(set) var currentToken: AuthToken?

    public init() {}

    public func authenticate(
        apiKey: String,
        context: Context,
        signature: String,
        externalId: String?
    ) async throws {
        authenticateCalled = true
        lastAuthenticateParams = (apiKey, context, signature, externalId)

        if let error = authenticateError {
            throw error
        }

        currentToken = AuthToken(
            id: UUID(),
            accessToken: "mock-access-token",
            refreshToken: "mock-refresh-token"
        )
    }

    public func signOut() throws(Utilities.UtilityError) {
        signOutCalled = true

        if let error = signOutError {
            throw error
        }

        currentToken = nil
    }
}
