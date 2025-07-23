//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A protocol that defines an interface for converting instances into a `URL`.
///
/// Types that conform to `URLConvertible` provide a standardized way to convert various representations
/// of a URL (such as `String`, `URLComponents`, or custom URL types) into a valid `URL` instance.
///
/// - Important: Conforming types must implement the `asURL()` method, which should either return a valid `URL`
///   or throw an error if conversion fails.
public protocol URLConvertible {
    /// Converts the conforming instance into a `URL`.
    ///
    /// - Throws: An error if the conversion fails. The specific error thrown depends on the implementation.
    /// - Returns: A valid `URL` instance representing the conforming type.
    func asURL() throws -> URL
}

/// A protocol that defines the requirements for building a `URLRequest`.
///
/// Types conforming to `RequestBuilder` are responsible for constructing and returning a valid `URLRequest`.
/// This allows for a flexible and reusable pattern when creating network requests, supporting customization of headers,
/// HTTP methods, URL paths, query parameters, and body content.
///
/// Conforming types should implement the `build()` method, which can throw errors if the request configuration is invalid
/// or if serialization fails.
public protocol RequestBuilder {
    /// Builds and returns a configured `URLRequest` instance.
    ///
    /// This method should be implemented by conforming types to provide the necessary logic for constructing
    /// a valid HTTP request. The request should include all necessary details such as the URL, HTTP method,
    /// headers, query parameters, and body content.
    ///
    /// - Throws: An error if the request cannot be constructed. This may occur due to invalid URL components, serialization issues, or missing required fields.
    /// - Returns: A fully configured `URLRequest` instance ready for execution.
    func build() throws -> URLRequest
}

/// A class responsible for managing and executing network requests using `URLSession`.
///
/// `Session` handles the lifecycle of network requests, including initialization, execution, monitoring, and cancellation.
/// It integrates with customizable middleware, monitors, and delegates for flexible request handling. The session operates asynchronously
/// on specified queues, ensuring efficient execution without blocking the main thread.
///
/// This class is ideal for managing network requests in applications requiring robust networking operations,
/// such as API calls, file uploads, and downloading data.
///
/// ### Example Usage:
/// ```swift
/// // Create a custom session delegate
/// let delegate = SessionDelegate()
///
/// // Initialize the networking session
/// let session = Session(
///     configuration: .default,
///     delegate: delegate,
///     middleware: nil, // Add custom middleware if needed
///     monitor: nil     // Add a request monitor for logging or analytics if required
/// )
///
/// // Construct a URLRequest using the builder
/// let requestBuilder = Session.URLRequestBuilder(
///     url: "https://api.example.com/data",
///     method: .get,
///     parameters: ["query": "swift"],
///     encoder: JSONParameterEncoder(),
///     headers: HTTPHeaders(["Authorization": "Bearer YOUR_TOKEN"])
/// )
///
/// // Execute the request and handle the response
/// let dataRequest = session.request(requestBuilder)
///
/// try await dataRequest.serializingData()
/// ```
///
/// - Note:
///   - Custom middleware can be used to handle authentication, logging, or request modification before sending.
///   - Use `RequestMonitor` for analytics, logging, or tracking request lifecycle events.
///   - All networking tasks are automatically handled on background queues to avoid blocking the main thread.
open class Session: @unchecked Sendable {
    // MARK: - Private Properties

    private let cache: URLCache?

    // MARK: - Properties

    /// The list of currently active `Request`s.
    var activeRequests: Set<Request> = []

    // MARK: - Public Properties

    // swiftlint:disable weak_delegate
    /// The delegate responsible for handling session events such as task completion and failures.
    public let delegate: SessionDelegate
    // swiftlint:enable weak_delegate

    /// An optional middleware used to modify or intercept requests before execution.
    public let middleware: RequestMiddleware?

    /// An optional monitor for observing and logging request events throughout their lifecycle.
    public let monitor: Monitor?

