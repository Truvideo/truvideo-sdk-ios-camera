//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Utilities

@testable import TruVideoApi

/// Mock implementation of `DeviceSettingsResource` for unit testing.
public final class DeviceSettingsResourceMock: DeviceSettingsResource {
    // MARK: - Properties

    /// The stubbed settings to return when `retrieve()` is called.
    public var stubDeviceSetting: DeviceSetting?

    /// Records whether `retrieve()` was called.
    public private(set) var retrieveCalled = false

    /// Error to throw from `retrieve()`, if set.
    public var retrieveError: UtilityError?

    // MARK: - Initializer

    public init() {}

    // MARK: - DeviceSettingsResource

    public func retrieve() async throws(UtilityError) -> DeviceSetting {
        retrieveCalled = true

        if let error = retrieveError {
            throw error
        }

        if let setting = stubDeviceSetting {
            return setting
        }

        return DeviceSetting(
            isAutoPlayEnabled: true,
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
    }
}
