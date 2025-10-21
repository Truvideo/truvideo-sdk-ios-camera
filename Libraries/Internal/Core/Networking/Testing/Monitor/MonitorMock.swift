//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Networking

/// A mock implementation of the `RequestMonitor` protocol used for testing network request events.
///
/// `MonitorMock` allows developers to capture and inspect events that occur during the lifecycle of a network request.
/// Each event can be handled using corresponding callback closures, making this class particularly useful for testing
/// and debugging.
///
/// ### Example Usage:
/// ```swift
/// let monitorMock = MonitorMock()
/// monitorMock.requestDidCompleteCallback = {
///     print("Request completed.")
/// }
/// ```
public final class MonitorMock: Monitor, @unchecked Sendable {
    // MARK: - Public Properties

    /// Closure called when a request is validated.
    public var didValidateRequestCallback: (() -> Void)?

    /// Closure called when a request is cancelled.
    public var requestDidCancelCallback: (() -> Void)?

    /// Closure called when a request is cancelled.
    public var requestDidCancelTaskCallback: (() -> Void)?

    /// Closure called when a request completes.
    public var requestDidFinishCallback: (() -> Void)?

    /// Closure called when a request is resumed.
    public var requestDidResumeCallback: (() -> Void)?

    /// Closure called when a request has resumed a task.
    public var requestDidResumeTaskCallback: (() -> Void)?

    /// Closure called when a request is suspended.
    public var requestDidSuspendCallback: (() -> Void)?

    /// Closure called when a request has suspended a task.
    public var requestDidSuspendTaskCallback: (() -> Void)?

    /// Closure called when a response is parsed from a `DataRequest`.
    public var requestDidParseResponseCallback: (() -> Void)?

    /// Closure called when a `URLRequest` creation fails.
    public var requestDidFailToCreateURLRequestCallback: ((NetworkingError) -> Void)?

    /// Closure called when a `URLRequest` creation fails.
    public var requestDidFailToCreateTaskWithErrorCallback: ((NetworkingError) -> Void)?

    /// Closure called when URL interception fails.
    public var requestDidFailToInterceptURLRequestCallback: ((NetworkingError) -> Void)?

    /// Closure called when task metrics are collected.
    public var requestDidGatherMetricsCallback: ((URLSessionTaskMetrics) -> Void)?

    /// Closure called when a session task completes with or without an error.
    public var requestDidCompleteTaskCallback: ((URLSessionTask, NetworkingError?) -> Void)?

    /// Closure called when a session task is successfully created.
    public var requestDidCreateTaskCallback: ((URLSessionTask) -> Void)?

    /// Closure called when a session task fails with a specific error.
    public var requestDidFailTaskWithErrorCallback: (() -> Void)?

    /// Closure called when a `URLRequest` is successfully created.
    public var requestDidCreateURLRequestCallback: ((URLRequest) -> Void)?

    /// Closure called when the initial url request is successfully created.
    public var requestDidCreateInitialURLRequestCallback: (() -> Void)?

    /// Closure called when a `URLRequest` is successfully intercepted and modified.
    public var requestDidInterceptURLRequestCallback: ((URLRequest, URLRequest) -> Void)?

    /// Closure called when a request is finishing.
    public var requestIsFinishingCallback: (() -> Void)?

    /// Closure called when a request is being prepared.
    public var requestIsPreparingCallback: (() -> Void)?

    /// Closure called when a request is scheduled for retry.
    public var requestIsRetryingCallback: ((any Request) -> Void)?

    /// Closure called when a the underlying url session receives data.
    public var urlSessionDataTaskDidReceiveDataCallback: (() -> Void)?

    /// Closure called when a the underlying url session receives the response.
    public var urlSessionDataTaskDidReceiveResponseCallback: (() -> Void)?

    /// Closure called when a the underlying url session becames invalid.
    public var urlSessionDidBecomeInvalidCallback: (() -> Void)?

    /// Closure called when a the underlying url session task completes.
    public var urlSessionTaskDidCompletedWithErrorCallback: (() -> Void)?

    /// Closure called when a the underlying url session task finish collecting metrics.
    public var urlSessionTaskDidFinishCollectingMetricsCallback: (() -> Void)?

    /// Callback closure invoked when `request(_:didCreateUploadable:)` is called.
    public var uploadRequestDidCreateUploadableCallback: ((HTTPURLUploadRequest.Uploadable) -> Void)?