    /// The dispatch queue responsible for executing networking operations.
    public let queue: DispatchQueue

    /// The underlying `URLSession` instance that manages HTTP networking.
    public let session: URLSession

    // MARK: - Types

    /// A builder responsible for constructing a `URLRequest` with configurable parameters, method, headers, and encoding.
    ///
    /// `URLRequestBuilder` conforms to the `RequestBuilder` protocol and provides a structured way to build HTTP requests.
    /// It allows for injecting parameters, encoding strategies, custom headers, and request interceptors.
    ///
    /// This is particularly useful for networking layers that require flexible request construction with support for various HTTP methods, encoders, and interceptors.
    ///
    /// ### Example Usage:
    /// ```swift
    /// let builder = URLRequestBuilder(
    ///     url: "https://api.example.com/data",
    ///     method: .get,
    ///     parameters: ["query": "swift"],
    ///     encoder: JSONParameterEncoder(),
    ///     headers: HTTPHeaders(["Authorization": "Bearer token"]),
    ///     interceptor: nil
    /// )
    ///
    /// let request = try builder.build()
    /// print(request)
    /// ```
    struct URLRequestBuilder: RequestBuilder {
        /// The target URL for the HTTP request, conforming to `URLConvertible`.
        let url: URLConvertible

        /// The HTTP method to be used for the request (e.g., `GET`, `POST`, `PUT`).
        let method: HTTPMethod

        /// A dictionary of parameters to be included in the request.
        let parameters: Parameters?

        /// An encoder responsible for encoding the parameters into the request.
        let encoder: ParameterEncoder

        /// Additional HTTP headers to include in the request.
        let headers: HTTPHeaders?

        // MARK: - RequestBuilder

        /// Builds and returns a configured `URLRequest` instance.
        ///
        /// This method should be implemented by conforming types to provide the necessary logic for constructing
        /// a valid HTTP request. The request should include all necessary details such as the URL, HTTP method,
        /// headers, query parameters, and body content.
        ///
        /// - Throws: An error if the request cannot be constructed. This may occur due to invalid URL components, serialization issues, or missing required fields.
        /// - Returns: A fully configured `URLRequest` instance ready for execution.
        func build() throws -> URLRequest {
            let request = try URLRequest(url: url, method: method, headers: headers)

            return try encoder.encode(parameters, into: request)
        }
    }

    // MARK: - Initializer

    /// Initializes a custom networking session with the specified configuration and dependencies.
    ///
    /// - Parameters:
    ///   - session: The `URLSession` instance responsible for managing HTTP requests.
    ///   - delegate: The `SessionDelegate` responsible for handling session events, such as task completion and failures.
    ///   - cache: The cache for providing cached responses to requests within the session.
    ///   - cachePolicy: The caching policy that defines how network requests should interact with local cache data.
    ///   - middleware: An optional `RequestMiddleware` instance used to modify requests before execution (default is `nil`).
    ///   - monitors: An optional `RequestMonitor`s list for observing request events.
    ///   - queue: A `DispatchQueue` used for executing networking operations (default is a custom background queue).
    ///   - requestQueue: A `DispatchQueue` used specifically for managing request execution (default is a custom background queue).
    public init(
        session: URLSession,
        delegate: SessionDelegate,
        cache: URLCache? = nil,
        middleware: RequestMiddleware? = nil,
        monitors: [Monitor] = [],
        queue: DispatchQueue = DispatchQueue(label: "com.networking.session.queue")
    ) {

        self.cache = cache
        self.delegate = delegate
        self.middleware = middleware
        self.monitor = CompositeMonitor(monitors: monitors)
        self.queue = queue
        self.session = session

        delegate.monitor = monitor
        delegate.provider = self
    }

