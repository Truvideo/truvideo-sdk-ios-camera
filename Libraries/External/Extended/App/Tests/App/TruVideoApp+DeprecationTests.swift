//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
import Testing
import TruVideoApi
import TruVideoApiTesting
import TruvideoSdkTesting
import Utilities

@testable import TruvideoSdk

struct TruVideoAppDeprecatedTests {
    // MARK: - Private Properties

    private let authenticatableClient: AuthenticatableClientMock
    private let deviceSettingResource: DeviceSettingsResourceMock

    // MARK: - Initializer

    init() {
        self.authenticatableClient = AuthenticatableClientMock()
        self.deviceSettingResource = DeviceSettingsResourceMock()
    }

    // MARK: - Tests

    @Test
    func testThatApiKeyReturnsApiKeyFromCurrentSessionAfterAuthenticate() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let sut = TruVideoApp()
            let signer = SignerMock()
            let context = Context(
                brand: "Apple",
                model: "iPhone 15 Pro",
                os: "iOS",
                osVersion: "18.0",
                timestamp: 123456789
            )
            let jsonData = try JSONEncoder().encode(context)
            let payload = String(data: jsonData, encoding: .utf8)!

            // When
            dependencies.authenticatableClient = authenticatableClient
            sut.configure(with: TruVideoOptions(signer: signer))
            try await sut.authenticate(
                apiKey: authenticatableClient.currentSession?.apiKey ?? "",
                payload: payload,
                signature: "sig",
                externalId: "ext"
            )
            let apiKey = try sut.apiKey()

