//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Networking

/// An actor that handles automatic token refresh for failed authentication requests.
///
/// This actor implements the `RequestRetrier` protocol to automatically refresh authentication
/// tokens when requests fail with 401 Unauthorized errors. It ensures thread-safe token refresh
/// operations and prevents multiple concurrent refresh attempts.
public actor SessionRequestRetrier: RequestRetrier {
    // MARK: - Private Properties

    private let maxNumberOfRetries = 3

    // MARK: - Properties

    let tokenRefresher: any TokenRefresher

    // MARK: - Initializer

    /// Creates a new instance with the specified token refresher.
    ///
    /// This initializer allows you to configure the component with a custom token refresher
    /// implementation. If no token refresher is provided, it defaults to a `SessionTokenRefresher`
    /// with standard network session configuration.
    ///
    /// - Parameter tokenRefresher: The token refresher implementation to use.
    public init(tokenRefresher: any TokenRefresher = SessionTokenRefresher()) {
        self.tokenRefresher = tokenRefresher
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
    public func retry(
        _ request: any Request,
        for session: any Session,
        failedWith error: any Error
    ) async -> RetryPolicy {
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
        case 401 where originalRequest.allHTTPHeaders.contains(where: { $0.name.lowercased() == "authorization" }):
            do {
                try await tokenRefresher.refreshToken()
                return .retry(1)
            } catch {
                return .doNotRetry
            }

        case 500 ... 599:
            return .retry(1)

        default:
            return .doNotRetry
        }
    }
}
