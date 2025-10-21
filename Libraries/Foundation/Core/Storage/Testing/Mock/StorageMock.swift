//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

@testable import StorageKit

public final class StorageMock: Storage, @unchecked Sendable {
    // MARK: - Properties

    private(set) var callCount = 0
    public var error: Error?

    // MARK: - Initializer

    public init() {}

    // MARK: - Storage

    /// Removes all stored key-value pairs from the storage.
    ///
    /// - Throws: An error if the clear operation fails.
    public func clear() throws {
        if let error {
            throw error
        }

        callCount += 1
    }

    /// Deletes the value associated with the specified `StorageKey` type.
    ///
    /// - Parameter key: The type conforming to `StorageKey` whose value should be removed.
    /// - Throws: An error if the delete operation fails.
    public func deleteValue(for key: (some StorageKey).Type) throws {
        if let error {
            throw error
        }
    }

    /// Reads the value associated with the given `StorageKey` type.
    ///
    /// - Parameter key: The type conforming to `StorageKey` to read the value for.
    /// - Returns: The decoded value associated with the key, or `nil` if not found.
    /// - Throws: An error if the underlying read operation fails.
    public func readValue<Key: StorageKey>(for key: Key.Type) throws -> Key.Value? {
        if let error {
            throw error
        }

        return (key as! Key.Value)
    }

    /// Writes the given value to the storage using the specified `StorageKey`.
    ///
    /// - Parameters:
    ///   - value: The value to store.
    ///   - key: The key type associated with the value.
    /// - Throws: An error if the write operation fails.
    public func write<Key: StorageKey>(_ value: Key.Value, forKey key: Key.Type) throws {
        if let error {
            throw error
        }
    }
}
