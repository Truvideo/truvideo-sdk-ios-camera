//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
import Foundation
import InternalUtilities
import Networking
import NetworkingTesting
import StorageKit
import Testing
import Utilities

@testable import TruVideoApi

struct SessionRequestRetrierTests {
    // MARK: - Tests

    @Test
    func testThatSessionRequestRetrierShouldInitialize() async throws {
        // Given
        let sut = SessionRequestRetrier()

        // When, Then
        await #expect(sut.tokenRefresher is SessionTokenRefresher)
    }

    @Test
    func testThatRetryShouldNotRetryIfThereIsNoRequest() async throws {
        // Given
        let session = SessionMock()
        let tokenRefresher = SessionTokenRefresher(session: session)
        let sut = SessionRequestRetrier(tokenRefresher: tokenRefresher)

        let dataRequest = DataRequestMock()
        let response = HTTPURLResponse(
            url: URL(string: "https://beta.truvideo.com/api/authenticate/exchange")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        // When
        dataRequest.request = nil
        dataRequest.response = response
        session.dataRequest = dataRequest

        let request = session.request("http://httpbin.org/", method: .get)
        let policy = await sut.retry(request, for: session, failedWith: NSError(domain: "", code: 0, userInfo: nil))

        // Then
        #expect(policy.isDoNotRetry)
    }

    @Test
    func testThatRetryShouldNotRetryIfThereIsNoResponse() async throws {
        // Given
        let session = SessionMock()
        let tokenRefresher = SessionTokenRefresher(session: session)
        let sut = SessionRequestRetrier(tokenRefresher: tokenRefresher)

        let dataRequest = DataRequestMock()
        let requestBuilder = RequestBuilderMock()
        let urlRequest = try requestBuilder.build()

        // When
        dataRequest.request = urlRequest
        dataRequest.response = nil
        session.dataRequest = dataRequest

        let request = session.request("http://httpbin.org/", method: .get)
        let policy = await sut.retry(request, for: session, failedWith: NSError(domain: "", code: 0, userInfo: nil))

        // Then
        #expect(policy.isDoNotRetry)
    }

    @Test
    func testThatRetryShouldNotRetryIfRetryCountExceedsMaxNumberOfRetriesPolicy() async throws {
        // Given
        let session = SessionMock()
        let tokenRefresher = SessionTokenRefresher(session: session)
        let sut = SessionRequestRetrier(tokenRefresher: tokenRefresher)

        let dataRequest = DataRequestMock()
        let requestBuilder = RequestBuilderMock()
        let urlRequest = try requestBuilder.build()
        let response = HTTPURLResponse(
            url: URL(string: "https://beta.truvideo.com/api/authenticate/exchange")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        // When
        dataRequest.request = urlRequest
        dataRequest.response = response
        dataRequest.retryCount = 3
        session.dataRequest = dataRequest

        let request = session.request("http://httpbin.org/", method: .get)
        let policy = await sut.retry(request, for: session, failedWith: NSError(domain: "", code: 0, userInfo: nil))

        // Then
        #expect(policy.isDoNotRetry)
    }

    @Test
    func testThatRetryShouldRetryIfResponseIs401AndAuthorizationHeaderIsPresentAndRefreshTokenSucceeds() async throws {
        try await withDependencyValues { dependencies in
            // Given
            /// Retry Policy
            let session = SessionMock()
            let tokenRefresher = SessionTokenRefresher(session: session)
            let sut = SessionRequestRetrier(tokenRefresher: tokenRefresher)

            /// Failing Request
            let expiredSession = AuthSession.mock
            let dataRequest = DataRequestMock()
            let requestBuilder = RequestBuilderMock()
            var failingUrlRequest = try requestBuilder.build()
            let unauthorizedResponse = HTTPURLResponse(
                url: URL(string: "https://rc.truvideo.com/api/authenticate/exchange")!,
                statusCode: 401,
                httpVersion: nil,
                headerFields: nil
            )!

            // When
            failingUrlRequest.allHTTPHeaders.append(.bearerToken(expiredSession.authToken.accessToken))
            dataRequest.request = failingUrlRequest
            dataRequest.response = unauthorizedResponse
            session.dataRequest = dataRequest

            /// Refresh token
            let sessionManager = SessionManagerMock()
            dependencies.environment = .rc
            dependencies.sessionManager = sessionManager
            dataRequest.mockResponse = Response<AuthToken, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: nil,
                result: .success(AuthToken.mock),
                type: .networkLoad
            )

            let request = session.request("http://httpbin.org/", method: .get)
            try sessionManager.set(expiredSession)
            let policy = await sut.retry(request, for: session, failedWith: NSError(domain: "", code: 0, userInfo: nil))
            let newSession = sessionManager.currentSession

            // Then
            #expect(policy.isRetry)

            #expect(session.requestURLCallCount == 2)

            #expect(newSession != nil)
            #expect(newSession!.authToken.id != expiredSession.authToken.id)
            #expect(newSession!.authToken.accessToken != expiredSession.authToken.accessToken)
            #expect(newSession!.authToken.refreshToken != expiredSession.authToken.refreshToken)
        }
    }

    @Test
    func testThatRetryShouldNotRetryIfResponseIs401AndAuthorizationHeaderIsPresentButRefreshTokenFails() async throws {
        try await withDependencyValues { dependencies in
            // Given
            /// Retry Policy
            let session = SessionMock()
            let tokenRefresher = SessionTokenRefresher(session: session)
            let sut = SessionRequestRetrier(tokenRefresher: tokenRefresher)

            /// Failing Request
            let expiredSession = AuthSession.mock
            let dataRequest = DataRequestMock()
            let requestBuilder = RequestBuilderMock()
            var failingUrlRequest = try requestBuilder.build()
            let unauthorizedResponse = HTTPURLResponse(
                url: URL(string: "https://rc.truvideo.com/api/authenticate/exchange")!,
                statusCode: 401,
                httpVersion: nil,
                headerFields: nil
            )!

            // When
            failingUrlRequest.allHTTPHeaders.append(.bearerToken(expiredSession.authToken.accessToken))
            dataRequest.request = failingUrlRequest
            dataRequest.response = unauthorizedResponse
            session.dataRequest = dataRequest

            /// Refresh Token
            let sessionManager = SessionManagerMock()
            dependencies.environment = .rc
            dependencies.sessionManager = sessionManager
            let responseError = RequestValidator.ResponseError(
                detail: "Invalid refresh token",
                message: nil
            )
            dataRequest.mockResponse = Response<AuthToken, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: nil,
                result: .failure(NetworkingError(kind: .invalidURL, underlyingError: responseError)),
                type: .networkLoad
            )

            let request = session.request("http://httpbin.org/", method: .get)
            try sessionManager.set(expiredSession)
            let policy = await sut.retry(request, for: session, failedWith: NSError(domain: "", code: 0, userInfo: nil))

            // Then
            #expect(policy.isDoNotRetry)
            #expect(session.requestURLCallCount == 2)
        }
    }

