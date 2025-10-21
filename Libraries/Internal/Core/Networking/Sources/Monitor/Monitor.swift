//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A protocol designed to monitor the lifecycle of network requests and URLSession tasks.
///
/// `RequestMonitor` provides hooks for various stages of a network request's lifecycle, allowing developers to log,
/// analyze,
/// or modify requests as needed. This includes monitoring task creation, validation, completion, failures, and retries.
/// It also integrates with `URLSessionDelegate` methods for deeper network session tracking.
///
/// Implementing this protocol allows you to build custom monitoring systems for network activity, such as logging
/// tools,
/// performance trackers, or analytics modules.
///
/// - Conforms to: `Sendable`
public protocol Monitor: Sendable {
    /// The working queue.
    var queue: DispatchQueue { get }

    // MARK: - Request Monitoring

    /// Called when a request is canceled.
    ///
    /// - Parameter request: The `Request` instance that was canceled.
    func requestDidCancel(_ request: any Request)

    /// Called when a request finishes successfully.
    ///
    /// - Parameter request: The `Request` instance that completed.
    func requestDidFinish(_ request: any Request)

    /// Called when a request is resumed after being suspended.
    ///
    /// - Parameter request: The `Request` instance that resumed execution.
    func requestDidResume(_ request: any Request)

    /// Called when a request is suspended.
    ///
    /// - Parameter request: The `Request` instance that was suspended.
    func requestDidSuspend(_ request: any Request)

    /// Called when a request is transitioning to a finished state.
    ///
    /// - Parameter request: The `Request` instance preparing to finish.
    func requestIsFinishing(_ request: any Request)

    /// Called when a request is being prepared.
    ///
    /// - Parameter request: The `Request` instance that is being prepared.
    func requestIsPreparing(_ request: any Request)

    /// Called when a request is being retried.
    ///
    /// - Parameter request: The `Request` instance that is being retried.
    func requestIsRetrying(_ request: any Request)

    /// Called when a URLSession task tied to the request is canceled.
    ///
    /// - Parameters:
    ///   - request: The `Request` associated with the canceled task.
    ///   - task: The `URLSessionTask` that was canceled.
    func request(_ request: any Request, didCancelTask task: URLSessionTask)

    /// Called when a URLSession task completes with or without an error.
    ///
    /// - Parameters:
    ///   - request: The `Request` associated with the completed task.
    ///   - task: The `URLSessionTask` that completed.
    ///   - error: The `NetworkingError` encountered, if any.
    func request(_ request: any Request, didCompleteTask task: URLSessionTask, with error: NetworkingError?)

    /// Called when a `URLRequest` is successfully created.
    ///
    /// - Parameters:
    ///   - request: The `Request` instance that created the URL request.
    ///   - urlRequest: The created `URLRequest` object.
    func request(_ request: any Request, didCreateURLRequest urlRequest: URLRequest)

    /// Called when the initial `URLRequest` for a request is created.
    ///
    /// - Parameters:
    ///   - request: The `Request` instance associated with the initial URL request.
    ///   - urlRequest: The initial `URLRequest` that was created.
    func request(_ request: any Request, didCreateInitialURLRequest urlRequest: URLRequest)

    /// Called when a new `URLSessionTask` is created for the request.
    ///
    /// - Parameters:
    ///   - request: The `Request` instance for which the task was created.
    ///   - task: The `URLSessionTask` that was created.
    func request(_ request: any Request, didCreateTask task: URLSessionTask)

    /// Called when a task fails with a specific error.
    ///
    /// - Parameters:
    ///   - request: The `Request` instance associated with the failed task.
    ///   - task: The `URLSessionTask` that failed.
    ///   - error: The `NetworkingError` that caused the failure.
    func request(_ request: any Request, didFailTask task: URLSessionTask, with error: NetworkingError)

    /// Called when request interception fails.
    ///
    /// - Parameters:
    ///   - request: The `Request` instance that failed interception.
    ///   - urlRequest: The `URLRequest` that failed interception.
    ///   - error: The `NetworkingError` describing the reason for failure.
    func request(_ request: any Request, didFailToIntercept urlRequest: URLRequest, with error: NetworkingError)

    /// Called when URL request creation fails with an error.
    ///
    /// - Parameters:
    ///   - request: The `Request` instance that failed during URL request creation.
    ///   - error: The `NetworkingError` describing the failure.
    func request(_ request: any Request, didFailToCreateURLRequestWithError error: NetworkingError)

