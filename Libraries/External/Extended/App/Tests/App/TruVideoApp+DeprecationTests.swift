//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
import TruVideoApi
import TruVideoApiTesting
import TruvideoSdkTesting
import Testing
import Utilities

@testable import TruvideoSdk

struct TruVideoAppDeprecatedTests {
    var authenticatableClient: AuthenticatableClientMock!
    var deviceSettingResource: DeviceSettingsResourceMock!
    
    private init() {
        self.authenticatableClient = AuthenticatableClientMock()
        self.deviceSettingResource = DeviceSettingsResourceMock()
    }

    // MARK: - Tests

    @Test
    func testThatApiKeyReturnsConfiguredValue() async throws {
        await withDependencyValues { dependencies in
            // Given
            let expectedKey = "VS2SG9WK"
            let sut = TruVideoApp()
            
            // When
            dependencies.authenticatableClient = authenticatableClient
            dependencies.deviceSettingResource = deviceSettingResource

            sut.configure(with: TruVideoOptions(apiKey: expectedKey, secretKey: "SECRET"))
            let key = try? sut.apiKey()
            
            // Then
            #expect(key == expectedKey)
        }
    }

    @Test
    func testThatApiKeyThrowsIfNotConfigured() async throws {
        await withDependencyValues { _ in
            // Given
            var expectError: TruvideoSdk.TruVideoSdkError!
            let sut = TruVideoApp()
            
            // When
            do {
                _ = try sut.apiKey()
            } catch let error {
                expectError = error as? TruvideoSdk.TruVideoSdkError
            }

            // Then
            #expect(expectError.kind == TruVideoSdkError.ErrorReason.configurationRequired)
            #expect(expectError.errorDescription != nil)
            #expect(expectError.failureReason != nil)
        }
    }

    @Test
    func testThatAuthenticateCallsAuthenticate() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let sut = TruVideoApp()

            // When
            dependencies.authenticatableClient = authenticatableClient
            dependencies.deviceSettingResource = deviceSettingResource
            sut.configure(with: TruVideoOptions(apiKey: "KEY", secretKey: "SECRET"))
            try await sut.authenticate(apiKey: "KEY", payload: "payload", signature: "sig", externalId: "ext")
            
            // Then
            #expect(authenticatableClient.authenticateCalled == true)
            #expect(authenticatableClient.currentToken != nil)
            print(deviceSettingResource.retrieveCalled)
            #expect(deviceSettingResource.retrieveCalled == true)
        }
    }

    @Test
    func testThatClearAuthenticationCallsSignOut() async throws {
        await withDependencyValues { dependencies in
            // Given
            let sut = TruVideoApp()

            // When
            dependencies.authenticatableClient = authenticatableClient

            sut.configure(with: TruVideoOptions(apiKey: "KEY", secretKey: "SECRET"))
            try? await sut.authenticate(apiKey: "KEY", payload: "payload", signature: "sig", externalId: "ext")
            try? sut.clearAuthentication()

            // Then
            #expect(authenticatableClient.signOutCalled == true)
            #expect(authenticatableClient.currentToken == nil)
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
        await withDependencyValues { dependencies in
            // Given
            let sut = TruVideoApp()
            
            // When
            dependencies.authenticatableClient = authenticatableClient

            sut.configure(with: TruVideoOptions(apiKey: "KEY", secretKey: "SECRET"))
            try? await sut.authenticate()
            let result = try! sut.isAuthenticationExpired()
            
            // Then
            #expect(result == false)
        }
    }
}
