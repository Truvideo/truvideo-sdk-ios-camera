//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AWSS3
import Foundation
import Networking
import Utilities

/// A protocol to monitor the lifecycle of an S3 upload task.
///
/// Implement this protocol to observe and react to key upload events,
/// such as task creation, completion, cancellation, suspension, or failure.
/// This allows for logging, analytics, error tracking, or performance measurement.
///
/// - Conforms to: `Sendable`
public protocol S3TaskMonitor: Sendable {
    /// The working queue for monitor callbacks.
    var queue: DispatchQueue { get }

    // MARK: - UploadTask Monitoring

    /// Called when a upload is canceled.
    ///
    /// - Parameter upload: The `UploadTask` instance that was canceled.
    func uploadDidCancel(_ upload: any UploadTask)

    /// Called when a upload finishes successfully.
    ///
    /// - Parameter request: The `upload` instance that completed.
    func uploadDidFinish(_ upload: any UploadTask)

    /// Called when a upload is resumed after being suspended.
    ///
    /// - Parameter upload: The `UploadTask` instance that resumed execution.
    func uploadDidResume(_ upload: any UploadTask)

    /// Called when a upload is suspended.
    ///
    /// - Parameter upload: The `UploadTask` instance that was suspended.
    func uploadDidSuspend(_ upload: any UploadTask)

    /// Called when a `AWSS3TransferUtilityUpload` tied to the request is canceled.
    ///
    /// - Parameters:
    ///   - upload: The `UploadTask` associated with the canceled task.
    ///   - task: The `AWSS3TransferUtilityUploadTask` that was canceled.
    func upload(_ upload: any UploadTask, didCancelTask task: AWSS3TransferUtilityUploadTask)

    /// Called when the upload request finishes (success or failure).
    func upload(
        _ upload: any UploadTask,
        didCompleteTask task: AWSS3TransferUtilityTask,
        with error: UtilityError?
    )

    /// Called when a new `AWSS3TransferUtilityUploadTask` is created for the request.
    ///
    /// - Parameters:
    ///   - upload: The `UploadTask` instance for which the task was created.
    ///   - task: The `AWSS3TransferUtilityUploadTask` that was created.
    func upload(_ upload: any UploadTask, didCreateTask task: AWSS3TransferUtilityUploadTask)

    /// Called when a task fails with a specific error.
    ///
    /// - Parameters:
    ///   - upload: The `UploadTask` instance associated with the failed task.
    ///   - task: The `AWSS3TransferUtilityUploadTask` that failed.
    ///   - error: The `Error` that caused the failure.
    func upload(_ upload: any UploadTask, didFailTask task: AWSS3TransferUtilityUploadTask, with error: UtilityError)

    /// Called when the creation of an upload task fails with an error.
    ///
    /// This method is invoked when an `AWSS3TransferUtilityUploadTask` cannot be created
    /// due to an error, such as invalid parameters, configuration issues, or underlying
    /// service errors. It allows implementers to log, analyze, or react to the failure.
    ///
    /// - Parameters:
    ///   - upload: The `UploadTask` instance that failed during upload task creation.
    ///   - error: The `Error` describing the reason for the creation failure.
    func upload(_ upload: any UploadTask, didFailToCreateUploadTaskWith error: UtilityError)

    /// Called when a task is resumed.
    ///
    /// - Parameters:
    ///   - upload: The `UploadTask` instance whose task was resumed.
    ///   - task: The resumed `AWSS3TransferUtilityUploadTask`.
    func upload(_ upload: any UploadTask, didResumeTask task: AWSS3TransferUtilityUploadTask)

    /// Called when a task is suspended.
    ///
    /// - Parameters:
    ///   - upload: The `UploadTask` instance whose task was suspended.
    ///   - task: The suspended `AWSS3TransferUtilityUploadTask`.
    func upload(_ upload: any UploadTask, didSuspendTask task: AWSS3TransferUtilityUploadTask)

    // MARK: - StreamUploadTask Monitoring

