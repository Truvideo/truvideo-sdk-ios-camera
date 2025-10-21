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

struct SessionTokenRefresherTests {
    // MARK: - Tests

    @Test
    func testThatSessionTokenRefresherShouldInitializes() async throws {
        // Given
        let sut = SessionTokenRefresher()

        // When, Then
        await #expect(sut.session is HTTPURLSession, "Expected the default session to be HTTPURLSession")
    }

    @Test
    func testThatRefreshTokenUpdatesSessionWithNewOne() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let expiredSession = AuthSession.mock
            let dataRequest = DataRequestMock()
            let session = SessionMock()
            let sessionManager = SessionManagerMock()
            let sut = SessionTokenRefresher(session: session)

            // When
            dependencies.environment = .dev
            dependencies.sessionManager = sessionManager
            session.dataRequest = dataRequest
            dataRequest.mockResponse = Response<AuthToken, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: nil,
                result: .success(AuthToken.new),
                type: .networkLoad
            )

            try sessionManager.set(expiredSession)
            try await sut.refreshToken()
            let newSession = sessionManager.currentSession

            // Then
            #expect(newSession != nil)
            #expect(newSession!.authToken.id != expiredSession.authToken.id)
            #expect(newSession!.authToken.accessToken != expiredSession.authToken.accessToken)
            #expect(newSession!.authToken.refreshToken != expiredSession.authToken.refreshToken)
        }
    }

    @Test
    func testThatRefreshTokenShouldUseCorrectHeathers() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let expiredSession = AuthSession.mock
            let dataRequest = DataRequestMock()
            let session = SessionMock()
            let sessionManager = SessionManagerMock()
            let sut = SessionTokenRefresher(session: session)

            // When
            dependencies.environment = .dev
            dependencies.sessionManager = sessionManager
            session.dataRequest = dataRequest
            dataRequest.mockResponse = Response<AuthToken, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: nil,
                result: .success(AuthToken.new),
                type: .networkLoad
            )

            try sessionManager.set(expiredSession)
            try await sut.refreshToken()

            // Then
            #expect(session.lastRequestHeaders?["x-authentication-api-key"] == expiredSession.apiKey)
            #expect(session.lastRequestHeaders?["x-authentication-device-id"] == expiredSession.authToken.id.uuidString)
        }
    }

    @Test
    func testThatAuthenticateShouldUseCorrectURL() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let expiredSession = AuthSession.mock
            let dataRequest = DataRequestMock()
            let session = SessionMock()
            let sessionManager = SessionManagerMock()
            let sut = SessionTokenRefresher(session: session)

            // When
            dependencies.environment = .dev
            dependencies.sessionManager = sessionManager
            session.dataRequest = dataRequest
            dataRequest.mockResponse = Response<AuthToken, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: nil,
                result: .success(AuthToken.new),
                type: .networkLoad
            )

            try sessionManager.set(expiredSession)
            try await sut.refreshToken()
            let url = try session.lastRequestURL?.asURL()

            // Then
            #expect(url!.absoluteString.contains("/api/authenticate/exchange"))
        }
    }

    @Test
    func testThatAuthenticateShouldUsePostMethod() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let expiredSession = AuthSession.mock
            let dataRequest = DataRequestMock()
            let session = SessionMock()
            let sessionManager = SessionManagerMock()
            let sut = SessionTokenRefresher(session: session)

            // When
            dependencies.environment = .dev
            dependencies.sessionManager = sessionManager
            session.dataRequest = dataRequest
            dataRequest.mockResponse = Response<AuthToken, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: nil,
                result: .success(AuthToken.new),
                type: .networkLoad
            )

            try sessionManager.set(expiredSession)
            try await sut.refreshToken()

            // Then
            #expect(session.lastRequestMethod == .post)
        }
    }

    @Test
    func testThatRefreshTokenValidateResponse() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let expiredSession = AuthSession.mock
            let dataRequest = DataRequestMock()
            let session = SessionMock()
            let sessionManager = SessionManagerMock()
            let sut = SessionTokenRefresher(session: session)

            let data = """
            {
                "id": "c263c628-5fd5-41b2-ae72-4c0f87ce5c8d",
                "accessToken": "test-access-token",
                "refreshToken": "test-refresh-token"
            }
            """.data(using: .utf8)!
            let response = HTTPURLResponse(
                url: URL(string: "https://beta.truvideo.com/api/authenticate/exchange")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!

            // When
            dependencies.environment = .dev
            dependencies.sessionManager = sessionManager
            session.dataRequest = dataRequest
            dataRequest.data = data
            dataRequest.response = response
            dataRequest.mockResponse = Response<AuthToken, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: nil,
                result: .success(AuthToken.new),
                type: .networkLoad
            )

            try sessionManager.set(expiredSession)

            // Then
            await #expect {
                try await sut.refreshToken()
            } throws: { error in
                (error as? UtilityError)?.kind == .TruVideoApiErrorReason.refreshTokenFailed
            }

            #expect(dataRequest.validateCallCount == 1, "Expected validate to be called once")
        }
    }

    @Test
    func testThatRefreshTokenShouldThrowResponseValidationFailedWhenValidationFails() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let expiredSession = AuthSession.mock
            let dataRequest = DataRequestMock()
            let session = SessionMock()
            let sessionManager = SessionManagerMock()
            let sut = SessionTokenRefresher(session: session)

            let data = """
            {
                "type": "about:blank",
                "title": "Unsupported Media Type",
                "message": "error.invalidApiKey",
                "status": 415,
                "detail": "Content-Type is not supported.",
                "instance": "/api/authenticate/exchange"
            }
            """.data(using: .utf8)!
            let response = HTTPURLResponse(
                url: URL(string: "https://beta.truvideo.com/api/authenticate/exchange")!,
                statusCode: 415,
                httpVersion: nil,
                headerFields: nil
            )!

            // When
            dependencies.environment = .dev
            dependencies.sessionManager = sessionManager
            session.dataRequest = dataRequest
            dataRequest.data = data
            dataRequest.response = response
            dataRequest.mockResponse = Response<AuthToken, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: nil,
                result: .success(AuthToken.new),
                type: .networkLoad
            )

            try sessionManager.set(expiredSession)

            // Then
            await #expect {
                try await sut.refreshToken()
            } throws: { error in
                (error as? UtilityError)?.kind == .TruVideoApiErrorReason.refreshTokenFailed
            }

            #expect(dataRequest.validateCallCount == 1, "Expected validate to be called once")
        }
    }

    @Test
    func testThatRefreshTokenShouldThrowRefreshTokenFailedWhenSessionNotFound() async throws {
        await withDependencyValues { dependencies in
            // Given
            let session = SessionMock()
            let sessionManager = SessionManagerMock()
            let sut = SessionTokenRefresher(session: session)

            // When
            dependencies.environment = .dev
            dependencies.sessionManager = sessionManager

            // Then
            await #expect {
                try await sut.refreshToken()
            } throws: { error in
                (error as? UtilityError)?.kind == .TruVideoApiErrorReason.refreshTokenFailed
            }

            #expect(sessionManager.currentSession == nil)
            #expect(session.requestURLCallCount == 0)
            #expect(session.lastRequestURL == nil)
            #expect(session.lastRequestHeaders == nil)
        }
    }

    @Test
    func testThatRefreshTokenShouldFailToSaveTheNewSessionInTheStorage() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let expiredSession = AuthSession.mock
            let dataRequest = DataRequestMock()
            let session = SessionMock()
            let sessionManager = SessionManagerMock()
            let sut = SessionTokenRefresher(session: session)

            // When
            dependencies.environment = .dev
            dependencies.sessionManager = sessionManager
            session.dataRequest = dataRequest
            dataRequest.mockResponse = Response<AuthToken, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: nil,
                result: .success(AuthToken.new),
                type: .networkLoad
            )

            try sessionManager.set(expiredSession)
            sessionManager.error = NSError(domain: "StorageError", code: 1)

            // Then
            await #expect {
                try await sut.refreshToken()
            } throws: { error in
                (error as? UtilityError)?.kind == .TruVideoApiErrorReason.refreshTokenFailed
            }

            #expect(sessionManager.currentSession?.authToken.id == expiredSession.authToken.id)
            #expect(sessionManager.currentSession?.authToken.accessToken == expiredSession.authToken.accessToken)
            #expect(sessionManager.currentSession?.authToken.refreshToken == expiredSession.authToken.refreshToken)
        }
    }

    @Test
    func testThatRefreshTokenShouldThrowRefreshTokenFailedOnRequestError() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let expiredSession = AuthSession.mock
            let dataRequest = DataRequestMock()
            let session = SessionMock()
            let sessionManager = SessionManagerMock()
            let sut = SessionTokenRefresher(session: session)
            let responseError = RequestValidator.ResponseError(
                detail: "Invalid refresh token",
                message: "refreshTokenFailed"
            )

            // When
            dependencies.environment = .dev
            dependencies.sessionManager = sessionManager
            session.dataRequest = dataRequest
            dataRequest.mockResponse = Response<AuthToken, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: nil,
                result: .failure(NetworkingError(kind: .invalidURL, underlyingError: responseError)),
                type: .networkLoad
            )

            try sessionManager.set(expiredSession)

            // Then
            await #expect {
                try await sut.refreshToken()
            } throws: { error in
                (error as? UtilityError)?.kind == .TruVideoApiErrorReason.refreshTokenFailed
            }
        }
    }
}
