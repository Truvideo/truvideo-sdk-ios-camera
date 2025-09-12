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
    // MARK: - Private Properties
    
    private let authenticatableClient: AuthenticatableClientMock
    private let deviceSettingResource: DeviceSettingsResourceMock
    
    // MARK: - Initializer

    init() {
        authenticatableClient = AuthenticatableClientMock()
        deviceSettingResource = DeviceSettingsResourceMock()
    }

    // MARK: - Tests

    @Test
    func testThatAuthentication() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let sut = TruVideoApp()
            
            // When
            dependencies.authenticatableClient = authenticatableClient
            dependencies.deviceSettingResource = deviceSettingResource

            sut.configure(with: TruVideoOptions(apiKey: "VS2SG9WK", secretKey: "ST2K33GR", signer: SignerMock()))
            
            try await sut.authenticate()
            
            // Then
            #expect(authenticatableClient.authenticateCalled == true)
            #expect(authenticatableClient.currentSession != nil)
            #expect(deviceSettingResource.retrieveCallCount == 1)
        }
    }

    @Test
    func testThatAuthenticationShouldFailWhenIsNotConfigured() async throws {
        await withDependencyValues { dependencies in
            // Given
            let sut = TruVideoApp()
            
            // When
            dependencies.authenticatableClient = authenticatableClient
            dependencies.deviceSettingResource = deviceSettingResource
            
            // Then
            await #expect {
                try await sut.authenticate()
            } throws: { error in
                let error = error as! TruVideoSdkError
                
                return [
                    error.kind == TruVideoSdkError.configurationRequired.kind,
                    error.errorDescription != nil,
                    error.failureReason != nil
                ]
                    .allSatisfy { _ in  true }
            }
            
            #expect(!authenticatableClient.authenticateCalled)
            #expect(authenticatableClient.currentSession == nil)
            #expect(deviceSettingResource.retrieveCallCount == 1)
        }
    }
    
    @Test
    func testThatAuthenticationShouldFailWhenClientFailsWithUtilityError() async throws {
        await withDependencyValues { dependencies in
            // Given
            let sut = TruVideoApp()

            // When
            dependencies.authenticatableClient = authenticatableClient
            dependencies.deviceSettingResource = deviceSettingResource

            authenticatableClient.authenticateError = UtilityError(kind: .init(rawValue: "authenticationFailed"))
            
            sut.configure(with: TruVideoOptions(apiKey: "VS2SG9WK", secretKey: "ST2K33GR"))
            
            // Then
            await #expect {
                try await sut.authenticate()
            } throws: { error in
                let error = error as! TruVideoSdkError
                
                return error.kind == TruVideoSdkError.ErrorReason.authenticationFailed
            }
            
            #expect(authenticatableClient.authenticateCalled == true)
            #expect(authenticatableClient.currentSession == nil)
            #expect(deviceSettingResource.retrieveCallCount == 1)
        }
    }
    
    @Test
    func testThatAuthenticationShouldFailWhenSignerFails() async throws {
        await withDependencyValues { dependencies in
            // Given
            let sut = TruVideoApp()
            let signer = SignerMock()
            
            // When
            dependencies.authenticatableClient = authenticatableClient
            dependencies.deviceSettingResource = deviceSettingResource

            signer.error = NSError(domain: "", code: 1)

            sut.configure(with: TruVideoOptions(apiKey: "VS2SG9WK", secretKey: "ST2K33GR", signer: signer))

            // Then
            await #expect {
                try await sut.authenticate()
            } throws: { error in
                let error = error as! TruVideoSdkError
                
                return error.kind == TruVideoSdkError.ErrorReason.authenticationFailed
            }
            
            #expect(authenticatableClient.authenticateCalled == false)
            #expect(authenticatableClient.currentSession == nil)
            #expect(deviceSettingResource.retrieveCallCount == 1)
        }
    }
}
