//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import KeychainAccess

/// A Secure Storage client which implements the base `Storage` interface.
/// `KeychainStorage` uses `Keychain` internally.
///
/// Create a `KeychainStorage` instance.
/// let storage = KeychainStorage();
///
/// Write a key/value pair.
/// storage.write("my_value",  forKey: "my_key")
///
/// Read value for key.
/// let value = storage.read(key:  "mykey")
public struct KeychainStorage: Storage {
    // MARK: - Private Properties

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let keychain: KeychainProtocol

    // MARK: - Initializers

    /// Creates a new instance of this `KeychainStorage`.
    ///
    /// - Parameter keychain: The underliying keychain storage.
    init(keychain: KeychainProtocol) {
        self.keychain = keychain
    }

    /// Creates a new instance of this `KeychainStorage` class.
    public init() {
        self.keychain = Keychain()
    }

    /// Creates a new instance of this `KeychainStorage` class.
    ///
    /// - Parameter accessGroup: The name of the logical collection of apps sharig this group.
    public init(accessGroup: String) {
        self.keychain = Keychain(accessGroup: accessGroup)
    }

    /// Creates a new instance of this `KeychainStorage` class.
    ///
    /// - Parameter url: The base url for the `Keychain`.
    public init(url: String) {
        let protocolType = url.contains("https") ? ProtocolType.https : .http
        self.keychain = Keychain(server: url, protocolType: protocolType).accessibility(.always)
    }

    // MARK: - Storage

    /// Removes all stored key-value pairs from the storage.
    ///
    /// - Throws: An error if the clear operation fails.
    public func clear() throws {
        do {
            try keychain.removeAll()
        } catch {
            throw StorageError.clearFailed(error)
        }
    }

    /// Deletes the value associated with the specified `StorageKey` type.
    ///
    /// - Parameter key: The type conforming to `StorageKey` whose value should be removed.
    /// - Throws: An error if the delete operation fails.
    public func deleteValue<Key: StorageKey>(for key: Key.Type) throws {
        do {
            try keychain.remove(key.name)
        } catch {
            throw StorageError.deleteFailed(error)
        }
    }

    /// Reads the value associated with the given `StorageKey` type.
    ///
    /// - Parameter key: The type conforming to `StorageKey` to read the value for.
    /// - Returns: The decoded value associated with the key, or `nil` if not found.
    /// - Throws: An error if the underlying read operation fails.
    public func readValue<Key: StorageKey>(for key: Key.Type) throws -> Key.Value? {
        guard let data = try keychain.getData(key.name) else {
            return nil
        }

        do {
            return try decoder.decode(Key.Value.self, from: data)
        } catch {
            throw StorageError.readFailed(error)
        }
    }

    /// Writes the given value to the storage using the specified `StorageKey`.
    ///
    /// - Parameters:
    ///   - value: The value to store.
    ///   - key: The key type associated with the value.
    /// - Throws: An error if the write operation fails.
    public func write<Key: StorageKey>(_ value: Key.Value, forKey key: Key.Type) throws {
        do {
            let data = try encoder.encode(value)

            try keychain.set(data, key: key.name)
        } catch {
            throw StorageError.writeFailed(error)
        }
    }
}
