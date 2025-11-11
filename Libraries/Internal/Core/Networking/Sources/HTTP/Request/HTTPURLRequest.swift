//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A delegate protocol that defines methods for handling request retries.
///
/// The `HTTPURLRequestDelegate` protocol provides methods for retrying failed requests,
/// either immediately or after a specified delay. Conforming types are responsible
/// for implementing custom retry logic based on the error encountered.
public protocol HTTPURLRequestDelegate: AnyObject, Sendable {
    /// The underlying session configuration used to configure the `Request`.
    var sessionConfiguration: URLSessionConfiguration { get }

    /// Handles the completion of a network request.
    ///
    /// This method is called when a `Request` instance has successfully completed its lifecycle,
    /// either by receiving a response, completing without errors, or failing due to an error.
    /// It is typically used for finalizing request handling, performing cleanup tasks, logging,
    /// or notifying observers that the request has finished processing.
    ///
    /// - Parameter request: The `Request` instance that has completed.
    func cleanup(_ request: HTTPURLRequest)

    /// Retries a request after a specified delay.
    ///
    /// This method is called when a request needs to be retried after a failure.
    ///
    /// - Parameters:
    ///   - request: The `Request` instance that should be retried.
    ///   - delay: The time interval (in seconds) to wait before retrying.
    func retry(request: HTTPURLRequest, after delay: TimeInterval)

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
    func retry(request: HTTPURLRequest, failedWith error: NetworkingError) async -> RetryPolicy
}

/// Represents a network request and its lifecycle.
///
/// The `HTTPURLRequest` class manages the execution, state, and retries of a network request.
/// It includes monitoring capabilities, request serialization, and task management.
///
/// - Important: This class is marked as `@unchecked Sendable` due to the use of
///   `@Protected` properties, which need manual synchronization.
///
/// - Note: The request transitions through various states, including `.initialized`,
///   `.resumed`, `.suspended`, `.cancelled`, `.finishing`, and `.finished`.
///
/// Example usage:
/// ```swift
/// let request = HTTPURLRequest(monitor: nil, queue: DispatchQueue(label: "network.queue"))
/// request.resume()
/// ```
public class HTTPURLRequest: @unchecked Sendable, Request {
    /// A typealias for request validation.
    typealias RequestValidator = @Sendable () -> Void

    /// A typealias for response serialization closure.
    typealias ResponseSerializer = @Sendable () -> Void

    // MARK: - Private Properties

    @Protected private var hasProcessedSerializers = false

    // MARK: - Properties

    /// The serial queue for all internal async actions.
    let queue: DispatchQueue

    /// The list of the `URLRequest` associated to this `Request`.
    @Protected private(set) var requests: [URLRequest] = []

    /// The response serializers associated to this `Request`.
    @Protected private(set) var responseSerializers: [ResponseSerializer] = []

    /// `Validator` callback closures that store the validation calls enqueued.
    @Protected var validators: [RequestValidator] = []

    // MARK: - Public Properties

    /// A unique identifier for the request.
    public let id: UUID

    /// The delegate responsible for handling retries.
    public private(set) weak var delegate: HTTPURLRequestDelegate?

    /// `HTTPURLResponse` received from the server, if any. If the `Request` was retried, this is the response of the
    /// last `URLSessionTask`.
    public internal(set) var response: HTTPURLResponse?

    /// An optional request interceptor for intercepting the request.
    public let middleware: RequestMiddleware?

    /// An optional request monitor for tracking lifecycle events.
    public let monitor: Monitor?

    /// The error associated with the request, if any.
    @Protected public internal(set) var error: NetworkingError?

    /// The collected metrics from URLSession tasks.
    @Protected public private(set) var metrics: [URLSessionTaskMetrics] = []

    /// The current retry count for this request.
    @Protected public private(set) var retryCount = 0

    /// The current state of the request.
    @Protected public internal(set) var state: State = .initialized

