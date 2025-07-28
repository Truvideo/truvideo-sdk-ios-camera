//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
import Foundation
import Storage

/// Represents an authenticated session with API credentials and authentication token.
///
/// This struct encapsulates the data required for an authenticated session,
/// including the API key for service identification and the authentication
/// token for API access authorization.
struct AuthSession: Codable {
    /// The API key that identifies the application or service.
    ///
    /// This key is used to authenticate requests to the TruVideo API
    /// and identify the source of the authentication request.
    let apiKey: String

    /// The authentication token containing access and refresh tokens.
    ///
    /// This token provides the necessary credentials for API access
    /// and includes both the access token for immediate use and the
    /// refresh token for token renewal.
    let authToken: AuthToken
}

/// A protocol that defines the interface for managing authentication sessions.
///
/// This protocol provides a centralized way to store and retrieve authentication sessions
/// across the application. It ensures thread-safe access to session data and provides
/// a consistent interface for session management operations.
protocol SessionManager: Sendable {
    /// The currently stored authentication session, if any.
    ///
    /// This property provides access to the authentication session that was most recently
    /// stored. Returns `nil` if no session has been stored or if the session has been cleared.
    var currentSession: AuthSession? { get }

    /// Stores the provided authentication session.
    ///
    /// This method persists the authentication session for future use. The session
    /// will be available through the `currentSession` property until it is replaced
    /// or cleared.
    ///
    /// - Parameter session: The authentication session to store
    /// - Throws: An error if the session cannot be stored
    func set(_ session: AuthSession) throws
}

final class SessionManagerImpl: SessionManager, @unchecked Sendable {
    // MARK: - Dependencies

    @Dependency(\.apiEnvironment)
    private var environment: Environment

    // MARK: - Properties

    lazy var storage: any Storage = {
        KeychainStorage(url: environment.baseURL)
    }()

    // MARK: - Computed Properties

    var currentSession: AuthSession? {
        try? storage.readValue(for: AuthSessionStorageKey.self)
    }

    // MARK: - Types

    /// A storage key for managing `Session` dependencies in the dependency injection system.
    ///
    /// `AuthSessionStorageKey` provides a type-safe way to store and retrieve `AuthSession`
    /// instances within the dependency injection container. This key is used to manage authentication
    /// tokens across the application lifecycle, ensuring consistent access to authentication state
    struct AuthSessionStorageKey: StorageKey {
        /// The associated value type that will be stored and retrieved using this key.
        ///
        /// This typealias defines that this storage key manages `AuthSession` instances.
        /// The storage system uses this type information to ensure type safety
        /// when storing and retrieving authentication tokens.
        typealias Value = AuthSession
    }

    // MARK: - SessionManager

    func set(_ session: AuthSession) throws {
        try storage.write(session, forKey: AuthSessionStorageKey.self)
    }
}
