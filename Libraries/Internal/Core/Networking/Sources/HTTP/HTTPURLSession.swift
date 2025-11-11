//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A class responsible for managing and executing network requests using `URLSession`.
///
/// `HTTPURLSession` handles the lifecycle of network requests, including initialization, execution, monitoring, and
/// cancellation.
/// It integrates with customizable middleware, monitors, and delegates for flexible request handling. The session
/// operates asynchronously
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
open class HTTPURLSession: @unchecked Sendable, Session {
    // MARK: - Private Properties

    private let cache: HTTPURLCache?

    // MARK: - Properties

    /// The list of currently active `Request`s.
    var activeRequests: Set<HTTPURLRequest> = []

    // MARK: - Public Properties

    // swiftlint:disable weak_delegate
    /// The delegate responsible for handling session events such as task completion and failures.
    public let delegate: HTTPURLSessionDelegate
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

    /// A builder responsible for constructing a `URLRequest` with configurable parameters, method, headers, and
    /// encoding.
    ///
    /// `URLRequestBuilder` conforms to the `RequestBuilder` protocol and provides a structured way to build HTTP
    /// requests.
    /// It allows for injecting parameters, encoding strategies, custom headers, and request interceptors.
    ///
    /// This is particularly useful for networking layers that require flexible request construction with support for
    /// various HTTP methods, encoders, and interceptors.
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
        /// - Throws: An error if the request cannot be constructed. This may occur due to invalid URL components,
        /// serialization issues, or missing required fields.
        /// - Returns: A fully configured `URLRequest` instance ready for execution.
        func build() throws -> URLRequest {
            let request = try URLRequest(url: url, method: method, headers: headers)

            return try encoder.encode(parameters, into: request)
        }
    }

    /// A builder responsible for constructing an `UploadRequest` with configurable
    /// parameters, method, headers, body data, and encoding.
    ///
    /// Unlike a `DataRequest`, an `UploadRequest` requires an uploadable body
    /// (such as `Data`, a file `URL`, or an `InputStream`) in addition to the
    /// request configuration.
    ///
    /// ### Example Usage:
    /// ```swift
    /// let builder = ParameterlessRequestBuilder(
    ///     url: "https://api.example.com/upload",
    ///     method: .post,
    ///     parameters: ["name": "file"],
    ///     encoder: JSONParameterEncoder(),
    ///     headers: HTTPHeaders(["Authorization": "Bearer token"]),
    ///     uploadable: .file(URL(fileURLWithPath: "/tmp/video.mp4"), shouldRemove: false)
    /// )
    /// ```
    struct ParameterlessRequestBuilder: RequestBuilder {
        /// The target URL for the HTTP request.
        let url: URLConvertible

        /// The HTTP method to be used for the request (usually `POST` or `PUT`).
        let method: HTTPMethod

        /// Additional HTTP headers to include in the request.
        let headers: HTTPHeaders?

        // MARK: - RequestBuilder

        /// Builds and returns a configured `URLRequest` and the associated `Uploadable`.
        ///
        /// - Throws: An error if the request cannot be constructed.
        /// - Returns: A tuple containing the `URLRequest` and the `Uploadable`.
        func build() throws -> URLRequest {
            let request = try URLRequest(url: url, method: method, headers: headers)

            return request
        }
    }

    /// A composite builder for constructing both an `UploadRequest.Uploadable` and its associated `URLRequest`.
    ///
    /// `Upload` conforms to `UploadBuilder`, combining the responsibilities of
    /// `UploadableBuilder` and `RequestBuilder`. This allows you to represent an upload
    /// operation as a single, reusable unit that knows how to:
    /// - Provide the data to upload.
    /// - Generate the `URLRequest` describing the upload.
    ///
    /// This abstraction is useful in networking layers that handle uploads by decoupling
    /// the request configuration from the actual uploadable content.
    ///
    /// ### Example Usage:
    /// ```swift
    /// let upload = Upload(
    ///     request: URLRequestBuilder(
    ///         url: "https://api.example.com/upload",
    ///         method: .post,
    ///         headers: ["Authorization": "Bearer token"]
    ///     ),
    ///     uploadable: DataUploadBuilder(data: myData)
    /// )
    /// ```
    struct SimpleUploadRequestBuilder: UploadRequestBuilder {
        /// The component responsible for constructing the underlying `URLRequest`.
        let request: any RequestBuilder

        /// The component responsible for constructing the uploadable payload.
        ///
        /// Represents the origin of the content to be uploaded (e.g., raw `Data`, a file on disk,
        /// or an input stream) and defines how it is transformed into an `UploadRequest.Uploadable`
        /// suitable for the upload request.
        let uploadable: any UploadableBuilder

        // MARK: - UploadableBuilder

        /// Produces an `UploadRequest.Uploadable` value from the instance.
        ///
        /// - Returns: The `UploadRequest.Uploadable`.
        /// - Throws:  Any `Error` produced during creation.
        func createUploadable() throws -> HTTPURLUploadRequest.Uploadable {
            try uploadable.createUploadable()
        }

        // MARK: - RequestBuilder

        /// Builds and returns a configured `URLRequest` instance.
        ///
        /// This method should be implemented by conforming types to provide the necessary logic for constructing
        /// a valid HTTP request. The request should include all necessary details such as the URL, HTTP method,
        /// headers, query parameters, and body content.
        ///
        /// - Throws: An error if the request cannot be constructed. This may occur due to invalid URL components,
        /// serialization issues, or missing required fields.
        /// - Returns: A fully configured `URLRequest` instance ready for execution.
        func build() throws -> URLRequest {
            try request.build()
        }
    }

    // MARK: - Initializer

    /// Initializes a custom networking session with the specified configuration and dependencies.
    ///
    /// - Parameters:
    ///   - session: The `URLSession` instance responsible for managing HTTP requests.
    ///   - delegate: The `HTTPURLSessionDelegate` responsible for handling session events, such as task completion and
    /// failures.
    ///   - cache: The cache for providing cached responses to requests within the session.
    ///   - cachePolicy: The caching policy that defines how network requests should interact with local cache data.
    ///   - middleware: An optional `RequestMiddleware` instance used to modify requests before execution (default is
    /// `nil`).
    ///   - monitors: An optional `RequestMonitor`s list for observing request events.
    ///   - queue: A `DispatchQueue` used for executing networking operations (default is a custom background queue).
    ///   - requestQueue: A `DispatchQueue` used specifically for managing request execution (default is a custom
    /// background queue).
    public init(
        session: URLSession,
        delegate: HTTPURLSessionDelegate,
        cache: HTTPURLCache? = nil,
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
    /// This convenience initializer automatically sets up a `URLSession` with a specified configuration, a delegate,
    /// and operation queues.
    /// It is useful for quickly setting up a networking session with sensible defaults, while still allowing for
    /// customization.
    ///
    /// - Parameters:
    ///   - configuration: A `URLSessionConfiguration` instance that defines behavior for the networking session
    /// (default is `.createDefault()`).
    ///   - delegate: A `SessionDelegate` instance responsible for handling session events (default is a new
    /// `SessionDelegate` instance).
    ///   - cache: The cache for providing cached responses to requests within the session.
    ///   - middleware: An optional `RequestMiddleware` instance used for modifying requests before execution (default
    /// is `nil`).
    ///   - monitors: An optional `RequestMonitor`s list for observing request events.
    ///   - queue: A `DispatchQueue` used for networking operations (default is a custom background queue).
    ///   - requestQueue: A `DispatchQueue` used for handling request execution (default is a custom background queue).
    public convenience init(
        configuration: URLSessionConfiguration = .createDefault(),
        delegate: HTTPURLSessionDelegate = HTTPURLSessionDelegate(),
        cache: HTTPURLCache? = nil,
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

        for request in activeRequests {
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

    // MARK: - DataRequest

    /// Creates and initiates a `DataRequest` using the provided URL, HTTP method, parameters, and additional
    /// configuration.
    ///
    /// - Parameters:
    ///   - url: A `URLConvertible` instance representing the endpoint for the request.
    ///   - method: The HTTP method for the request (default is `.get`).
    ///   - parameters: A dictionary of parameters to be included in the request (default is `nil`).
    ///   - encoder: The `ParameterEncoder` used for encoding request parameters (default is `.url`).
    ///   - headers: Additional HTTP headers to be included in the request (default is `nil`).
    ///   - middleware: An optional `RequestMiddleware` to handle pre-processing or modifications before the request is
    /// executed (default is `nil`).
    ///   - cachePolicy: The caching policy that defines how network requests should interact with local cache data.
    /// - Returns: A `DataRequest` instance representing the network request, ready for execution.
    open func request(
        _ url: URLConvertible,
        method: HTTPMethod,
        parameters: Parameters?,
        encoder: ParameterEncoder,
        headers: HTTPHeaders?,
        middleware: RequestMiddleware?,
        cachePolicy: URLCachePolicy
    ) -> any DataRequest {
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
    ///   - requestBuilder: An instance conforming to `RequestBuilder`, responsible for constructing a valid
    /// `URLRequest`.
    ///   - middleware: An optional `RequestMiddleware` instance that can modify or handle the request before it is
    /// executed.
    ///   - cachePolicy: The caching policy that defines how network requests should interact with local cache data.
    /// - Returns: A `DataRequest` instance representing the ongoing network request, which can be monitored, cancelled,
    /// or validated.
    open func request(
        _ requestBuilder: RequestBuilder,
        middleware: RequestMiddleware?,
        cachePolicy: URLCachePolicy
    ) -> any DataRequest {
        let dataRequest = HTTPURLDataRequest(
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

    // MARK: - UploadRequest

    /// Creates and initiates an `UploadRequest` for uploading `Data` to the specified endpoint.
    ///
    /// This method builds a `URLRequest` using the provided URL, HTTP method, headers, and optional
    /// request modifications. The upload is then managed by the returned `UploadRequest`, which supports
    /// additional features like interceptors and custom file management.
    ///
    /// - Parameters:
    ///   - data: The `Data` to upload.
    ///   - url: A `URLConvertible` value representing the endpoint for the request.
    ///   - method: The `HTTPMethod` for the request. Defaults to `.post`.
    ///   - headers: Additional `HTTPHeaders` to include in the request. Defaults to `nil`.
    ///   - middleware: An optional `RequestMiddleware` instance that can modify or handle the request before it is
    /// executed.
    /// - Returns: An `UploadRequest` instance representing the upload operation, ready for execution.
    open func upload(
        _ data: Data,
        to url: any URLConvertible,
        method: HTTPMethod,
        headers: HTTPHeaders?,
        middleware: RequestMiddleware?
    ) -> any UploadRequest {
        let requestBuilder = ParameterlessRequestBuilder(url: url, method: method, headers: headers)

        return upload(data, with: requestBuilder, middleware: middleware)
    }

    /// Creates an `UploadRequest` to send raw `Data` to a server using the provided request configuration.
    ///
    /// This method builds and initiates an `UploadRequest` by combining the provided raw `Data` payload
    /// with a `RequestBuilder`, which is responsible for constructing the base `URLRequest`.
    /// Optionally, a `RequestMiddleware` can be applied to intercept or modify the request before
    /// it is executed (e.g., to inject headers, perform logging, or apply custom pre-processing logic).
    ///
    /// - Parameters:
    ///   - data: The `Data` payload to be uploaded.
    ///   - requestBuilder: A `RequestBuilder` instance responsible for generating the `URLRequest`
    ///     configuration (e.g., URL, HTTP method, headers).
    ///   - middleware: An optional `RequestMiddleware` that can modify or inspect the request before
    ///     execution. Defaults to `nil`.
    /// - Returns: An `UploadRequest` configured with the given `Data` and request parameters.
    open func upload(
        _ data: Data,
        with requestBuilder: any RequestBuilder,
        middleware: RequestMiddleware?
    ) -> any UploadRequest {
        upload(.data(data), with: requestBuilder, middleware: middleware)
    }

    /// Creates and initiates an `UploadRequest` for uploading `file URL` to the specified endpoint.
    ///
    /// This method builds a `URLRequest` using the provided URL, HTTP method, headers, and optional
    /// request modifications. The upload is then managed by the returned `UploadRequest`, which supports
    /// additional features like interceptors and custom file management.
    ///
    /// - Parameters:
    ///   - fileURL: The `URL` of the file to upload.
    ///   - url: A `URLConvertible` value representing the endpoint for the request.
    ///   - method: The `HTTPMethod` for the request. Defaults to `.post`.
    ///   - headers: Additional `HTTPHeaders` to include in the request. Defaults to `nil`.
    ///   - fileManager: `FileManager` instance to be used by the returned `UploadRequest`. `.default` instance by
    /// default.
    ///   - middleware: An optional `RequestMiddleware` instance that can modify or handle the request before it is
    /// executed.
    /// - Returns: An `UploadRequest` instance representing the upload operation, ready for execution.
    open func upload(
        _ fileURL: URL,
        to url: any URLConvertible,
        method: HTTPMethod,
        headers: HTTPHeaders?,
        fileManager: FileManager,
        middleware: RequestMiddleware?
    ) -> any UploadRequest {
        let requestBuilder = ParameterlessRequestBuilder(url: url, method: method, headers: headers)

        return upload(fileURL, with: requestBuilder, fileManager: fileManager, middleware: middleware)
    }

    /// Creates an `UploadRequest` to send `file URL` to a server using the provided request configuration.
    ///
    /// This method builds and initiates an `UploadRequest` by combining the provided `file URL` payload
    /// with a `RequestBuilder`, which is responsible for constructing the base `URLRequest`.
    /// Optionally, a `RequestMiddleware` can be applied to intercept or modify the request before
    /// it is executed (e.g., to inject headers, perform logging, or apply custom pre-processing logic).
    ///
    /// - Parameters:
    ///   - fileURL: The `URL` of the file to upload.
    ///   - requestBuilder: A `RequestBuilder` instance responsible for generating the `URLRequest`
    ///     configuration (e.g., URL, HTTP method, headers).
    ///   - fileManager: `FileManager` instance to be used by the returned `UploadRequest`. `.default` instance by
    /// default.
    ///   - middleware: An optional `RequestMiddleware` that can modify or inspect the request before
    ///     execution. Defaults to `nil`.
    /// - Returns: An `UploadRequest` configured with the given `file URL` and request parameters.
    open func upload(
        _ fileURL: URL,
        with requestBuilder: any RequestBuilder,
        fileManager: FileManager,
        middleware: RequestMiddleware?
    ) -> any UploadRequest {
        upload(
            .file(fileURL, shouldRemove: false),
            with: requestBuilder,
            fileManager: fileManager,
            middleware: middleware
        )
    }

    // MARK: - Private methods

    private func configure(_ request: HTTPURLDataRequest, requestBuilder: RequestBuilder) {
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
                    self.didCreate(urlRequest: interceptedRequest, for: request)
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

    private func didCreate(urlRequest: URLRequest, for request: HTTPURLRequest) {
        dispatchPrecondition(condition: .onQueue(queue))

        request.didCreate(urlRequest: urlRequest)

        if request.state != .cancelled {
            do {
                let task = try request.task(for: urlRequest, using: session)
                request.didCreate(task: task)
            } catch {
                request.didFailToCreateTask(with: error)

                return
            }
        }
    }

    private func middleware(for request: HTTPURLRequest) -> RequestMiddleware? {
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

    private func perform(_ request: HTTPURLRequest) {
        queue.async {
            self.activeRequests.insert(request)

            switch request {
            // UploadRequest must come before DataRequest due to subtype relationship.
            case let uploadRequest as HTTPURLUploadRequest:
                self.performUploadRequest(uploadRequest)

            case let dataRequest as HTTPURLDataRequest:
                self.performDataRequest(dataRequest)

            default:
                fatalError("Unsupported request type: \(type(of: request))")
            }
        }
    }

    private func performDataRequest(_ request: HTTPURLDataRequest) {
        dispatchPrecondition(condition: .onQueue(queue))

        configure(request, requestBuilder: request.requestBuilder)
    }

    private func performUploadRequest(_ request: HTTPURLUploadRequest) {
        dispatchPrecondition(condition: .onQueue(queue))

        let uploadable: HTTPURLUploadRequest.Uploadable

        do {
            uploadable = try request.uploadableBuilder.createUploadable()
            request.didCreateUploadable(uploadable)
        } catch {
            let error =
                error as? NetworkingError
                    ?? NetworkingError(
                        kind: .createUploadableFailed,
                        underlyingError: error
                    )

            request.didFailToCreateUploadable(with: error)

            return
        }

        configure(request, requestBuilder: request.requestBuilder)
    }

    private func retrier(for request: HTTPURLRequest) -> RequestRetrier? {
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

    private func upload(
        _ uploadable: HTTPURLUploadRequest.Uploadable,
        with requestBuilder: any RequestBuilder,
        fileManager: FileManager? = nil,
        middleware: RequestMiddleware?
    ) -> any UploadRequest {
        let uploadBuilder = SimpleUploadRequestBuilder(request: requestBuilder, uploadable: uploadable)

        return upload(uploadBuilder, fileManager: fileManager, middleware: middleware)
    }

    private func upload(
        _ uploadBuilder: any UploadRequestBuilder,
        fileManager: FileManager? = nil,
        middleware: RequestMiddleware?
    ) -> any UploadRequest {
        let uploadRequest = HTTPURLUploadRequest(
            uploadBuilder: uploadBuilder,
            delegate: self,
            fileManager: fileManager,
            middleware: middleware,
            monitor: monitor,
            queue: queue
        )

        perform(uploadRequest)

        return uploadRequest
    }
}

extension HTTPURLSession: HTTPURLRequestDelegate {
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
    public func cleanup(_ request: HTTPURLRequest) {
        activeRequests.remove(request)
    }

    /// Retries a request after a specified delay.
    ///
    /// This method is called when a request needs to be retried after a failure.
    ///
    /// - Parameters:
    ///   - request: The `HTTPURLRequest` instance that should be retried.
    ///   - delay: The time interval (in seconds) to wait before retrying.
    public func retry(request: HTTPURLRequest, after delay: TimeInterval) {
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
    public func retry(request: HTTPURLRequest, failedWith error: NetworkingError) async -> RetryPolicy {
        guard let retrier = retrier(for: request) else {
            return .doNotRetry
        }

        let retryPolicy = await retrier.retry(request, for: self, failedWith: error)

        switch retryPolicy {
        case let .doNotRetryWithError(retryError):
            let error = RetryError.retryFailed(error: retryError, originalError: error)

            return .doNotRetryWithError(error)

        default:
            return retryPolicy
        }
    }
}

extension HTTPURLSession: HTTPURLSessionDelegateProvider {
    // MARK: - SessionDelegateProvider

    /// Retrieves the `Request` associated with a given URL session task.
    ///
    /// - Parameter task: The `URLSessionTask` for which to retrieve the request.
    /// - Returns: The corresponding `Request` instance, if available.
    func request(for task: URLSessionTask) -> HTTPURLRequest? {
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