    /// The active `URLSessionTask` instances associated with this request.
    @Protected public private(set) var tasks: [URLSessionTask] = []

    // MARK: - Computed Properties

    /// The acceptable status codes.
    var acceptableStatusCodes: Range<Int> {
        200 ..< 300
    }

    /// Current `URLRequest` created on behalf of the `Request`.
    public var request: URLRequest? {
        requests.last
    }

    // MARK: - Types

    /// Represents the possible states of an operation or process.
    public enum State {
        /// The operation has been explicitly cancelled and cannot proceed further.
        case cancelled

        /// The operation has successfully completed.
        case finished

        /// The operation is finishing.
        case finishing

        /// The operation has been initialized but has not yet started execution.
        case initialized

        /// The operation is actively running or executing.
        case resumed

        /// The operation is temporarily paused and can be resumed later.
        case suspended

        // MARK: - Instance methods

        /// Determines whether a transition from the current state to a given state is valid.
        ///
        /// This function evaluates the current state and checks if transitioning to the specified
        /// state is allowed based on predefined rules. It ensures that only legal state transitions
        /// occur within the system.
        ///
        /// - Parameter state: The target `State` to which a transition is being requested.
        /// - Returns: `true` if the transition is allowed, `false` otherwise.
        func canTransition(to state: State) -> Bool {
            switch (self, state) {
            case (.initialized, _),
                 (.finishing, .finished),
                 (.finishing, .cancelled),
                 (.resumed, .cancelled),
                 (.resumed, .finishing),
                 (.resumed, .suspended),
                 (.suspended, .cancelled),
                 (.suspended, .finishing),
                 (.suspended, .resumed),
                 (_, .finished):
                true

            case (_, .initialized),
                 (.cancelled, _),
                 (.finished, _),
                 (.finishing, .finishing),
                 (.finishing, .resumed),
                 (.finishing, .suspended),
                 (.suspended, .suspended),
                 (.resumed, .resumed):
                false
            }
        }
    }

    // MARK: - Initializer

    /// Initializes a new request.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the request.
    ///   - delegate: The delegate responsible for handling retries.
    ///   - middleware: An optional request interceptor for intercepting the request.
    ///   - monitor: An optional request monitor.
    ///   - queue: The dispatch queue for processing tasks.
    init(
        id: UUID = UUID(),
        delegate: HTTPURLRequestDelegate?,
        middleware: RequestMiddleware?,
        monitor: Monitor?,
        queue: DispatchQueue
    ) {
        self.id = id
        self.delegate = delegate
        self.middleware = middleware
        self.monitor = monitor
        self.queue = queue
    }

    // MARK: - LifeCycle methods

    /// Final cleanup step executed when the instance finishes response serialization.
    func cleanup() {
        delegate?.cleanup(self)
    }

    /// Handles the cancellation of the request.
    ///
    /// This method ensures the request is properly marked as cancelled,
    /// setting the appropriate error if it has not already been assigned.
    ///
    /// - Note: This method must be called on the request's internal queue.
    func didCancel() {
        dispatchPrecondition(condition: .onQueue(queue))

        error = error ?? NetworkingError(kind: .explicitlyCancelled, failureReason: "Request Explicitly Cancelled")
        monitor?.requestDidCancel(self)
    }

    /// Handles the cancellation of a `URLSessionTask`.
    ///
    /// This method is called when a network task is explicitly cancelled. It ensures that the cancellation
    /// is processed on the appropriate dispatch queue to maintain thread safety and informs the associated
    /// request monitor of the cancellation event.
    ///
    /// The cancellation of a task might occur due to user actions, timeouts, or manual intervention.
    /// Notifying the monitor allows for logging, debugging, or any additional side effects needed upon cancellation.
    ///
    /// - Parameter task: The `URLSessionTask` instance that was cancelled.
    func didCancel(task: URLSessionTask) {
        dispatchPrecondition(condition: .onQueue(queue))

        monitor?.request(self, didCancelTask: task)
    }

