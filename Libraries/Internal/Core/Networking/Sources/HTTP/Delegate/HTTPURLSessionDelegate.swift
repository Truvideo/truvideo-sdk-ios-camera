//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A protocol that provides session-related events to manage URL session tasks.
///
/// Types conforming to `HTTPURLSessionDelegateProvider` are responsible for handling URL session events,
/// such as task completion, metric gathering, and session invalidation. This protocol acts as
/// an intermediary between the `SessionDelegate` and the actual request handling logic.
///
/// - Conforms to: `AnyObject`, `Sendable`
protocol HTTPURLSessionDelegateProvider: AnyObject, Sendable {
    /// Retrieves the `Request` associated with a given URL session task.
    ///
    /// - Parameter task: The `URLSessionTask` for which to retrieve the request.
    /// - Returns: The corresponding `Request` instance, if available.
    func request(for task: URLSessionTask) -> HTTPURLRequest?

    /// Called when the session becomes invalid due to an error.
    ///
    /// - Parameter error: An optional `Error` indicating why the session became invalid.
    func sessionDidBecomeInvalid(with error: Error?)
}

/// A delegate that manages URL session events.
///
/// `HTTPURLSessionDelegate` acts as a bridge between `URLSession` and the `HTTPURLSessionDelegateProvider`,
/// forwarding session-related events such as request completion, error handling, and metrics gathering.
///
/// - Note: This class is marked as `@unchecked Sendable` due to the use of `weak var provider`.
///
/// Example usage:
/// ```swift
/// let sessionDelegate = HTTPURLSessionDelegate()
/// sessionDelegate.provider = someProvider
/// let session = URLSession(configuration: .default, delegate: sessionDelegate, delegateQueue: nil)
/// ```
open class HTTPURLSessionDelegate: NSObject, @unchecked Sendable {
    // MARK: - Properties

    /// An optional `RequestMonitor` instance responsible for observing request events.
    var monitor: Monitor?

    /// The delegate provider responsible for handling session-related events.
    weak var provider: HTTPURLSessionDelegateProvider?
}

extension HTTPURLSessionDelegate: URLSessionDelegate {
    // MARK: - URLSessionDelegate

    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: (any Error)?) {
        monitor?.urlSession(session, didBecomeInvalidWithError: error)

        provider?.sessionDidBecomeInvalid(with: error)
    }
}

extension HTTPURLSessionDelegate: URLSessionDataDelegate {
    // MARK: - URLSessionDataDelegate

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        monitor?.urlSession(session, dataTask: dataTask, didReceive: data)

        if let dataRequest = provider?.request(for: dataTask) as? HTTPURLDataRequest {
            dataRequest.didReceive(data: data)
        }
    }

    public func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        monitor?.urlSession(session, dataTask: dataTask, didReceive: response)

        completionHandler(.allow)
    }
}

extension HTTPURLSessionDelegate: URLSessionTaskDelegate {
    // MARK: - URLSessionTaskDelegate

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        monitor?.urlSession(session, task: task, didCompleteWithError: error)

        let request = provider?.request(for: task)
        let error = error.map { NetworkingError(kind: .sessionTaskFailed, underlyingError: $0) }

        request?.didComplete(task: task, error: error)
    }

    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didFinishCollecting metrics: URLSessionTaskMetrics
    ) {
        monitor?.urlSession(session, task: task, didFinishCollecting: metrics)

        let request = provider?.request(for: task)

        request?.didGatherMetrics(metrics)
    }
}
