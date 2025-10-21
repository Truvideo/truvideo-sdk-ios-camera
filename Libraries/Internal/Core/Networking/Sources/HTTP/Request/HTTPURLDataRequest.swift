//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A concrete class that represents a data request in a network operation.
///
/// `DataRequest` is responsible for handling network requests that expect a response with a body.
/// It extends the `Request` class and provides methods for processing and serializing response data
/// into various formats, such as `Decodable` models, raw `Data`, or `String`.
///
/// This class also supports request validation, ensuring that responses meet predefined conditions.
///
/// - Note: This class is marked as `@unchecked Sendable` due to its use of shared mutable state.
/// - Inherits from: `Request`
public class HTTPURLDataRequest: HTTPURLRequest, DataRequest, @unchecked Sendable {
    /// A typealias for a validation closure.
    ///
    /// This closure takes the original `URLRequest`, `HTTPURLResponse`, and optional response `Data`,
    /// and throws an error if validation fails.
    public typealias Validation = @Sendable (URLRequest?, HTTPURLResponse, Data?) throws -> Void

    // MARK: - Private Properties

    private let cache: HTTPURLCache?
    private let cachePolicy: URLCachePolicy
    private var responseType: ResponseType = .networkLoad

    // MARK: - Properties

    /// The builder used to construct the request.
    let requestBuilder: RequestBuilder

    // MARK: - Public Properties

    /// The raw response data received from the server.
    @Protected public private(set) var data: Data?

    // MARK: - Initializer

    /// Initializes a new request.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the request.
    ///   - requestBuilder: The builder used to construct the request.
    ///   - cache: The cache for providing cached responses to requests within the session.
    ///   - cachePolicy: The caching policy that defines how network requests should interact with local cache data.
    ///   - delegate: The delegate responsible for handling retries.
    ///   - middleware: An optional request interceptor for intercepting the request.
    ///   - monitor: An optional request monitor.
    ///   - queue: The dispatch queue for processing tasks.
    init(
        id: UUID = UUID(),
        requestBuilder: RequestBuilder,
        cache: HTTPURLCache?,
        cachePolicy: URLCachePolicy,
        delegate: HTTPURLRequestDelegate?,
        middleware: RequestMiddleware?,
        monitor: Monitor?,
        queue: DispatchQueue
    ) {
        self.cache = cache
        self.cachePolicy = cachePolicy
        self.requestBuilder = requestBuilder

        super.init(id: id, delegate: delegate, middleware: middleware, monitor: monitor, queue: queue)
    }

    // MARK: - Instance methods

    /// Handles incoming data by appending it to the existing stored state.
    ///
    /// This function ensures that received data is safely written into the `state`
    /// while maintaining thread safety. If no data has been previously stored, it initializes
    /// the state with the newly received data. Otherwise, it appends the new data to the existing buffer.
    ///
    /// - Parameter data: The `Data` object received from a network response or stream.
    func didReceive(data: Data) {
        self.data = (self.data ?? Data()) + data
    }

    // MARK: - Overriden methods

    /// Handles the completion of a request task.
    ///
    /// This method is triggered when a `URLSessionTask` finishes execution.
    /// It sets any encountered error and notifies the request monitor.
    ///
    /// - Parameters:
    ///   - task: The `URLSessionTask` that completed.
    ///   - error: An optional `NetworkingError` encountered during execution.
    override func didComplete(task: URLSessionTask, error: NetworkingError?) {
        dispatchPrecondition(condition: .onQueue(queue))

        if /// The cache for providing cached responses to requests within the session.
            let cache,

            /// The received data from the server.
            let data,

            /// The metadata associated with the response to an HTTP protocol URL load request.
            let response = task.response as? HTTPURLResponse, [.head, .get].contains(request?.method) {
            let response = URLCachedResponse(data: data, response: response)
            cache.cache(response, for: self)
        }

        super.didComplete(task: task, error: error)
    }

    /// Prepares the request for execution.
    ///
    /// This method ensures that the preparation logic is executed on the correct dispatch queue.
    override func prepare() {
        super.prepare()

        if let cache {
            func didReceiveCachedResponse(_ cachedResponse: URLCachedResponse) {
                didReceive(data: cachedResponse.data)
                response = cachedResponse.response
                responseType = .localCache
            }

            switch cachePolicy {
            case .returnCacheDataDontLoad where [.head, .get].contains(request?.method):
                if let cachedResponse = cache.cachedResponse(for: self) {
                    didReceiveCachedResponse(cachedResponse)
                }

                responseType = .localCache
                finish()

            case .returnCacheDataElseLoad where [.head, .get].contains(request?.method):
                if let cachedResponse = cache.cachedResponse(for: self) {
                    didReceiveCachedResponse(cachedResponse)
                    finish()
                }

            default:
                break
            }
        }
    }