    /// Handles the completion of a request task.
    ///
    /// This method is triggered when a `URLSessionTask` finishes execution.
    /// It sets any encountered error and notifies the request monitor.
    ///
    /// - Parameters:
    ///   - task: The `URLSessionTask` that completed.
    ///   - error: An optional `NetworkingError` encountered during execution.
    func didComplete(task: URLSessionTask, error: NetworkingError?) {
        dispatchPrecondition(condition: .onQueue(queue))

        self.error = self.error ?? error

        response = task.response as? HTTPURLResponse
        validators.forEach { $0() }

        monitor?.request(self, didCompleteTask: task, with: self.error)
        retryOrFinish(error: self.error)
    }

    /// Handles the creation of the initial `URLRequest` for the request.
    ///
    /// - Parameter request: The initial `URLRequest` created for execution.
    func didCreateInitial(request: URLRequest) {
        dispatchPrecondition(condition: .onQueue(queue))

        requests.append(request)
        monitor?.request(self, didCreateInitialURLRequest: request)
    }

    /// Handles the creation of a new `URLSessionTask` for the request.
    ///
    /// - Parameter task: The `URLSessionTask` that was created.
    func didCreate(task: URLSessionTask) {
        dispatchPrecondition(condition: .onQueue(queue))

        tasks.append(task)
        monitor?.request(self, didCreateTask: task)

        switch state {
        case .initialized, .finished, .finishing:
            break

        case .cancelled:
            task.resume()
            task.cancel()

            queue.async {
                self.didCancel(task: task)
            }

        case .resumed:
            task.resume()

            queue.async {
                self.didResume(task: task)
            }

        case .suspended:
            task.suspend()

            queue.async {
                self.didSuspend(task: task)
            }
        }
    }

    /// Handles the creation of a `URLRequest` for the request.
    ///
    /// - Parameter request: The initial `URLRequest` created for execution.
    func didCreate(urlRequest: URLRequest) {
        dispatchPrecondition(condition: .onQueue(queue))

        monitor?.request(self, didCreateURLRequest: urlRequest)
    }

    /// Handles a failure when creating a `URLRequest`.
    ///
    /// If the request fails to be created, this method assigns the error,
    /// notifies the monitor, and attempts to retry or finish the request.
    ///
    /// - Parameter error: The `NetworkingError` encountered during request creation.
    func didFailToCreateURLRequest(with error: NetworkingError) {
        dispatchPrecondition(condition: .onQueue(queue))

        self.error = error

        monitor?.request(self, didFailToCreateURLRequestWithError: error)
        retryOrFinish(error: error)
    }

    /// Handles a failure that occurs during the interception of a `URLRequest`.
    ///
    /// This method is triggered when an attempt to intercept and modify a request fails, typically due to a
    /// `NetworkingError`.
    ///
    /// - Parameters:
    ///   - request: The `URLRequest` that failed during interception.
    ///   - error: The `NetworkingError` encountered during the interception attempt.
    func didFailToIntercept(_ request: URLRequest, with error: NetworkingError) {
        dispatchPrecondition(condition: .onQueue(queue))

        self.error = error

        monitor?.request(self, didFailToIntercept: request, with: error)

        retryOrFinish(error: error)
    }

    /// Handles a failure encountered by a `URLSessionTask`.
    ///
    /// This method is called when a `URLSessionTask` encounters an error,
    /// ensuring the error is recorded and notifying the monitor.
    ///
    /// - Parameters:
    ///   - task: The `URLSessionTask` that failed.
    ///   - error: The `NetworkingError` encountered.
    func didFail(task: URLSessionTask, with error: NetworkingError) {
        dispatchPrecondition(condition: .onQueue(queue))

        self.error = error
        monitor?.request(self, didFailTask: task, with: error)
    }

