//
//  AsyncDataTask.swift
//
//  Created by TruVideo on 8/08/23.
//  Copyright © TruVideo. All rights reserved.
//

@_implementationOnly import Alamofire

extension Error {
    /// Casts the instance as `NetworkError` or returns the error
    /// created in the `defaultError` callback.
    ///
    /// - Returns: A new instance of the `NetworkError` object.
    func asNetworkError(or defaultError: @autoclosure () -> NetworkError) -> NetworkError {
        guard let error = self.asAFError else { return defaultError() }

        switch error {
        case .requestAdaptationFailed:
            return NetworkError(kind: .requestAdaptationFailed, underlyingError: error.underlyingError ?? error)
            
        case .requestRetryFailed:
            return NetworkError(kind: .requestRetryFailed, underlyingError: error.underlyingError ?? error)
            
        case .responseValidationFailed:
            return NetworkError(kind: .responseValidationFailed, underlyingError: error.underlyingError ?? error)
            
        case .sessionInvalidated:
            return NetworkError(kind: .sessionInvalidated, underlyingError: error.underlyingError ?? error)
            
        case .sessionTaskFailed:
            return NetworkError(kind: .sessionTaskFailed, underlyingError: error.underlyingError ?? error)
            
        case .urlRequestValidationFailed:
            return NetworkError(kind: .urlRequestValidationFailed, underlyingError: error.underlyingError ?? error)
            
        case .parameterEncoderFailed, .parameterEncodingFailed:
            return NetworkError(kind: .parameterEncodingFailed, underlyingError: error.underlyingError ?? error)

        case .responseSerializationFailed:
            return NetworkError(kind: .responseSerializationFailed, underlyingError: error.underlyingError ?? error)

        default: return defaultError()
        }
    }
}

extension AFDataResponse {
    /// Maps the current `AFDataResponse` into a `Response`
    ///
    /// - Returns: The new instance of the `Response` object.
    func asResponse() -> Response<Success> {
        Response(
            data: data,
            request: request,
            response: response,
            result: result.mapError { $0.asNetworkError(or: .unknown) }
        )
    }
}

/// Value used to `await` a ``Response`` and associated values.
public struct AsyncDataTask<Value> {
    private let dataTask: DataTask<Value>

    /// `Response` produced by the `DataRequest` and its response handler.
    public var response: Response<Value> {
        get async {
            await dataTask.response.asResponse()
        }
    }

    /// `Result` of any response serialization performed for the `response`.
    public var result: Result<Value, NetworkError> {
        get async {
            await response.result
        }
    }

    /// `Value` returned by the `response`.
    public var value: Value {
        get async throws {
            try await result.get()
        }
    }

    // MARK: Initializers

    /// Creates a new instance of the `AsyncDataTask`.
    ///
    /// - Parameter dataTask: The underliying AF async task.
    init(dataTask: DataTask<Value>) {
        self.dataTask = dataTask
    }

    // MARK: Public methods

    /// Cancel the underlying `DataRequest` and `Task`.
    public func cancel() {
        dataTask.cancel()
    }

    /// Resume the underlying `DataRequest`.
    public func resume() {
        dataTask.resume()
    }

    /// Suspend the underlying `DataRequest`.
    public func suspend() {
        dataTask.suspend()
    }
}