    /// Callback closure invoked when `request(_:didFailToCreateUploadableWithError:)` is called.
    public var uploadRequestDidFailToCreateUploadableCallback: ((NetworkingError) -> Void)?

    /// Tracks the number of times the request has been cancelled.
    public private(set) var requestDidCancelCallCount = 0

    /// Tracks the number of times the request has cancelled a task.
    public private(set) var requestDidCancelTaskCallCount = 0

    /// Tracks the number of times the request has completed a task.
    public private(set) var requestDidCompleteTaskCallCount = 0

    /// Tracks the number of times an initial `URLRequest` was successfully created.
    public private(set) var requestDidCreateInitialURLRequestCallCount = 0

    /// Tracks the number of times a `URLSessionTask` was created.
    public private(set) var requestDidCreateTaskCallCount = 0

    /// Tracks the number of times a `URLRequest` was successfully created.
    public private(set) var requestDidCreateURLRequestCallCount = 0

    /// Tracks the number of times the request has failed a task.
    public private(set) var requestDidFailTaskCallCount = 0

    /// Tracks the number of times a `URLRequest` was interception has failed by a `RequestInterceptor`.
    public private(set) var requestDidFailToInterceptURLRequestCallCount = 0

    /// Tracks the number of times a `Request` has finished.
    public private(set) var requestDidFinishCallCount = 0

    /// Tracks the number of times a `Request` has gathered metrics.
    public private(set) var requestDidGatherMetricsCallCount = 0

    /// Tracks the number of times a `Request` has failed to create the `URLRequest`.
    public private(set) var didFailToCreateURLRequestWithErrorCallCount = 0

    /// Tracks the number of times a `Request` has failed to create the `URLRequest`.
    public private(set) var didFailToCreateTaskWithErrorCallCount = 0

    /// Tracks the number of times a `URLRequest` was intercepted by a `RequestInterceptor`.
    public private(set) var requestDidInterceptURLRequestCallCount = 0

    /// Tracks the number of times a `DataRequest` has parsed a response.
    public private(set) var requestDidParseResponseCallCount = 0

    /// Tracks the number of times a `Request` has resumed.
    public private(set) var requestDidResumeCallCount = 0

    /// Tracks the number of times the request has resumed a task.
    public private(set) var requestDidResumeTaskCallCount = 0

    /// Tracks the number of times a `Request` has been suspended.
    public private(set) var requestDidSuspendCallCount = 0

    /// Tracks the number of times a `Request` has been suspended a task.
    public private(set) var requestDidSuspendTaskCallCount = 0

    /// Tracks the number of times the request has been validated.
    public private(set) var requestDidValidateCallCount = 0

    /// Tracks the number of times a `Request` is finishing.
    public private(set) var requestIsFinishingCallCount = 0

    /// Tracks the number of times the request has been prepared.
    public private(set) var requestIsPreparingCallCount = 0

    /// Tracks the number of times a `Request` is retrying.
    public private(set) var requestIsRetryingCallCount = 0

    /// Tracks the number of times `didCreateUploadable` was called on an `UploadRequest`.
    public private(set) var uploadRequestDidCreateUploadableCallCount = 0

    /// Tracks the number of times `didFailToCreateUploadableWithError` was called on an `UploadRequest`.
    public private(set) var uploadRequestDidFailToCreateUploadableCallCount = 0

    // MARK: - Initializer

    /// Creates a new instance of the `MonitorMock` .
    public init() {}

    // MARK: - RequestMonitor

