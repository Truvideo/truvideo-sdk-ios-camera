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

struct TruVideoAppTests {
    var authenticatableClient: AuthenticatableClientMock!
    var deviceSettingResource: DeviceSettingsResourceMock!

    private init() {
        self.authenticatableClient = AuthenticatableClientMock()
        self.deviceSettingResource = DeviceSettingsResourceMock()
    }

    // MARK: - Tests

    @Test
    func testThatAuthentication() async throws {
        await withDependencyValues { dependencies in
            // Given
            let sut = TruVideoApp()
            
            // When
            dependencies.authenticatableClient = authenticatableClient
            dependencies.deviceSettingResource = deviceSettingResource

            sut.configure(with: TruVideoOptions(apiKey: "VS2SG9WK", secretKey: "ST2K33GR"))
            try? await sut.authenticate()
            
            // Then
            #expect(authenticatableClient.authenticateCalled == true)
            #expect(authenticatableClient.currentToken != nil)
            print(deviceSettingResource.retrieveCalled)
            #expect(deviceSettingResource.retrieveCalled == true)
        }
    }

    @Test
    func testThatAuthenticationShouldFailWhenIsNotConfigured() async throws {
        await withDependencyValues { dependencies in
            // Given
            var expectError: TruvideoSdk.TruVideoSdkError!
            let sut = TruVideoApp()
            
            // When
            dependencies.authenticatableClient = authenticatableClient
            dependencies.deviceSettingResource = deviceSettingResource

            do {
                try await sut.authenticate()
            } catch let error {
                expectError = error as? TruvideoSdk.TruVideoSdkError
            }
            
            // Then
            #expect(expectError.kind == TruVideoSdkError.ErrorReason.configurationRequired)
            #expect(expectError.errorDescription != nil)
            #expect(expectError.failureReason != nil)
            #expect(authenticatableClient.authenticateCalled == false)
            #expect(authenticatableClient.currentToken == nil)
            #expect(deviceSettingResource.retrieveCalled == false)
        }
    }
    
    @Test
    func testThatAuthenticationShouldFailWhenClientFailsWithUtilityError() async throws {
        await withDependencyValues { dependencies in
            // Given
            var expectError: TruvideoSdk.TruVideoSdkError!
            let sut = TruVideoApp()
            
            // When
            dependencies.authenticatableClient = authenticatableClient
            dependencies.deviceSettingResource = deviceSettingResource

            authenticatableClient.authenticateError = UtilityError(kind: .init(rawValue: "authenticationFailed"))
            sut.configure(with: TruVideoOptions(apiKey: "VS2SG9WK", secretKey: "ST2K33GR"))

            do {
                try await sut.authenticate()
            } catch let error {
                expectError = error as? TruvideoSdk.TruVideoSdkError
            }
            
            // Then
            #expect(expectError.kind == TruVideoSdkError.ErrorReason.authenticationFailed)
            #expect(authenticatableClient.authenticateCalled == true)
            #expect(authenticatableClient.currentToken == nil)
            #expect(deviceSettingResource.retrieveCalled == false)
        }
    }
    
    @Test
    func testThatAuthenticationShouldFailWhenSignerFails() async throws {
        await withDependencyValues { dependencies in
            // Given
            var expectError: TruvideoSdk.TruVideoSdkError!
            let sut = TruVideoApp()
            let signer = SignerMock()
            
            // When
            dependencies.authenticatableClient = authenticatableClient
            dependencies.deviceSettingResource = deviceSettingResource

            signer.error = NSError(domain: "", code: 1)

            sut.configure(with: TruVideoOptions(apiKey: "VS2SG9WK", secretKey: "ST2K33GR", signer: signer))

            do {
                try await sut.authenticate()
            } catch let error {
                expectError = error as? TruvideoSdk.TruVideoSdkError
            }
            
            // Then
            #expect(expectError.kind == TruVideoSdkError.ErrorReason.authenticationFailed)
            #expect(authenticatableClient.authenticateCalled == false)
            #expect(authenticatableClient.currentToken == nil)
            #expect(deviceSettingResource.retrieveCalled == false)
        }
    }
    
    @Test
    func testThatConfigureShouldFailIfIsAlreadyConfigured() async throws {
        await withDependencyValues { dependencies in
            // Given
            var expectError: TruvideoSdk.TruVideoSdkError!
            let sut = TruVideoApp()
            
            // When
            dependencies.authenticatableClient = authenticatableClient
            dependencies.deviceSettingResource = deviceSettingResource

            sut.configure(with: TruVideoOptions(apiKey: "VS2SG9WK", secretKey: "ST2K33GR"))

            do {
                sut.configure(with: TruVideoOptions(apiKey: "VS2SG9WK", secretKey: "ST2K33GR"))
            } catch let error {
                expectError = error as? TruvideoSdk.TruVideoSdkError
            }
            
            // Then
            #expect(expectError.kind == TruVideoSdkError.ErrorReason(rawValue: "appAlreadyConfigured"))
            #expect(authenticatableClient.authenticateCalled == false)
            #expect(authenticatableClient.currentToken == nil)
            #expect(deviceSettingResource.retrieveCalled == false)
        }
    }
    
    @Test
    func testThatIsAuthenticatedReturnsTrueIfTokenExists() async throws {
        await withDependencyValues { dependencies in
            // Given
            let sut = TruVideoApp()

            // When
            dependencies.authenticatableClient = authenticatableClient

            sut.configure(with: TruVideoOptions(apiKey: "KEY", secretKey: "SECRET"))
            try? await sut.authenticate()
            let result = try! sut.isAuthenticated()

            // Then
            #expect(result == true)
        }
    }

    @Test
    func testThatIsAuthenticatedReturnsFalseIfNoToken() async throws {
        await withDependencyValues { dependencies in
            // Given
            let sut = TruVideoApp()

            // When
            dependencies.authenticatableClient = authenticatableClient

            let result = try! sut.isAuthenticated()

            // Then
            #expect(result == false)
        }
    }
}
