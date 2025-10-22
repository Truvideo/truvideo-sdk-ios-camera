//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
import Registry
import RegistryTesting
import Testing
import TruVideoApi
import TruVideoApiTesting
import TruvideoSdkTesting
import Utilities
import UtilitiesTesting

@testable import TruvideoSdk

struct TruVideoAppTests {
    // MARK: - Private Properties

    private let migrator: MigratorMock

    // MARK: - Initializer

    init() {
        migrator = MigratorMock()
    }

    // MARK: - Tests

    @Test
    func testThatRetrieveDeviceSettingsIsCalledWhenPathMonitorBecomesSatisfied() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let pathMonitor = NetworkPathMonitorMock(initialPath: .init(status: .unsatisfied))
            let deviceSettingResource = DeviceSettingsResourceMock()
            let sut = TruVideoApp(pathMonitor: pathMonitor)

            // When, Then
            dependencies.deviceSettingResource = deviceSettingResource
            sut.configure(with: TruVideoOptions(signer: SignerMock()))

            let newPath = NetworkPathMock(status: .satisfied)
            pathMonitor.path = newPath
            pathMonitor.pathUpdateHandler?(newPath)

            try await Task.sleep(nanoseconds: 500_000)

            // Then
            #expect(deviceSettingResource.retrieveCallCount == 2)
        }
    }

    @Test
    func testThatConfigureExecutesMigration() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let deviceSettingResource = DeviceSettingsResourceMock()
            let sut = TruVideoApp(migrator: migrator)

            // When
            dependencies.deviceSettingResource = deviceSettingResource
            sut.configure(with: TruVideoOptions())

            try await Task.sleep(nanoseconds: 500)

            // Then
            #expect(migrator.migrateCallCount == 1)
        }
    }

    @Test
    func testThatConfigureShouldCallLibraryRegistryConfigure() async throws {
        try await withDependencyValues { _ in
            // Given
            let library = LibraryRegistryMock(name: "foo-bar", version: "1.0.0")
            let sut = TruVideoApp()

            // When
            LibraryRegistry.register(library)

            sut.configure(with: TruVideoOptions(signer: SignerMock()))

            try await Task.sleep(nanoseconds: 500)

            // Then
            #expect(LibraryRegistry.isConfigured == true)
            #expect(library.configureCalled == true)
        }
    }

    @Test
    func testThatAuthenticateThrowsWhenNotConfigured() async throws {
        await withDependencyValues { dependencies in
            // Given
            let authenticatableClient = AuthenticatableClientMock()
            let sut = TruVideoApp()

            // When
            authenticatableClient.currentSession = nil
            dependencies.authenticatableClient = authenticatableClient

            // Then
            await #expect {
                try await sut.authenticate(apiKey: "KEY", secretKey: "SECRET", externalId: "EXT")
            } throws: { error in
                guard let error = error as? TruVideoSdkError else {
                    return false
                }
                return error.kind == TruVideoSdkError.configurationRequired.kind
            }
        }
    }

    @Test
    func testThatAuthenticateThrowsTruVideoErrorWhenClientFailsWithError() async throws {
        await withDependencyValues { dependencies in
            // Given
            let authenticatableClient = AuthenticatableClientMock()
            let deviceSettingResource = DeviceSettingsResourceMock()
            let signer = SignerMock()
            let sut = TruVideoApp()

            // When
            authenticatableClient.error = UtilityError(kind: .unknown)

            dependencies.authenticatableClient = authenticatableClient
            dependencies.deviceSettingResource = deviceSettingResource

            sut.configure(with: TruVideoOptions(signer: signer))

            // Then
            await #expect {
                try await sut.authenticate(apiKey: "KEY", secretKey: "SECRET", externalId: "EXT")
            } throws: { error in
                guard let error = error as? TruVideoSdkError else {
                    return false
                }

                return error.kind == .unknown
            }
        }
    }

    @Test
    func testThatAuthenticateSucceedsWithValidCredentials() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let authenticatableClient = AuthenticatableClientMock()
            let sut = TruVideoApp()
            let signer = SignerMock()

            // When
            dependencies.authenticatableClient = authenticatableClient

            sut.configure(with: TruVideoOptions(signer: signer))

            try await sut.authenticate(apiKey: "APIKEY", secretKey: "SECRET", externalId: "EXT")

            // Then
            #expect(authenticatableClient.authenticateCalled == true)
            #expect(authenticatableClient.currentSession != nil)
            #expect(signer.signCalled == true)
        }
    }

    @Test
    func testThatAuthenticateWithValidCredentialsCreatesSessionAndFetchesDeviceSettings() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let cloudStorageProvider = CloudStorageProviderMock()
            let authenticatableClient = AuthenticatableClientMock()
            let deviceSettingResource = DeviceSettingsResourceMock()
            let sut = TruVideoApp(cloudStorageProvider: cloudStorageProvider)

            // When
            dependencies.authenticatableClient = authenticatableClient
            dependencies.deviceSettingResource = deviceSettingResource
            cloudStorageProvider.deviceSetting = DeviceSetting(
                isAutoPlayEnabled: true,
                isCameraModuleEnabled: true,
                isNoseCancellingEnabled: false,
                s3Configuration: DeviceSetting.S3Configuration(
                    bucketName: "mock-bucket",
                    bucketForLogs: "logs",
                    bucketForMedia: "media",
                    identityId: "mock-identity-id",
                    identityPoolId: "mock-identity-pool-id",
                    newBucketFolderForLogs: "new-logs",
                    newBucketFolderForMedia: "new-media",
                    region: "us-east-1"
                )
            )

            sut.configure(with: TruVideoOptions(signer: SignerMock()))

            try await sut.authenticate(apiKey: "VS2SG9WK", secretKey: "ST2K33GR", externalId: nil)

            try await Task.sleep(nanoseconds: 1_000_000)

            // Then
            #expect(authenticatableClient.authenticateCalled == true)
            #expect(authenticatableClient.currentSession != nil)
            #expect(deviceSettingResource.retrieveCallCount == 1)
        }
    }

    @Test
    func testThatAuthenticateWithPayloadThrowsConfigurationRequiredErrorWhenNotConfigured() async throws {
        await withDependencyValues { dependencies in
            // Given
            let authenticatableClient = AuthenticatableClientMock()
            let deviceSettingResource = DeviceSettingsResourceMock()
            let sut = TruVideoApp()

            // When
            dependencies.authenticatableClient = authenticatableClient
            dependencies.deviceSettingResource = deviceSettingResource

            // Then
            await #expect {
                try await sut.authenticate(apiKey: "KEY", payload: "payload", signature: "sig", externalId: "ext")
            } throws: { error in
                let error = error as! TruVideoSdkError

                return [
                    error.kind == TruVideoSdkError.configurationRequired.kind,
                    error.errorDescription != nil,
                    error.failureReason != nil
                ]
                    .allSatisfy { _ in true }
            }

            #expect(!authenticatableClient.authenticateCalled)
            #expect(authenticatableClient.currentSession == nil)
            #expect(deviceSettingResource.retrieveCallCount == 0)
        }
    }

    @Test
    func testThatAuthenticateWithPayloadThrowsAuthenticationFailedErrorWhenClientFails() async throws {
        await withDependencyValues { dependencies in
            // Given
            let authenticatableClient = AuthenticatableClientMock()
            let deviceSettingResource = DeviceSettingsResourceMock()
            let sut = TruVideoApp()
            let signer = SignerMock()

            // When
            dependencies.authenticatableClient = authenticatableClient
            dependencies.deviceSettingResource = deviceSettingResource

            authenticatableClient.error = UtilityError(kind: .init(rawValue: "authenticationFailed"))

            sut.configure(with: TruVideoOptions(signer: signer))

            // Then
            await #expect {
                try await sut.authenticate(apiKey: "KEY", payload: "payload", signature: "sig", externalId: "ext")
            } throws: { error in
                let error = error as! TruVideoSdkError

                return error.kind == TruVideoSdkError.ErrorReason.authenticationFailed
            }

            #expect(authenticatableClient.authenticateCalled == false)
            #expect(authenticatableClient.currentSession == nil)
            #expect(deviceSettingResource.retrieveCallCount == 0)
        }
    }

    @Test
    func testThatAuthenticateWithPayloadThrowsAuthenticationFailedErrorWhenSignerFails() async throws {
        await withDependencyValues { dependencies in
            // Given
            let authenticatableClient = AuthenticatableClientMock()
            let deviceSettingResource = DeviceSettingsResourceMock()
            let sut = TruVideoApp()
            let signer = SignerMock()

            // When
            dependencies.authenticatableClient = authenticatableClient
            dependencies.deviceSettingResource = deviceSettingResource

            signer.error = NSError(domain: "", code: 1)

            sut.configure(with: TruVideoOptions(signer: signer))

            // Then
            await #expect {
                try await sut.authenticate(apiKey: "KEY", payload: "payload", signature: "sig", externalId: "ext")
            } throws: { error in
                let error = error as! TruVideoSdkError

                return error.kind == TruVideoSdkError.ErrorReason.authenticationFailed
            }

            #expect(authenticatableClient.authenticateCalled == false)
            #expect(authenticatableClient.currentSession == nil)
            #expect(deviceSettingResource.retrieveCallCount == 0)
        }
    }
}
