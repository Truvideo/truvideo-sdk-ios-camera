//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// Represents common HTTP methods used in network requests.
///
/// `HTTPMethod` encapsulates standard HTTP request methods such as `GET`, `POST`, `DELETE`, etc.
/// Each method corresponds to a string representation used in HTTP requests.
///
/// Example usage:
/// ```swift
/// let method = HTTPMethod.get
/// print(method.rawValue) // "GET"
/// ```
public struct HTTPMethod: RawRepresentable, Hashable, Sendable {
    /// The corresponding value of the raw type.
    public let rawValue: String

    // MARK: - Static Properties

    /// The HTTP `DELETE` method.
    ///
    /// Used to request the deletion of a resource.
    public static let delete = HTTPMethod(rawValue: "DELETE")

    /// The HTTP `GET` method.
    public static let get = HTTPMethod(rawValue: "GET")

    /// The HTTP `HEAD` method.
    public static let head = HTTPMethod(rawValue: "HEAD")

    /// The HTTP `OPTIONS` method.
    public static let options = HTTPMethod(rawValue: "OPTIONS")

    /// The HTTP `PATCH` method.
    public static let patch = HTTPMethod(rawValue: "PATCH")

    /// The HTTP `POST` method.
    public static let post = HTTPMethod(rawValue: "POST")

    /// The HTTP `PUT` method.
    public static let put = HTTPMethod(rawValue: "PUT")

    /// The HTTP `TRACE` method.
    public static let trace = HTTPMethod(rawValue: "TRACE")

    // MARK: - Initializer

    /// Creates a new instance with the specified raw value.
    ///
    /// - Parameter rawValue: The raw value to use for the new instance.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}