    /// Handles the failure to create a URLSession task for this request.
    ///
    ///
    /// - Parameter error: The `NetworkingError` describing why the task creation failed.
    func didFailToCreateTask(with error: NetworkingError) {
        dispatchPrecondition(condition: .onQueue(queue))

        self.error = error
        monitor?.request(self, didFailToCreateTaskWithError: error)
    }

    /// Gathers performance metrics for the request.
    ///
    /// This method is called when `URLSessionTaskMetrics` become available,
    /// storing them for later analysis and notifying the monitor.
    ///
    /// - Parameter metrics: The collected `URLSessionTaskMetrics` for the request.
    func didGatherMetrics(_ metrics: URLSessionTaskMetrics) {
        dispatchPrecondition(condition: .onQueue(queue))

        self.metrics.append(metrics)

        monitor?.request(self, didGatherMetrics: metrics)
    }

    /// Handles the successful interception and modification of a `URLRequest`.
    /// This method is called when an initial network request has been intercepted and modified successfully.
    ///
    /// - Parameters:
    ///   - initialRequest: The original `URLRequest` before any modifications were applied.
    ///   - request: The modified `URLRequest` after interception, ready to be sent.
    func didIntercept(_ initialRequest: URLRequest, to request: URLRequest) {
        dispatchPrecondition(condition: .onQueue(queue))

        requests.append(request)

        monitor?.request(self, didIntercept: initialRequest, to: request)
    }

    /// Handles when the request is resumed.
    ///
    /// This method notifies the monitor that the request has resumed execution.
    func didResume() {
        dispatchPrecondition(condition: .onQueue(queue))

        monitor?.requestDidResume(self)
    }

    /// Handles when a specific task within the request is resumed.
    ///
    /// - Parameter task: The `URLSessionTask` that was resumed.
    func didResume(task: URLSessionTask) {
        dispatchPrecondition(condition: .onQueue(queue))

        monitor?.request(self, didResumeTask: task)
    }

    /// Handles when the request is suspended.
    ///
    /// This method notifies the monitor that the request has been paused.
    func didSuspend() {
        dispatchPrecondition(condition: .onQueue(queue))

        monitor?.requestDidSuspend(self)
    }

    /// Handles when a specific task within the request is suspended.
    ///
    /// - Parameter task: The `URLSessionTask` that was suspended.
    func didSuspend(task: URLSessionTask) {
        dispatchPrecondition(condition: .onQueue(queue))

        monitor?.request(self, didSuspendTask: task)
    }

    /// Finalizes the request and marks it as finishing.
    ///
    /// This method ensures that the request is transitioning to a finishing state
    /// before running response serializers and notifying the monitor.
    ///
    /// - Parameter error: An optional `NetworkingError` encountered before finishing.
    func finish(error: NetworkingError? = nil) {
        dispatchPrecondition(condition: .onQueue(queue))

        if state.canTransition(to: .finishing) {
            state = .finishing

            monitor?.requestIsFinishing(self)

            if let error {
                self.error = error
            }

            processSerializers()
            monitor?.requestDidFinish(self)
        }
    }

    /// Prepares the request for execution.
    ///
    /// This method ensures that the preparation logic is executed on the correct dispatch queue.
    func prepare() {
        dispatchPrecondition(condition: .onQueue(queue))

        monitor?.requestIsPreparing(self)
    }

    /// Prepares the request for a retry attempt by resetting its state and incrementing the retry count.
    ///
    /// This method is called when a request is scheduled for a retry. It performs the following actions:
    /// 1. Ensures thread safety by verifying that the function is executed on the correct dispatch queue.
    /// 2. Increments the `retryCount` property to track the number of retry attempts made.
    /// 3. Calls `reset()` to clear any existing errors, reinitialize the state, and remove response serializers.
    /// 4. Notifies the associated `monitor` that the request is being retried, allowing for logging, tracking, or
    /// custom actions.
    ///
    /// This method is typically used in network request frameworks where retries are automatically managed based on
    /// response failures
    /// or retry policies.
    func prepareForRetry() {
        dispatchPrecondition(condition: .onQueue(queue))

        retryCount += 1
        reset()

        monitor?.requestIsRetrying(self)
    }

