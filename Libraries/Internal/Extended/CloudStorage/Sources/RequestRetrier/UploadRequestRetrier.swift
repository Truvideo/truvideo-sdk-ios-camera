//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
internal import Networking

/// An actor that handles automatic token refresh for failed authentication requests.
///
/// This actor implements the `RequestRetrier` protocol to automatically refresh authentication
/// tokens when requests fail with 401 Unauthorized errors. It ensures thread-safe token refresh
/// operations and prevents multiple concurrent refresh attempts.
actor UploadRequestRetrier: RequestRetrier {
    // MARK: - Private Properties

    private let exponentialBackoff = 2
    private let exponentialBackoffScale = 0.5
    private let maxNumberOfRetries = 3

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
    func retry(_ request: any Request, for session: any Session, failedWith error: any Error) async -> RetryPolicy {
        guard
            /// The request sent to the server.
            let originalRequest = request.request,

            /// The response sent by the server.
            let response = request.response
        else {
            return .doNotRetry
        }

        guard request.retryCount < maxNumberOfRetries else {
            return .doNotRetry
        }

        switch response.statusCode {
        case 408, 429, 500 ... 599:
            let delay = pow(Double(exponentialBackoff), Double(request.retryCount)) * exponentialBackoffScale

            return .retry(delay)

        default:
            return .doNotRetry
        }
    }
}
