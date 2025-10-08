//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
import Foundation
internal import InternalUtilities
import Networking
import StorageKit
import Utilities

/// A protocol defining the interface for client authentication with the TruVideo API.
///
/// `AuthenticatableClient` provides a standardized way to authenticate devices and users
/// with the TruVideo API. It handles the authentication process by sending device context
/// information along with cryptographic signatures to verify the client's identity.
///
/// ## Authentication Flow
///
/// 1. **Device Context**: Collect device and system information
/// 2. **Signature Generation**: Create cryptographic signature using secret key
/// 3. **API Request**: Send authentication request with context and signature
/// 4. **Token Storage**: Store received authentication token for future use
/// 5. **API Access**: Use token for subsequent API requests
///
/// ## Security Considerations
///
/// ### API Key Security
///
/// - **Never expose in client code**: API keys should be server-side only
/// - **Use environment variables**: Store keys securely
/// - **Rotate regularly**: Change keys periodically
/// - **Scope appropriately**: Use least-privilege principle
///
/// ### Signature Security
///
/// - **Keep secret keys secure**: Never expose secret keys
/// - **Use strong algorithms**: HMAC-SHA256 or better
/// - **Include all context data**: Sign complete context
/// - **Validate server-side**: Verify signatures on server
///
/// ### Device Context
///
/// - **Accurate information**: Ensure device info is correct
/// - **Timestamp validation**: Check for clock skew
/// - **Context integrity**: Prevent tampering with context data
///
/// - Note: Authentication tokens are automatically stored after successful authentication.
public protocol AuthenticatableClient {
    /// The currently stored authentication session, if any.
    ///
    /// This property provides access to the authentication session that was received
    /// during the most recent successful authentication. The session is automatically
    /// stored after successful authentication and can be used for subsequent API requests.
    var currentSession: AuthSession? { get }

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
    func authenticate(
        apiKey: String,
        context: Context,
        signature: String,
        externalId: String?
    ) async throws(UtilityError)

    /// Signs out the current authenticated session.
    ///
    /// This method clears the stored authentication session from secure storage,
    /// effectively logging out the current user or device. After sign-out, the
    /// `currentToken` property will return `nil`, and any operations requiring
    /// authentication must perform a new login.
    ///
    /// - Throws: An error if the session cannot be deleted from storage.
    func signOut() throws(UtilityError)
}

/// Default implementation providing convenience methods for authentication.
///
/// This extension provides a default implementation that makes the `externalId` parameter
/// optional with a default value of `nil`, simplifying the authentication process for
/// single-tenant applications.
extension AuthenticatableClient {
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
    /// - Throws: An error if the authentication process fails.
    public func authenticate(
        apiKey: String,
        context: Context,
        signature: String
    ) async throws(UtilityError) {
        try await authenticate(apiKey: apiKey, context: context, signature: signature, externalId: nil)
    }
}

/// A client responsible for handling authentication with the TruVideo API.
///
/// `AuthenticationClient` provides a complete authentication solution for the TruVideo Api,
/// managing the authentication flow, token storage, and session management. It conforms to
/// `AuthenticatableClient` to provide a standardized interface for authentication operations.
public final class AuthenticationClient: AuthenticatableClient {
    // MARK: - Dependencies

    @Dependency(\.environment)
    private var environment: Environment

    @Dependency(\.sessionManager)
    private var sessionManager: any SessionManager

    // MARK: - Properties

    let session: Session

    // MARK: - Computed Properties

    /// The currently stored authentication session, if any.
    ///
    /// This property provides access to the authentication session that was received
    /// during the most recent successful authentication. The session is automatically
    /// stored after successful authentication and can be used for subsequent API requests.
    public var currentSession: AuthSession? {
        sessionManager.currentSession
    }

    // MARK: - Initializer

    /// Creates an authentication client with a custom session for network communication.
    ///
    /// This designated initializer allows you to provide a custom `Session` implementation
    /// for network communication. This is useful for testing, custom network configurations,
    /// or when you need specific session behavior that differs from the default.
    ///
    /// - Parameter session: The session implementation to use for network communication.
    init(session: any Session) {
        self.session = session
    }

    /// Creates an authentication client with default HTTP session configuration.
    ///
    /// This convenience initializer creates an `AuthenticationClient` instance
    /// using a default `HTTPURLSession` for network communication. It provides
    /// a simple way to create an authentication client without needing to
    /// configure a custom session.
    public convenience init() {
        self.init(session: HTTPURLSession(monitors: [SessionMonitor()]))
    }

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
        context: Context,
        signature: String,
        externalId: String?
    ) async throws(UtilityError) {
        do {
            var headers: HTTPHeaders = [
                "x-authentication-api-key": apiKey,
                "x-authentication-signature": signature,
            ]

            if let externalId, !externalId.isEmpty {
                headers["x-multitenant-external-id"] = externalId
            }

            if let deviceId = currentSession?.authToken.id {
                headers["x-authentication-device-id"] = deviceId.uuidString
            }

            let authToken = try await session.request(
                environment.baseURL.appending("/api/device"),
                method: .post,
                parameters: [
                    "brand": context.brand,
                    "model": context.model,
                    "os": context.os,
                    "osVersion": context.osVersion,
                    "timestamp": context.timestamp,
                ],
                encoder: .json,
                headers: headers
            )
            .validate(RequestValidator.validate)
            .serializing(AuthToken.self)
            .result
            .get()

            let authSession = AuthSession(apiKey: apiKey, authToken: authToken)
            try sessionManager.set(authSession)
        } catch {
            throw error.asUtilityError(or: .TruVideoApiErrorReason.authenticationFailed)
        }
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
        do {
            try sessionManager.deleteCurrentSession()
        } catch {
            throw error.asUtilityError(or: .TruVideoApiErrorReason.signOutFailed)
        }
    }
}
