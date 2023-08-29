//
//  BearerTokenRequestRetrier.swift
//
//  Created by TruVideo on 8/08/23.
//  Copyright © TruVideo. All rights reserved.
//

import Foundation

/// A type that determines whether a request should be retried after being executed
/// if the authorization token is expired.
public actor BearerTokenRequestRetrier: RequestRetrier {
    private let tokenProvider: TokenProvider
    private var task: Task<Void, Error>?
    
    /// The current access token.
    var authToken: AuthToken? {
        get async {
            await tokenProvider.retrieveToken()
        }
    }
    
    /// All the possibles errors that can be thrown by the `BearerTokenRefresher`.
    enum BearerTokenRefresherError: Error {
        /// The device has not been authenticated.
        case unauthenticatedDevice
    }

    // MARK: Initializers

    /// Creates a new instance of the `TokenRefresher` with an
    /// associated `TokenProvider`.
    ///
    /// - Parameter tokenProvider: The authentication token provider.
    public init(tokenProvider: TokenProvider) {
        self.tokenProvider = tokenProvider
    }
    
    // MARK: RequestRetrier
    
    /// Determines whether the `Request` should be retried by calling the `completion` closure.
    ///
    /// - Parameters:
    ///   - request: `Request` that failed due to the provided `Error`.
    ///   - client: `HTTPApiClient` that produced the `Request`.
    ///   - error: `Error` encountered while executing the `Request`.
    public func retry(_ request: Request, for client: HTTPApiClient, dueTo error: Error) async -> RetryPolicy {
        guard
            /// The task in charge of the URLRequest.
            let task = request.task,

            /// The response sent by the server.
            let response = task.response as? HTTPURLResponse else {

            return .doNotRetry
        }

        guard request.retryCount < client.configuration.requestRetryCount else {
            return .doNotRetry
        }

        switch response.statusCode {
        case 401:
            do {
                try await refreshToken(for: client)
                return .retry
            } catch {
                return .doNotRetry
            }

        case 500...599:
            return .retry

        default:
            return .doNotRetry
        }
    }

    // MARK: Private methods

    /// Send a request to the provider to refresh the token.
    private func refreshToken(for apiClient: HTTPApiClient) async throws {
        guard let task = task else {
            let task = Task<Void, Error> {
                defer { self.task = nil }
                
                guard let token = await self.authToken else {
                    throw BearerTokenRefresherError.unauthenticatedDevice
                }

                let response = try await apiClient.request(
                    "api/authenticate/exchange/\(token.id)",
                    method: .post,
                    parameters: [:],
                    headers: [HTTPHeader.bearerToken(token.refreshToken)]
                )
                    .serializing(AuthToken.self)
                    .response
                
                let newToken = try response.result.get()
                try await tokenProvider.save(newToken)
            }

            self.task = task
            try await task.value
            
            return
        }

        try await task.value
    }
}
