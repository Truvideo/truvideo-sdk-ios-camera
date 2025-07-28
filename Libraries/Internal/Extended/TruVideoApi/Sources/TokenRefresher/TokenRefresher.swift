//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
import Foundation
import Networking
import Utilities

/// An actor that handles automatic token refresh for failed authentication requests.
///
/// This actor implements the `RequestRetrier` protocol to automatically refresh authentication
/// tokens when requests fail with 401 Unauthorized errors. It ensures thread-safe token refresh
/// operations and prevents multiple concurrent refresh attempts.
actor TokenRefresher: RequestRetrier {
    // MARK: - Private Properties

    private let maxNumberOfRetries = 3
    private var refreshTokenTask: Task<Void, Error>?
    private let session: any Session

    // MARK: - Dependencies

    @Dependency(\.apiEnvironment)
    private var environment: Environment

    @Dependency(\.sessionManager)
    private var sessionManager: any SessionManager

    // MARK: - Initializer

    /// Creates a new token refresher with the specified session.
    ///
    /// This initializer allows you to configure the token refresher with a custom network session.
    /// If no session is provided, it defaults to an `HTTPURLSession` with a `SessionMonitor`
    /// for tracking network operations.
    ///
    /// - Parameter session: The network session to use for token refresh requests. Defaults to a monitored HTTP session.
    init(session: any Session = HTTPURLSession(monitors: [SessionMonitor()])) {
        self.session = session
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
        case 401 where originalRequest.allHTTPHeaders.contains(where: { $0.name.lowercased() == "authorization" }):
            do {
                try await refreshToken()
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

    // MARK: - Private methods

    private func refreshToken() async throws {
        guard let authSession = sessionManager.currentSession else {
            throw UtilityError(
                kind: .TruVideoApiErrorReason.refreshTokenFailed,
                failureReason: "No authentication token available for refresh"
            )
        }

        guard let refreshTokenTask else {
            let refreshTokenTask = Task { [weak self] in
                guard let self else {
                    throw UtilityError(
                        kind: .TruVideoApiErrorReason.refreshTokenFailed,
                        failureReason: "Authentication client reference lost during token refresh"
                    )
                }

                do {
                    let authToken = authSession.authToken
                    var headers = HTTPHeaders(array: [.bearerToken(authToken.refreshToken)])
                    let url = await environment.baseURL.appending("/api/authenticate/exchange")

                    headers.append(HTTPHeader(name: "x-authentication-api-key", value: authSession.apiKey))
                    headers.append(HTTPHeader(name: "x-authentication-device-id", value: authToken.id.uuidString))

                    let newToken = try await session.request(url, method: .post, headers: headers)
                        .validate(RequestValidator.validate)
                        .serializing(AuthToken.self)
                        .result
                        .get()

                    let newSession = AuthSession(apiKey: authSession.apiKey, authToken: newToken)
                    try await sessionManager.set(newSession)
                } catch let error as NetworkingError {
                    throw error.asUtilityError(or: .TruVideoApiErrorReason.refreshTokenFailed)
                } catch {
                    throw UtilityError(kind: .TruVideoApiErrorReason.refreshTokenFailed, underlyingError: error)
                }
            }

            self.refreshTokenTask = refreshTokenTask
            return try await refreshTokenTask.value
        }

        try await refreshTokenTask.value
    }
}