    /// Determines whether the request should be retried or finished.
    ///
    /// If the request encountered an error, this method evaluates whether it should be retried
    /// based on the `RequestDelegate`. If retrying is not allowed, the request is marked as finished.
    ///
    /// - Parameter error: The `NetworkingError` encountered.
    func retryOrFinish(error: NetworkingError?) {
        dispatchPrecondition(condition: .onQueue(queue))

        guard
            /// The request delegate responsible for handling retries.
            let delegate,

            /// The underlying error that triggered the retry decision.
            let error,

            /// Ensure the request is not already cancelled.
            state != .cancelled
        else {
            finish(error: error)
            return
        }

        Task {
            let result = await delegate.retry(request: self, failedWith: error)

            switch result {
            case .doNotRetry:
                queue.async {
                    self.finish(error: error)
                }

            case let .doNotRetryWithError(error):
                let error =
                    error as? NetworkingError
                        ?? NetworkingError(
                            kind: .requestRetryFailed,
                            underlyingError: error
                        )

                queue.async {
                    self.finish(error: error)
                }

            case let .retry(delay):
                delegate.retry(request: self, after: delay)
            }
        }
    }

    // swiftlint:disable unavailable_function

    /// Called when creating a `URLSessionTask` for this `Request`. Subclasses must override.
    ///
    /// - Parameters:
    ///   - urlRequest: `URLRequest` to use to create the `URLSessionTask`.
    ///   - session: `URLSession` which creates the `URLSessionTask`.
    ///
    /// - Returns:   The `URLSessionTask` created.
    func task(for urlRequest: URLRequest, using session: URLSession) throws(NetworkingError) -> URLSessionTask {
        fatalError("Subclasses must override.")
    }

    // swiftlint:enable unavailable_function

    // MARK: - Instance methods

    /// Resets the request's state to its initial configuration.
    ///
    /// This method clears the internal state of the request by performing the following actions:
    /// 1. Sets the `error` property to `nil`, effectively clearing any previously encountered errors.
    /// 2. Resets the `state` property to `.initialized`, preparing the request for a fresh start.
    /// 3. Removes all registered response serializers from the `responseSerializers` array.
    ///
    /// This function is useful for reinitializing a request instance without creating a new object,
    /// particularly in scenarios where you want to retry a request from a clean state or reuse the same instance.
    func reset() {
        error = nil
        hasProcessedSerializers = false
    }

    // MARK: - Public methods

    /// Cancels the request, if allowed.
    ///
    /// - Returns: The current `Request` instance.
    @discardableResult
    public func cancel() -> Self {
        if state.canTransition(to: .cancelled) {
            state = .cancelled
            queue.async {
                self.didCancel()
            }
        }

        return self
    }

    /// Resumes the request, if allowed.
    ///
    /// - Returns: The current `Request` instance.
    @discardableResult
    public func resume() -> Self {
        if state.canTransition(to: .resumed) {
            state = .resumed

            queue.async {
                self.didResume()
            }

            if let task = tasks.last, task.state != .completed {
                task.resume()

                queue.async {
                    self.didResume(task: task)
                }
            }
        }

        return self
    }

    /// Suspends the request, if allowed.
    ///
    /// - Returns: The current `Request` instance.
    @discardableResult
    public func suspend() -> Self {
        if state.canTransition(to: .suspended) {
            state = .suspended

            queue.async {
                self.didSuspend()
            }

            guard let task = tasks.last, task.state != .completed else {
                return self
            }

            task.suspend()
            queue.async {
                self.didSuspend(task: task)
            }
        }

        return self
    }

    // MARK: - Serializer methods