    @Test
    func testThatRetryShouldNotRetryIfResponseIs401ButAuthorizationHeaderIsNotPresent() async throws {
        // Given
        let session = SessionMock()
        let tokenRefresher = SessionTokenRefresher(session: session)
        let sut = SessionRequestRetrier(tokenRefresher: tokenRefresher)

        let dataRequest = DataRequestMock()
        let requestBuilder = RequestBuilderMock()
        let urlRequest = try requestBuilder.build()
        let response = HTTPURLResponse(
            url: URL(string: "https://beta.truvideo.com/api/authenticate/exchange")!,
            statusCode: 401,
            httpVersion: nil,
            headerFields: nil
        )!

        // When
        dataRequest.request = urlRequest
        dataRequest.response = response
        session.dataRequest = dataRequest

        let request = session.request("http://httpbin.org/", method: .get)
        let policy = await sut.retry(request, for: session, failedWith: NSError(domain: "", code: 0, userInfo: nil))

        // Then
        #expect(policy.isDoNotRetry)
        #expect(session.requestURLCallCount == 1)
    }

    @Test
    func testThatRetryShouldRetryOnServerError() async throws {
        // Given
        let session = SessionMock()
        let tokenRefresher = SessionTokenRefresher(session: session)
        let sut = SessionRequestRetrier(tokenRefresher: tokenRefresher)

        let dataRequest = DataRequestMock()
        let requestBuilder = RequestBuilderMock()
        let urlRequest = try requestBuilder.build()
        let response = HTTPURLResponse(
            url: URL(string: "https://beta.truvideo.com/api/authenticate/exchange")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )!

        // When
        dataRequest.request = urlRequest
        dataRequest.response = response
        session.dataRequest = dataRequest

        let request = session.request("http://httpbin.org/", method: .get)
        let policy = await sut.retry(request, for: session, failedWith: NSError(domain: "", code: 0, userInfo: nil))

        // Then
        #expect(policy.isRetry)
        #expect(session.requestURLCallCount == 1)
    }

    @Test
    func retryShouldNotRetryForUnhandledStatusCode() async throws {
        // Given
        let session = SessionMock()
        let tokenRefresher = SessionTokenRefresher(session: session)
        let sut = SessionRequestRetrier(tokenRefresher: tokenRefresher)

        let dataRequest = DataRequestMock()
        let requestBuilder = RequestBuilderMock()
        let urlRequest = try requestBuilder.build()
        let response = HTTPURLResponse(
            url: URL(string: "https://beta.truvideo.com/api/authenticate/exchange")!,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )!

        // When
        dataRequest.request = urlRequest
        dataRequest.response = response
        session.dataRequest = dataRequest

        let request = session.request("http://httpbin.org/", method: .get)
        let policy = await sut.retry(request, for: session, failedWith: NSError(domain: "", code: 0, userInfo: nil))

        // Then
        #expect(policy.isDoNotRetry)
        #expect(session.requestURLCallCount == 1)
    }
}

private extension RetryPolicy {
    /// Indicates whether the policy is `.doNotRetry` or `.doNotRetryWithError`.
    var isDoNotRetry: Bool {
        switch self {
        case .doNotRetry: true

        default: false
        }
    }

    /// Indicates whether the policy is `.retry`.
    var isRetry: Bool {
        switch self {
        case .retry: true

        default: false
        }
    }
}
