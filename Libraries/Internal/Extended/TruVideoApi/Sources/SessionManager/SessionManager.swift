//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
import Foundation
internal import InternalUtilities
internal import StorageKit

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

/// A secure, environment-aware implementation of the `SessionManager` protocol.
///
/// `SecureSessionManager` provides encrypted storage and retrieval of authentication sessions
/// using AES-GCM encryption. It leverages the dependency injection system for environment
/// configuration and isolates session data per environment to prevent cross-environment
/// session leakage.
///
/// ## Overview
///
/// This implementation combines multiple security layers:
/// - **AES-GCM Encryption**: All sessions are encrypted before storage using AES-GCM
///   (Galois/Counter Mode), which provides both confidentiality and authentication
/// - **Environment Isolation**: Sessions are stored in separate UserDefaults suites
///   based on the environment's base URL, preventing session mixing across environments
/// - **Type Safety**: Strongly-typed storage keys ensure compile-time safety
///
/// ## Architecture
///
/// The session manager uses a lazy-initialized storage backend that adapts to the
/// current environment. This allows the same manager instance to work across different
/// API environments (dev, staging, production) while maintaining proper data isolation.
///
/// ## Security Considerations
///
/// While sessions are encrypted using AES-GCM, they are stored in UserDefaults rather
/// than the Keychain. This provides a balance between security and accessibility for
/// session data that needs to be accessed frequently. For highly sensitive credentials,
/// consider using KeychainStorage directly.
///
/// ## Example Usage
///
/// ```swift
/// let sessionManager = SecureSessionManager()
///
/// // Store a new authentication session
/// let token = AuthToken(accessToken: "abc123", refreshToken: "xyz789")
/// let session = AuthSession(apiKey: "my-api-key", authToken: token)
/// try sessionManager.set(session)
///
/// // Retrieve the current session
/// if let currentSession = sessionManager.currentSession {
///     print("Logged in with API key: \(currentSession.apiKey)")
///     // Use session.authToken for authenticated requests
/// }
///
/// // Clear the session (logout)
/// try sessionManager.deleteCurrentSession()
/// ```
///
/// ## Thread Safety
///
/// This class is marked as `@unchecked Sendable` because it uses lazy initialization
/// for its storage property. Ensure that the storage is fully initialized before
/// concurrent access occurs. The underlying `UserDefaultsStorage` and `AESCrypto`
/// are designed to be thread-safe.
///
/// - Note: Session retrieval through `currentSession` never throws. If decryption
///   or storage access fails, it returns `nil` rather than propagating errors.
public final class SecureSessionManager: SessionManager, @unchecked Sendable {
    // MARK: - Private Properties

    private let crypto: Crypto

    // MARK: - Dependencies

    @Dependency(\.environment)
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
    lazy var storage: any Storage =
        UserDefaultsStorage(userDefaults: UserDefaults(suiteName: environment.baseURL) ?? .standard)

    // MARK: - Computed Properties

    /// The currently stored authentication session, if any.
    ///
    /// This computed property attempts to read the current authentication session from
    /// secure storage. If no session exists or if reading fails, it returns `nil`.
    /// This provides a safe way to access the current session without throwing errors.
    ///
    /// - Returns: The current authentication session, or `nil` if none exists
    public var currentSession: AuthSession? {
        do {
            guard let data = try storage.readValue(for: AuthSessionStorageKey.self) else {
                return nil
            }

            return try crypto.decrypt(AuthSession.self, from: data) as AuthSession
        } catch {
            return nil
        }
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
        typealias Value = Data
    }

    // MARK: - Initializers

    /// Creates a session manager with a custom cryptographic implementation.
    ///
    /// This designated initializer allows dependency injection of a custom `Crypto`
    /// implementation, primarily used for testing or when you need to provide a
    /// specific encryption strategy.
    ///
    /// For production use, prefer the `init(secretKey:)` convenience initializer which
    /// uses the default AES-GCM encryption.
    ///
    /// - Parameter crypto: The cryptographic implementation to use for encrypting
    ///   and decrypting session data.
    init(crypto: Crypto) {
        self.crypto = crypto
    }

    /// Creates a session manager with AES-GCM encryption using the specified secret key.
    ///
    /// This is the recommended initializer for production use. It automatically configures
    /// AES-GCM encryption using a key derived from the provided secret string via SHA-256 hashing.
    ///
    /// The secret key is transformed into a 256-bit encryption key, providing strong
    /// cryptographic protection for stored sessions. The same secret key must be used
    /// to decrypt sessions later, so ensure it remains consistent across app launches.
    ///
    /// - Parameter secretKey: A string used to derive the encryption key. This should be
    ///   a strong, randomly-generated secret. An empty string is acceptable but provides
    ///   minimal security and should only be used for development or testing.
    public convenience init(secretKey: String) {
        let crypto = AESCrypto(secretKey: secretKey)

        self.init(crypto: crypto)
    }

    // MARK: - SessionManager

    /// Deletes the currently stored authentication session.
    ///
    /// This method removes the authentication session from secure storage, effectively
    /// logging out the current user. After deletion, the `currentSession` property
    /// will return `nil`, and any operations requiring authentication will need to re-authenticate.
    ///
    /// - Throws: A storage error if the session cannot be deleted from storage
    public func deleteCurrentSession() throws {
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
    public func set(_ session: AuthSession) throws {
        let data = try crypto.encrypt(session)
        try storage.write(data, forKey: AuthSessionStorageKey.self)
    }
}
