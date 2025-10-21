//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A protocol that defines a mechanism for serializing network responses.
///
/// `Serializer` provides a generic interface for converting raw `Data` from a network response
/// into a strongly typed object. Implementations must handle serialization logic and error handling.
///
/// - Note: Conforming types should be `Sendable` to ensure thread safety in concurrent environments.
public protocol Serializer: Sendable {
    /// The type of object produced by the serializer.
    associatedtype SerializedObject: Sendable

    /// HTTP response status codes that indicate an empty response body is valid.
    ///
    /// - Default: `[204, 205]` (No Content & Reset Content)
    var emptyResponseCodes: Set<Int> { get }

    /// Serializes the provided response data into the expected type.
    ///
    /// - Parameters:
    ///   - request: The original `URLRequest` that was sent.
    ///   - response: The `HTTPURLResponse` received from the server.
    ///   - data: The raw `Data` returned by the server.
    ///   - error: An optional `Error` encountered during the request.
    /// - Throws: An error if serialization fails.
    /// - Returns: A `SerializedObject` instance if serialization succeeds.
    func serialize(
        request: URLRequest?,
        response: HTTPURLResponse?,
        data: Data?,
        error: Error?
    ) throws -> SerializedObject
}

extension Serializer {
    /// HTTP response codes for which empty response bodies are considered appropriate.
    public static var emptyResponseCodes: Set<Int> {
        [204, 205]
    }
}

/// A serializer that returns raw `Data` from the network response.
///
/// `DataResponseSerializer` simply passes the raw response `Data`, ensuring that an empty
/// response is handled correctly based on predefined empty response codes.
public struct DataResponseSerializer: Serializer {
    // MARK: - Public Properties

    /// HTTP response codes for which empty response bodies are considered appropriate.
    public let emptyResponseCodes: Set<Int>

    // MARK: - Initializer

    /// Creates a `DataResponseSerializer` with customizable empty response codes.
    ///
    /// - Parameter emptyResponseCodes: HTTP status codes that indicate a valid empty response.
    public init(emptyResponseCodes: Set<Int> = DataResponseSerializer.emptyResponseCodes) {
        self.emptyResponseCodes = emptyResponseCodes
    }

    // MARK: - Serializer

    /// Serializes the provided response data into the expected type.
    ///
    /// - Parameters:
    ///   - request: The original `URLRequest` that was sent.
    ///   - response: The `HTTPURLResponse` received from the server.
    ///   - data: The raw `Data` returned by the server.
    ///   - error: An optional `Error` encountered during the request.
    /// - Throws: An error if serialization fails.
    /// - Returns: A `Data` instance if serialization succeeds.
    public func serialize(
        request: URLRequest?,
        response: HTTPURLResponse?,
        data: Data?,
        error: Error?
    ) throws -> Data {
        if let error {
            throw error
        }

        guard let data, !data.isEmpty else {
            guard let response, emptyResponseCodes.contains(response.statusCode) else {
                throw NetworkingError(
                    kind: .responseSerializationFailed,
                    failureReason: "Input data nil or zero length"
                )
            }

            return Data()
        }

        return data
    }
}

/// A type representing an empty response.
///
/// `Empty` is used for API responses where an empty body is expected.
public struct Empty: Codable, Equatable, Sendable {
    /// A shared static instance of `Empty`.
    public static let value = Empty()
}

/// A serializer that decodes JSON responses into `Decodable` objects.
///
/// This serializer attempts to decode the response data into a `Decodable` type `T`,
/// using the provided `JSONDecoder`.
public struct DecodableResponseSerializer<T: Decodable>: Serializer where T: Sendable {
    // MARK: - Public Properties

    /// The `JSONDecoder` used for decoding response data.
    public let decoder: JSONDecoder

    /// HTTP response codes for which empty response bodies are considered appropriate.
    public let emptyResponseCodes: Set<Int>

    // MARK: - Initializer