    /// Called when performance metrics for a request are gathered.
    ///
    /// - Parameters:
    ///   - request: The `Request` instance for which metrics were gathered.
    ///   - metrics: The `URLSessionTaskMetrics` containing timing and network metrics.
    func request(_ request: any Request, didGatherMetrics metrics: URLSessionTaskMetrics)

    /// Called when a request is successfully intercepted.
    ///
    /// - Parameters:
    ///   - request: The `Request` instance that was intercepted.
    ///   - initialRequest: The original `URLRequest` before interception.
    ///   - request: The modified `URLRequest` after interception.
    func request(_ request: any Request, didIntercept initialRequest: URLRequest, to urlRequest: URLRequest)

    /// Called when a task is resumed.
    ///
    /// - Parameters:
    ///   - request: The `Request` instance whose task was resumed.
    ///   - task: The resumed `URLSessionTask`.
    func request(_ request: any Request, didResumeTask task: URLSessionTask)

    /// Called when a task is suspended.
    ///
    /// - Parameters:
    ///   - request: The `Request` instance whose task was suspended.
    ///   - task: The suspended `URLSessionTask`.
    func request(_ request: any Request, didSuspendTask task: URLSessionTask)

    /// Called when a request's response is validated.
    ///
    /// - Parameters:
    ///   - request: The `Request` being validated.
    ///   - urlRequest: The validated `URLRequest`, if any.
    ///   - data: The response `Data`, if any.
    ///   - error: The `NetworkingError` if validation failed.
    func request(_ request: any Request, didValidate urlRequest: URLRequest?, data: Data?, error: NetworkingError?)

    // MARK: - DataRequest Monitoring

    /// Called when a `DataRequest` parses a response with a specified value type.
    ///
    /// - Parameters:
    ///   - request: The `DataRequest` instance being parsed.
    ///   - response: The `Response` containing the parsed value or an error.
    func request(
        _ request: any DataRequest,
        didParseResponse response: Response<some Sendable, NetworkingError>
    )

    // MARK: - UploadRequest Monitoring

    /// Event called when an `UploadRequest` creates its `Uploadable` value, indicating the type of upload it
    /// represents.
    ///
    /// - Parameters:
    ///   - request: The `UploadRequest` instance that created the uploadable.
    ///   - uploadable: The `UploadRequest.Uploadable` value that was successfully created, representing the content to
    /// be uploaded.
    func request(_ request: any UploadRequest, didCreateUploadable uploadable: HTTPURLUploadRequest.Uploadable)

    /// Event called when an `UploadRequest` failed to create its `Uploadable` value due to an error.
    ///
    /// - Parameters:
    ///   - request: The `UploadRequest` instance that attempted to create the uploadable.
    ///   - error: The `NetworkingError` describing the reason for the failure.
    func request(_ request: any UploadRequest, didFailToCreateUploadableWithError error: NetworkingError)

    /// Notifies that the given request failed to create a URLSession task.
    ///
    /// - Parameters:
    ///   - request: The request that failed to create a task.
    ///   - error: The error describing why the task could not be created.
    func request(_ request: any Request, didFailToCreateTaskWithError error: NetworkingError)

    // MARK: - URLSession Delegate Methods

    /// Called when data is received from the server.
    ///
    /// - Parameters:
    ///   - session: The `URLSession` receiving the data.
    ///   - dataTask: The `URLSessionDataTask` that received the data.
    ///   - data: The received `Data`.
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data)

    /// Called when a response is received from the server.
    ///
    /// - Parameters:
    ///   - session: The `URLSession` receiving the response.
    ///   - dataTask: The `URLSessionDataTask` that received the response.
    ///   - response: The `URLResponse` from the server.
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse)

    /// Called when the URLSession becomes invalid due to an error.
    ///
    /// - Parameters:
    ///   - session: The invalidated `URLSession`.
    ///   - error: The `Error` that caused the session to become invalid.
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?)

    /// Called when a task completes, either successfully or with an error.
    ///
    /// - Parameters:
    ///   - session: The `URLSession` containing the completed task.
    ///   - task: The `URLSessionTask` that completed.
    ///   - error: The `Error` that caused failure, if any.
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)

    /// Called when performance metrics for a task are collected.
    ///
    /// - Parameters:
    ///   - session: The `URLSession` collecting the metrics.
    ///   - task: The `URLSessionTask` for which metrics were collected.
    ///   - metrics: The `URLSessionTaskMetrics` containing performance metrics.
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didFinishCollecting metrics: URLSessionTaskMetrics
    )
}

