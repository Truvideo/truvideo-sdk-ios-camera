//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
import Foundation
internal import InternalUtilities
import Networking
import Utilities

/// A protocol that defines the contract for refreshing authentication tokens.
///
/// `TokenRefresher` provides a standardized interface for refreshing expired authentication
/// tokens. It handles the token exchange process by using the current refresh token to
/// obtain a new access token from the authentication server.
///
/// ## Purpose
///
/// Token refresh is a critical security mechanism that allows applications to maintain
/// continuous authentication without requiring users to re-authenticate. When an access
/// token expires, the refresh token can be used to obtain a new valid access token.
///
/// ## Implementation Requirements
///
/// Implementations should:
/// - Use the current refresh token to request a new access token
/// - Handle network errors and authentication failures gracefully
/// - Update the stored session with the new token upon successful refresh
/// - Ensure thread safety for concurrent refresh operations
///
/// ## Example Usage
///
/// ```swift
/// // Refresh the current authentication token
/// do {
///     try await tokenRefresher.refreshToken()
///     // Token has been successfully refreshed
/// } catch {
///     // Handle refresh failure - may require re-authentication
///     try await authenticate()
/// }
///
/// // Use in authentication flow
/// if let session = sessionManager.currentSession,
///    session.authToken.isExpired {
///     try await tokenRefresher.refreshToken()
/// }
/// ```
public protocol TokenRefresher: Sendable {
    /// Refreshes the current authentication token using the stored refresh token.
    ///
    /// This method exchanges the current refresh token for a new access token and
    /// updates the stored authentication session. The refresh process involves
    /// making a network request to the authentication server with the refresh token.
    ///
    /// - Throws: An error if the token refresh fails, including network errors, authentication failures, or missing
    /// session data
    func refreshToken() async throws
}

/// A concrete implementation of the TokenRefresher protocol that handles authentication token refresh.
///
/// `SessionTokenRefresher` provides a complete implementation for refreshing expired authentication
/// tokens using network requests. It integrates with the dependency injection system to access
/// environment configuration and session management, and uses an actor to ensure thread-safe
/// token refresh operations.
public actor SessionTokenRefresher: TokenRefresher {
    // MARK: - Private methods

    private let onSessionRenewed: (AuthSession) -> Void

    // MARK: - Dependencies

    @Dependency(\.environment)
    private var environment: Environment

    @Dependency(\.sessionManager)
    private var sessionManager: any SessionManager

    // MARK: - Properties

    let session: any Session

    // MARK: - Initializer

    /// Creates a new token refresher with the specified session.
    ///
    /// This initializer allows you to configure the token refresher with a custom network session.
    /// If no session is provided, it defaults to an `HTTPURLSession` with a `SessionMonitor`
    /// for tracking network operations.
    ///
    /// - Parameters:
    ///    - session: The network session to use for token refresh requests. Defaults to a monitored HTTP session.
    ///    - onSessionRenewed: A callback closure that will be called when the authentication session
    ///                        is successfully renewed. This allows you to perform additional actions such as updating
    ///                        UI state, logging events, or triggering other authentication-dependent operations.
    public init(
        session: any Session = HTTPURLSession(monitors: [SessionMonitor()]),
        onSessionRenewed: @escaping (AuthSession) -> Void = { _ in }
    ) {
        self.onSessionRenewed = onSessionRenewed
        self.session = session
    }

    // MARK: - TokenRefresher

    /// Refreshes the current authentication token using the stored refresh token.
    ///
    /// This method exchanges the current refresh token for a new access token and
    /// updates the stored authentication session. The refresh process involves
    /// making a network request to the authentication server with the refresh token.
    ///
    /// - Throws: An error if the token refresh fails, including network errors, authentication failures, or missing
    /// session data
    public func refreshToken() async throws {
        guard let authSession = sessionManager.currentSession else {
            throw UtilityError(
                kind: .TruVideoApiErrorReason.refreshTokenFailed,
                failureReason: "No authentication token available for refresh"
            )
        }

        do {
            let authToken = authSession.authToken
            var headers = HTTPHeaders(array: [.bearerToken(authToken.refreshToken)])
            let url = environment.baseURL.appending("/api/authenticate/exchange")

            headers.append(HTTPHeader(name: "x-authentication-api-key", value: authSession.apiKey))
            headers.append(HTTPHeader(name: "x-authentication-device-id", value: authToken.id.uuidString))

            let newToken = try await session.request(url, method: .post, headers: headers)
                .validate(RequestValidator.validate)
                .serializing(AuthToken.self)
                .result
                .get()

            let newSession = AuthSession(apiKey: authSession.apiKey, authToken: newToken)
            try sessionManager.set(newSession)

            onSessionRenewed(newSession)
        } catch {
            throw UtilityError(kind: .TruVideoApiErrorReason.refreshTokenFailed, underlyingError: error)
        }
    }
}
