//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
import Foundation
import Networking
import NetworkingTesting
import Testing
import TruVideoApiTesting
import Utilities

@testable import TruVideoApi

struct DeviceSettingResourceTests {
    // MARK: - Private Properties

    private let session = SessionMock()

    // MARK: - Tests

    @Test
    func testThatRetrieveSucceedsWithValidSession() async throws {
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
    func testThatRetrieveThrowsUnauthenticatedErrorWhenNoSession() async throws {
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
                (error as? UtilityError)?.kind == .TruVideoApiErrorReason.unauthenticated
            }
        }
    }

    @Test
    func testThatRetrieveFailsOnRequestError() async throws {
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
                (error as? UtilityError)?.kind == .TruVideoApiErrorReason.deviceSettingsRetrivalFailed
            }
        }
    }

    @Test
    func testThatRetrieveUsesCorrectURLWithAuthTokenId() async throws {
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
    func testThatRetrieveUsesGetMethod() async throws {
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
    func testThatRetrieveUsesReturnCacheDataElseLoadPolicy() async throws {
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
    func testThatRetrieveValidatesResponse() async throws {
        try await withDependencyValues { dependencyValues in
            // Given
            let authSession = AuthSession.mock
            let dataRequest = DataRequestMock()
            let sessionManager = SessionManagerMock()
            let sut = DeviceSettingsResourceImpl()
            let response = HTTPURLResponse(
                url: URL(string: "https://beta.truvideo.com/api/device/\(authSession.authToken.id)/settings")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!

            let data = """
            {
                "isAutoPlayEnabled": true,
                "isNoseCancellingEnabled": false,
                "s3Configuration": {
                    "bucket": "truvideo-device-uploads",
                    "region": "us-east-1"
                }
            }
            """.data(using: .utf8)!

            // When
            session.dataRequest = dataRequest
            dependencyValues.session = session
            dependencyValues.sessionManager = sessionManager
            dataRequest.response = response
            dataRequest.data = data
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

    @Test
    func testThatRetrieveThrowsResponseValidationFailedWhenValidationFails() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let authSession = AuthSession.mock
            let dataRequest = DataRequestMock()
            let sessionManager = SessionManagerMock()
            let sut = DeviceSettingsResourceImpl()
            let response = HTTPURLResponse(
                url: URL(string: "https://beta.truvideo.com/api/device/\(authSession.authToken.id)/settings")!,
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
                "instance": "/api/device/36BBA8E7-A9C6-4F00-B4E1-F6BA888FF093/setting"
            }
            """.data(using: .utf8)!

            // When
            session.dataRequest = dataRequest
            dependencies.session = session
            dependencies.sessionManager = sessionManager
            dataRequest.response = response
            dataRequest.data = data
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
