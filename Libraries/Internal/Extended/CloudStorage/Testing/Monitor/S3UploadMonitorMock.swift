//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AWSS3
import Utilities

@testable import CloudStorage

/// A mock implementation of `S3UploadMonitor` used for unit testing.
///
/// This mock tracks how many times each upload event is invoked and allows
/// custom callbacks to be injected for asserting expected behavior during tests.
/// It is especially useful to verify event handling in components that rely on
/// `S3UploadMonitor` without performing real S3 uploads.
public final class S3UploadMonitorMock: S3UploadMonitor {
    // MARK: - Properties

    /// Closure executed when `uploadDidCancel` is called.
    public var uploadDidCancelCallback: ((S3UploadTask) -> Void)?

    /// Closure executed when `uploadDidFinish` is called.
    public var uploadDidFinishCallback: ((S3UploadTask) -> Void)?

    /// Closure executed when `uploadDidResume` is called.
    public var uploadDidResumeCallback: ((S3UploadTask) -> Void)?

    /// Closure executed when `uploadDidSuspend` is called.
    public var uploadDidSuspendCallback: ((S3UploadTask) -> Void)?

    /// Closure executed when `upload(_:didCancelTask:)` is called.
    public var uploadDidCancelTaskCallback: ((S3UploadTask, AWSS3TransferUtilityUploadTask) -> Void)?

    /// Closure executed when `upload(_:didCompleteTask:with:)` is called.
    public var uploadDidCompleteTaskCallback: ((S3UploadTask, AWSS3TransferUtilityTask, UtilityError?) -> Void)?

    /// Closure executed when `upload(_:didCreateTask:)` is called.
    public var uploadDidCreateTaskCallback: ((S3UploadTask, AWSS3TransferUtilityUploadTask) -> Void)?

    /// Closure executed when `upload(_:didFailTask:with:)` is called.
    public var uploadDidFailTaskCallback: ((S3UploadTask, AWSS3TransferUtilityUploadTask, UtilityError) -> Void)?

    /// Closure executed when `upload(_:didFailToCreateUploadTaskWith:)` is called.
    public var uploadDidFailToCreateUploadTaskCallback: ((S3UploadTask, UtilityError) -> Void)?

    /// Closure executed when `upload(_:didResumeTask:)` is called.
    public var uploadDidResumeTaskCallback: ((S3UploadTask, AWSS3TransferUtilityUploadTask) -> Void)?

    /// Closure executed when `upload(_:didSuspendTask:)` is called.
    public var uploadDidSuspendTaskCallback: ((S3UploadTask, AWSS3TransferUtilityUploadTask) -> Void)?

    /// Number of times `uploadDidCancel` was called.
    public private(set) var uploadDidCancelCallCount = 0

    /// Number of times `upload(_:didCancelTask:)` was called.
    public private(set) var uploadDidCancelTaskCallCount = 0

    /// Number of times `upload(_:didCompleteTask:with:)` was called.
    public private(set) var uploadDidCompleteTaskCallCount = 0

    /// Number of times `upload(_:didCreateTask:)` was called.
    public private(set) var uploadDidCreateTaskCallCount = 0

    /// Number of times `upload(_:didFailTask:with:)` was called.
    public private(set) var uploadDidFailTaskCallCount = 0

    /// Number of times `upload(_:didFailToCreateUploadTaskWith:)` was called.
    public private(set) var uploadDidFailToCreateUploadTaskCallCount = 0

    /// Number of times `upload(_:didResumeTask:)` was called.
    public private(set) var uploadDidResumeTaskCallCount = 0

    /// Number of times `upload(_:didSuspendTask:)` was called.
    public private(set) var uploadDidSuspendTaskCallCount = 0

    /// Number of times `uploadDidFinish` was called.
    public private(set) var uploadDidFinishCallCount = 0

    /// Number of times `uploadDidResume` was called.
    public private(set) var uploadDidResumeCallCount = 0

    /// Number of times `uploadDidSuspend` was called.
    public private(set) var uploadDidSuspendCallCount = 0

    /// Creates a new instance of the `S3UploadMonitor` .
    public init() {}

    // MARK: - S3UploadMonitor

    /// Notifies that the upload process was canceled.
    ///
    /// - Parameter upload: The `S3UploadTask` instance representing the canceled upload.
    public func uploadDidCancel(_ upload: S3UploadTask) {
        uploadDidCancelCallCount += 1
        uploadDidCancelCallback?(upload)
    }

