//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Utilities

@testable import CloudStorageKit

/// A mock implementation of `StreamUploadTask` used for unit testing.
///
/// This mock tracks how many times each method is invoked and allows
/// inspection of state changes and injected callbacks. It is useful
/// for verifying the behavior of components that interact with
/// `StreamUploadTask` without performing real uploads.
public final class StreamUploadTaskMock: StreamUploadTask {
    // MARK: - Properties

    /// Number of times `cancel()` was invoked.
    public private(set) var cancelCallCount = 0

    /// Number of times `finalize()` was invoked.
    public private(set) var finalizeCallCount = 0

    /// Number of times `onComplete(_:)` was invoked.
    public private(set) var onCompleteCallCount = 0

    /// The stored completion handler provided via `onComplete(_:)`.
    public private(set) var onCompleteHandler: ((Result<StreamUploadResponse, UtilityError>) -> Void)?

    /// Number of times `pause()` was invoked.
    public private(set) var pauseCallCount = 0

    /// Number of times `resume()` was invoked.
    public private(set) var resumeCallCount = 0

    /// Number of times `upload()` was invoked.
    public private(set) var uploadCallCount = 0

    /// Number of times `upload(_:)` was invoked.
    public private(set) var uploadCallBack: ((Data, URL) -> Void)?

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

    // MARK: - StreamUploadTask

    /// Simulates finalizing the upload task.
    ///
    /// - Returns: The current `StreamUploadTaskMock` for chaining.
    public func finalize() -> Self {
        finalizeCallCount += 1
        state = .finished

        return self
    }

    /// Registers a completion handler to be invoked when the upload finishes.
    ///
    /// - Parameter completion: The closure to be executed when the task completes.
    /// - Returns: The current `StreamUploadTaskMock` for chaining.
    public func onComplete(_ completion: @escaping (Result<StreamUploadResponse, UtilityError>) -> Void) -> Self {
        onCompleteCallCount += 1
        self.onCompleteHandler = completion

        return self
    }

    /// Simulates uploading data to a given URL.
    ///
    /// - Parameters:
    ///   - data: The `Data` to be uploaded.
    ///   - url: The destination `URL` of the upload.
    /// - Returns: The current `StreamUploadTaskMock` for chaining.
    public func upload(_ data: Data, to url: URL) -> Self {
        uploadCallCount += 1
        uploadCallBack?(data, url)

        return self
    }

    /// Executes the stored completion handler with the provided result.
    ///
    /// - Parameter result: The simulated result of the upload operation.
    public func complete(with result: Result<StreamUploadResponse, UtilityError>) {
        onCompleteHandler?(result)
    }
}