            // Then
            #expect(authenticatableClient.authenticateCalled == true)
            #expect(apiKey == "apiKey")
        }
    }

    @Test
    func testThatApiKeyThrowsWhenCurrentSessionIsNil() async throws {
        await withDependencyValues { dependencies in
            // Given
            let sut = TruVideoApp()

            // When, Then
            authenticatableClient.currentSession = nil
            dependencies.authenticatableClient = authenticatableClient

            #expect {
                _ = try sut.apiKey()
            } throws: { error in
                guard let error = error as? TruVideoSdkError else {
                    return false
                }
                return error.kind == TruVideoSdkError.apiKeyNotFound.kind
            }
        }
    }

    @Test
    func testThatAuthenticateCallsAuthenticate() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let sut = TruVideoApp()
            let signer = SignerMock()
            let context = Context(
                brand: "Apple",
                model: "iPhone 15 Pro",
                os: "iOS",
                osVersion: "18.0",
                timestamp: 123456789
            )
            let jsonData = try JSONEncoder().encode(context)
            let payload = String(data: jsonData, encoding: .utf8)!

            // When
            dependencies.authenticatableClient = authenticatableClient
            dependencies.deviceSettingResource = deviceSettingResource
            sut.configure(with: TruVideoOptions(signer: signer))
            try await sut.authenticate(
                apiKey: authenticatableClient.currentSession?.apiKey ?? "",
                payload: payload,
                signature: "sig",
                externalId: "ext"
            )

            try await Task.sleep(nanoseconds: 5_000_000)

            // Then
            #expect(authenticatableClient.authenticateCalled == true)
            #expect(authenticatableClient.currentSession != nil)
            #expect(deviceSettingResource.retrieveCallCount == 1)
        }
    }

    @Test
    func testThatClearAuthenticationCallsSignOut() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let sut = TruVideoApp()
            let signer = SignerMock()
            let context = Context(
                brand: "Apple",
                model: "iPhone 15 Pro",
                os: "iOS",
                osVersion: "18.0",
                timestamp: 123456789
            )
            let jsonData = try JSONEncoder().encode(context)
            let payload = String(data: jsonData, encoding: .utf8)!

            // When
            dependencies.authenticatableClient = authenticatableClient
            sut.configure(with: TruVideoOptions(signer: signer))

            try await sut
                .authenticate(
                    apiKey: authenticatableClient.currentSession?.apiKey ?? "",
                    payload: payload,
                    signature: "sig",
                    externalId: "ext"
                )
            try sut.clearAuthentication()

            // Then
            #expect(authenticatableClient.currentSession == nil)
            #expect(authenticatableClient.signOutCalled == true)
        }
    }

    @Test
    func testThatAuthenticateThrowsAuthenticationFailedWhenPayloadIsInvalid() async throws {
        await withDependencyValues { dependencies in
            // Given
            let sut = TruVideoApp()
            let signer = SignerMock()
            dependencies.authenticatableClient = authenticatableClient
            sut.configure(with: TruVideoOptions(signer: signer))

            // When, Then
            await #expect {
                try await sut.authenticate(apiKey: "", payload: "", signature: "", externalId: "")
            } throws: { error in
                guard let error = error as? TruVideoSdkError else {
                    return false
                }

                return error.kind == TruVideoSdkError.authenticationFailed.kind
            }
        }
    }

    @Test
    func testThatAuthenticateThrowsTruVideoErrorWhenClientFailsWithError() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let sut = TruVideoApp()
            let signer = SignerMock()
            let context = Context(
                brand: "Apple",
                model: "iPhone 15 Pro",
                os: "iOS",
                osVersion: "18.0",
                timestamp: 123456789
            )
            let jsonData = try JSONEncoder().encode(context)
            let payload = String(data: jsonData, encoding: .utf8)!

            // When, Then
            dependencies.authenticatableClient = authenticatableClient
            authenticatableClient.authenticateError = UtilityError(kind: .unknown)
            sut.configure(with: TruVideoOptions(signer: signer))

            await #expect {
                try await sut.authenticate(
                    apiKey: "KEY",
                    payload: payload,
                    signature: "sig",
                    externalId: "ext"
                )
            } throws: { error in
                guard let error = error as? TruVideoSdkError else {
                    return false
                }

                return error.kind == .unknown
            }
        }
    }

    @Test
    func testThatClearAuthenticationThrowsWhenSignOutFails() async throws {
        await withDependencyValues { dependencies in
            // Given
            let sut = TruVideoApp()
            let signer = SignerMock()

            // When
            dependencies.authenticatableClient = authenticatableClient
            authenticatableClient.signOutError = UtilityError(kind: ErrorReason(rawValue: "signOutFailed"))
            sut.configure(with: TruVideoOptions(signer: signer))

            // Then
            #expect {
                try sut.clearAuthentication()
            } throws: { error in
                guard let error = error as? TruVideoSdkError else {
                    return false
                }

                return error.kind == TruVideoSdkError.signOutFailed.kind
            }
        }
    }

    // MARK: - generatePayload()

    @Test
    func testThatGeneratePayloadReturnsValidJson() async throws {
        await withDependencyValues { _ in
            // Given
            let sut = TruVideoApp()

            // When
            let payload = try! sut.generatePayload()

            // Then
            #expect(payload.contains("{"))
            #expect(payload.contains("}"))
        }
    }

    @Test
    func testThatInitAuthenticationDoesNothing() async throws {
        await withDependencyValues { _ in
            let sut = TruVideoApp()
            try! await sut.initAuthentication()
        }
    }

    @Test
    func testThatIsAuthenticationExpiredReturnsTrueIfTokenExists() async throws {
        await withDependencyValues { dependencies in
            // Given
            let sut = TruVideoApp()

            // When
            dependencies.authenticatableClient = authenticatableClient

            let result = try! sut.isAuthenticationExpired()

            // Then
            #expect(result == true)
        }
    }

    @Test
    func testThatIsAuthenticationExpiredReturnsFalseIfNoToken() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let sut = TruVideoApp()
            let signer = SignerMock()
            let context = Context(
                brand: "Apple",
                model: "iPhone 15 Pro",
                os: "iOS",
                osVersion: "18.0",
                timestamp: 123456789
            )
            let jsonData = try JSONEncoder().encode(context)
            let payload = String(data: jsonData, encoding: .utf8)!

            // When
            dependencies.authenticatableClient = authenticatableClient

            sut.configure(with: TruVideoOptions(signer: signer))

            try await sut.authenticate(
                apiKey: authenticatableClient.currentSession?.apiKey ?? "",
                payload: payload,
                signature: "sig",
                externalId: "ext"
            )

            let isAuthenticationExpired = try! sut.isAuthenticationExpired()

            // Then
            #expect(isAuthenticationExpired == false)
        }
    }
}
