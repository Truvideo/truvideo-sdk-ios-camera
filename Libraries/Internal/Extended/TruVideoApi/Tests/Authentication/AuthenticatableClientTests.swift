//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
import Foundation
import Networking
import NetworkingTesting
import Testing
import Utilities

@testable import TruVideoApi

struct AuthenticatableClientTests {
    // MARK: - Tests
    
    @Test
    func testThatAuthenticateClientShouldInitializes() {
        // Given
        let sut = AuthenticationClient()
        
        // When, Then
        #expect(sut.session is HTTPURLSession, "Expected the default session to be HTTPURLSession")
    }
    
    @Test
    func testThatAuthenticateShouldSaveTheAuthSessionInTheStorage() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let dataRequest = DataRequestMock()
            let session = SessionMock()
            let sessionManager = SessionManagerMock()
            let authToken = AuthToken.mock
            let apiKey = "test-api-Key"
            let context = Context()
            let signature = "signature"
            let sut = AuthenticationClient(session: session)
            
            // When
            dependencies.apiEnvironment = .beta
            dependencies.sessionManager = sessionManager
            session.dataRequest = dataRequest
            dataRequest.mockResponse = Response<AuthToken, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: nil,
                result: .success(authToken),
                type: .networkLoad
            )
            
            try await sut.authenticate(
                apiKey: apiKey,
                context: context,
                signature: signature
            )
            
            // Then
            #expect(sessionManager.currentSession != nil)
            #expect(sessionManager.currentSession!.apiKey == apiKey)
            #expect(sessionManager.currentSession!.authToken.id == authToken.id)
            #expect(sessionManager.currentSession!.authToken.accessToken == authToken.accessToken)
            #expect(sessionManager.currentSession!.authToken.refreshToken == authToken.refreshToken)
        }
    }
    
    @Test
    func testThatAuthenticateShouldFailToSaveTheAuthSessionInTheStorage() async throws {
        await withDependencyValues { dependencies in
            // Given
            let dataRequest = DataRequestMock()
            let session = SessionMock()
            let sessionManager = SessionManagerMock()
            let authToken = AuthToken.mock
            let apiKey = "test-api-Key"
            let context = Context()
            let signature = "signature"
            let externalId = ""
            let sut = AuthenticationClient(session: session)
            
            // When
            dependencies.apiEnvironment = .beta
            dependencies.sessionManager = sessionManager
            session.dataRequest = dataRequest
            dataRequest.mockResponse = Response<AuthToken, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: nil,
                result: .success(authToken),
                type: .networkLoad
            )
            sessionManager.error = NSError(domain: "StorageError", code: 1)
            
            // Then
            await #expect {
                try await sut.authenticate(
                    apiKey: apiKey,
                    context: context,
                    signature: signature,
                    externalId: externalId
                )
            } throws: { error in
                return (error as? UtilityError)?.kind == .TruVideoApiErrorReason.authenticationFailed
            }
            
            #expect(sessionManager.currentSession == nil, "Auth session should not be saved if storage fails")
        }
    }
    
    @Test
    func testThatAuthenticateIncludesMultitenantExternalIdHeaderForMultiTenantScenarios() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let dataRequest = DataRequestMock()
            let session = SessionMock()
            let sessionManager = SessionManagerMock()
            let authToken = AuthToken.mock
            let apiKey = "test-api-Key"
            let context = Context()
            let signature = "signature"
            let externalId = "QA"
            let sut = AuthenticationClient(session: session)
            
            // When
            dependencies.apiEnvironment = .beta
            dependencies.sessionManager = sessionManager
            session.dataRequest = dataRequest
            dataRequest.mockResponse = Response<AuthToken, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: nil,
                result: .success(authToken),
                type: .networkLoad
            )
            
            try await sut.authenticate(
                apiKey: apiKey,
                context: context,
                signature: signature,
                externalId: externalId
            )
            
            // Then
            #expect(session.lastRequestHeaders?["x-multitenant-external-id"] == externalId)
        }
    }
    
    @Test
    func testThatAuthenticateIncludesAuthenticationDeviceIdHeaderWhenCurrentSessionExists() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let dataRequest = DataRequestMock()
            let session = SessionMock()
            let sessionManager = SessionManagerMock()
            let authToken = AuthToken.mock
            let apiKey = "test-api-Key"
            let context = Context()
            let signature = "signature"
            let externalId = ""
            let sut = AuthenticationClient(session: session)
            let deviceId = "36BBA8E7-A9C6-4F00-B4E1-F6BA888FF093"
            
            // When
            dependencies.apiEnvironment = .beta
            dependencies.sessionManager = sessionManager
            session.dataRequest = dataRequest
            dataRequest.mockResponse = Response<AuthToken, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: nil,
                result: .success(authToken),
                type: .networkLoad
            )
            
            try sessionManager.set(AuthSession.mock)
            
            try await sut.authenticate(
                apiKey: apiKey,
                context: context,
                signature: signature,
                externalId: externalId
            )
            
            // Then
            #expect(session.lastRequestHeaders?["x-authentication-device-id"] == deviceId)
        }
    }
    
    @Test
    func testThatAuthenticateShouldIncludesApiKeyAndSignatureHeaders() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let dataRequest = DataRequestMock()
            let session = SessionMock()
            let sessionManager = SessionManagerMock()
            let authToken = AuthToken.mock
            let apiKey = "test-api-Key"
            let context = Context()
            let signature = "signature"
            let externalId = ""
            let sut = AuthenticationClient(session: session)
            
            // When
            dependencies.apiEnvironment = .beta
            dependencies.sessionManager = sessionManager
            session.dataRequest = dataRequest
            dataRequest.mockResponse = Response<AuthToken, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: nil,
                result: .success(authToken),
                type: .networkLoad
            )
            
            try await sut.authenticate(
                apiKey: apiKey,
                context: context,
                signature: signature,
                externalId: externalId
            )
            
            // Then
            #expect(session.lastRequestHeaders?["x-authentication-api-key"] == apiKey)
            #expect(session.lastRequestHeaders?["x-authentication-signature"] == signature)
        }
    }
    
    @Test
    func testThatAuthenticateShouldUseCorrectParameters() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let dataRequest = DataRequestMock()
            let session = SessionMock()
            let sessionManager = SessionManagerMock()
            let authToken = AuthToken.mock
            let apiKey = "test-api-Key"
            let context = Context()
            let signature = "signature"
            let externalId = ""
            let sut = AuthenticationClient(session: session)
            
            // When
            dependencies.apiEnvironment = .beta
            dependencies.sessionManager = sessionManager
            session.dataRequest = dataRequest
            dataRequest.mockResponse = Response<AuthToken, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: nil,
                result: .success(authToken),
                type: .networkLoad
            )
            
            try await sut.authenticate(
                apiKey: apiKey,
                context: context,
                signature: signature,
                externalId: externalId
            )
            
            // Then
            #expect(session.lastRequestParameters?["brand"] as? String == context.brand)
            #expect(session.lastRequestParameters?["model"] as? String == context.model)
            #expect(session.lastRequestParameters?["os"] as? String == context.os)
            #expect(session.lastRequestParameters?["osVersion"] as? String == context.osVersion)
            #expect(session.lastRequestParameters?["timestamp"] as? Int == context.timestamp)
        }
    }
    
    @Test
    func testThatAuthenticateShouldUseCorrectURL() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let dataRequest = DataRequestMock()
            let session = SessionMock()
            let sessionManager = SessionManagerMock()
            let authToken = AuthToken.mock
            let apiKey = "test-api-Key"
            let context = Context()
            let signature = "signature"
            let externalId = ""
            let sut = AuthenticationClient(session: session)
            
            // When
            dependencies.apiEnvironment = .beta
            dependencies.sessionManager = sessionManager
            session.dataRequest = dataRequest
            dataRequest.mockResponse = Response<AuthToken, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: nil,
                result: .success(authToken),
                type: .networkLoad
            )
            
            try await sut.authenticate(
                apiKey: apiKey,
                context: context,
                signature: signature,
                externalId: externalId
            )
            
            let url = try session.lastRequestURL?.asURL()
            
            // Then
            #expect(url!.absoluteString.contains("api/device"))
        }
    }
    
    @Test
    func testThatAuthenticateShouldUsePostMethod() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let dataRequest = DataRequestMock()
            let session = SessionMock()
            let sessionManager = SessionManagerMock()
            let authToken = AuthToken.mock
            let apiKey = "test-api-Key"
            let context = Context()
            let signature = "signature"
            let externalId = ""
            let sut = AuthenticationClient(session: session)
            
            // When
            dependencies.apiEnvironment = .beta
            dependencies.sessionManager = sessionManager
            session.dataRequest = dataRequest
            dataRequest.mockResponse = Response<AuthToken, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: nil,
                result: .success(authToken),
                type: .networkLoad
            )
            
            try await sut.authenticate(
                apiKey: apiKey,
                context: context,
                signature: signature,
                externalId: externalId
            )
            
            // Then
            #expect(session.lastRequestMethod == .post)
        }
    }
    
    @Test
    func testThatAuthenticateValidateResponse() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let dataRequest = DataRequestMock()
            let session = SessionMock()
            let sessionManager = SessionManagerMock()
            let authToken = AuthToken.mock
            let apiKey = "test-api-Key"
            let context = Context()
            let signature = "signature"
            let externalId = ""
            let sut = AuthenticationClient(session: session)
            let response = HTTPURLResponse(
                url: URL(string: "https://beta.truvideo.com/api/device")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            let data = """
                {
                    "id": "36BBA8E7-A9C6-4F00-B4E1-F6BA888FF093",
                    "accessToken": "test-access-token",
                    "refreshToken": "test-refresh-token"
                }
                """.data(using: .utf8)!
            
            // When
            dependencies.apiEnvironment = .beta
            dependencies.sessionManager = sessionManager
            session.dataRequest = dataRequest
            dataRequest.data = data
            dataRequest.response = response
            dataRequest.mockResponse = Response<AuthToken, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: nil,
                result: .success(authToken),
                type: .networkLoad
            )

            try await sut.authenticate(
                apiKey: apiKey,
                context: context,
                signature: signature,
                externalId: externalId
            )

            // Then
            #expect(dataRequest.validateCallCount == 1, "Expected validate to be called once")
            #expect(dataRequest.lastValidationError == nil)
        }
    }
    
