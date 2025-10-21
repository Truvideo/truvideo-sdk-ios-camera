//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A representation of an HTTP header, consisting of a name and a value.
///
/// `HTTPHeader` provides a type-safe way to define and manage HTTP headers.
/// It supports common headers such as `Authorization`, `Content-Type`, and `Accept-Language`.
///
/// Example usage:
/// ```swift
/// let header = HTTPHeader.authorization("Bearer token123")
/// print(header.name)  // "Authorization"
/// print(header.value) // "Bearer token123"
/// ```
public struct HTTPHeader: Hashable, Sendable {
    /// The name of the header.
    public let name: String

    /// The value of the header.
    public let value: String

    // MARK: - Static Properties

    /// Returns the default `Accept-Language` header based on the preferred languages of the device.
    ///
    /// This header provides the top six preferred languages, encoded for quality.
    public static var defaultAcceptLanguage: HTTPHeader {
        let value = Locale.preferredLanguages.prefix(6)

        return .acceptLanguage(value.qualityEncoded())
    }

    // MARK: - Static Methods

    /// Creates an `Accept-Language` HTTP header.
    ///
    /// - Parameter value: The language value to be set in the header.
    /// - Returns: An instance of `HTTPHeader` with the `Accept-Language` name.
    public static func acceptLanguage(_ value: String) -> HTTPHeader {
        .init(name: "Accept-Language", value: value)
    }

    /// Creates an `Authorization` HTTP header.
    ///
    /// - Parameter value: The authorization value (e.g., a token).
    /// - Returns: An instance of `HTTPHeader` with the `Authorization` name.
    public static func authorization(_ value: String) -> HTTPHeader {
        .init(name: "Authorization", value: value)
    }

    /// Creates a `Bearer` authorization header.
    ///
    /// - Parameter value: The bearer token to be used for authorization.
    /// - Returns: An instance of `HTTPHeader` with the `Authorization` name formatted as `Bearer <token>`.
    public static func bearerToken(_ value: String) -> HTTPHeader {
        .init(name: "Authorization", value: "Bearer \(value)")
    }

    /// Creates a `Content-Type` HTTP header.
    ///
    /// - Parameter value: The content type value (e.g., `"application/json"`).
    /// - Returns: An instance of `HTTPHeader` with the `Content-Type` name.
    public static func contentType(_ value: String) -> HTTPHeader {
        .init(name: "Content-Type", value: value)
    }

    // MARK: - Initializer

    /// Creates a new instance of `HTTPHeader` with the specified name and value.
    ///
    /// - Parameters:
    ///   - name: The name of the HTTP header.
    ///   - value: The value of the HTTP header.
    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }
}

extension Sequence<String> {
    /// Returns the Quality Encoded header.
    func qualityEncoded() -> String {
        enumerated().map { index, value in
            let quality = 1.0 - (Double(index) * 0.1)
            return "\(value);q=\(quality)"
        }
        .joined(separator: ", ")
    }
}
