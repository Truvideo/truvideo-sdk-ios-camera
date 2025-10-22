//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// Device-specific configuration and settings retrieved from the TruVideo API.
///
/// This struct contains configuration parameters that are specific to the authenticated
/// device. The settings include feature flags, AWS S3 storage configuration, and other
/// device-specific preferences that are dynamically retrieved from the TruVideo backend.
public struct DeviceSetting: Codable, Sendable {
    /// Indicates whether auto play is enabled for the device.
    public let isAutoPlayEnabled: Bool

    /// A boolean indicating whether the camera module is active.
    public let isCameraModuleEnabled: Bool

    /// Indicates whether noise cancellation is enabled for the device.
    public let isNoseCancellingEnabled: Bool

    /// AWS S3 storage configuration for the device.
    public let s3Configuration: S3Configuration

    // MARK: - Types

    /// Configuration for AWS S3 storage settings retrieved from the remote server.
    ///
    /// This struct contains all the necessary configuration parameters for connecting
    /// to and using AWS S3 services. The configuration is dynamically retrieved from
    /// the TruVideo backend server and includes bucket information, folder paths,
    /// authentication credentials, and regional settings.
    public struct S3Configuration: Codable, Sendable {
        /// The name of the S3 bucket for storing files.
        public let bucketName: String

        /// The folder path within the bucket for log files.
        public let bucketForLogs: String

        /// The folder path within the bucket for media files.
        public let bucketForMedia: String

        /// The AWS identity ID for authentication.
        public let identityId: String

        /// The AWS identity pool ID for authentication.
        public let identityPoolId: String

        /// The new folder path within the bucket for log files.
        public let newBucketFolderForLogs: String

        /// The new folder path within the bucket for media files.
        public let newBucketFolderForMedia: String

        /// The AWS region where the bucket is located.
        public let region: String

        // MARK: - CodingKeys

        /// Allowable keys for the model.
        enum CodingKeys: String, CodingKey {
            case bucketName
            case bucketForLogs = "bucketFolderLogs"
            case bucketForMedia = "bucketFolderMedia"
            case identityId = "identityID"
            case identityPoolId = "identityPoolID"
            case newBucketFolderForLogs = "newBucketFolderLogs"
            case newBucketFolderForMedia = "newBucketFolderMedia"
            case region
        }

        // MARK: - Initializer

        /// Creates a new instance of `S3Configuration`.
        ///
        /// - Parameters:
        ///   - bucketName: The name of the S3 bucket for storing files.
        ///   - bucketForLogs: The folder path within the bucket for log files.
        ///   - bucketForMedia: The folder path within the bucket for media files.
        ///   - identityId: The AWS identity ID for authentication.
        ///   - identityPoolId: The AWS identity pool ID for authentication.
        ///   - newBucketFolderForLogs: The new folder path within the bucket for log files.
        ///   - newBucketFolderForMedia: The new folder path within the bucket for media files.
        ///   - region: The AWS region where the bucket is located.
        public init(
            bucketName: String,
            bucketForLogs: String,
            bucketForMedia: String,
            identityId: String,
            identityPoolId: String,
            newBucketFolderForLogs: String,
            newBucketFolderForMedia: String,
            region: String
        ) {
            self.bucketName = bucketName
            self.bucketForLogs = bucketForLogs
            self.bucketForMedia = bucketForMedia
            self.identityId = identityId
            self.identityPoolId = identityPoolId
            self.newBucketFolderForLogs = newBucketFolderForLogs
            self.newBucketFolderForMedia = newBucketFolderForMedia
            self.region = region
        }
    }

    // MARK: - CodingKeys

    /// Allowable keys for the model.
    enum CodingKeys: String, CodingKey {
        case isAutoPlayEnabled = "enabledAutoPlay"
        case isCameraModuleEnabled = "cameraModule"
        case isNoseCancellingEnabled = "noiseCancelling"
        case s3Configuration = "credentials"
    }

    // MARK: - Initializer

    /// Creates a new instance of `DeviceSetting`.
    ///
    /// - Parameters:
    ///   - isAutoPlayEnabled: Indicates whether auto play is enabled for the device.
    ///   - isCameraModuleEnabled: A boolean indicating whether the camera module is active.
    ///   - isNoseCancellingEnabled: Indicates whether noise cancellation is enabled for the device.
    ///   - s3Configuration: AWS S3 storage configuration for the device.
    public init(
        isAutoPlayEnabled: Bool,
        isCameraModuleEnabled: Bool,
        isNoseCancellingEnabled: Bool,
        s3Configuration: S3Configuration
    ) {
        self.isAutoPlayEnabled = isAutoPlayEnabled
        self.isCameraModuleEnabled = isCameraModuleEnabled
        self.isNoseCancellingEnabled = isNoseCancellingEnabled
        self.s3Configuration = s3Configuration
    }
}