    /// Resets the request's state to its initial configuration.
    ///
    /// This method clears the internal state of the request by performing the following actions:
    /// 1. Sets the `error` property to `nil`, effectively clearing any previously encountered errors.
    /// 2. Resets the `state` property to `.initialized`, preparing the request for a fresh start.
    /// 3. Removes all registered response serializers from the `responseSerializers` array.
    ///
    /// This function is useful for reinitializing a request instance without creating a new object,
    /// particularly in scenarios where you want to retry a request from a clean state or reuse the same instance.
    override func reset() {
        super.reset()

        data = nil
    }

    /// Called when creating a `URLSessionTask` for this `Request`. Subclasses must override.
    ///
    /// - Parameters:
    ///   - urlRequest: `URLRequest` to use to create the `URLSessionTask`.
    ///   - session: `URLSession` which creates the `URLSessionTask`.
    ///
    /// - Returns:   The `URLSessionTask` created.
    override func task(
        for urlRequest: URLRequest,
        using session: URLSession
    ) throws(NetworkingError) -> URLSessionTask {
        session.dataTask(with: urlRequest)
    }

    // MARK: - Serializing methods

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
    /// let task: AsyncDataTask<User> = request.serializing(User.self)
    /// let user = try await task.value
    /// ```
    public func serializing<Value: Decodable>(
        _ type: Value.Type,
        decoder: JSONDecoder = JSONDecoder(),
        emptyResponseCodes: Set<Int> = DataResponseSerializer.emptyResponseCodes
    ) async -> Response<Value, NetworkingError> where Value: Sendable {
        await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                self.response(
                    serializer: DecodableResponseSerializer<Value>(
                        decoder: decoder,
                        emptyResponseCodes: emptyResponseCodes
                    )
                ) { response in
                    continuation.resume(returning: response)
                }
            }
        } onCancel: {
            cancel()
        }
    }

    /// Serializes the response as raw `Data` asynchronously.
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
    public func serializingData(
        emptyResponseCodes: Set<Int> = DataResponseSerializer.emptyResponseCodes
    ) async -> Response<Data, NetworkingError> {
        await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                self.response(
                    serializer: DataResponseSerializer(
                        emptyResponseCodes: emptyResponseCodes
                    )
                ) { response in
                    continuation.resume(returning: response)
                }
            }
        } onCancel: {
            cancel()
        }
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
    public func serializingString(
        queue: DispatchQueue = .main,
        encoding: String.Encoding = .utf8,
        emptyResponseCodes: Set<Int> = DataResponseSerializer.emptyResponseCodes
    ) async -> Response<String, NetworkingError> {
        await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                self.response(
                    serializer: StringResponseSerializer(encoding: encoding, emptyResponseCodes: emptyResponseCodes)
                ) { response in
                    continuation.resume(returning: response)
                }
            }
        } onCancel: {
            cancel()
        }
    }

    // MARK: - Validation methods

    /// Validates whether the response's status code is within an acceptable range.
    ///
    /// This method checks if the provided `HTTPURLResponse` contains a status code that is considered valid.
    /// If the status code is not within the allowed range, a `NetworkingError.responseValidationFailed` is thrown.
    ///
    /// - Parameter acceptableStatusCodes: A sequence of acceptable HTTP status codes.
    /// - Throws: A `NetworkingError` if the status code is not within the acceptable range.
    public func validate() -> Self {
        validate { [weak self] _, response, _ in
            if let self {
                try validate(acceptableStatusCodes: self.acceptableStatusCodes, response: response)
            }
        }
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
        let validator: RequestValidator = { [weak self] in
            if /// Strong self.
                let self,

                /// The received response if any.
                let response, error == nil {
                do {
                    try validator(request, response, data)
                } catch {
                    self.error =
                        error as? NetworkingError
                            ?? NetworkingError(
                                kind: .responseValidationFailed,
                                underlyingError: error
                            )
                }

                monitor?.request(self, didValidate: request, data: data, error: self.error)
            }
        }

        validators.append(validator)

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
    ///
    /// ### Example Usage:
    /// ```swift
    /// request.validate(acceptableStatusCodes: [200])
    /// ```
    @discardableResult
    public func validate<S: Sequence>(acceptableStatusCodes: S) -> Self where S: Sendable, S.Iterator.Element == Int {
        validate { [weak self] _, response, _ in
            guard let self else { return }

            try validate(acceptableStatusCodes: acceptableStatusCodes, response: response)
        }
    }

    // MARK: - Private methods

    @discardableResult
    private func response<S: Serializer>(
        serializer: S,
        completionHandler: @escaping @Sendable (Response<S.SerializedObject, NetworkingError>) -> Void
    ) -> Self {
        appendResponseSerializer { [weak self] in
            guard let self else { return }

            let result = Result {
                try serializer.serialize(
                    request: self.request,
                    response: self.response,
                    data: self.data,
                    error: self.error
                )
            }
            .mapError { error in
                error as? NetworkingError
                    ?? NetworkingError(
                        kind: .responseSerializationFailed,
                        underlyingError: error
                    )
            }

            self.queue.async {
                let response = Response(
                    data: self.data,
                    metrics: self.metrics.last,
                    request: self.request,
                    response: self.response,
                    result: result,
                    type: self.responseType
                )

                self.monitor?.request(self, didParseResponse: response)
                completionHandler(response)
            }
        }

        return self
    }
}