extension Monitor {
    /// The working queue.
    public var queue: DispatchQueue {
        .main
    }

    // MARK: - Request Monitoring

    /// Called when a request is canceled.
    ///
    /// - Parameter request: The `Request` instance that was canceled.
    public func requestDidCancel(_ request: any Request) {}

    /// Called when a request finishes successfully.
    ///
    /// - Parameter request: The `Request` instance that completed.
    public func requestDidFinish(_ request: any Request) {}

    /// Called when a request is resumed after being suspended.
    ///
    /// - Parameter request: The `Request` instance that resumed execution.
    public func requestDidResume(_ request: any Request) {}

    /// Called when a request is suspended.
    ///
    /// - Parameter request: The `Request` instance that was suspended.
    public func requestDidSuspend(_ request: any Request) {}

    /// Called when a request is transitioning to a finished state.
    ///
    /// - Parameter request: The `Request` instance preparing to finish.
    public func requestIsFinishing(_ request: any Request) {}

    /// Called when a request is being prepared.
    ///
    /// - Parameter request: The `Request` instance that is being prepared.
    public func requestIsPreparing(_ request: any Request) {}

    /// Called when a request is being retried.
    ///
    /// - Parameter request: The `Request` instance that is being retried.
    public func requestIsRetrying(_ request: any Request) {}

    /// Called when a URLSession task tied to the request is canceled.
    ///
    /// - Parameters:
    ///   - request: The `Request` associated with the canceled task.
    ///   - task: The `URLSessionTask` that was canceled.
    public func request(_ request: any Request, didCancelTask task: URLSessionTask) {}

    /// Called when a URLSession task completes with or without an error.
    ///
    /// - Parameters:
    ///   - request: The `Request` associated with the completed task.
    ///   - task: The `URLSessionTask` that completed.
    ///   - error: The `NetworkingError` encountered, if any.
    public func request(
        _ request: any Request,
        didCompleteTask task: URLSessionTask,
        with error: NetworkingError?
    ) {}

    /// Called when a `URLRequest` is successfully created.
    ///
    /// - Parameters:
    ///   - request: The `Request` instance that created the URL request.
    ///   - urlRequest: The created `URLRequest` object.
    public func request(_ request: any Request, didCreateURLRequest urlRequest: URLRequest) {}

    /// Called when the initial `URLRequest` for a request is created.
    ///
    /// - Parameters:
    ///   - request: The `Request` instance associated with the initial URL request.
    ///   - urlRequest: The initial `URLRequest` that was created.
    public func request(_ request: any Request, didCreateInitialURLRequest urlRequest: URLRequest) {}

    /// Called when a new `URLSessionTask` is created for the request.
    ///
    /// - Parameters:
    ///   - request: The `Request` instance for which the task was created.
    ///   - task: The `URLSessionTask` that was created.
    public func request(_ request: any Request, didCreateTask task: URLSessionTask) {}

    /// Called when a task fails with a specific error.
    ///
    /// - Parameters:
    ///   - request: The `Request` instance associated with the failed task.
    ///   - task: The `URLSessionTask` that failed.
    ///   - error: The `NetworkingError` that caused the failure.
    public func request(_ request: any Request, didFailTask task: URLSessionTask, with error: NetworkingError) {}

    /// Called when request interception fails.
    ///
    /// - Parameters:
    ///   - request: The `Request` instance that failed interception.
    ///   - urlRequest: The `URLRequest` that failed interception.
    ///   - error: The `NetworkingError` describing the reason for failure.
    public func request(
        _ request: any Request,
        didFailToIntercept urlRequest: URLRequest,
        with error: NetworkingError
    ) {}

    /// Called when URL request creation fails with an error.
    ///
    /// - Parameters:
    ///   - request: The `Request` instance that failed during URL request creation.
    ///   - error: The `NetworkingError` describing the failure.
    public func request(_ request: any Request, didFailToCreateURLRequestWithError error: NetworkingError) {}

    /// Called when performance metrics for a request are gathered.
    ///
    /// - Parameters:
    ///   - request: The `Request` instance for which metrics were gathered.
    ///   - metrics: The `URLSessionTaskMetrics` containing timing and network metrics.
    public func request(_ request: any Request, didGatherMetrics metrics: URLSessionTaskMetrics) {}