    /// Creates and initializes a networking session using default configuration settings.
    ///
    /// This convenience initializer automatically sets up a `URLSession` with a specified configuration, a delegate, and operation queues.
    /// It is useful for quickly setting up a networking session with sensible defaults, while still allowing for customization.
    ///
    /// - Parameters:
    ///   - configuration: A `URLSessionConfiguration` instance that defines behavior for the networking session (default is `.createDefault()`).
    ///   - delegate: A `SessionDelegate` instance responsible for handling session events (default is a new `SessionDelegate` instance).
    ///   - cache: The cache for providing cached responses to requests within the session.
    ///   - middleware: An optional `RequestMiddleware` instance used for modifying requests before execution (default is `nil`).
    ///   - monitors: An optional `RequestMonitor`s list for observing request events.
    ///   - queue: A `DispatchQueue` used for networking operations (default is a custom background queue).
    ///   - requestQueue: A `DispatchQueue` used for handling request execution (default is a custom background queue).
    public convenience init(
        configuration: URLSessionConfiguration = .createDefault(),
        delegate: SessionDelegate = SessionDelegate(),
        cache: URLCache? = nil,
        middleware: RequestMiddleware? = nil,
        monitors: [Monitor] = [],
        queue: DispatchQueue = DispatchQueue(label: "com.networking.session.queue")
    ) {

        let serialQueue = queue === DispatchQueue.main ? queue : DispatchQueue(label: queue.label, target: queue)
        let delegateQueue = OperationQueue.createDefault(with: serialQueue)
        let session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: delegateQueue)

