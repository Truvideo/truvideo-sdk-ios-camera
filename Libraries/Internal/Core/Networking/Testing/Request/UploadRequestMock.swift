//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Networking

/// A mock implementation of the `UploadRequest` protocol, used for unit testing.
///
/// This mock tracks the number of times certain request-related methods
/// (e.g., `resume()`, `suspend()`, `cancel()`, `validate()`) are called.
/// It can be inspected in tests to verify that expected operations occurred.
public final class UploadRequestMock: UploadRequest {
    // MARK: - Private Properties

    /// Unique identifier for this mock instance.
    private let id = UUID()

    // MARK: - Public Properties

    /// A human-readable description for debugging purposes.
    public var debugDescription: String {
        "UploadRequestMock(id: \(id), retryCount: \(retryCount))"
    }

    /// The error to be thrown.
    public var error: NetworkingError?

    /// The current `URLRequest` associated with the request, if any.
    public var request: URLRequest?

    /// `HTTPURLResponse` received from the server, if any.
    public var response: HTTPURLResponse?

    /// The artificial delay, in nanoseconds, that this mock request will simulate
    /// before completing its asynchronous operations.
    public var responseDelay: UInt64

    /// The current retry count for this request.
    public var retryCount: Int = 0

    // MARK: - Call Count Properties

    /// The number of times `cancel()` has been called.
    public private(set) var cancelCallCount = 0

    /// The number of times `resume()` has been called.
    public private(set) var resumeCallCount = 0

    /// The number of times `suspend()` has been called.
    public private(set) var suspendCallCount = 0

    /// The number of times any variant of `validate()` has been called.
    public private(set) var validateCallCount = 0

    /// The number of times `validate(acceptableStatusCodes:)` has been called.
    public private(set) var validateStatusCodesCallCount = 0

    // MARK: - Initializer

    /// Creates a new instance of the `UploadRequestMock`.
    ///
    /// - Parameter responseDelay: The artificial delay, in nanoseconds.
    public init(responseDelay: UInt64 = 0) {
        self.responseDelay = responseDelay
    }

    // MARK: - DataRequest

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
        emptyResponseCodes: Set<Int> = DecodableResponseSerializer<Value>.emptyResponseCodes
    ) async -> Response<Value, NetworkingError> where Value: Sendable {

        try? await Task.sleep(nanoseconds: responseDelay)

        if let error {
            return Response(
                data: nil,
                metrics: nil,
                request: nil,
                response: nil,
                result: .failure(error),
                type: .networkLoad
            )
        }

        return Response(
            data: nil,
            metrics: nil,
            request: nil,
            response: nil,
            result: .success(Networking.Empty.value as! Value),
            type: .networkLoad
        )
    }

    /// Tracks a call to `validate()`.
    ///
    /// - Returns: The mock instance for chaining.
    @discardableResult
    public func validate() -> Self {
        validateCallCount += 1
        return self
    }

    /// Tracks a call to `validate(_:)`.
    ///
    /// - Parameter validator: A custom validation closure.
    /// - Returns: The mock instance for chaining.
    @discardableResult
    public func validate(_ validator: @escaping Validation) -> Self {
        validateCallCount += 1
        return self
    }

    /// Tracks a call to `validate(acceptableStatusCodes:)`.
    ///
    /// - Parameter acceptableStatusCodes: A sequence of acceptable status codes.
    /// - Returns: The mock instance for chaining.
    @discardableResult
    public func validate<S: Sequence>(acceptableStatusCodes: S) -> Self where S: Sendable, S.Element == Int {
        validateStatusCodesCallCount += 1
        return self
    }

    // MARK: - Request Control

    /// Tracks a call to `cancel()`.
    ///
    /// - Returns: The mock instance for chaining.
    @discardableResult
    public func cancel() -> Self {
        cancelCallCount += 1
        return self
    }

    /// Tracks a call to `resume()`.
    ///
    /// - Returns: The mock instance for chaining.
    @discardableResult
    public func resume() -> Self {
        resumeCallCount += 1
        return self
    }

    /// Tracks a call to `suspend()`.
    ///
    /// - Returns: The mock instance for chaining.
    @discardableResult
    public func suspend() -> Self {
        suspendCallCount += 1
        return self
    }

    // MARK: - Equatable

    /// Compares two `UploadRequestMock` instances for equality.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side instance.
    ///   - rhs: The right-hand side instance.
    /// - Returns: `true` if both instances have the same identifier, otherwise `false`.
    public static func == (lhs: UploadRequestMock, rhs: UploadRequestMock) -> Bool {
        lhs.id == rhs.id
    }
}
