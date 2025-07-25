//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A protocol that defines a unique, type-safe key for identifying values in a storage system.
///
/// `StorageKey` allows storage implementations to associate values with strongly typed keys.
/// Each conforming type must specify the value's type via the `associatedtype Value`, which
/// must conform to `Codable`.
///
/// You can optionally override the default `name` to customize the identifier used for storage.
///
/// ## Example
/// ```swift
/// struct AccessTokenKey: StorageKey {
///     typealias Value = String
/// }
///
/// try storage.write("token_123", forKey: AccessTokenKey.self)
/// let token = try storage.readValue(for: AccessTokenKey.self)
/// ```
public protocol StorageKey: Sendable {
    /// The associated value type that will be stored and retrieved using this key.
    associatedtype Value: Codable

    /// A unique string identifier for the storage key, typically used as the file name or dictionary key.
    static var name: String { get }
}

extension StorageKey {
    /// The default implementation of `name`, using the type's name as the storage identifier.
    public static var name: String {
        String(describing: Self.self)
    }
}
