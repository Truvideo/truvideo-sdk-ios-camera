//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Networking

/// A mock implementation of the `DataRequest` protocol for testing network requests.
public final class DataRequestMock: DataRequest {
    // MARK: - Private Properties

    private let id = UUID()

    // MARK: - Public Properties

    /// The current `URLRequest` created on behalf of the `Request`.
    public var request: URLRequest?

    /// `HTTPURLResponse` received from the server, if any.
    public var response: HTTPURLResponse?

    /// The current retry count for this request.
    public var retryCount = 0

    /// A human-readable description for debugging purposes.
    public var debugDescription: String {
        "DataRequestMock(id: \(id), retryCount: \(retryCount))"
    }

    // MARK: - Mock Configuration Properties

    /// The data associated to the request.
    public var data: Data?

    /// The mock response object to return for data serialization.
    public var mockDataResponse: Response<Data, NetworkingError>?

    /// The mock response object to return for generic serialization.
    public var mockResponse: Any?

    /// The mock response object to return for string serialization.
    public var mockStringResponse: Response<String, NetworkingError>?

    // MARK: - Call Count Properties

    /// The number of times `cancel()` has been called.
    public private(set) var cancelCallCount = 0

    /// The number of times `resume()` has been called.
    public private(set) var resumeCallCount = 0

    /// The number of times `suspend` has been called.
    public private(set) var suspendCallCount = 0

    /// The number of times `validate()` has been called.
    public private(set) var validateCallCount = 0

    /// The number of times `validate(acceptableStatusCodes:)` has been called.
    public private(set) var validateStatusCodesCallCount = 0

    /// The number of times `serializing(_:)` has been called.
    public private(set) var serializingCallCount = 0

    /// The number of times `serializingData()` has been called.
    public private(set) var serializingDataCallCount = 0

    /// The number of times `serializingString()` has been called.
    public private(set) var serializingStringCallCount = 0

    // MARK: - Initializer

    /// Creates a new instance of the `DataRequestMock`.
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
        decoder: JSONDecoder = JSONDecoder(),
        emptyResponseCodes: Set<Int> = DataResponseSerializer.emptyResponseCodes
    ) async -> Response<Value, NetworkingError> where Value: Sendable {
        serializingCallCount += 1

        return mockResponse as! Response<Value, NetworkingError>
    }

    /// Serializes the response as raw `Data` asynchronously.
    ///
    /// This method allows retrieving the response body as raw `Data`, handling empty responses
    /// based on predefined HTTP status codes.
    ///
    /// - Parameter emptyResponseCodes: HTTP status codes that indicate an empty response body.
    /// - Returns: An `Response<Data, NetworkingError>` that provides the raw response asynchronously.
    public func serializingData(
        emptyResponseCodes: Set<Int> = DataResponseSerializer.emptyResponseCodes
    ) async -> Response<Data, NetworkingError> {
        serializingDataCallCount += 1

        return mockDataResponse!
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
    /// - Returns: An `Response<String, NetworkingError>` that provides the response as a `String` asynchronously.
    public func serializingString(
        queue: DispatchQueue = .main,
        encoding: String.Encoding = .utf8,
        emptyResponseCodes: Set<Int> = DataResponseSerializer.emptyResponseCodes
    ) async -> Response<String, NetworkingError> {
        serializingStringCallCount += 1

        return mockStringResponse!
    }

    /// Validates the request without any custom validation logic.
    ///
    /// This method provides a parameterless validation option that simply tracks
    /// the call and returns the current instance for method chaining.
    ///
    /// - Returns: The current `DataRequest` instance.
    @discardableResult
    public func validate() -> Self {
        validateCallCount += 1
        return self
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
    @discardableResult
    public func validate(_ validator: @escaping Validation) -> Self {
        validateCallCount += 1
        return self
    }

    /// Validates whether the response's status code is within an acceptable range.
    ///
    /// This method checks if the provided `HTTPURLResponse` contains a status code that is considered valid.
    /// If the status code is not within the allowed range, a `NetworkingError.responseValidationFailed` is thrown.
    ///
    /// - Parameter acceptableStatusCodes: A sequence of acceptable HTTP status codes.
    /// - Throws: A `NetworkingError` if the status code is not within the acceptable range.
    /// - Returns: The current `DataRequest` instance.
    @discardableResult
    public func validate<S: Sequence>(acceptableStatusCodes: S) -> Self where S: Sendable, S.Iterator.Element == Int {
        validateStatusCodesCallCount += 1
        return self
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
    @discardableResult
    public func resume() -> Self {
        resumeCallCount += 1
        return self
    }

    /// Suspends the request, if allowed.
    ///
    /// - Returns: The current `Request` instance.
    public func suspend() -> Self {
        suspendCallCount += 1
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
