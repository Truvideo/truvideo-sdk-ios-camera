//
// Copyright © 2025 TruVideo. All rights reserved.
//

internal import CloudStorage
internal import TruVideoApi
internal import Utilities

/// A type that provides access to a cloud storage service.
///
/// Conforming types are responsible for creating and configuring a `CloudStorage`
/// instance when requested. Implementations may return `nil` if the provider
/// does not yet have sufficient information to create a valid storage instance
/// (e.g., missing configuration).
protocol CloudStorageProvider {
    /// Creates and returns a cloud storage instance.
    ///
    /// - Returns: A configured `CloudStorage` instance, or `nil` if the provider
    ///   cannot create one at this time.
    /// - Throws: An error if the creation process fails due to invalid configuration
    ///   or other runtime issues.
    func makeStorage() throws(TruVideoSdkError) -> CloudStorage?
}

/// A cloud storage provider that manages S3-based storage instances.
///
/// This class implements the CloudStorageProvider protocol to provide
/// Amazon S3 cloud storage functionality. It manages the lifecycle of
/// S3CloudStorage instances, including creation, caching, and configuration
/// validation. The provider uses device settings to configure the S3
/// connection with appropriate region, bucket, and identity pool settings.
final class S3CloudStorageProvider: CloudStorageProvider {
    // MARK: - Private Properties

    private var cloudStorage: CloudStorage?

    // MARK: - Properties

    /// The device settings containing S3 configuration information.
    var deviceSetting: DeviceSetting?

    // MARK: - Instance methods

    /// Creates and returns a cloud storage instance.
    ///
    /// - Returns: A configured `CloudStorage` instance, or `nil` if the provider
    ///   cannot create one at this time.
    /// - Throws: An error if the creation process fails due to invalid configuration
    ///   or other runtime issues.
    func makeStorage() throws(TruVideoSdkError) -> CloudStorage? {
        guard let cloudStorage else {
            guard let deviceSetting else { return nil }

            do {
                let cloudStorage = try S3CloudStorage(
                    awsRegion: .USWest2,
                    bucketName: deviceSetting.s3Configuration.bucketName,
                    poolId: deviceSetting.s3Configuration.identityPoolId,
                    isAccelerateModeEnabled: false
                )

                self.cloudStorage = cloudStorage
                return cloudStorage
            } catch {
                throw TruVideoSdkError(
                    kind: .makeCloudStorageFailed,
                    errorDescription: error.localizedDescription,
                    failureReason: error.localizedDescription
                )
            }
        }

        return cloudStorage
    }
}