    /// Called when a request is successfully intercepted.
    ///
    /// - Parameters:
    ///   - request: The `Request` instance that was intercepted.
    ///   - initialRequest: The original `URLRequest` before interception.
    ///   - request: The modified `URLRequest` after interception.
    public func request(
        _ request: any Request,
        didIntercept initialRequest: URLRequest,
        to urlRequest: URLRequest
    ) {}

    /// Called when a task is resumed.
    ///
    /// - Parameters:
    ///   - request: The `Request` instance whose task was resumed.
    ///   - task: The resumed `URLSessionTask`.
    public func request(_ request: any Request, didResumeTask task: URLSessionTask) {}

    /// Called when a task is suspended.
    ///
    /// - Parameters:
    ///   - request: The `Request` instance whose task was suspended.
    ///   - task: The suspended `URLSessionTask`.
    public func request(_ request: any Request, didSuspendTask task: URLSessionTask) {}

    /// Called when a request's response is validated.
    ///
    /// - Parameters:
    ///   - request: The `Request` being validated.
    ///   - urlRequest: The validated `URLRequest`, if any.
    ///   - data: The response `Data`, if any.
    ///   - error: The `NetworkingError` if validation failed.
    public func request(
        _ request: any Request,
        didValidate urlRequest: URLRequest?,
        data: Data?,
        error: NetworkingError?
    ) {}

    // MARK: - DataRequest Monitoring

    /// Called when a `DataRequest` parses a response with a specified value type.
    ///
    /// - Parameters:
    ///   - request: The `DataRequest` instance being parsed.
    ///   - response: The `Response` containing the parsed value or an error.
    public func request(
        _ request: any DataRequest,
        didParseResponse response: Response<some Sendable, NetworkingError>
    ) {}

    // MARK: - UploadRequest Monitoring

    /// Event called when an `UploadRequest` creates its `Uploadable` value, indicating the type of upload it
    /// represents.
    ///
    /// - Parameters:
    ///   - request: The `UploadRequest` instance that created the uploadable.
    ///   - uploadable: The `UploadRequest.Uploadable` value that was successfully created, representing the content to
    /// be uploaded.
    public func request(
        _ request: any UploadRequest,
        didCreateUploadable uploadable: HTTPURLUploadRequest.Uploadable
    ) {}

    /// Event called when an `UploadRequest` failed to create its `Uploadable` value due to an error.
    ///
    /// - Parameters:
    ///   - request: The `UploadRequest` instance that attempted to create the uploadable.
    ///   - error: The `NetworkingError` describing the reason for the failure.
    public func request(
        _ request: any UploadRequest,
        didFailToCreateUploadableWithError error: NetworkingError
    ) {}

    /// Notifies that the given request failed to create a URLSession task.
    ///
    /// - Parameters:
    ///   - request: The request that failed to create a task.
    ///   - error: The error describing why the task could not be created.
    public func request(_ request: any Request, didFailToCreateTaskWithError error: NetworkingError) {}

    // MARK: - URLSession Delegate Methods

    /// Called when data is received from the server.
    ///
    /// - Parameters:
    ///   - session: The `URLSession` receiving the data.
    ///   - dataTask: The `URLSessionDataTask` that received the data.
    ///   - data: The received `Data`.
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {}

    /// Called when a response is received from the server.
    ///
    /// - Parameters:
    ///   - session: The `URLSession` receiving the response.
    ///   - dataTask: The `URLSessionDataTask` that received the response.
    ///   - response: The `URLResponse` from the server.
    public func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse
    ) {}

    /// Called when the URLSession becomes invalid due to an error.
    ///
    /// - Parameters:
    ///   - session: The invalidated `URLSession`.
    ///   - error: The `Error` that caused the session to become invalid.
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {}

    /// Called when a task completes, either successfully or with an error.
    ///
    /// - Parameters:
    ///   - session: The `URLSession` containing the completed task.
    ///   - task: The `URLSessionTask` that completed.
    ///   - error: The `Error` that caused failure, if any.
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {}

    /// Called when performance metrics for a task are collected.
    ///
    /// - Parameters:
    ///   - session: The `URLSession` collecting the metrics.
    ///   - task: The `URLSessionTask` for which metrics were collected.
    ///   - metrics: The `URLSessionTaskMetrics` containing performance metrics.
    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didFinishCollecting metrics: URLSessionTaskMetrics
    ) {}
}
