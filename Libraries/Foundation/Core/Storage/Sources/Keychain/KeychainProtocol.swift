//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import KeychainAccess

/// A protocol that defines an interface for securely storing, retrieving, and managing data using the keychain.
protocol KeychainProtocol: Sendable {
    /// Retrieves stored data from the keychain associated with the given key.
    ///
    /// - Parameters:
    ///   - key: The key used to store the data.
    ///   - ignoringAttributeSynchronizable: A Boolean flag indicating whether to ignore the `synchronizable` attribute when retrieving data.
    /// - Returns: The data associated with the given key, or `nil` if no data is found.
    /// - Throws: An error if the retrieval operation fails.
    func getData(_ key: String, ignoringAttributeSynchronizable: Bool) throws -> Data?

    /// Removes all keychain entries for the current keychain instance.
    ///
    /// - Throws: An error if the operation fails.
    func removeAll() throws

    /// Removes a specific key-value pair from the keychain.
    ///
    /// - Parameters:
    ///   - key: The key associated with the data to be removed.
    ///   - ignoringAttributeSynchronizable: A Boolean flag indicating whether to ignore the `synchronizable` attribute when removing data.
    /// - Throws: An error if the removal operation fails.
    func remove(_ key: String, ignoringAttributeSynchronizable: Bool) throws

    /// Stores data securely in the keychain with the associated key.
    ///
    /// - Parameters:
    ///   - value: The data to be stored in the keychain.
    ///   - key: The key used to store the data.
    ///   - ignoringAttributeSynchronizable: A Boolean flag indicating whether to ignore the `synchronizable` attribute when storing data.
    /// - Throws: An error if the storage operation fails.
    func set(_ value: Data, key: String, ignoringAttributeSynchronizable: Bool) throws
}

extension KeychainProtocol {
    /// Retrieves stored data from the keychain with a default value for `ignoringAttributeSynchronizable`.
    ///
    /// - SeeAlso: `KeychainProtocol.getData(_:ignoringAttributeSynchronizable:)`
    func getData(_ key: String, ignoringAttributeSynchronizable: Bool = true) throws -> Data? {
        try getData(key, ignoringAttributeSynchronizable: ignoringAttributeSynchronizable)
    }

    /// Removes a key-value pair from the keychain with a default value for `ignoringAttributeSynchronizable`.
    ///
    /// - SeeAlso: `KeychainProtocol.remove(_:ignoringAttributeSynchronizable:)`
    func remove(_ key: String, ignoringAttributeSynchronizable: Bool = true) throws {
        try remove(key, ignoringAttributeSynchronizable: ignoringAttributeSynchronizable)
    }

    /// Stores data securely in the keychain with a default value for `ignoringAttributeSynchronizable`.
    ///
    /// - SeeAlso: `KeychainProtocol.set(_:key:ignoringAttributeSynchronizable:)`
    func set(_ value: Data, key: String, ignoringAttributeSynchronizable: Bool = true) throws {
        try set(value, key: key, ignoringAttributeSynchronizable: ignoringAttributeSynchronizable)
    }
}

extension Keychain: KeychainProtocol {}
extension Keychain: @unchecked @retroactive Sendable {}
