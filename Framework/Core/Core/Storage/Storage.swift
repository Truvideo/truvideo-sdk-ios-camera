//
//  Storage.swift
//
//  Created by TruVideo on 8/08/23.
//  Copyright © TruVideo. All rights reserved.
//

import Foundation

/// A Swift Storage Client Interface
public protocol Storage {
    /// Removes all key, value pairs asynchronously.
    ///
    /// - Throws: a `StorageError` if the read fails.
    func clear() throws
    
    /// Removes the value for the provided `key`.
    ///
    /// - Parameter key: The storaged key.
    /// - Throws: a `StorageError` if the read fails.
    func delete(key: String) throws
    
    /// Fetch the value for the given key.
    ///
    /// - Parameters:
    ///    - key: The storaged key.
    ///    - type: The resulting type when decoding.
    /// - Returns: value for the provided `key` or returns `nil` if no value is found for the given `key`.
    /// - Throws: a `StorageError` if the read fails.
    func readValue<T>(_ type: T.Type, forKey key: String) throws -> T? where T: Decodable
    
    /// Writes the provided `key`, `value` pair asynchronously.
    ///
    /// - Parameters:
    ///   - value: The value that will be storage.
    ///   - key: The key that save the given value.
    ///   - Throws: a `StorageError` if the read fails.
    func write<T>(_ value: T, forKey key: String) throws where T: Encodable
}