    /// Appends a response serializer to the request and processes it if applicable.
    ///
    /// This method adds a response serializer to the `responseSerializers` queue, ensuring that the response data
    /// is properly processed once the request completes. If the request has already finished, it transitions
    /// back to a resumed state before processing serializers asynchronously.
    ///
    /// The method also ensures that if serializers have already been processed (`hasProcessedSerializers == true`),
    /// they will be reprocessed on a background queue. Additionally, if the request state allows transitioning
    /// to `.resumed`, the request is resumed asynchronously.
    ///
    /// - Parameter serializer: A closure responsible for serializing the response data.
    func appendResponseSerializer(_ serializer: @escaping ResponseSerializer) {
        responseSerializers.append(serializer)

        if state == .finished {
            state = .resumed
        }

        if hasProcessedSerializers {
            queue.async {
                self.processSerializers()
            }
        }

        if state.canTransition(to: .resumed) {
            resume()
        }
    }

    // MARK: - Validation methods

    /// Validates whether the response's status code is within an acceptable range.
    ///
    /// This method checks if the provided `HTTPURLResponse` contains a status code that is considered valid.
    /// If the status code is not within the allowed range, a `NetworkingError.responseValidationFailed` is thrown.
    ///
    /// - Parameters:
    ///   - acceptableStatusCodes: A sequence of acceptable HTTP status codes.
    ///   - response: The `HTTPURLResponse` object to validate.
    /// - Throws: A `NetworkingError.responseValidationFailed` if the status code is not within the acceptable range.
    func validate<S: Sequence>(
        acceptableStatusCodes: S,
        response: HTTPURLResponse
    ) throws where S.Iterator.Element == Int {
        guard !acceptableStatusCodes.contains(response.statusCode) else {
            return
        }

        throw NetworkingError(
            kind: .responseValidationFailed,
            failureReason: "Unacceptable status code: \(response.statusCode)"
        )
    }

    // MARK: - Private methods

    private func processSerializers() {
        let serializers = responseSerializers

        hasProcessedSerializers = true
        serializers.forEach { $0() }

        responseSerializers.removeAll()
        cleanup()

        if state.canTransition(to: .finished) {
            state = .finished
        }
    }
}

extension HTTPURLRequest: Equatable {
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: HTTPURLRequest, rhs: HTTPURLRequest) -> Bool {
        lhs.id == rhs.id
    }
}

extension HTTPURLRequest: Hashable {
    /// Hashes the essential components of this value by feeding them into the
    /// given hasher.
    ///
    /// - Parameter hasher: The hasher to use when combining the components of this instance.
    public func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}

extension HTTPURLRequest {
    /// A textual representation of this instance, suitable for debugging.
    public var debugDescription: String {
        guard
            /// The last request sent.
            let request = requests.last,

            /// The url of the rquest.
            let url = request.url,

            /// The HTTPMethod of the request.
            let method = request.httpMethod
        else {
            return "$ curl command could not be created"
        }

        var components = ["$ curl -v"]

        components.append("-X \(method)")

        var headers = HTTPHeaders()

        if let sessionHeaders = delegate?.sessionConfiguration.headers {
            for header in sessionHeaders where header.name != "Cookie" {
                headers[header.name] = header.value
            }
        }

        for header in request.allHTTPHeaders {
            headers[header.name] = header.value
        }

        for header in headers {
            let escapedValue = header.value.replacingOccurrences(of: "\"", with: "\\\"")
            components.append("-H \"\(header.name): \(escapedValue)\"")
        }

        if /// The body data.
            let httpBodyData = request.httpBody,

            /// The string representation of the body.
            let httpBody = String(data: httpBodyData, encoding: .utf8) {
            var escapedBody = httpBody.replacingOccurrences(of: "\\\"", with: "\\\\\"")
            escapedBody = escapedBody.replacingOccurrences(of: "\"", with: "\\\"")

            components.append("-d \"\(escapedBody)\"")
        }

        components.append("\"\(url.absoluteString)\"")

        return components.joined(separator: " \\\n\t")
    }
}
