//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// Represents the outcome of determining whether a failed request should be retried.
///
/// This enum conforms to `Sendable`, ensuring it is safe to use in concurrent contexts.
public enum RetryPolicy: Sendable {
    /// Indicates that no retry should be attempted.
    case doNotRetry

    /// Do not retry due to the associated `Error`.
    case doNotRetryWithError(Error)

    /// Indicates that the operation should be retried after a specified delay.
    case retry(TimeInterval)
}

/// A type that determines whether a request should be retried after being executed by the specified session manager
/// and encountering an error.
public protocol RequestRetrier {
    /// Determines whether the `Request` should be retried by calling the `completion` closure.
    ///
    /// This operation is fully asynchronous. Any amount of time can be taken to determine whether the request needs
    /// to be retried. The one requirement is that the completion closure is called to ensure the request is properly
    /// cleaned up after.
    ///
    /// - Parameters:
    ///   - request: The `Request` that failed due to the provided `Error`.
    ///   - session: The `Session` that produced the `Request`.
    ///   - error: The `Error` encountered while executing the `Request`.
    func retry(_ request: any Request, for session: Session, failedWith error: Error) async -> RetryPolicy
}

/// A type that determines whether a request should be intercepted.
public protocol RequestInterceptor {
    /// Inspects and adapts the specified `URLRequest` in some
    /// manner and returns the Result.
    ///
    /// - Parameters:
    ///   - request: The `URLRequest` tha has been intercepted.
    ///   - session: The `Session` that produced the `Request`.
    /// - Throws: An error if something went wrong.
    func intercept(_ request: URLRequest, for session: Session) async throws -> URLRequest
}

/// A protocol that combines the responsibilities of both `RequestRetrier` and `RequestInterceptor`.
///
/// `RequestMiddleware` acts as a composable middleware component within the network request lifecycle.
/// It enables conforming types to intercept, modify, and potentially retry network requests based on custom logic.
///
/// This protocol is particularly useful for implementing advanced request handling features, such as:
/// - Modifying requests before they are sent (e.g., adding headers, logging).
/// - Retrying failed requests based on specific conditions (e.g., network errors, token refresh).
/// - Monitoring and logging request outcomes.
///
/// Conforming types must implement the required methods from both `RequestInterceptor` and `RequestRetrier`, enabling
/// full control over request
/// modification and retry logic.
public protocol RequestMiddleware: RequestRetrier, RequestInterceptor {}

extension RequestRetrier {
    /// Determines whether the `Request` should be retried by calling the `completion` closure.
    ///
    /// This operation is fully asynchronous. Any amount of time can be taken to determine whether the request needs
    /// to be retried. The one requirement is that the completion closure is called to ensure the request is properly
    /// cleaned up after.
    ///
    /// - Parameters:
    ///   - request: The `Request` that failed due to the provided `Error`.
    ///   - session: The `Session` that produced the `Request`.
    ///   - error: The `Error` encountered while executing the `Request`.
    /// Determines whether the `Request` should be retried by calling the `completion` closure.
    ///
    /// This operation is fully asynchronous. Any amount of time can be taken to determine whether the request needs
    /// to be retried. The one requirement is that the completion closure is called to ensure the request is properly
    /// cleaned up after.
    ///
    /// - Parameters:
    ///   - request: The `Request` that failed due to the provided `Error`.
    ///   - session: The `Session` that produced the `Request`.
    ///   - error: The `Error` encountered while executing the `Request`.
    public func retry(_ request: any Request, for session: Session, failedWith error: Error) async -> RetryPolicy {
        .doNotRetry
    }
}

/// A composite interceptor and retrier for handling request adaptation and retries.
///
/// `Interceptor` allows multiple `RequestInterceptor` and `RequestRetrier` implementations
/// to be combined into a single entity, enabling modular and extensible request handling.
///
/// - Conforms to:
///   - `RequestInterceptor`: Enables request modification before execution.
///   - `RequestRetrier`: Handles request retries in case of failure.
///
/// ### Example Usage:
/// ```swift
/// let authInterceptor = AuthenticationInterceptor()
/// let retryPolicy = DefaultRetryPolicy()
/// let middleware = Middleware(interceptors: [authInterceptor], retriers: [retryPolicy])
///
/// let session = Session(interceptor: interceptor)
/// ```
public struct Middleware: RequestMiddleware {
    // MARK: - Public Properties

    /// All `RequestInterceptor`s associated with the instance.
    public let interceptors: [RequestInterceptor]

    /// All `RequestRetrier`s associated with the instance.
    public let retriers: [RequestRetrier]

    // MARK: - Initializer

    /// Creates a new `Middleware` instance from a list of interceptors.
    ///
    /// - Parameters:
    ///    - interceptors: The list of child interceptors.
    ///    - retriers: All `RequestRetrier`s associated with the instance.
    public init(interceptors: [RequestInterceptor], retriers: [RequestRetrier]) {
        self.interceptors = interceptors
        self.retriers = retriers
    }

    // MARK: - RequestInterceptor

    /// Inspects and adapts the specified `URLRequest` in some
    /// manner and returns the Result.
    ///
    /// - Parameters:
    ///   - request: The `URLRequest` tha has been intercepted.
    ///   - session: The `Session` that produced the `Request`.
    /// - Throws: An error if something went wrong.
    public func intercept(_ request: URLRequest, for session: Session) async throws -> URLRequest {
        try await intercept(request, interceptors: interceptors, session: session)
    }

    // MARK: - RequestRetrier

    /// Determines whether the `Request` should be retried by calling the `completion` closure.
    ///
    /// This operation is fully asynchronous. Any amount of time can be taken to determine whether the request needs
    /// to be retried. The one requirement is that the completion closure is called to ensure the request is properly
    /// cleaned up after.
    ///
    /// - Parameters:
    ///   - request: The `Request` that failed due to the provided `Error`.
    ///   - session: The `Session` that produced the `Request`.
    ///   - error: The `Error` encountered while executing the `Request`.
    public func retry(_ request: any Request, for session: Session, failedWith error: Error) async -> RetryPolicy {
        await retry(request, retriers: retriers, for: session, failedWith: error)
    }

    // MARK: - Private methods

    private func intercept(
        _ request: URLRequest,
        interceptors: [RequestInterceptor],
        session: Session
    ) async throws -> URLRequest {
        var interceptors = interceptors

        guard !interceptors.isEmpty else {
            return request
        }

        let interceptor = interceptors.removeFirst()
        let request = try await interceptor.intercept(request, for: session)

        return try await intercept(request, interceptors: interceptors, session: session)
    }

    private func retry(
        _ request: any Request,
        retriers: [RequestRetrier],
        for session: Session,
        failedWith error: Error
    ) async -> RetryPolicy {
        var retriers = retriers

        guard !retriers.isEmpty else {
            return .doNotRetry
        }

        let retrier = retriers.removeFirst()
        let policy = await retrier.retry(request, for: session, failedWith: error)

        switch policy {
        case .doNotRetry:
            return await retry(request, retriers: retriers, for: session, failedWith: error)

        case .retry, .doNotRetryWithError:
            return policy
        }
    }
}
