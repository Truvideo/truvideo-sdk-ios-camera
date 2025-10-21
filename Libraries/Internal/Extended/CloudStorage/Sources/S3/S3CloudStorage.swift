//
// Copyright © 2025 TruVideo. All rights reserved.
//

internal import AWSS3
import DI
import Foundation
internal import Networking
import Utilities

/// Global actor that provides thread-safe isolation for S3 cloud storage operations.
///
/// The S3CloudStorageActor provides a centralized execution context for managing
/// AWS S3 cloud storage operations, ensuring that all storage operations, file
/// uploads, downloads, and metadata management occur on a single, well-defined
/// executor.
@globalActor
actor S3CloudStorageActor {
    /// The shared global actor instance used to isolate device operations.
    static let shared = S3CloudStorageActor()
}

/// A concrete implementation of `CloudStorage` that uploads files to Amazon S3.
///
/// This struct provides a high-level interface for uploading data to Amazon S3 buckets
/// using the AWS SDK for iOS. It abstracts the complexity of S3 operations and provides
/// a simple, consistent API for file uploads with progress tracking and control capabilities.
///
/// ## Features
///
/// - **Asynchronous Uploads**: All upload operations are performed asynchronously
/// - **Progress Tracking**: Monitor upload progress through the returned `UploadTask`
/// - **Upload Control**: Pause, resume, and cancel uploads as needed
/// - **Content Type Support**: Automatic handling of MIME types and file extensions
/// - **Error Handling**: Comprehensive error handling for network and S3-specific issues
/// - **Thread Safety**: Safe for concurrent use across multiple threads
///
/// ## Usage Example
///
/// ```swift
/// let cloudStorage = S3CloudStorage()
///
/// // Upload an image
/// let imageData = UIImage(named: "profile")?.jpegData(compressionQuality: 0.8) ?? Data()
/// let uploadTask = cloudStorage.upload(
///     imageData,
///     fileName: "users/123/profile-photo.jpg",
///     contentType: .jpeg
/// )
///
/// // Monitor progress
/// uploadTask.uploadProgress { progress in
///     let percentage = progress.fractionCompleted * 100
///     print("Upload progress: \(percentage)%")
/// }
///
/// // Control upload
/// uploadTask.pause()   // Pause upload
/// uploadTask.resume()  // Resume upload
/// uploadTask.cancel()  // Cancel upload
/// ```
public final class S3CloudStorage: CloudStorage, @unchecked Sendable {
    // MARK: - Private Properties

    private let bucketName: String
    private let monitor: S3TaskMonitor?

    // MARK: - Properties

    /// A dictionary of the currently active upload tasks, keyed by their unique `UUID`.
    ///
    /// Each entry represents an ongoing `S3UploadTask` that has been started but not yet
    /// completed or cancelled. The `UUID` key provides a stable identifier for managing,
    /// tracking, and removing specific uploads from the active set.
    private(set) var activeUploadTasks = Set<S3UploadTask>()

    /// The AWS S3 transfer utility responsible for performing storage operations.
    let transferUtility: S3TransferUtilityProtocol

    // MARK: - Private Static Properties

    private static let maxNumberOfRetries = 3
    private static let s3key = "com.truvideo.cloudStorage.s3"
    private static let timeoutInterval = 15 * 60

    // MARK: - Types

    /// Represents an AWS S3 region for cloud storage operations.
    ///
    /// The `Region` struct encapsulates AWS S3 region identifiers used to specify
    /// the geographical location where cloud storage operations should be performed.
    /// It conforms to `RawRepresentable` to allow for easy serialization and
    /// integration with external systems that use integer-based region identifiers.
    ///
    /// ## Purpose
    ///
    /// This struct provides a type-safe way to represent AWS S3 regions within
    /// the TruVideo SDK's cloud storage system. It ensures that region identifiers
    /// are properly validated and prevents invalid region values from being used
    /// in cloud storage operations.
    ///
    /// ## Available Regions
    ///
    /// Currently supported regions:
    /// - `usWest2`: US West (Oregon) region with raw value 4
    public struct Region: RawRepresentable {
        // MARK: - Public Properties

        /// The corresponding value of the raw type.
        public var rawValue: Int

        // MARK: - Static Properties

        /// US West (Oregon) AWS S3 region.
        ///
        /// This region represents the US West 2 (Oregon) AWS data center,
        /// which provides low-latency access for users in the western United States
        /// and serves as the primary region for TruVideo cloud storage operations.
        public static let usWest2 = Region(rawValue: 4)

        // MARK: - Initializer

        /// Creates a new instance with the specified raw value.
        ///
        /// - Parameter rawValue: The raw value to use for the new instance
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }

    // MARK: - Initializer

    /// Creates an instance using an existing `AWSS3TransferUtility`.
    ///
    /// Use this initializer when dependency injection is preferred,
    /// for example in unit tests or when the transfer utility is shared.
    ///
    /// - Parameters:
    ///   - bucketName: The name of the S3 bucket.
    ///   - transferUtility: A pre-configured `S3TransferUtilityProtocol` instance.
    ///   - monitor: A type to monitor the lifecycle of an S3 upload task.
    init(bucketName: String, transferUtility: S3TransferUtilityProtocol, monitor: S3TaskMonitor? = nil) {
        self.bucketName = bucketName
        self.monitor = monitor
        self.transferUtility = transferUtility
    }

