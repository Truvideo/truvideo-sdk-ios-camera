//
// Copyright © 2025 TruVideo. All rights reserved.
//

internal import DI
import Foundation
internal import InternalUtilities
internal import StorageKit
internal import TruVideoApi
internal import Utilities

/// A protocol that defines the interface for performing data migrations.
///
/// The `Migrator` protocol provides a standardized way to implement data migration
/// functionality across different parts of the application. It defines a single
/// method that handles the migration process, ensuring consistent error handling
/// and a uniform approach to data transformation operations.
protocol Migrator {
    /// Performs the migration operation.
    ///
    /// This method executes the migration logic for the conforming type.
    /// The implementation should handle all necessary data transformation,
    /// validation, and error handling specific to the migration being performed.
    ///
    /// - Throws: Various errors depending on the specific migration implementation
    func migrate() throws
}

/// A migrator that handles the transition from legacy storage to the new storage system.
///
/// The `SDKMigrator` class manages the migration of authentication data from the legacy
/// UserDefaults-based storage to the new unified storage system. It handles the conversion
/// of stored API keys and authentication tokens into the new `AuthSession` format,
/// ensuring a smooth transition between storage implementations.
///
/// The migrator performs a one-time migration process that reads legacy data,
/// converts it to the new format, and marks the migration as completed to prevent
/// duplicate migrations on subsequent runs.
struct SDKMigrator: Migrator {
    // MARK: - Private Properties

    private let legacyStorage: UserDefaults
    private let storage: Storage

    // MARK: - Types

    /// A storage key for managing migration state in the storage system.
    ///
    /// The `MigrationStorageKey` struct implements the `StorageKey` protocol to provide
    /// a type-safe way to store and retrieve migration state information. It defines
    /// the associated value type as `Bool`, allowing the storage system to manage
    /// boolean values that indicate whether specific migrations have been completed.
    struct MigrationStorageKey: StorageKey {
        /// The associated value type that will be stored and retrieved using this key.
        ///
        /// This typealias defines that this storage key manages `Boolean` instances.
        /// The storage system uses this type information to ensure type safety
        /// when storing and retrieving authentication tokens.
        typealias Value = Bool
    }

    // MARK: - Initializer

    /// Creates a new migrator instance with optional custom storage and legacy storage.
    ///
    /// This initializer sets up the migrator with both legacy and new storage systems.
    /// It provides flexibility to inject custom storage implementations for testing
    /// or specific use cases, while maintaining sensible defaults for production use.
    /// The migrator uses the current API environment to determine the appropriate
    /// storage suite and falls back to standard UserDefaults when custom storage
    /// is not provided.
    ///
    /// - Parameters:
    ///   - storage: Optional custom storage instance for the new storage system.
    ///   - legacyStorage: Optional custom UserDefaults instance for legacy data.
    init(
        storage: Storage = UserDefaultsStorage(),
        legacyStorage: UserDefaults = UserDefaults(suiteName: "truvideo-sdk-common-settings") ?? .standard
    ) {
        self.legacyStorage = legacyStorage
        self.storage = storage
    }

    // MARK: - Migrator

    /// Performs the migration from legacy storage to the new storage system.
    ///
    /// This method reads authentication data from the legacy storage system,
    /// converts it to the new `AuthSession` format, and stores it in the new
    /// storage system. The migration is performed only once, as indicated by
    /// the migration state flag.
    ///
    /// - Throws: An error if migration fails or legacy data is invalid
    func migrate() throws {
        let hasBeenMigrated = try storage.readValue(for: MigrationStorageKey.self) ?? false

        guard !hasBeenMigrated else {
            return
        }

        if
            /// The stored api key used for authentication.
            let apiKey = legacyStorage.string(forKey: "truvideo-sdk-api-key"),

            /// The stored authentication token.
            let rawToken = legacyStorage.string(forKey: "truvideo-sdk-authentication")?.data(using: .utf8) {
            if let authenticationDictionary = try JSONSerialization.jsonObject(with: rawToken) as? [String: Any] {
                let jsonDictionary: [String: Any] = [
                    "apiKey": apiKey,
                    "authToken": authenticationDictionary
                ]

                let rawSession = try JSONSerialization.data(withJSONObject: jsonDictionary)
                let authSession = try JSONDecoder().decode(AuthSession.self, from: rawSession)

                try DependencyValues.current.sessionManager.set(authSession)
                try storage.write(true, forKey: MigrationStorageKey.self)
            } else {
                throw UtilityError(kind: .unknown, failureReason: "Unable to perform the migration.")
            }
        }
    }
}
