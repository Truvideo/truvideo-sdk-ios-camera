//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Utilities

@testable import CloudStorageKit

public final class UploadDataTaskMock: UploadDataTask {
    // MARK: - Properties

    /// Number of times `cancel()` was invoked.
    public private(set) var cancelCallCount = 0

    /// Number of times `onComplete(_:)` was invoked.
    public private(set) var onCompleteCallCount = 0

    /// Number of times `onProgress(_:)` was invoked.
    public private(set) var onProgressCallCount = 0

    /// The stored completion handler provided via `onComplete(_:)`.
    public private(set) var onCompleteHandler: ((Result<URL, Utilities.UtilityError>) -> Void)?

    /// The stored progress handler provided via `onProgress(_:)`.
    public private(set) var onProgressHandler: ((Progress) -> Void)?

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

    // MARK: - UploadDataTask

    /// Registers a completion handler to be executed when the upload finishes.
    ///
    /// - Parameter completion: A closure invoked with the upload result.
    public func onComplete(_ completion: @escaping (Result<URL, UtilityError>) -> Void) -> Self {
        onCompleteCallCount += 1
        self.onCompleteHandler = completion

        return self
    }

    /// Registers a progress handler to be executed during upload progress updates.
    ///
    /// - Parameter progress: A closure invoked with a `Progress` instance.
    public func onProgress(_ progress: @escaping (Progress) -> Void) -> Self {
        onProgressCallCount += 1
        self.onProgressHandler = progress

        return self
    }

    /// Executes the stored completion handler with the provided result.
    ///
    /// - Parameter result: The simulated result of the upload operation.
    public func complete(with result: Result<URL, UtilityError>) {
        onCompleteHandler?(result)
    }

    /// Executes the stored progress handler with the provided progress.
    ///
    /// - Parameter progress: The simulated `Progress` object.
    public func progress(_ progress: Progress) {
        onProgressHandler?(progress)
    }
}
