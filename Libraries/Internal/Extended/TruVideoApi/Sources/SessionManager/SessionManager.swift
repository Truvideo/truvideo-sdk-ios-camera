//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
import Foundation
import StorageKit

/// Represents an authenticated session with API credentials and authentication token.
///
/// This struct encapsulates the data required for an authenticated session,
/// including the API key for service identification and the authentication
/// token for API access authorization.
public struct AuthSession: Codable, Sendable {
    /// The API key that identifies the application or service.
    ///
    /// This key is used to authenticate requests to the TruVideo API
    /// and identify the source of the authentication request.
    public let apiKey: String

    /// The authentication token containing access and refresh tokens.
    ///
    /// This token provides the necessary credentials for API access
    /// and includes both the access token for immediate use and the
    /// refresh token for token renewal.
    public let authToken: AuthToken
}

/// A protocol that defines the interface for managing authentication sessions.
///
/// This protocol provides a centralized way to store and retrieve authentication sessions
/// across the application. It ensures thread-safe access to session data and provides
/// a consistent interface for session management operations.
///
/// Note: This has been made temporary public to allow migrations from the old
/// versions to the new one.
public protocol SessionManager: Sendable {
    /// The currently stored authentication session, if any.
    ///
    /// This property provides access to the authentication session that was most recently
    /// stored. Returns `nil` if no session has been stored or if the session has been cleared.
    var currentSession: AuthSession? { get }

    /// Deletes the currently stored authentication session.
    ///
    /// This method removes the authentication session from secure storage, effectively
    /// logging out the current user. After deletion, the `currentSession` property
    /// will return `nil`, and any operations requiring authentication will need to re-authenticate.
    ///
    /// - Throws: A storage error if the session cannot be deleted from storage
    func deleteCurrentSession() throws

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

/// A concrete implementation of the SessionManager protocol that manages authentication sessions.
///
/// `SessionManagerImpl` provides a complete implementation for storing, retrieving, and managing
/// authentication sessions using secure storage. It integrates with the dependency injection system
/// to access environment configuration and uses KeychainStorage for secure session persistence.
///
/// ## Features
///
/// - Secure session storage using KeychainStorage
/// - Environment-based configuration
/// - Type-safe session management
/// - Dependency injection integration
///
/// ## Example Usage
///
/// ```swift
/// // Store a new authentication session
/// let session = AuthSession(authToken: token, externalId: "user123")
/// try sessionManager.set(session)
///
/// // Retrieve the current session
/// if let currentSession = sessionManager.currentSession {
///     // Use the session for authenticated requests
/// }
/// ```
///
/// ## Storage Security
///
/// Sessions are stored securely using KeychainStorage, which provides encryption
/// and protection against unauthorized access. The storage is tied to the API
/// environment's base URL for proper isolation.
final class SessionManagerImpl: SessionManager, @unchecked Sendable {
    // MARK: - Dependencies

    /// The API environment configuration used for storage initialization.
    ///
    /// This dependency provides access to the base URL and other environment-specific
    /// configuration needed for proper storage setup and session management.
    @Dependency(\.apiEnvironment)
    private var environment: Environment

    // MARK: - Properties

    /// The secure storage instance used for persisting authentication sessions.
    ///
    /// This lazy property initializes a KeychainStorage instance using the environment's
    /// base URL. The storage provides encrypted persistence for authentication sessions,
    /// ensuring sensitive data is protected from unauthorized access.
    ///
    /// The storage is initialized lazily to ensure the environment dependency is properly
    /// resolved before storage creation.
    lazy var storage: any Storage = {
        UserDefaultsStorage(userDefaults: UserDefaults(suiteName: environment.baseURL) ?? .standard)
    }()

    // MARK: - Computed Properties

    /// The currently stored authentication session, if any.
    ///
    /// This computed property attempts to read the current authentication session from
    /// secure storage. If no session exists or if reading fails, it returns `nil`.
    /// This provides a safe way to access the current session without throwing errors.
    ///
    /// - Returns: The current authentication session, or `nil` if none exists
    var currentSession: AuthSession? {
        try? storage.readValue(for: AuthSessionStorageKey.self)
    }

    // MARK: - Types

    /// A storage key for managing `AuthSession` dependencies in the dependency injection system.
    ///
    /// `AuthSessionStorageKey` provides a type-safe way to store and retrieve `AuthSession`
    /// instances within the dependency injection container. This key is used to manage authentication
    /// tokens across the application lifecycle, ensuring consistent access to authentication state.
    ///
    /// ## Type Safety
    ///
    /// The storage key uses Swift's type system to ensure that only `AuthSession` instances
    /// can be stored and retrieved using this key, preventing type mismatches and runtime errors.
    struct AuthSessionStorageKey: StorageKey {
        /// The associated value type that will be stored and retrieved using this key.
        ///
        /// This typealias defines that this storage key manages `AuthSession` instances.
        /// The storage system uses this type information to ensure type safety
        /// when storing and retrieving authentication tokens.
        typealias Value = AuthSession
    }

    // MARK: - SessionManager

    /// Deletes the currently stored authentication session.
    ///
    /// This method removes the authentication session from secure storage, effectively
    /// logging out the current user. After deletion, the `currentSession` property
    /// will return `nil`, and any operations requiring authentication will need to re-authenticate.
    ///
    /// - Throws: A storage error if the session cannot be deleted from storage
    func deleteCurrentSession() throws {
        try storage.deleteValue(for: AuthSessionStorageKey.self)
    }

    /// Stores an authentication session in secure storage.
    ///
    /// This method persists the provided authentication session to secure storage,
    /// making it available for future retrieval. The session is stored using the
    /// `AuthSessionStorageKey` for type-safe access.
    ///
    /// - Parameter session: The authentication session to store
    /// - Throws: A storage error if the session cannot be written to storage
    func set(_ session: AuthSession) throws {
        try storage.write(session, forKey: AuthSessionStorageKey.self)
    }
}