@Test
    func testThatAuthenticateShouldThrowResponseValidationFailedWhenValidationFails() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let dataRequest = DataRequestMock()
            let session = SessionMock()
            let sessionManager = SessionManagerMock()
            let authToken = AuthToken.mock
            let apiKey = "test-api-Key"
            let context = Context()
            let signature = "signature"
            let externalId = ""
            let sut = AuthenticationClient(session: session)
            let response = HTTPURLResponse(
                url: URL(string: "https://beta.truvideo.com/api/device")!,
                statusCode: 415,
                httpVersion: nil,
                headerFields: nil
            )!
            let data = """
            {
                "type": "about:blank",
                "title": "Unsupported Media Type",
                "message": "error.invalidApiKey",
                "status": 415,
                "detail": "Content-Type is not supported.",
                "instance": "/api/device"
            }
            """.data(using: .utf8)!
            
            // When
            dependencies.apiEnvironment = .beta
            dependencies.sessionManager = sessionManager
            dataRequest.data = data
            session.dataRequest = dataRequest
            dataRequest.response = response
            dataRequest.mockResponse = Response<AuthToken, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: nil,
                result: .success(authToken),
                type: .networkLoad
            )
            
            try await sut.authenticate(
                apiKey: apiKey,
                context: context,
                signature: signature,
                externalId: externalId
            )

            // Then
            #expect(dataRequest.validateCallCount == 1, "Expected validate to be called once")
            #expect(dataRequest.lastValidationError != nil)
            #expect((dataRequest.lastValidationError as? NetworkingError)?.kind == .responseValidationFailed)
        }
    }

    @Test
    func testThatAuthenticateShouldThrowAuthenticationFailedOnRequestError() async throws {
        await withDependencyValues { dependencies in
            // Given
            let dataRequest = DataRequestMock()
            let session = SessionMock()
            let sessionManager = SessionManagerMock()
            let apiKey = "test-api-Key"
            let context = Context()
            let signature = "signature"
            let externalId = ""
            let sut = AuthenticationClient(session: session)
            
            // When
            dependencies.apiEnvironment = .beta
            dependencies.sessionManager = sessionManager
            session.dataRequest = dataRequest
            dataRequest.mockResponse = Response<AuthToken, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: nil,
                result: .failure(NetworkingError(kind: .invalidURL, failureReason: "")),
                type: .networkLoad
            )
            
            // Then
            await #expect {
                try await sut.authenticate(
                    apiKey: apiKey,
                    context: context,
                    signature: signature,
                    externalId: externalId
                )
            } throws: { error in
                return (error as? UtilityError)?.kind == .TruVideoApiErrorReason.authenticationFailed
            }
        }
    }
}

private extension AuthToken {
    /// A mock instance of the device setting.
    static var mock: AuthToken {
        AuthToken(
            id: UUID(),
            accessToken: "test-access-token",
            refreshToken: "test-refresh-token"
        )
    }
}
