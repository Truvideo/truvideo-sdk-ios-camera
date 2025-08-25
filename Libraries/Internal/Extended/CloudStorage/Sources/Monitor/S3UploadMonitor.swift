//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AWSS3
import Foundation
import Utilities

/// A protocol to monitor the lifecycle of an S3 upload task.
///
/// Implement this protocol to observe and react to key upload events,
/// such as task creation, completion, cancellation, suspension, or failure.
/// This allows for logging, analytics, error tracking, or performance measurement.
///
/// - Conforms to: `Sendable`
public protocol S3UploadMonitor: Sendable {
    /// The working queue for monitor callbacks.
    var queue: DispatchQueue { get }

    /// Called when a upload is canceled.
    ///
    /// - Parameter upload: The `UploadTask` instance that was canceled.
    func uploadDidCancel(_ upload: S3UploadTask)

    /// Called when a upload finishes successfully.
    ///
    /// - Parameter request: The `upload` instance that completed.
    func uploadDidFinish(_ upload: S3UploadTask)

    /// Called when a upload is resumed after being suspended.
    ///
    /// - Parameter upload: The `UploadTask` instance that resumed execution.
    func uploadDidResume(_ upload: S3UploadTask)

    /// Called when a upload is suspended.
    ///
    /// - Parameter upload: The `UploadTask` instance that was suspended.
    func uploadDidSuspend(_ upload: S3UploadTask)

    /// Called when a `AWSS3TransferUtilityUpload` tied to the request is canceled.
    ///
    /// - Parameters:
    ///   - upload: The `UploadTask` associated with the canceled task.
    ///   - task: The `AWSS3TransferUtilityUploadTask` that was canceled.
    func upload(_ upload: S3UploadTask, didCancelTask task: AWSS3TransferUtilityUploadTask)

    /// Called when the upload request finishes (success or failure).
    func upload(
        _ upload: S3UploadTask,
        didCompleteTask task: AWSS3TransferUtilityTask,
        with error: UtilityError?
    )

    /// Called when a new `AWSS3TransferUtilityUploadTask` is created for the request.
    ///
    /// - Parameters:
    ///   - upload: The `UploadTask` instance for which the task was created.
    ///   - task: The `AWSS3TransferUtilityUploadTask` that was created.
    func upload(_ upload: S3UploadTask, didCreateTask task: AWSS3TransferUtilityUploadTask)

    /// Called when a task fails with a specific error.
    ///
    /// - Parameters:
    ///   - upload: The `UploadTask` instance associated with the failed task.
    ///   - task: The `AWSS3TransferUtilityUploadTask` that failed.
    ///   - error: The `Error` that caused the failure.
    func upload(_ upload: S3UploadTask, didFailTask task: AWSS3TransferUtilityUploadTask, with error: UtilityError)

    /// Called when the creation of an upload task fails with an error.
    ///
    /// This method is invoked when an `AWSS3TransferUtilityUploadTask` cannot be created
    /// due to an error, such as invalid parameters, configuration issues, or underlying
    /// service errors. It allows implementers to log, analyze, or react to the failure.
    ///
    /// - Parameters:
    ///   - upload: The `UploadTask` instance that failed during upload task creation.
    ///   - error: The `Error` describing the reason for the creation failure.
    func upload(_ upload: S3UploadTask, didFailToCreateUploadTaskWith error: UtilityError)

    /// Called when a task is resumed.
    ///
    /// - Parameters:
    ///   - upload: The `UploadTask` instance whose task was resumed.
    ///   - task: The resumed `AWSS3TransferUtilityUploadTask`.
    func upload(_ upload: S3UploadTask, didResumeTask task: AWSS3TransferUtilityUploadTask)

    /// Called when a task is suspended.
    ///
    /// - Parameters:
    ///   - upload: The `UploadTask` instance whose task was suspended.
    ///   - task: The suspended `AWSS3TransferUtilityUploadTask`.
    func upload(_ upload: S3UploadTask, didSuspendTask task: AWSS3TransferUtilityUploadTask)
}

extension S3UploadMonitor {

    /// The working queue for monitor callbacks.
    public var queue: DispatchQueue { .main }

    /// Called when a upload is canceled.
    ///
    /// - Parameter upload: The `UploadTask` instance that was canceled.
    public func uploadDidCancel(_ upload: S3UploadTask) {}

    /// Called when a upload finishes successfully.
    ///
    /// - Parameter request: The `upload` instance that completed.
    public func uploadDidFinish(_ upload: S3UploadTask) {}

    /// Called when a upload is resumed after being suspended.
    ///
    /// - Parameter upload: The `UploadTask` instance that resumed execution.
    public func uploadDidResume(_ upload: S3UploadTask) {}

    /// Called when a upload is suspended.
    ///
    /// - Parameter upload: The `UploadTask` instance that was suspended.
    public func uploadDidSuspend(_ upload: S3UploadTask) {}

    /// Called when a `AWSS3TransferUtilityUpload` tied to the request is canceled.
    ///
    /// - Parameters:
    ///   - upload: The `UploadTask` associated with the canceled task.
    ///   - task: The `AWSS3TransferUtilityUploadTask` that was canceled.
    public func upload(_ upload: S3UploadTask, didCancelTask task: AWSS3TransferUtilityUploadTask) {}

    /// Called when the upload request finishes (success or failure) {}.
    public func upload(
        _ upload: S3UploadTask,
        didCompleteTask task: AWSS3TransferUtilityUploadTask,
        with error: UtilityError?
    ) {}

    /// Called when a new `AWSS3TransferUtilityUploadTask` is created for the request.
    ///
    /// - Parameters:
    ///   - upload: The `UploadTask` instance for which the task was created.
    ///   - task: The `AWSS3TransferUtilityUploadTask` that was created.
    public func upload(_ upload: S3UploadTask, didCreateTask task: AWSS3TransferUtilityUploadTask) {}

    /// Called when a task fails with a specific error.
    ///
    /// - Parameters:
    ///   - upload: The `UploadTask` instance associated with the failed task.
    ///   - task: The `AWSS3TransferUtilityUploadTask` that failed.
    ///   - error: The `Error` that caused the failure.
    public func upload(
        _ upload: S3UploadTask,
        didFailTask task: AWSS3TransferUtilityUploadTask,
        with error: UtilityError
    ) {}

    /// Called when the creation of an upload task fails with an error.
    ///
    /// This method is invoked when an `AWSS3TransferUtilityUploadTask` cannot be created
    /// due to an error, such as invalid parameters, configuration issues, or underlying
    /// service errors. It allows implementers to log, analyze, or react to the failure.
    ///
    /// - Parameters:
    ///   - upload: The `UploadTask` instance that failed during upload task creation.
    ///   - error: The `Error` describing the reason for the creation failure.
    public func upload(_ upload: S3UploadTask, didFailToCreateUploadTaskWith error: UtilityError) {}

    /// Called when a task is resumed.
    ///
    /// - Parameters:
    ///   - upload: The `UploadTask` instance whose task was resumed.
    ///   - task: The resumed `AWSS3TransferUtilityUploadTask`.
    public func upload(_ upload: S3UploadTask, didResumeTask task: AWSS3TransferUtilityUploadTask) {}

    /// Called when a task is suspended.
    ///
    /// - Parameters:
    ///   - upload: The `UploadTask` instance whose task was suspended.
    ///   - task: The suspended `AWSS3TransferUtilityUploadTask`.
    public func upload(_ upload: S3UploadTask, didSuspendTask task: AWSS3TransferUtilityUploadTask) {}
}