    /// Creates a `DecodableResponseSerializer` with a custom JSON decoder and empty response codes.
    ///
    /// - Parameters:
    ///   - decoder: The `JSONDecoder` used for decoding the response data.
    ///   - emptyResponseCodes: HTTP status codes that indicate a valid empty response.
    public init(
        decoder: JSONDecoder = JSONDecoder(),
        emptyResponseCodes: Set<Int> = DecodableResponseSerializer<T>.emptyResponseCodes
    ) {
        self.decoder = decoder
        self.emptyResponseCodes = emptyResponseCodes
    }

    // MARK: - Serializer

    /// Serializes the provided response data into the expected type.
    ///
    /// - Parameters:
    ///   - request: The original `URLRequest` that was sent.
    ///   - response: The `HTTPURLResponse` received from the server.
    ///   - data: The raw `Data` returned by the server.
    ///   - error: An optional `Error` encountered during the request.
    /// - Throws: An error if serialization fails.
    /// - Returns: A `T` instance if serialization succeeds.
    public func serialize(
        request: URLRequest?,
        response: HTTPURLResponse?,
        data: Data?,
        error: Error?
    ) throws -> T {
        if let error {
            throw error
        }

        guard let data, !data.isEmpty else {
            guard let response, emptyResponseCodes.contains(response.statusCode) else {
                throw NetworkingError(
                    kind: .responseSerializationFailed,
                    failureReason: "Input data nil or zero length"
                )
            }

            guard
                /// T should be an empty type.
                T.self is Empty.Type,

                /// Empty instance.
                let empty = Empty() as? T
            else {
                throw NetworkingError(kind: .responseSerializationFailed, failureReason: "Invalid empty response type")
            }

            return empty
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkingError(kind: .responseSerializationFailed, underlyingError: error)
        }
    }
}

/// A serializer that converts response `Data` into a `String`.
///
/// This serializer ensures the response is properly decoded into a `String`
/// using the specified character encoding.
public struct StringResponseSerializer: Serializer {
    // MARK: - Public Properties

    /// HTTP response codes for which empty response bodies are considered appropriate.
    public let emptyResponseCodes: Set<Int>

    /// The string encoding used to decode the response.
    public let encoding: String.Encoding

    // MARK: - Initializer

    /// Creates a `StringResponseSerializer` with a specific encoding and empty response codes.
    ///
    /// - Parameters:
    ///   - encoding: The `String.Encoding` used to decode the response.
    ///   - emptyResponseCodes: HTTP status codes that indicate a valid empty response.
    public init(
        encoding: String.Encoding = .utf8,
        emptyResponseCodes: Set<Int> = DataResponseSerializer.emptyResponseCodes
    ) {
        self.emptyResponseCodes = emptyResponseCodes
        self.encoding = encoding
    }

    // MARK: - Serializer

    /// Serializes the provided response data into the expected type.
    ///
    /// - Parameters:
    ///   - request: The original `URLRequest` that was sent.
    ///   - response: The `HTTPURLResponse` received from the server.
    ///   - data: The raw `Data` returned by the server.
    ///   - error: An optional `Error` encountered during the request.
    /// - Throws: An error if serialization fails.
    /// - Returns: A `String` instance if serialization succeeds.
    public func serialize(
        request: URLRequest?,
        response: HTTPURLResponse?,
        data: Data?,
        error: Error?
    ) throws -> String {
        if let error {
            throw error
        }

        guard let data, !data.isEmpty else {
            guard let response, emptyResponseCodes.contains(response.statusCode) else {
                throw NetworkingError(
                    kind: .responseSerializationFailed,
                    failureReason: "Input data nil or zero length"
                )
            }

            return ""
        }

        guard let string = String(data: data, encoding: encoding) else {
            throw NetworkingError(
                kind: .responseSerializationFailed,
                failureReason: "Could not convert data to string using specified encoding \(encoding)"
            )
        }

        return string
    }
}
