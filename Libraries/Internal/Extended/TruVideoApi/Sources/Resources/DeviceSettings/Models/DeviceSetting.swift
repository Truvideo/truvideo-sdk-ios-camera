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
    }

    // MARK: - CodingKeys

    /// Allowable keys for the model.
    enum CodingKeys: String, CodingKey {
        case isAutoPlayEnabled = "enabledAutoPlay"
        case isNoseCancellingEnabled = "noiseCancelling"
        case s3Configuration = "credentials"
    }
}