    /// Event called when a `DataRequest` calls a `Validation`.
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
    ) {
        requestDidValidateCallCount += 1
        didValidateRequestCallback?()
    }

    /// Called when cancellation is completed.
    public func requestDidCancel(_ request: any Request) {
        requestDidCancelCallCount += 1
        requestDidCancelCallback?()
    }

    /// Called when a request finishes successfully.
    ///
    /// - Parameter request: The `Request` instance that completed.
    public func requestDidFinish(_ request: any Request) {
        requestDidFinishCallCount += 1
        requestDidFinishCallback?()
    }

    /// Called when a request is transitioning to a finished state.
    ///
    /// - Parameter request: The `Request` instance preparing to finish.
    public func requestIsFinishing(_ request: any Request) {
        requestIsFinishingCallCount += 1
        requestIsFinishingCallback?()
    }

    /// Called when performance metrics for a request are gathered.
    ///
    /// - Parameters:
    ///   - request: The `Request` instance for which metrics were gathered.
    ///   - metrics: The `URLSessionTaskMetrics` containing timing and network metrics.
    public func request(_ request: any Request, didGatherMetrics metrics: URLSessionTaskMetrics) {
        requestDidGatherMetricsCallCount += 1
        requestDidGatherMetricsCallback?(metrics)
    }

    /// Called when the request has been resumed.
    public func requestDidResume(_ request: any Request) {
        requestDidResumeCallCount += 1
        requestDidResumeCallback?()
    }

    /// Called when the request has been suspended.
    public func requestDidSuspend(_ request: any Request) {
        requestDidSuspendCallCount += 1
        requestDidSuspendCallback?()
    }

    // MARK: - DataRequest Monitoring

    /// Event called when a `DataRequest` calls a `ResponseSerializer` and creates a generic `Response<Value>`.
    public func request(
        _ request: any DataRequest,
        didParseResponse response: Response<some Any, NetworkingError>
    ) {
        requestDidParseResponseCallCount += 1
        requestDidParseResponseCallback?()
    }

    // MARK: - UploadRequest Monitoring

    /// Called when an `UploadRequest` successfully creates an `Uploadable` object.
    ///
    /// - Parameters:
    ///   - request: The upload request that triggered this callback.
    ///   - uploadable: The uploadable object that was created.
    public func request(
        _ request: any UploadRequest,
        didCreateUploadable uploadable: HTTPURLUploadRequest.Uploadable
    ) {
        uploadRequestDidCreateUploadableCallCount += 1
        uploadRequestDidCreateUploadableCallback?(uploadable)
    }

    /// Called when an `UploadRequest` fails to create an `Uploadable` object.
    ///
    /// - Parameters:
    ///   - request: The upload request that triggered this callback.
    ///   - error: The error that occurred while attempting to create the uploadable.
    public func request(
        _ request: any UploadRequest,
        didFailToCreateUploadableWithError error: NetworkingError
    ) {
        uploadRequestDidFailToCreateUploadableCallCount += 1
        uploadRequestDidFailToCreateUploadableCallback?(error)
    }

    /// Called when URL request creation fails with an error.
    ///
    /// - Parameters:
    ///   - request: The `Request` instance that failed during URL request creation.
    ///   - error: The `NetworkingError` describing the failure.
    public func request(_ request: any Request, didFailToCreateURLRequestWithError error: NetworkingError) {
        didFailToCreateURLRequestWithErrorCallCount += 1
        requestDidFailToCreateURLRequestCallback?(error)
    }

    /// Called when a `URLSessionTask` could not be created for the given request.
    ///
    /// - Parameters:
    ///   - request: The `Request` instance for which task creation failed.
    ///   - error: The `NetworkingError` that describes the reason for the failure.
    public func request(_ request: any Request, didFailToCreateTaskWithError error: NetworkingError) {
        didFailToCreateTaskWithErrorCallCount += 1
        requestDidFailToCreateTaskWithErrorCallback?(error)
    }

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
    ) {
        requestDidFailToInterceptURLRequestCallCount += 1
        requestDidFailToInterceptURLRequestCallback?(error)
    }

    /// Called when a URLSession task tied to the request is canceled.
    ///
    /// - Parameters:
    ///   - request: The `Request` associated with the canceled task.
    ///   - task: The `URLSessionTask` that was canceled.
    public func request(_ request: any Request, didCancelTask task: URLSessionTask) {
        requestDidCancelTaskCallCount += 1
        requestDidCancelTaskCallback?()
    }

    /// Event called when a `Request`'s task completes, possibly with an error.
    public func request(_ request: any Request, didCompleteTask task: URLSessionTask, with error: NetworkingError?) {
        requestDidCompleteTaskCallCount += 1
        requestDidCompleteTaskCallback?(task, error)
    }

    /// Called when the initial `URLRequest` for a request is created.
    ///
    /// - Parameters:
    ///   - request: The `Request` instance associated with the initial URL request.
    ///   - urlRequest: The initial `URLRequest` that was created.
    public func request(_ request: any Request, didCreateInitialURLRequest urlRequest: URLRequest) {
        requestDidCreateInitialURLRequestCallCount += 1
        requestDidCreateInitialURLRequestCallback?()
    }

    /// Called when a new `URLSessionTask` is created for the request.
    ///
    /// - Parameters:
    ///   - request: The `Request` instance for which the task was created.
    ///   - task: The `URLSessionTask` that was created.
    public func request(_ request: any Request, didCreateTask task: URLSessionTask) {
        requestDidCreateTaskCallCount += 1
        requestDidCreateTaskCallback?(task)
    }

    /// Called when a `URLRequest` is successfully created.
    ///
    /// - Parameters:
    ///   - request: The `Request` instance that created the URL request.
    ///   - urlRequest: The created `URLRequest` object.
    public func request(_ request: any Request, didCreateURLRequest urlRequest: URLRequest) {
        requestDidCreateURLRequestCallCount += 1
        requestDidCreateURLRequestCallback?(urlRequest)
    }

    /// Called when a task fails with a specific error.
    ///
    /// - Parameters:
    ///   - request: The `Request` instance associated with the failed task.
    ///   - task: The `URLSessionTask` that failed.
    ///   - error: The `NetworkingError` that caused the failure.
    public func request(_ request: any Request, didFailTask task: URLSessionTask, with error: NetworkingError) {
        requestDidFailTaskCallCount += 1
        requestDidFailTaskWithErrorCallback?()
    }

    /// Called when a request is successfully intercepted.
    ///
    /// - Parameters:
    ///   - request: The `Request` instance that was intercepted.
    ///   - initialRequest: The original `URLRequest` before interception.
    ///   - request: The modified `URLRequest` after interception.
    public func request(_ request: any Request, didIntercept initialRequest: URLRequest, to urlRequest: URLRequest) {
        requestDidInterceptURLRequestCallCount += 1
        requestDidInterceptURLRequestCallback?(urlRequest, urlRequest)
    }

    /// Called when a task is resumed.
    ///
    /// - Parameters:
    ///   - request: The `Request` instance whose task was resumed.
    ///   - task: The resumed `URLSessionTask`.
    public func request(_ request: any Request, didResumeTask task: URLSessionTask) {
        requestDidResumeTaskCallCount += 1
        requestDidResumeTaskCallback?()
    }

    /// Called when a task is suspended.
    ///
    /// - Parameters:
    ///   - request: The `Request` instance whose task was suspended.
    ///   - task: The suspended `URLSessionTask`.
    public func request(_ request: any Request, didSuspendTask task: URLSessionTask) {
        requestDidSuspendTaskCallCount += 1
        requestDidSuspendTaskCallback?()
    }

    /// Called when a request is being prepared.
    ///
    /// - Parameter request: The `Request` instance that is being prepared.
    public func requestIsPreparing(_ request: any Request) {
        requestIsPreparingCallCount += 1
        requestIsPreparingCallback?()
    }

    /// Event called when a `Request` is about to be retried.
    public func requestIsRetrying(_ request: any Request) {
        requestIsRetryingCallCount += 1
        requestIsRetryingCallback?(request)
    }

    /// Called when data is received from the server.
    ///
    /// - Parameters:
    ///   - session: The `URLSession` receiving the data.
    ///   - dataTask: The `URLSessionDataTask` that received the data.
    ///   - data: The received `Data`.
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        urlSessionDataTaskDidReceiveDataCallback?()
    }

    /// Called when a response is received from the server.
    ///
    /// - Parameters:
    ///   - session: The `URLSession` receiving the response.
    ///   - dataTask: The `URLSessionDataTask` that received the response.
    ///   - response: The `URLResponse` from the server.
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse) {
        urlSessionDataTaskDidReceiveResponseCallback?()
    }

    /// Called when the URLSession becomes invalid due to an error.
    ///
    /// - Parameters:
    ///   - session: The invalidated `URLSession`.
    ///   - error: The `Error` that caused the session to become invalid.
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        urlSessionDidBecomeInvalidCallback?()
    }

    /// Called when a task completes, either successfully or with an error.
    ///
    /// - Parameters:
    ///   - session: The `URLSession` containing the completed task.
    ///   - task: The `URLSessionTask` that completed.
    ///   - error: The `Error` that caused failure, if any.
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        urlSessionTaskDidCompletedWithErrorCallback?()
    }

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
    ) {
        urlSessionTaskDidFinishCollectingMetricsCallback?()
    }
}
