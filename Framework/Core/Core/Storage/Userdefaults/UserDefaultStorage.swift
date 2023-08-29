//
//  UserDefaultsStorage.swift
//
//  Created by TruVideo on 8/08/23.
//  Copyright © TruVideo. All rights reserved.
//

import Foundation

/// A Storage client which implements the base `Storage` interface.
/// `UserDefaultsStorage` uses `UserDefaults` internally.
///
/// Create a `UserDefaultsStorage` instance.
/// let storage = UserDefaultsStorage();
///
/// Write a key/value pair.
/// storage.write("my_value",  forKey: "my_key")
///
/// Read value for key.
/// let value = storage.read(key:  "mykey")
public struct UserDefaultsStorage: Storage {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let userDefaults: UserDefaults

    // MARK: Initializers

    /// Creates a new instance of this `UserDefaultsStorage`.
    ///
    /// - Parameter userDefaults: The underliying userDefault storage.
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: Storage

    /// Removes all key, value pairs asynchronously.
    ///
    /// - Throws: a `StorageError` if the read fails.
    public func clear() throws {
        for key in userDefaults.dictionaryRepresentation().keys {
            userDefaults.removeObject(forKey: key)
        }
    }

    /// Removes the value for the provided `key`.
    ///
    /// - Parameter key: The storaged key.
    /// - Throws: a `StorageError` if the read fails.
    public func delete(key: String) throws {
        userDefaults.removeObject(forKey: key)
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
            if let data = userDefaults.value(forKey: key) as? Data {
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
            userDefaults.setValue(data, forKey: key)
        } catch {
            throw StorageError(kind: .writeFailed, underlyingError: error)
        }
    }
}
