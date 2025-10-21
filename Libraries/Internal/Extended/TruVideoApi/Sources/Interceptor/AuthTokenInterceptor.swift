//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
import Foundation
import Networking

/// An interceptor that automatically adds authentication tokens to HTTP requests.
///
/// This interceptor checks for existing authentication sessions and automatically
/// adds the bearer token to requests that don't already have an authorization header.
/// It ensures that authenticated requests are properly authorized without manual
/// token management.
public struct AuthTokenInterceptor: RequestInterceptor {
    // MARK: - Dependencies

    @Dependency(\.sessionManager)
    private var sessionManager: any SessionManager

    // MARK: - Initializer

    /// Creates a new instance of the `AuthTokenInterceptor`.
    public init() {}

    // MARK: - RequestInterceptor

    /// Inspects and adapts the specified `URLRequest` in some
    /// manner and returns the Result.
    ///
    /// - Parameters:
    ///   - request: The `URLRequest` tha has been intercepted.
    ///   - session: The `Session` that produced the `Request`.
    /// - Throws: An error if something went wrong.
    public func intercept(_ request: URLRequest, for session: Session) async throws -> URLRequest {
        var request = request

        if /// The current session.
            let authSession = sessionManager.currentSession,
            !request.allHTTPHeaders.contains(where: { $0.name.lowercased() == "authorization" }) {
            request.allHTTPHeaders.append(.bearerToken(authSession.authToken.accessToken))
        }

        return request
    }
}