    /// Called when a `AWSS3TransferUtilityUpload` tied to the request is canceled.
    ///
    /// - Parameters:
    ///   - upload: The `StreamUploadTask` associated with the canceled task.
    ///   - task: The `UploadRequest` that was canceled
    ///   - partNumber: The identifier of the subtask in the multipart upload sequence.
    func upload(_ upload: any StreamUploadTask, didCancelTask task: any UploadRequest, for partNumber: Int)

    /// Called when the upload request finishes (success or failure).
    ///
    /// - Parameters:
    ///   - request: The `StreamUploadTask` associated with the completed task.
    ///   - task: The `UploadRequest` that completed.
    ///   - partNumber: The identifier of the subtask in the multipart upload sequence.
    ///   - error: The `UtilityError` encountered, if any.
    func upload(
        _ upload: any StreamUploadTask,
        didCompleteTask task: any UploadRequest,
        for partNumber: Int,
        with error: UtilityError?
    )

    /// Called when a new `UploadRequest` is created for the request.
    ///
    /// - Parameters:
    ///   - upload: The `UploadTask` instance for which the task was created.
    ///   - task: The `AWSS3TransferUtilityUploadTask` that was created.
    ///   - partNumber: The identifier of the subtask in the multipart upload sequence.
    func upload(_ upload: any StreamUploadTask, didCreateTask task: any UploadRequest, for partNumber: Int)

    /// Called when a task fails with a specific error.
    ///
    /// - Parameters:
    ///   - upload: The `StreamUploadTask` instance associated with the failed task.
    ///   - task: The `AWSS3TransferUtilityUploadTask` that failed.
    ///   - error: The `Error` that caused the failure.
    func upload(_ upload: any StreamUploadTask, didFailTask task: any UploadRequest, with error: UtilityError)

    /// Called when a task is resumed.
    ///
    /// - Parameters:
    ///   - upload: The `StreamUploadTask` instance whose task was resumed.
    ///   - task: The resumed `UploadRequest`.
    ///   - partNumber: The identifier of the subtask in the multipart upload sequence.
    func upload(_ upload: any StreamUploadTask, didResumeTask task: any UploadRequest, for partNumber: Int)

    /// Called when a task is suspended.
    ///
    /// - Parameters:
    ///   - upload: The `StreamUploadTask` instance whose task was suspended.
    ///   - task: The suspended `UploadRequest`.
    ///   - partNumber: The identifier of the subtask in the multipart upload sequence.
    func upload(_ upload: any StreamUploadTask, didSuspendTask task: any UploadRequest, for partNumber: Int)
}

extension S3TaskMonitor {

    /// The working queue for monitor callbacks.
    public var queue: DispatchQueue { .main }

    /// Called when a upload is canceled.
    ///
    /// - Parameter upload: The `UploadTask` instance that was canceled.
    public func uploadDidCancel(_ upload: any UploadTask) {}

    /// Called when a upload finishes successfully.
    ///
    /// - Parameter request: The `upload` instance that completed.
    public func uploadDidFinish(_ upload: any UploadTask) {}

    /// Called when a upload is resumed after being suspended.
    ///
    /// - Parameter upload: The `UploadTask` instance that resumed execution.
    public func uploadDidResume(_ upload: any UploadTask) {}

    /// Called when a upload is suspended.
    ///
    /// - Parameter upload: The `UploadTask` instance that was suspended.
    public func uploadDidSuspend(_ upload: any UploadTask) {}

    /// Called when a `AWSS3TransferUtilityUpload` tied to the request is canceled.
    ///
    /// - Parameters:
    ///   - upload: The `UploadTask` associated with the canceled task.
    ///   - task: The `AWSS3TransferUtilityUploadTask` that was canceled.
    public func upload(_ upload: any UploadTask, didCancelTask task: AWSS3TransferUtilityUploadTask) {}

    /// Called when the upload request finishes (success or failure) {}.
    public func upload(
        _ upload: any UploadTask,
        didCompleteTask task: AWSS3TransferUtilityUploadTask,
        with error: UtilityError?
    ) {}

