//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import NetworkingInterop

/// A mock implementation of the `Request` protocol for testing.
public final class DataRequestMock: DataRequest {
    // MARK: - Private Properties

    let id = UUID()

    // MARK: - Public Properties

    public private(set) var cancelCallCount = 0
    public private(set) var resumeCallCount = 0

    // MARK: - Initializer

    /// Creates a new instance of the `RequestMock`.
    public init() {}

    // MARK: - DataRequest

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
    public func serializing<Value: Decodable>(
        _ type: Value.Type,
        decoder: JSONDecoder,
        emptyResponseCodes: Set<Int>
    ) async -> Response<Value, NetworkingError> where Value: Sendable {

        Response(
            data: nil,
            metrics: nil,
            request: nil,
            response: nil,
            result: .failure(NetworkingError(kind: .explicitlyCancelled, failureReason: "")),
            type: .networkLoad
        )
    }

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
    public func serializingData(emptyResponseCodes: Set<Int>) async -> Response<Data, NetworkingError> {
        Response(
            data: nil,
            metrics: nil,
            request: nil,
            response: nil,
            result: .success(Data()),
            type: .networkLoad
        )
    }

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
    public func serializingString(
        queue: DispatchQueue,
        encoding: String.Encoding,
        emptyResponseCodes: Set<Int>
    ) async -> Response<String, NetworkingError> {

        Response(
            data: nil,
            metrics: nil,
            request: nil,
            response: nil,
            result: .success(""),
            type: .networkLoad
        )
    }

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
    public func validate(_ validator: @escaping Validation) -> Self {
        self
    }

    // MARK: - Request

    /// Cancels the request, if allowed.
    ///
    /// - Returns: The current `Request` instance.
    @discardableResult
    public func cancel() -> Self {
        cancelCallCount += 1
        return self
    }

    /// Resumes the request, if allowed.
    ///
    /// - Returns: The current `Request` instance.
    public func resume() -> Self {
        resumeCallCount += 1
        return self
    }
}

extension DataRequestMock {
    // MARK: - Equatable

    /// Returns a Boolean value indicating whether two values are equal.
    public static func == (lhs: DataRequestMock, rhs: DataRequestMock) -> Bool {
        lhs.id == rhs.id
    }
}
