//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AWSS3
import Utilities

@testable import CloudStorageKit

/// A mock implementation of the `S3UploadTaskDelegate` protocol,
/// used for testing purposes. Tracks the number of times a task completes
/// and stores a reference to the last completed task.
public final class S3UploadTaskDelegateMock: S3UploadTaskDelegate {
    // MARK: - Properties

    /// The number of times `taskDidComplete(_:)` has been called.
    public private(set) var taskDidCompleteCallCount = 0

    /// The last `S3UploadTask` instance that completed.
    public private(set) var task: S3UploadTask?

    // MARK: - Initializer

    public init() {}

    // MARK: - S3UploadTaskDelegate

    /// Called when an S3 upload task completes.
    ///
    /// - Parameter task: The `S3UploadTask` that has completed.
    public func taskDidComplete(_ task: S3UploadTask) {
        taskDidCompleteCallCount += 1
        self.task = task
    }
}
