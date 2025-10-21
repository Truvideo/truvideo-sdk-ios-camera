//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import KeychainAccess

@testable import StorageKit

/// A mock implementation of `KeychainProtocol` used for testing purposes.
///
/// `KeychainProtocolMock` simulates the behavior of a keychain storage without
/// persisting any real data. It provides counters for method calls, allows
/// injecting custom errors, and stores data in memory.
public final class KeychainProtocolMock: KeychainProtocol, @unchecked Sendable {
    // MARK: - Properties

    /// An optional error to simulate failures during keychain operations.
    public var error: Error?

    /// Records whether `getData(_ key: String, ignoringAttributeSynchronizable: Bool)` was called.
    public private(set) var getDataCallCount = 0

    /// The most recent key used in a keychain operation.
    public private(set) var key: String?

    /// The most recent value passed for the `ignoringAttributeSynchronizable` parameter.
    public private(set) var ignoringAttributeSynchronizable: Bool?

    /// Records whether `removeAll()` was called.
    public private(set) var removeAllCallCount = 0

    /// Records whether `remove()` was called.
    public private(set) var removeCallCount = 0

    /// Records whether `set()` was called.
    public private(set) var setCallCount = 0

    /// A simple in-memory storage that simulates the keychain's persistence layer.
    public private(set) var storage: [String: Data] = [:]

    // MARK: - Initializer

    public init() {}

    // MARK: - KeychainProtocol

    /// Simulates retrieving stored data for a given key.
    ///
    /// - Parameters:
    ///   - key: The key whose data should be retrieved.
    ///   - ignoringAttributeSynchronizable: Indicates whether the synchronizable
    ///     attribute should be ignored during retrieval.
    /// - Returns: The data associated with the specified key, or `nil` if no data exists.
    /// - Throws: The `error` property if it has been set.
    public func getData(_ key: String, ignoringAttributeSynchronizable: Bool) throws -> Data? {
        self.key = key
        self.ignoringAttributeSynchronizable = ignoringAttributeSynchronizable
        getDataCallCount += 1

        if let error {
            throw error
        }

        return storage[key]
    }

    /// Simulates removing all entries from the keychain.
    ///
    /// - Throws: The `error` property if it has been set.
    public func removeAll() throws {
        removeAllCallCount += 1

        if let error {
            throw error
        }

        storage.removeAll()
    }

    /// Simulates removing a specific key-value pair from the keychain.
    ///
    /// - Parameters:
    ///   - key: The key whose value should be removed.
    ///   - ignoringAttributeSynchronizable: Indicates whether the synchronizable
    ///     attribute should be ignored during deletion.
    /// - Throws: The `error` property if it has been set.
    public func remove(_ key: String, ignoringAttributeSynchronizable: Bool) throws {
        self.key = key
        self.ignoringAttributeSynchronizable = ignoringAttributeSynchronizable
        removeCallCount += 1

        if let error {
            throw error
        }

        storage.removeValue(forKey: key)
    }

    /// Simulates securely storing data in the keychain.
    ///
    /// - Parameters:
    ///   - value: The data to store.
    ///   - key: The key used to store the data.
    ///   - ignoringAttributeSynchronizable: Indicates whether the synchronizable
    ///     attribute should be ignored during storage.
    /// - Throws: The `error` property if it has been set.
    public func set(_ value: Data, key: String, ignoringAttributeSynchronizable: Bool) throws {
        self.key = key
        self.ignoringAttributeSynchronizable = ignoringAttributeSynchronizable
        setCallCount += 1

        if let error {
            throw error
        }

        storage[key] = value
    }
}
