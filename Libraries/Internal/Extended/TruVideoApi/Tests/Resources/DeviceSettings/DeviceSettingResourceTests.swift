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

struct DeviceSettingResourceTests {
    // MARK: - Private Properties
    
    private let session = SessionMock()
    
    // MARK: - Tests
    
    @Test
    func testThatRetrieveShouldSucceedWithValidSession() async throws {
        try await withDependencyValues { dependencyValues in
            // Given
            let dataRequest = DataRequestMock()
            let deviceSetting = DeviceSetting.mock
            let sessionManager = SessionManagerMock()
            let sut = DeviceSettingsResourceImpl()
            
            // When
            session.dataRequest = dataRequest
            dependencyValues.session = session
            dependencyValues.sessionManager = sessionManager
            dataRequest.mockResponse = Response<DeviceSetting, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: nil,
                result: .success(deviceSetting),
                type: .networkLoad
            )

            try sessionManager.set(AuthSession.mock)
            
            let result = try await sut.retrieve()
                        
            // Then
            #expect(result.isAutoPlayEnabled == deviceSetting.isAutoPlayEnabled)
            #expect(result.isNoseCancellingEnabled == deviceSetting.isNoseCancellingEnabled)
            #expect(result.s3Configuration.bucketName == deviceSetting.s3Configuration.bucketName)
        }
    }
    
    @Test
    func testThatRetrieveShouldThrowUnauthenticatedErrorWhenNoSession() async throws {
        await withDependencyValues { dependencyValues in
            // Given
            let dataRequest = DataRequestMock()
            let sut = DeviceSettingsResourceImpl()
            
            // When
            session.dataRequest = dataRequest
            dependencyValues.session = session
            
            // Then
            await #expect {
                try await sut.retrieve()
            } throws: { error in
                return (error as? UtilityError)?.kind == .TruVideoApiErrorReason.unauthenticated
            }
        }
    }
    
    @Test
    func testThatRetrieveShouldThrowDeviceSettingsRetrievalFailedOnRequestError() async throws {
        try await withDependencyValues { dependencyValues in
            // Given
            let dataRequest = DataRequestMock()
            let sessionManager = SessionManagerMock()
            let sut = DeviceSettingsResourceImpl()
            
            // When
            session.dataRequest = dataRequest
            dependencyValues.session = session
            dependencyValues.sessionManager = sessionManager
            dataRequest.mockResponse = Response<DeviceSetting, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: nil,
                result: .failure(NetworkingError(kind: .invalidURL, failureReason: "")),
                type: .networkLoad
            )
            
            try sessionManager.set(AuthSession.mock)
            
            // Then
            await #expect {
                try await sut.retrieve()
            } throws: { error in
                return (error as? UtilityError)?.kind == .TruVideoApiErrorReason.deviceSettingsRetrivalFailed
            }
        }
    }
    
    @Test
    func testThatRetrieveShouldUseCorrectURLWithAuthTokenId() async throws {
        try await withDependencyValues { dependencyValues in
            // Given
            let authSession = AuthSession.mock
            let dataRequest = DataRequestMock()
            let sessionManager = SessionManagerMock()
            let sut = DeviceSettingsResourceImpl()
            
            // When
            session.dataRequest = dataRequest
            dependencyValues.session = session
            dependencyValues.sessionManager = sessionManager
            dataRequest.mockResponse = Response<DeviceSetting, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: nil,
                result: .success(DeviceSetting.mock),
                type: .networkLoad
            )
            
            try sessionManager.set(authSession)
            _ = try await sut.retrieve()
            
            let url = try session.lastRequestURL?.asURL()
            
            // Then
            #expect(url!.absoluteString.contains("api/device/\(authSession.authToken.id)/settings"))
        }
    }
    
    @Test
    func testThatRetrieveShouldUseGetMethod() async throws {
        try await withDependencyValues { dependencyValues in
            // Given
            let dataRequest = DataRequestMock()
            let sessionManager = SessionManagerMock()
            let sut = DeviceSettingsResourceImpl()
            
            // When
            session.dataRequest = dataRequest
            dependencyValues.session = session
            dependencyValues.sessionManager = sessionManager
            dataRequest.mockResponse = Response<DeviceSetting, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: nil,
                result: .success(DeviceSetting.mock),
                type: .networkLoad
            )
            
            try sessionManager.set(AuthSession.mock)
            _ = try await sut.retrieve()
            
            // Then
            #expect(session.lastRequestMethod == .get)
        }
    }
    
    @Test
    func testThatRetrieveShouldUseReturnCacheDataElseLoadPolicy() async throws {
        try await withDependencyValues { dependencyValues in
            // Given
            let dataRequest = DataRequestMock()
            let sessionManager = SessionManagerMock()
            let sut = DeviceSettingsResourceImpl()
            
            // When
            session.dataRequest = dataRequest
            dependencyValues.session = session
            dependencyValues.sessionManager = sessionManager
            dataRequest.mockResponse = Response<DeviceSetting, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: nil,
                result: .success(DeviceSetting.mock),
                type: .networkLoad
            )
            
            try sessionManager.set(AuthSession.mock)
            
            _ = try await sut.retrieve()
            
            // Then
            #expect(session.lastRequestCachePolicy == .returnCacheDataElseLoad)
        }
    }
    
    @Test
    func testThatRetrieveShouldValidateResponse() async throws {
        try await withDependencyValues { dependencyValues in
            // Given
            let dataRequest = DataRequestMock()
            let sessionManager = SessionManagerMock()
            let sut = DeviceSettingsResourceImpl()
            
            // When
            session.dataRequest = dataRequest
            dependencyValues.session = session
            dependencyValues.sessionManager = sessionManager
            dataRequest.mockResponse = Response<DeviceSetting, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: nil,
                result: .success(DeviceSetting.mock),
                type: .networkLoad
            )
            
            try sessionManager.set(AuthSession.mock)
            
            _ = try await sut.retrieve()
            
            // Then
            #expect(dataRequest.validateCallCount == 2)
        }
    }
}

private extension DeviceSetting {
    /// A mock instance of the device setting.
    static var mock: DeviceSetting {
        DeviceSetting(
            isAutoPlayEnabled: true,
            isNoseCancellingEnabled: false,
            s3Configuration: DeviceSetting.S3Configuration(
                bucketName: "test-bucket",
                bucketForLogs: "logs",
                bucketForMedia: "media",
                identityId: "test-identity",
                identityPoolId: "test-pool",
                newBucketFolderForLogs: "new-logs",
                newBucketFolderForMedia: "new-media",
                region: "us-east-1"
            )
        )
    }
}
