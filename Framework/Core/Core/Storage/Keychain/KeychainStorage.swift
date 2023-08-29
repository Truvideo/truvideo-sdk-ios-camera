//
//  KeychainStorage.swift
//
//  Created by TruVideo on 8/08/23.
//  Copyright © TruVideo. All rights reserved.
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
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let keychain: Keychain

    // MARK: Initializers

    /// Creates a new instance of this `KeychainStorage`.
    ///
    /// - Parameter keychain: The underliying keychain storage.
    init(keychain: Keychain) {
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

    // MARK: Storage

    /// Removes all key, value pairs asynchronously.
    ///
    /// - Throws: a `KeychainStorageError` if the read fails.
    public func clear() throws {
        do {
            try keychain.removeAll()
        } catch {
            throw StorageError(kind: .clearFailed, underlyingError: error)
        }
    }

    /// Removes the value for the provided `key`.
    ///
    /// - Parameter key: The storaged key.
    /// - Throws: a `StorageError` if the read fails.
    public func delete(key: String) throws {
        do {
            try keychain.remove(key)
        } catch {
            throw StorageError(kind: .deleteFailed, underlyingError: error)
        }
    }

    /// Fetch the value for the given key.
    ///
    /// - Parameters:
    ///    - key: The storaged key.
    ///    - type: The resulting type when decoding.
    /// - Returns: value for the provided `key` or returns `nil` if no value is found for the given `key`.
    /// - Throws: a `StorageError` if the read fails.
    public func readValue<T>(_ type: T.Type, forKey key: String) throws -> T? where T: Decodable {
        do {
            if let data = try keychain.getData(key) {
                return try decoder.decode(T.self, from: data)
            }
        } catch {
            throw StorageError(kind: .readValueFailed, underlyingError: error)
        }

        return nil
    }

    /// Writes the provided `key`, `value` pair asynchronously.
    ///
    /// - Parameters:
    ///   - value: The value that will be storage.
    ///   - key: The key that save the given value.
    ///   - Throws: a `StorageError` if the read fails.
    public func write<T>(_ value: T, forKey key: String) throws where T: Encodable {
        do {
            let data = try encoder.encode(value)
            try keychain.set(data, key: key)
        } catch {
            throw StorageError(kind: .writeFailed, underlyingError: error)
        }
    }
}