        self.init(
            session: session,
            delegate: delegate,
            cache: cache,
            middleware: middleware,
            monitors: monitors,
            queue: serialQueue
        )
    }

    deinit {
        let error = NetworkingError(kind: .sessionInvalidated, failureReason: "Session deinitialized.")

        activeRequests.forEach { request in
            self.queue.async {
                request.finish(error: error)
            }
        }
        session.invalidateAndCancel()
    }

    // MARK: - Public methods

    /// Cancels all active network requests.
    ///
    /// This method asynchronously iterates through all currently active requests and cancels them.
    public func cancelAllRequests() {
        queue.async {
            self.activeRequests.forEach { $0.cancel() }
        }
    }

    /// Creates and initiates a `DataRequest` using the provided URL, HTTP method, parameters, and additional configuration.
    ///
    /// - Parameters:
    ///   - url: A `URLConvertible` instance representing the endpoint for the request.
    ///   - method: The HTTP method for the request (default is `.get`).
    ///   - parameters: A dictionary of parameters to be included in the request (default is `nil`).
    ///   - encoder: The `ParameterEncoder` used for encoding request parameters (default is `.url`).
    ///   - headers: Additional HTTP headers to be included in the request (default is `nil`).
    ///   - middleware: An optional `RequestMiddleware` to handle pre-processing or modifications before the request is executed (default is `nil`).
    ///   - cachePolicy: The caching policy that defines how network requests should interact with local cache data.
    /// - Returns: A `DataRequest` instance representing the network request, ready for execution.
    open func request(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoder: ParameterEncoder = .url,
        headers: HTTPHeaders? = nil,
        middleware: RequestMiddleware? = nil,
        cachePolicy: URLCachePolicy = .reloadIgnoringLocalCacheData
    ) -> DataRequest {

        let requestBuilder = URLRequestBuilder(
            url: url,
            method: method,
            parameters: parameters,
            encoder: encoder,
            headers: headers
        )

        return request(requestBuilder, middleware: middleware, cachePolicy: cachePolicy)
    }

    /// Creates and initiates a `DataRequest` using the provided request builder and optional middleware.
    ///
    /// This method constructs a `DataRequest` by utilizing the given `RequestBuilder` to configure the request.
    /// Optionally, a `RequestMiddleware` can be applied to modify the request before execution, such as adding headers,
    /// logging, or handling pre-processing logic.
    ///
    /// - Parameters:
    ///   - requestBuilder: An instance conforming to `RequestBuilder`, responsible for constructing a valid `URLRequest`.
    ///   - middleware: An optional `RequestMiddleware` instance that can modify or handle the request before it is executed.
    ///   - cachePolicy: The caching policy that defines how network requests should interact with local cache data.
    /// - Returns: A `DataRequest` instance representing the ongoing network request, which can be monitored, cancelled, or validated.
    open func request(
        _ requestBuilder: RequestBuilder,
        middleware: RequestMiddleware? = nil,
        cachePolicy: URLCachePolicy = .reloadIgnoringLocalCacheData
    ) -> DataRequest {

        let dataRequest = DataRequest(
            requestBuilder: requestBuilder,
            cache: cache,
            cachePolicy: cachePolicy,
            delegate: self,
            middleware: middleware,
            monitor: monitor,
            queue: queue
        )

        perform(dataRequest)

        return dataRequest
    }

    // MARK: - Private methods

    private func configure(_ request: Request, requestBuilder: RequestBuilder) {
        dispatchPrecondition(condition: .onQueue(queue))

        let urlRequest: URLRequest

        do {
            urlRequest = try requestBuilder.build()
        } catch {
            let error =
                error as? NetworkingError
                ?? NetworkingError(
                    kind: .requestCreationFailed,
                    underlyingError: error
                )

            request.didFailToCreateURLRequest(with: error)

            return
        }

        request.didCreateInitial(request: urlRequest)
        request.prepare()

        guard ![.cancelled, .finished].contains(request.state) else { return }

        guard let middleware = middleware(for: request) else {
            didCreate(urlRequest: urlRequest, for: request)
            return
        }

        Task {
            do {
                let interceptedRequest = try await middleware.intercept(urlRequest, for: self)

                queue.async {
                    request.didIntercept(urlRequest, to: interceptedRequest)
                    self.didCreate(urlRequest: urlRequest, for: request)
                }
            } catch {
                queue.async {
                    let error =
                        error as? NetworkingError
                        ?? NetworkingError(
                            kind: .requestInterceptationFailed,
                            underlyingError: error
                        )

                    request.didFailToIntercept(urlRequest, with: error)
                }
            }
        }
    }

    private func didCreate(urlRequest: URLRequest, for request: Request) {
        dispatchPrecondition(condition: .onQueue(queue))

        request.didCreate(urlRequest: urlRequest)

        if request.state != .cancelled {
            let task = session.dataTask(with: urlRequest)

            request.didCreate(task: task)
        }
    }

    private func middleware(for request: Request) -> RequestMiddleware? {
        guard
            /// The local request middleware.
            let requestMiddleware = request.middleware,

            /// The global middleware.
            let sessionMiddleware = middleware
        else {

            return request.middleware ?? middleware
        }

        return Middleware(interceptors: [requestMiddleware, sessionMiddleware], retriers: [])
    }

    private func perform(_ request: Request) {
        queue.async {
            self.activeRequests.insert(request)

            switch request {
            case let dataRequest as DataRequest:
                self.performDataRequest(dataRequest)

            default:
                fatalError("Unsupported request type: \(type(of: request))")
            }
        }
    }

    private func performDataRequest(_ request: DataRequest) {
        dispatchPrecondition(condition: .onQueue(queue))

        configure(request, requestBuilder: request.requestBuilder)
    }

    private func retrier(for request: Request) -> RequestRetrier? {
        guard
            /// The local request middleware.
            let requestMiddleware = request.middleware,

            /// The global middleware.
            let sessionMiddleware = middleware
        else {

            return request.middleware ?? middleware
        }

        return Middleware(interceptors: [], retriers: [requestMiddleware, sessionMiddleware])
    }
}

extension Session: RequestDelegate {
    /// The underlying session configuration used to configure the `Request`.
    public var sessionConfiguration: URLSessionConfiguration {
        session.configuration
    }

    // MARK: - Types

