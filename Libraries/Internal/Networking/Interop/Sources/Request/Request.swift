//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A protocol that defines the basic interface for controlling a network or asynchronous request.
///
/// Types conforming to `Request` must support cancellation and resumption of the operation. This
/// abstraction is commonly used to manage the lifecycle of an in-flight task, such as a network
/// request or file transfer.
public protocol Request: Equatable {
    /// Cancels the request, if allowed.
    ///
    /// - Returns: The current `Request` instance.
    @discardableResult
    func cancel() -> Self

    /// Resumes the request, if allowed.
    ///
    /// - Returns: The current `Request` instance.
    @discardableResult
    func resume() -> Self
}

public protocol DataRequest: Request {
    /// A typealias for a validation closure.
    ///
    /// This closure takes the original `URLRequest`, `HTTPURLResponse`, and optional response `Data`,
    /// and throws an error if validation fails.
    typealias Validation = @Sendable (URLRequest?, HTTPURLResponse, Data?) throws -> Void

    /// Serializes the response into a `Decodable` type asynchronously.
    ///
    /// This method allows decoding the response data into a `Decodable` object of type `Value`.
    /// It internally uses `DecodableResponseSerializer` to handle serialization.
    ///
    /// - Parameters:
    ///   - type: The `Decodable` type to which the response should be serialized.
    ///   - decoder: The `JSONDecoder` used for decoding.
    ///   - emptyResponseCodes: HTTP status codes that indicate an empty response body.
    /// - Returns: An `Response<Value, NetworkingError>` that provides the serialized response asynchronously.
    ///
    /// ### Example Usage:
    /// ```swift
    /// let task: Response<User> = request.serializing(User.self)
    /// let user = try await task.value
    /// ```
    func serializing<Value: Decodable>(
        _ type: Value.Type,
        decoder: JSONDecoder,
        emptyResponseCodes: Set<Int>
    ) async -> Response<Value, NetworkingError> where Value: Sendable

    /// Serializes the response as raw `Data` asynchronously.
    ///
    /// This method allows retrieving the response body as raw `Data`, handling empty responses
    /// based on predefined HTTP status codes.
    ///
    /// - Parameter emptyResponseCodes: HTTP status codes that indicate an empty response body.
    /// - Returns: An `Response<Value, NetworkingError>` that provides the raw response asynchronously.
    ///
    /// ### Example Usage:
    /// ```swift
    /// let task = request.serializingData()
    /// let data = try await task.value
    /// ```
    func serializingData(emptyResponseCodes: Set<Int>) async -> Response<Data, NetworkingError>

    /// Serializes the response as a `String` asynchronously.
    ///
    /// This method retrieves the response body as a `String`, using the specified encoding.
    /// It handles empty responses based on predefined HTTP status codes.
    ///
    /// - Parameters:
    ///   - queue: The `DispatchQueue` on which serialization occurs.
    ///   - encoding: The `String.Encoding` used for decoding the response.
    ///   - emptyResponseCodes: HTTP status codes that indicate an empty response body.
    /// - Returns: An `Response<Value, NetworkingError>` that provides the response as a `String` asynchronously.
    ///
    /// ### Example Usage:
    /// ```swift
    /// let task = request.serializingString()
    /// let text = try await task.value
    /// ```
    func serializingString(
        queue: DispatchQueue,
        encoding: String.Encoding,
        emptyResponseCodes: Set<Int>
    ) async -> Response<String, NetworkingError>

    /// Adds a custom validation step to the request.
    ///
    /// This method allows defining a custom validation logic for the response,
    /// ensuring the response meets specific criteria before being considered successful.
    ///
    /// - Parameter validator: A closure that validates the `URLRequest`, `HTTPURLResponse`, and response `Data`.
    /// - Returns: The current instance of `Self` to allow method chaining.
    /// - Throws: A `NetworkingError.responseValidationFailed` if the validation fails.
    /// - Returns: The current `DataRequest` instance.
    ///
    /// ### Example Usage:
    /// ```swift
    /// request.validate { request, response, data in
    ///     guard response.statusCode == 200 else {
    ///         throw NetworkingError(kind: .responseValidationFailed, failureReason: "Unexpected status code")
    ///     }
    /// }
    /// ```
    @discardableResult
    func validate(_ validator: @escaping Validation) -> Self
}

extension DataRequest {
    /// Serializes the response into a `Decodable` type asynchronously.
    ///
    /// This method allows decoding the response data into a `Decodable` object of type `Value`.
    /// It internally uses `DecodableResponseSerializer` to handle serialization.
    ///
    /// - Parameters:
    ///   - type: The `Decodable` type to which the response should be serialized.
    ///   - decoder: The `JSONDecoder` used for decoding (default: `.init()`).
    ///   - emptyResponseCodes: HTTP status codes that indicate an empty response body (default: `[204, 205]`).
    /// - Returns: An `Response<Value, NetworkingError>` that provides the serialized response asynchronously.
    ///
    /// ### Example Usage:
    /// ```swift
    /// let task: Response<User, NetworkingError> = request.serializing(User.self)
    /// let user = try await task.value
    /// ```
    public func serializing<Value: Decodable>(
        _ type: Value.Type,
        decoder: JSONDecoder = JSONDecoder(),
        emptyResponseCodes: Set<Int> = DataResponseSerializer.emptyResponseCodes
    ) async -> Response<Value, NetworkingError> where Value: Sendable {
        await serializing(Value.self, decoder: JSONDecoder(), emptyResponseCodes: emptyResponseCodes)
    }

    // Serializes the response as raw `Data` asynchronously.
    ///
    /// This method allows retrieving the response body as raw `Data`, handling empty responses
    /// based on predefined HTTP status codes.
    ///
    /// - Parameter emptyResponseCodes: HTTP status codes that indicate an empty response body (default: `[204, 205]`).
    /// - Returns: An `Response<Value, NetworkingError>` that provides the raw response asynchronously.
    ///
    /// ### Example Usage:
    /// ```swift
    /// let task = request.serializingData()
    /// let data = try await task.value
    /// ```
    func serializingData(
        emptyResponseCodes: Set<Int> = DataResponseSerializer.emptyResponseCodes
    ) async -> Response<Data, NetworkingError> {
        await serializingData(emptyResponseCodes: emptyResponseCodes)
    }

    /// Serializes the response as a `String` asynchronously.
    ///
    /// This method retrieves the response body as a `String`, using the specified encoding.
    /// It handles empty responses based on predefined HTTP status codes.
    ///
    /// - Parameters:
    ///   - queue: The `DispatchQueue` on which serialization occurs (default: `.main`).
    ///   - encoding: The `String.Encoding` used for decoding the response (default: `.utf8`).
    ///   - emptyResponseCodes: HTTP status codes that indicate an empty response body (default: `[204, 205]`).
    /// - Returns: An `Response<Value, NetworkingError>` that provides the response as a `String` asynchronously.
    ///
    /// ### Example Usage:
    /// ```swift
    /// let task = request.serializingString()
    /// let text = try await task.value
    /// ```
    func serializingString(
        queue: DispatchQueue = .main,
        encoding: String.Encoding = .utf8,
        emptyResponseCodes: Set<Int> = DataResponseSerializer.emptyResponseCodes
    ) async -> Response<String, NetworkingError> {
        await serializingString(queue: queue, encoding: encoding, emptyResponseCodes: emptyResponseCodes)
    }
}
