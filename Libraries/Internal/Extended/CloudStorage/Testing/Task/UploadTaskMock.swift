//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Utilities

@testable import CloudStorageKit

/// A mock implementation of `UploadTask` used for unit testing.
public final class UploadTaskMock: UploadTask {
    // MARK: - Properties

    /// Number of times `cancel()` was invoked.
    public private(set) var cancelCallCount = 0

    /// Number of times `pause()` was invoked.
    public private(set) var pauseCallCount = 0

    /// Number of times `resume()` was invoked.
    public private(set) var resumeCallCount = 0

    /// The current state of the upload task.
    public private(set) var state: UploadTaskState = .initialized

    // MARK: - Initializer

    public init() {}

    // MARK: - UploadTask

    /// Simulates cancelling the upload task.
    ///
    /// - Returns: The current `UploadTaskMock` for chaining.
    public func cancel() -> Self {
        cancelCallCount += 1
        state = .cancelled

        return self
    }

    /// Simulates pausing the upload task.
    ///
    /// - Returns: The current `UploadTaskMock` for chaining.
    public func pause() -> Self {
        pauseCallCount += 1
        state = .suspended

        return self
    }

    /// Simulates resuming the upload task.
    ///
    /// - Returns: The current `UploadTaskMock` for chaining.
    public func resume() -> Self {
        resumeCallCount += 1
        state = .resumed

        return self
    }
}