    /// An error type that represents failures encountered during the request retry process.
    ///
    /// `RetryError` is used to capture and describe errors that occur when a retry attempt fails.
    /// It helps distinguish between errors that happen during the retry attempt and the original
    /// error that triggered the retry in the first place.
    public enum RetryError: LocalizedError {
        /// `RequestRetrier` threw an error during the request retry process.
        case retryFailed(error: Error, originalError: Error)

        // MARK: LocalizedError

        /// A localized message describing what error occurred.
        public var errorDescription: String? {
            switch self {
            case let .retryFailed(error, originalError):
                """
                Request retry failed with retry error: \(error.localizedDescription), \
                original error: \(originalError.localizedDescription)
                """
            }
        }
    }

    // MARK: - RequestDelegate

    /// Handles the completion of a network request.
    ///
    /// This method is called when a `Request` instance has successfully completed its lifecycle,
    /// either by receiving a response, completing without errors, or failing due to an error.
    /// It is typically used for finalizing request handling, performing cleanup tasks, logging,
    /// or notifying observers that the request has finished processing.
    ///
    /// - Parameter request: The `Request` instance that has completed.
    public func requestDidComplete(_ request: Request) {
        activeRequests.remove(request)
    }

    /// Retries a request after a specified delay.
    ///
    /// This method is called when a request needs to be retried after a failure.
    ///
    /// - Parameters:
    ///   - request: The `Request` instance that should be retried.
    ///   - delay: The time interval (in seconds) to wait before retrying.
    public func retry(request: Request, after delay: TimeInterval) {
        queue.asyncAfter(deadline: .now() + delay) {
            if request.state != .cancelled {
                request.prepareForRetry()
                self.perform(request)
            }
        }
    }

    /// Determines whether a failed request should be retried.
    ///
    /// This method evaluates the error that caused the request failure and determines
    /// if the request should be retried. It returns a `RetryResult` indicating the
    /// next step.
    ///
    /// - Parameters:
    ///   - request: The `Request` instance that failed.
    ///   - error: The `NetworkingError` that caused the failure.
    /// - Returns: A `RetryResult` indicating whether to retry or not.
    public func retry(request: Request, failedWith error: NetworkingError) async -> RetryPolicy {
        guard let retrier = retrier(for: request) else {
            return .doNotRetry
        }

        let retryPolicy = await retrier.retry(request, for: self, failedWith: error)

        switch retryPolicy {
        case .doNotRetryWithError(let retryError):
            let error = RetryError.retryFailed(error: retryError, originalError: error)

            return .doNotRetryWithError(error)

        default:
            return retryPolicy
        }
    }
}

extension Session: SessionDelegateProvider {

    // MARK: - SessionDelegateProvider

    /// Retrieves the `Request` associated with a given URL session task.
    ///
    /// - Parameter task: The `URLSessionTask` for which to retrieve the request.
    /// - Returns: The corresponding `Request` instance, if available.
    func request(for task: URLSessionTask) -> Request? {
        dispatchPrecondition(condition: .onQueue(queue))

        return activeRequests.first(where: { $0.tasks.contains(task) })
    }

    /// Called when the session becomes invalid due to an error.
    ///
    /// - Parameter error: An optional `Error` indicating why the session became invalid.
    func sessionDidBecomeInvalid(with error: Error?) {
        dispatchPrecondition(condition: .onQueue(queue))

        let error = NetworkingError(kind: .sessionInvalidated, underlyingError: error)
        activeRequests.forEach { $0.finish(error: error) }
    }
}

extension OperationQueue {
    /// Creates a default `OperationQueue` with the provided name.
    ///
    /// - Parameter queue: The worker queue.
    /// - Returns: A new instance of the `OperationQueue`.
    fileprivate static func createDefault(with queue: DispatchQueue) -> OperationQueue {
        let operationQueue = OperationQueue()

        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.name = "\(queue.label).sessionDelegate"
        operationQueue.qualityOfService = .default
        operationQueue.underlyingQueue = queue

        return operationQueue
    }
}
