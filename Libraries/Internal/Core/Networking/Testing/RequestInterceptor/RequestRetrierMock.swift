//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Networking

/// A mock implementation of the `RequestRetrier` protocol for testing retry behavior.
///
/// `RequestRetrierMock` is primarily used in unit tests to simulate retry logic after a network request failure.
/// It captures the failed request, session, and error, and allows for configurable retry behavior.
///
/// ### Example Usage:
/// ```swift
/// let retrierMock = RequestRetrierMock()
/// retrierMock.retry = .retry(2) // Retry after 2 seconds
///
/// let request = Request()
/// let session = Session()
/// let error = NSError(domain: "NetworkError", code: -1009, userInfo: nil) // Simulated offline error
///
/// Task {
///     let retryPolicy = await retrierMock.retry(request, for: session, failedWith: error)
///     XCTAssertEqual(retrierMock.error as NSError?, error)
///     XCTAssertEqual(retrierMock.request, request)
/// }
/// ```
public final class RequestRetrierMock: RequestRetrier {
    // MARK: - Private Properties

    private var currentRetries = 0

    // MARK: - Public Properties

    /// The maximun number of retries allowed.
    public var maxNumberOfRetries = 3

    /// The retry policy that determines how the retrier behaves when a failure occurs.
    public var retry = RetryPolicy.retry(0)

    /// The underlying error which the retrier has failed.
    public private(set) var error: Error?

    /// The request to retry.
    public private(set) var request: (any Request)?

    /// The `Session` that initiated the retried request.
    public private(set) var session: Session?

    // MARK: - Initializer

    /// Initializes a new instance of `RequestRetrierMock`.
    public init() {}

    /// Determines whether the `Request` should be retried by calling the `completion` closure.
    ///
    /// - Parameters:
    ///   - request: `Request` that failed due to the provided `Error`.
    ///   - client: `HTTPApiClient` that produced the `Request`.
    ///   - error: `Error` encountered while executing the `Request`.
    public func retry(_ request: any Request, for session: Session, failedWith error: Error) async -> RetryPolicy {
        self.request = request
        self.session = session
        self.error = error

        currentRetries += 1

        guard currentRetries <= maxNumberOfRetries else {
            return .doNotRetry
        }

        return retry
    }
}
