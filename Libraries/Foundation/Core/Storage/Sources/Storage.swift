//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A protocol that defines a readable key-value storage interface.
///
/// `ReadableStorage` provides a type-safe mechanism for retrieving values
/// from storage using `StorageKey` types.
///
/// Typical usage:
/// ```swift
/// let value = try storage.readValue(for: MyStorageKey.self)
/// ```
public protocol ReadableStorage: Sendable {
    /// Reads the value associated with the given `StorageKey` type.
    ///
    /// - Parameter key: The type conforming to `StorageKey` to read the value for.
    /// - Returns: The decoded value associated with the key, or `nil` if not found.
    /// - Throws: An error if the underlying read operation fails.
    func readValue<Key: StorageKey>(for key: Key.Type) throws -> Key.Value?
}

/// A protocol that defines a writable key-value storage interface.
///
/// `WritableStorage` provides methods to write, delete, or clear values
/// in a type-safe way using `StorageKey` types.
///
/// Typical usage:
/// ```swift
/// try storage.write("token_123", forKey: AuthTokenKey.self)
/// try storage.delete(key: AuthTokenKey.self)
/// try storage.clear()
/// ```
public protocol WritableStorage: Sendable {
    /// Removes all stored key-value pairs from the storage.
    ///
    /// - Throws: An error if the clear operation fails.
    func clear() throws

    /// Deletes the value associated with the specified `StorageKey` type.
    ///
    /// - Parameter key: The type conforming to `StorageKey` whose value should be removed.
    /// - Throws: An error if the delete operation fails.
    func deleteValue(for key: (some StorageKey).Type) throws

    /// Writes the given value to the storage using the specified `StorageKey`.
    ///
    /// - Parameters:
    ///   - value: The value to store.
    ///   - key: The key type associated with the value.
    /// - Throws: An error if the write operation fails.
    func write<Key: StorageKey>(_ value: Key.Value, forKey key: Key.Type) throws
}

/// A type that can convert types into and out of an external representation.
public typealias Storage = ReadableStorage & WritableStorage
