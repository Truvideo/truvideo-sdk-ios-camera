//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A Storage client which implements the base `Storage` interface.
/// `InMemoryStorage` uses a `Dictionary` internally.
///
/// Create a `InMemoryStorage` instance.
/// let storage = InMemoryStorage();
///
/// Write a key/value pair.
/// storage.write("my_value",  forKey: "my_key")
///
/// Read value for key.
/// let value = storage.read(key:  "mykey")
public final class InMemoryStorage: Storage, @unchecked Sendable {
    // MARK: - Private Properties

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var storage: [String: Data] = [:]

    // MARK: - Initializer

    /// Creates a new instance of this `InMemoryStorage`.
    public init() {}

    // MARK: - Storage

    /// Removes all stored key-value pairs from the storage.
    ///
    /// - Throws: An error if the clear operation fails.
    public func clear() throws {
        for key in storage.keys {
            storage.removeValue(forKey: key)
        }
    }

    /// Deletes the value associated with the specified `StorageKey` type.
    ///
    /// - Parameter key: The type conforming to `StorageKey` whose value should be removed.
    /// - Throws: An error if the delete operation fails.
    public func deleteValue(for key: (some StorageKey).Type) throws {
        storage.removeValue(forKey: key.name)
    }

    /// Reads the value associated with the given `StorageKey` type.
    ///
    /// - Parameter key: The type conforming to `StorageKey` to read the value for.
    /// - Returns: The decoded value associated with the key, or `nil` if not found.
    /// - Throws: An error if the underlying read operation fails.
    public func readValue<Key: StorageKey>(for key: Key.Type) throws -> Key.Value? {
        guard let data = storage[key.name] else {
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
            storage[key.name] = try encoder.encode(value)
        } catch {
            throw StorageError.writeFailed(error)
        }
    }
}
