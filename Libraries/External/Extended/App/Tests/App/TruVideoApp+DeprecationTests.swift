//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
import TruVideoApi
import TruVideoApiTesting
import Testing
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
    func testThatApiKeyReturnsConfiguredValue() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let expectedKey = "VS2SG9WK"
            let authenticatableClient = AuthenticatableClientMock()
            let sut = TruVideoApp()
            
            // When            
            sut.configure(with: TruVideoOptions(apiKey: expectedKey, secretKey: "ST2K33GR"))
            
            let storedApiKey = try sut.apiKey()
                        
            // Then
            #expect(expectedKey == storedApiKey)
        }
    }

    @Test
    func testThatApiKeyThrowsIfNotConfigured() async throws {
        // Given
        let sut = TruVideoApp()
        
        // When, Then
        #expect {
            _ = try sut.apiKey()
        } throws: { error in
            guard let error = error as? TruVideoSdkError else {
                return false
            }
            
            return [
                error.kind == TruVideoSdkError.configurationRequired.kind,
                error.errorDescription != nil,
                error.failureReason != nil
            ].allSatisfy {  _ in true }
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
            #expect(authenticatableClient.currentSession != nil)            
            #expect(deviceSettingResource.retrieveCallCount == 1)
        }
    }

    @Test
    func testThatClearAuthenticationCallsSignOut() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let sut = TruVideoApp()

            // When
            dependencies.authenticatableClient = authenticatableClient

            sut.configure(with: TruVideoOptions(apiKey: "KEY", secretKey: "SECRET"))
            
            try await sut.authenticate(apiKey: "KEY", payload: "payload", signature: "sig", externalId: "ext")
            try sut.clearAuthentication()

            // Then
            #expect(authenticatableClient.currentSession == nil)
            #expect(authenticatableClient.signOutCalled == true)
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
            
            // When
            dependencies.authenticatableClient = authenticatableClient

            sut.configure(with: TruVideoOptions(apiKey: "KEY", secretKey: "SECRET"))
            
            try await sut.authenticate()
            
            let isAuthenticationExpired = try! sut.isAuthenticationExpired()
            
            // Then
            #expect(isAuthenticationExpired == false)
        }
    }
}