    /// Called when a new `AWSS3TransferUtilityUploadTask` is created for the request.
    ///
    /// - Parameters:
    ///   - upload: The `UploadTask` instance for which the task was created.
    ///   - task: The `AWSS3TransferUtilityUploadTask` that was created.
    public func upload(_ upload: any UploadTask, didCreateTask task: AWSS3TransferUtilityUploadTask) {}

    /// Called when a task fails with a specific error.
    ///
    /// - Parameters:
    ///   - upload: The `UploadTask` instance associated with the failed task.
    ///   - task: The `AWSS3TransferUtilityUploadTask` that failed.
    ///   - error: The `Error` that caused the failure.
    public func upload(
        _ upload: any UploadTask,
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
    public func upload(_ upload: any UploadTask, didFailToCreateUploadTaskWith error: UtilityError) {}

    /// Called when a task is resumed.
    ///
    /// - Parameters:
    ///   - upload: The `UploadTask` instance whose task was resumed.
    ///   - task: The resumed `AWSS3TransferUtilityUploadTask`.
    public func upload(_ upload: any UploadTask, didResumeTask task: AWSS3TransferUtilityUploadTask) {}

    /// Called when a task is suspended.
    ///
    /// - Parameters:
    ///   - upload: The `UploadTask` instance whose task was suspended.
    ///   - task: The suspended `AWSS3TransferUtilityUploadTask`.
    public func upload(_ upload: any UploadTask, didSuspendTask task: AWSS3TransferUtilityUploadTask) {}

    /// Called when a `AWSS3TransferUtilityUpload` tied to the request is canceled.
    ///
    /// - Parameters:
    ///   - upload: The `StreamUploadTask` associated with the canceled task.
    ///   - task: The `UploadRequest` that was canceled
    ///   - partNumber: The identifier of the subtask in the multipart upload sequence.
    func upload(_ upload: any StreamUploadTask, didCancelTask task: any UploadRequest, for partNumber: Int) {}

    /// Called when the upload request finishes (success or failure).
    ///
    /// - Parameters:
    ///   - request: The `StreamUploadTask` associated with the completed task.
    ///   - task: The `UploadRequest` that completed.
    ///   - partNumber: The identifier of the subtask in the multipart upload sequence.
    ///   - error: The `UtilityError` encountered, if any.
    func upload(
        _ upload: any StreamUploadTask,
        didCompleteTask task: any UploadRequest,
        for partNumber: Int,
        with error: UtilityError?
    ) {}

    /// Called when a new `UploadRequest` is created for the request.
    ///
    /// - Parameters:
    ///   - upload: The `UploadTask` instance for which the task was created.
    ///   - task: The `AWSS3TransferUtilityUploadTask` that was created.
    ///   - partNumber: The identifier of the subtask in the multipart upload sequence.
    func upload(_ upload: any StreamUploadTask, didCreateTask task: any UploadRequest, for partNumber: Int) {}

    /// Called when a task fails with a specific error.
    ///
    /// - Parameters:
    ///   - upload: The `StreamUploadTask` instance associated with the failed task.
    ///   - task: The `AWSS3TransferUtilityUploadTask` that failed.
    ///   - error: The `Error` that caused the failure.
    func upload(_ upload: any StreamUploadTask, didFailTask task: any UploadRequest, with error: UtilityError) {}

    /// Called when a task is resumed.
    ///
    /// - Parameters:
    ///   - upload: The `StreamUploadTask` instance whose task was resumed.
    ///   - task: The resumed `UploadRequest`.
    ///   - partNumber: The identifier of the subtask in the multipart upload sequence.
    func upload(_ upload: any StreamUploadTask, didResumeTask task: any UploadRequest, for partNumber: Int) {}

    /// Called when a task is suspended.
    ///
    /// - Parameters:
    ///   - upload: The `StreamUploadTask` instance whose task was suspended.
    ///   - task: The suspended `UploadRequest`.
    ///   - partNumber: The identifier of the subtask in the multipart upload sequence.
    func upload(_ upload: any StreamUploadTask, didSuspendTask task: any UploadRequest, for partNumber: Int) {}
}
