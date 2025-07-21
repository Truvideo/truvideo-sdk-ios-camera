//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Utilities

/// A storage implementation that persists `Codable` objects to the local file system using JSON encoding.
///
/// `FileSystemStorage` is a generic file-based key-value storage utility that reads and writes data
/// using the local file system. It encodes values using `JSONEncoder` and decodes them using `JSONDecoder`.
/// Each value is stored as an individual `.dat` file under a specified directory.
///
/// This is particularly useful for caching or persisting lightweight state across app launches.
struct FileSystemStorage: Storage {
    // MARK: - Private Properties

    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let fileManager: FileManager
    private let url: URL

    // MARK: - Initializer

    /// Creates a new instance of the `FileSystemStorage`.
    ///
    /// - Parameters:
    ///    - url: The root file system url the storage.
    ///    - fileManager: Interface to the contents of the file system.
    init(url: URL? = nil, fileManager: FileManager = .default) {
        self.fileManager = fileManager
        self.url = url ?? fileManager.telemetryDirectory
    }

    // MARK: - Storage

    /// Removes all stored key-value pairs from the storage.
    ///
    /// - Throws: An error if the clear operation fails.
    func clear() throws {
        do {
            try fileManager.removeItem(at: url)
        } catch {
            throw UtilityError(kind: .StorageErrorReason.clearFailed, underlyingError: error)
        }
    }

    /// Deletes the value associated with the specified `StorageKey` type.
    ///
    /// - Parameter key: The type conforming to `StorageKey` whose value should be removed.
    /// - Throws: An error if the delete operation fails.
    func deleteValue<Key: StorageKey>(for key: Key.Type) throws {
        do {
            try fileManager.removeItem(at: url.appendingPathComponent("\(key.name).dat"))
        } catch {
            throw UtilityError(kind: .StorageErrorReason.deleteFailed, underlyingError: error)
        }
    }

    //// Reads the value associated with the given `StorageKey` type.
    ///
    /// - Parameter key: The type conforming to `StorageKey` to read the value for.
    /// - Returns: The decoded value associated with the key, or `nil` if not found.
    /// - Throws: An error if the underlying read operation fails.
    func readValue<Key: StorageKey>(for key: Key.Type) throws -> Key.Value? {
        do {
            guard let data = try? Data(contentsOf: url.appendingPathComponent("\(key.name).dat")) else {
                return nil
            }

            return try decoder.decode(Key.Value.self, from: data)
        } catch {
            throw UtilityError(kind: .StorageErrorReason.readValueFailed, underlyingError: error)
        }
    }

    /// Writes the given value to the storage using the specified `StorageKey`.
    ///
    /// - Parameters:
    ///   - value: The value to store.
    ///   - key: The key type associated with the value.
    /// - Throws: An error if the write operation fails.
    func write<Key: StorageKey>(_ value: Key.Value, forKey key: Key.Type) throws {
        do {
            let data = try encoder.encode(value)
            let url = url.appendingPathComponent("\(key.name).dat")

            try fileManager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: url, options: .atomic)
        } catch {
            throw UtilityError(kind: .StorageErrorReason.writeFailed, underlyingError: error)
        }
    }
}