    /// Notifies that the upload process finished successfully.
    ///
    /// - Parameter upload: The `S3UploadTask` instance representing the completed upload.
    public func uploadDidFinish(_ upload: S3UploadTask) {
        uploadDidFinishCallCount += 1
        uploadDidFinishCallback?(upload)
    }

    /// Notifies that the upload process was resumed after being paused.
    ///
    /// - Parameter upload: The `S3UploadTask` instance representing the resumed upload.
    public func uploadDidResume(_ upload: S3UploadTask) {
        uploadDidResumeCallCount += 1
        uploadDidResumeCallback?(upload)
    }

    /// Notifies that the upload process was suspended (paused).
    ///
    /// - Parameter upload: The `S3UploadTask` instance representing the suspended upload.
    public func uploadDidSuspend(_ upload: S3UploadTask) {
        uploadDidSuspendCallCount += 1
        uploadDidSuspendCallback?(upload)
    }

    /// Notifies that an individual AWS S3 upload task was canceled.
    ///
    /// - Parameters:
    ///   - upload: The `S3UploadTask` that owns the AWS task.
    ///   - task: The `AWSS3TransferUtilityUploadTask` that was canceled.
    public func upload(_ upload: S3UploadTask, didCancelTask task: AWSS3TransferUtilityUploadTask) {
        uploadDidCancelTaskCallCount += 1
        uploadDidCancelTaskCallback?(upload, task)
    }

    /// Notifies that an individual AWS S3 upload task completed, with or without error.
    ///
    /// - Parameters:
    ///   - upload: The `S3UploadTask` that owns the AWS task.
    ///   - task: The `AWSS3TransferUtilityUploadTask` that completed.
    ///   - error: An optional `UtilityError` if the task failed, otherwise `nil`.
    public func upload(
        _ upload: S3UploadTask,
        didCompleteTask task: AWSS3TransferUtilityTask,
        with error: UtilityError?
    ) {
        uploadDidCompleteTaskCallCount += 1
        uploadDidCompleteTaskCallback?(upload, task, error)
    }

    /// Notifies that an AWS S3 upload task was successfully created.
    ///
    /// - Parameters:
    ///   - upload: The `S3UploadTask` that owns the AWS task.
    ///   - task: The `AWSS3TransferUtilityUploadTask` that was created.
    public func upload(_ upload: S3UploadTask, didCreateTask task: AWSS3TransferUtilityUploadTask) {
        uploadDidCreateTaskCallCount += 1
        uploadDidCreateTaskCallback?(upload, task)
    }

    /// Notifies that an AWS S3 upload task failed during execution.
    ///
    /// - Parameters:
    ///   - upload: The `S3UploadTask` that owns the AWS task.
    ///   - task: The `AWSS3TransferUtilityUploadTask` that failed.
    ///   - error: The `UtilityError` describing the failure.
    public func upload(
        _ upload: S3UploadTask,
        didFailTask task: AWSS3TransferUtilityUploadTask,
        with error: UtilityError
    ) {
        uploadDidFailTaskCallCount += 1
        uploadDidFailTaskCallback?(upload, task, error)
    }

    /// Notifies that the upload process failed to create an AWS S3 upload task.
    ///
    /// - Parameters:
    ///   - upload: The `S3UploadTask` associated with the failure.
    ///   - error: The `UtilityError` describing why the task could not be created.
    public func upload(_ upload: S3UploadTask, didFailToCreateUploadTaskWith error: UtilityError) {
        uploadDidFailToCreateUploadTaskCallCount += 1
        uploadDidFailToCreateUploadTaskCallback?(upload, error)
    }

    /// Notifies that an AWS S3 upload task was resumed after being paused.
    ///
    /// - Parameters:
    ///   - upload: The `S3UploadTask` that owns the AWS task.
    ///   - task: The `AWSS3TransferUtilityUploadTask` that was resumed.
    public func upload(_ upload: S3UploadTask, didResumeTask task: AWSS3TransferUtilityUploadTask) {
        uploadDidResumeTaskCallCount += 1
        uploadDidResumeTaskCallback?(upload, task)
    }

    /// Notifies that an AWS S3 upload task was suspended (paused).
    ///
    /// - Parameters:
    ///   - upload: The `S3UploadTask` that owns the AWS task.
    ///   - task: The `AWSS3TransferUtilityUploadTask` that was suspended.
    public func upload(_ upload: S3UploadTask, didSuspendTask task: AWSS3TransferUtilityUploadTask) {
        uploadDidSuspendTaskCallCount += 1
        uploadDidSuspendTaskCallback?(upload, task)
    }
}
