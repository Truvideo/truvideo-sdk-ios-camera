//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Utilities

@testable import TruVideoApi

/// Mock implementation of `DeviceSettingsResource` for unit testing.
public final class DeviceSettingsResourceMock: DeviceSettingsResource, @unchecked Sendable {
    // MARK: - Properties

    /// The stubbed settings to return when `retrieve()` is called.
    public var stubDeviceSetting: DeviceSetting?

    /// Records whether `retrieve()` was called.
    public private(set) var retrieveCallCount = 0

    /// Error to throw from `retrieve()`, if set.
    public var retrieveError: UtilityError?

    // MARK: - Initializer

    /// Creates a new instance of the `DeviceSettingsResourceMock`.
    public init() {}

    // MARK: - DeviceSettingsResource

    /// Retrieves the current device settings from the TruVideo API.
    ///
    /// This method fetches device-specific configuration and settings that are
    /// associated with the authenticated device. The settings may include
    /// feature flags, configuration parameters, and device-specific preferences.
    ///
    /// ## Prerequisites
    ///
    /// - The user must be authenticated before calling this method
    /// - A valid authentication session must be available
    ///
    /// - Returns: The device settings for the authenticated device
    /// - Throws: An error if the request fails or the user is not authenticated
    public func retrieve() async throws(UtilityError) -> DeviceSetting {
        retrieveCallCount += 1

        if let retrieveError {
            throw UtilityError(kind: .unknown, underlyingError: retrieveError)
        }

        if let stubDeviceSetting {
            return stubDeviceSetting
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
