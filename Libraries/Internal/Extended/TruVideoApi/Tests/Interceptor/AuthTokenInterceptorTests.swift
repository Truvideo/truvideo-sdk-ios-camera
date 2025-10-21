//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
import Foundation
import Networking
import Testing

@testable import TruVideoApi

struct AuthTokenInterceptorTests {
    // MARK: - Tests

    @Test
    func testThatInterceptShouldAddBearerTokenWhenNoAuthorizationHeaderExists() async throws {
        try await withDependencyValues { dependencyValues in
            // Given
            let authSession = AuthSession.mock
            let sut = AuthTokenInterceptor()
            let request = URLRequest(url: URL(string: "https://api.example.com/test")!)
            let session = HTTPURLSession()

            // When
            dependencyValues.sessionManager = SessionManagerMock()

            try dependencyValues.sessionManager.set(authSession)

            let interceptedRequest = try await sut.intercept(request, for: session)

            // Then
            #expect(
                interceptedRequest.allHTTPHeaders["Authorization"] == "Bearer \(authSession.authToken.accessToken)"
            )
        }
    }

    @Test
    func testThatInterceptShouldNotAddBearerTokenWhenAuthorizationHeaderAlreadyExists() async throws {
        try await withDependencyValues { dependencyValues in
            // Given
            let sut = AuthTokenInterceptor()
            var request = URLRequest(url: URL(string: "https://api.example.com/test")!)
            let session = HTTPURLSession()

            // When
            dependencyValues.sessionManager = SessionManagerMock()

            try dependencyValues.sessionManager.set(AuthSession.mock)

            request.allHTTPHeaders["Authorization"] = "Bearer existing-token"

            let interceptedRequest = try await sut.intercept(request, for: session)

            // Then
            #expect(interceptedRequest.allHTTPHeaders["Authorization"] == "Bearer existing-token")
        }
    }

    @Test
    func testThatInterceptShouldNotAddBearerTokenWhenNoSessionExists() async throws {
        try await withDependencyValues { dependencyValues in
            // Given
            let sessionManager = SessionManagerMock()
            sessionManager.currentSession = nil

            let sut = AuthTokenInterceptor()
            dependencyValues.sessionManager = sessionManager

            var request = URLRequest(url: URL(string: "https://api.example.com/test")!)
            request.httpMethod = "GET"

            let session = HTTPURLSession()

            // When
            let result = try await sut.intercept(request, for: session)

            // Then
            #expect(!result.allHTTPHeaders.contains { $0.name.lowercased() == "authorization" })
        }
    }

    @Test
    func testThatInterceptShouldPreserveExistingHeaders() async throws {
        try await withDependencyValues { dependencyValues in
            // Given
            let sut = AuthTokenInterceptor()
            var request = URLRequest(url: URL(string: "https://api.example.com/test")!)
            let session = HTTPURLSession()

            // When
            request.allHTTPHeaders.append(HTTPHeader(name: "Content-Type", value: "application/json"))
            request.allHTTPHeaders.append(HTTPHeader(name: "Accept", value: "application/json"))

            dependencyValues.sessionManager = SessionManagerMock()

            try dependencyValues.sessionManager.set(AuthSession.mock)

            request.allHTTPHeaders["Authorization"] = "Bearer existing-token"

            let interceptedRequest = try await sut.intercept(request, for: session)

            // Then
            #expect(interceptedRequest.allHTTPHeaders["Content-Type"] == "application/json")
            #expect(interceptedRequest.allHTTPHeaders["Accept"] == "application/json")
            #expect(interceptedRequest.allHTTPHeaders["Authorization"] == "Bearer existing-token")
            #expect(interceptedRequest.allHTTPHeaders.count == 3)
        }
    }
}