    /// Creates an instance and registers a new `AWSS3TransferUtility` if needed.
    ///
    /// This initializer configures AWS credentials, service settings,
    /// and transfer behavior before registering the utility.
    /// If a transfer utility with the same key already exists, it is reused.
    ///
    /// - Parameters:
    ///   - region: The AWS region where the S3 bucket resides.
    ///   - bucketName: The name of the S3 bucket.
    ///   - poolId: The Amazon Cognito Identity Pool ID for authentication.
    ///   - isAccelerateModeEnabled: Enables or disables S3 Transfer Acceleration.
    ///   - monitor: A type to monitor the lifecycle of an S3 upload task.
    public convenience init(
        region: Region,
        bucketName: String,
        poolId: String,
        isAccelerateModeEnabled: Bool,
        monitor: S3TaskMonitor? = nil
    ) throws {
        var transferUtility = AWSS3TransferUtility.s3TransferUtility(forKey: Self.s3key)

        if transferUtility == nil {
            let regionType = AWSRegionType(rawValue: region.rawValue) ?? .USWest2
            let credentialsProvider = AWSCognitoCredentialsProvider(regionType: regionType, identityPoolId: poolId)
            let configuration = AWSServiceConfiguration(region: regionType, credentialsProvider: credentialsProvider)

            guard let configuration else {
                throw UtilityError(
                    kind: .CloudStorageErrorReason.cloudStorageInitializationFailed,
                    failureReason: "Missing Configuration."
                )
            }

            let transferUtilityConfiguration = AWSS3TransferUtilityConfiguration()

            transferUtilityConfiguration.retryLimit = Self.maxNumberOfRetries
            transferUtilityConfiguration.timeoutIntervalForResource = Self.timeoutInterval
            transferUtilityConfiguration.isAccelerateModeEnabled = isAccelerateModeEnabled

            AWSS3TransferUtility.register(
                with: configuration,
                transferUtilityConfiguration: transferUtilityConfiguration,
                forKey: Self.s3key
            )

            transferUtility = AWSS3TransferUtility.s3TransferUtility(forKey: Self.s3key)
        }

        guard let transferUtility else {
            throw UtilityError(
                kind: .CloudStorageErrorReason.cloudStorageInitializationFailed,
                failureReason: "Missing Transfer Utility."
            )
        }

        self.init(bucketName: bucketName, transferUtility: transferUtility, monitor: monitor)
    }

    // MARK: - CloudStorage

    /// Creates a new stream-based upload task to cloud storage.
    ///
    /// This method initializes and returns a `StreamUploadTask`, designed for uploading
    /// large files or continuous data streams in smaller, manageable chunks instead of
    /// sending them as a single in-memory `Data` object.
    ///
    /// This approach is particularly useful for:
    /// - Uploading videos or other large media files that may exceed memory limits.
    /// - Handling real-time generated content (e.g., live recording).
    /// - Ensuring resilience and efficiency in unstable network conditions.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the upload task, typically associated with the file
    ///     or resource being uploaded.
    ///   - contentType: The MIME type of the data being uploaded (e.g., `.videoMp4`, `.imageJpeg`).
    ///
    /// - Returns: A `StreamUploadTask` instance that enables incremental, chunk-based
    ///   uploading with full control over the streaming lifecycle.
    public func streamUpload(with id: String, contentType: ContentType) -> any StreamUploadTask {
        S3StreamUploadTask(id: id, contentType: contentType, delegate: self, monitor: monitor)
    }

    /// Uploads data to cloud storage and returns an upload task for monitoring and control.
    ///
    /// This method initiates an upload operation to the cloud storage service and returns
    /// an `UploadDataTask` that provides full control over the upload process. The upload
    /// task allows you to monitor progress, control the upload lifecycle, and handle
    /// completion or errors.
    ///
    /// - Parameters:
    ///   - data: The data to upload to cloud storage
    ///   - fileName: The name under which the file will be stored in cloud storage
    ///   - contentType: The MIME type of the data being uploaded
    /// - Returns: An `UploadDataTask` that provides control and monitoring capabilities for the upload operation
    public func upload(_ data: Data, fileName: String, contentType: ContentType) -> any UploadDataTask {
        let payload = S3DataPayload(bucket: bucketName, contentType: contentType, data: data, path: fileName)
        let uploadDataTask = S3UploadDataTask(payload: payload, delegate: self, monitor: monitor)

        Task { @S3CloudStorageActor in
            activeUploadTasks.insert(uploadDataTask)

            if uploadDataTask.state != .cancelled {
                let awsTask = transferUtility.uploadData(
                    payload.data,
                    bucket: payload.bucket,
                    key: payload.path,
                    contentType: payload.contentType.rawValue,
                    expression: uploadDataTask.expression
                ) { awsTask, error in
                    Task { @S3CloudStorageActor in
                        var wrappedError: UtilityError?

                        if let error {
                            wrappedError = UtilityError(
                                kind: .CloudStorageErrorReason.failedToUploadData,
                                underlyingError: error
                            )
                        }

                        await uploadDataTask.didComplete(task: awsTask, error: wrappedError)
                    }
                }

                awsTask.continueWith { awsTask in
                    Task {
                        guard let uploadTask = awsTask.result else {
                            let errorReason = ErrorReason.CloudStorageErrorReason.uploadTaskCreationFailed
                            let error = UtilityError(kind: errorReason, underlyingError: awsTask.error)

                            await uploadDataTask.didFailToCreateUploadTask(with: error)

                            return
                        }

                        uploadTask.suspend()

                        await uploadDataTask.didCreate(task: uploadTask)
                    }

                    return nil
                }
            }
        }

        return uploadDataTask
    }
}

extension S3CloudStorage: S3UploadTaskDelegate {
    // MARK: - S3UploadTaskDelegate

    func taskDidComplete(_ task: S3UploadTask) {
        activeUploadTasks.remove(task)
    }
}
