//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AWSS3
import DI
import Foundation
import Networking
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

    // MARK: - Dependencies

    @Dependency(\.session)
    private var session: Session

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

    // MARK: - Initializer

    /// Creates an instance using an existing `AWSS3TransferUtility`.
    ///
    /// Use this initializer when dependency injection is preferred,
    /// for example in unit tests or when the transfer utility is shared.
    ///
    /// - Parameters:
    ///   - bucketName: The name of the S3 bucket.
    ///   - transferUtility: A pre-configured `S3TransferUtilityProtocol` instance.
    init(
        bucketName: String,
        monitor: S3TaskMonitor? = nil,
        transferUtility: S3TransferUtilityProtocol
    ) {

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
    ///   - awsRegion: The AWS region where the S3 bucket resides.
    ///   - bucketName: The name of the S3 bucket.
    ///   - poolId: The Amazon Cognito Identity Pool ID for authentication.
    ///   - isAccelerateModeEnabled: Enables or disables S3 Transfer Acceleration.
    ///   - monitor: An optional `S3TaskMonitor`s for observing request events.
    public convenience init(
        awsRegion: AWSRegionType,
        bucketName: String,
        poolId: String,
        isAccelerateModeEnabled: Bool,
        monitor: S3TaskMonitor? = nil
    ) throws {

        var transferUtility = AWSS3TransferUtility.s3TransferUtility(forKey: Self.s3key)

        if transferUtility == nil {
            let credentialsProvider = AWSCognitoCredentialsProvider(regionType: awsRegion, identityPoolId: poolId)
            let configuration = AWSServiceConfiguration(region: awsRegion, credentialsProvider: credentialsProvider)

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

        self.init(
            bucketName: bucketName,
            monitor: monitor,
            transferUtility: transferUtility
        )
    }

    // MARK: - CloudStorage

    /// Cancels all active upload tasks.
    ///
    /// This method asynchronously iterates through all currently active `S3UploadTask`
    /// instances and requests their cancellation. Each task is cancelled by invoking
    /// its `cancel()` method within a new asynchronous context.
    ///
    /// This is useful for stopping all ongoing uploads, for example when the user
    /// logs out, the app is shutting down, or network conditions change.
    public func cancelAllUploads() {
        Task { @S3CloudStorageActor in
            activeUploadTasks.forEach { $0.cancel() }
        }
    }

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
        S3StreamUploadTask(id: id, contentType: contentType, monitor: monitor, session: session)
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
        let uploadTask = S3UploadTask(monitor: monitor, payload: payload)

        Task { @S3CloudStorageActor in
            activeUploadTasks.insert(uploadTask)

            if uploadTask.state != .cancelled {
                let awsTask = self.transferUtility.uploadData(
                    payload.data,
                    bucket: payload.bucket,
                    key: payload.path,
                    contentType: payload.contentType.rawValue,
                    expression: uploadTask.expression
                ) { [weak self] awsTask, error in

                    self?.didComplete(awsTask, for: uploadTask, with: error)
                }

                await didCreate(awsTask: awsTask, for: uploadTask)
            }
        }

        return uploadTask
    }

    // MARK: - Private methods

    private func didComplete(
        _ awsTask: AWSS3TransferUtilityUploadTask,
        for task: S3UploadTask,
        with error: Error?
    ) {
        activeUploadTasks.remove(task)

        Task {
            var wrappedError: UtilityError?

            if let error {
                wrappedError = UtilityError(
                    kind: .CloudStorageErrorReason.failedToUploadData,
                    underlyingError: error
                )
            }

            await task.didComplete(task: awsTask, error: wrappedError)
        }
    }

    private func didCreate(
        awsTask: AWSTask<AWSS3TransferUtilityUploadTask>,
        for task: S3UploadTask
    ) async {
        awsTask.continueWith { awsTask in
            guard let uploadTask = awsTask.result else {
                let error = UtilityError(
                    kind: .CloudStorageErrorReason.uploadTaskCreationFailed,
                    failureReason: "Unable to create the S3 upload task.",
                    underlyingError: awsTask.error
                )

                Task {
                    await task.didFailToCreateUploadTask(with: error)
                }

                return nil
            }

            uploadTask.suspend()
            Task {
                await task.didCreate(task: uploadTask)
            }

            return nil
        }
    }
}
