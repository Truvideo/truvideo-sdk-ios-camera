//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AWSS3
import Foundation
import Utilities

@testable import CloudStorageKit

/// A mock implementation of `AWSS3TransferUtilityUploadTask` used for unit testing.
///
/// This class captures calls to `resume()`, `suspend()`, and `cancel()`,
/// so that tests can verify the correct behavior of `didCreate` and task state transitions.
public final class AWSS3TransferUtilityUploadTaskMock: AWSS3TransferUtilityUploadTask {
    // MARK: - Properties

    /// Number of times `cancel()` was invoked.
    public private(set) var didCancelCallCount = 0

    /// Number of times `resume()` was invoked.
    public private(set) var didResumeCallCount = 0

    /// Number of times `pause()` was invoked.
    public private(set) var didSuspendCallCount = 0

    // MARK: - Overrides

    /// Overrides `resume()` to increment `didResumeCallCount`.
    override public func cancel() {
        didCancelCallCount += 1
    }

    /// Overrides `resume()` to increment `didResumeCallCount`.
    override public func resume() {
        didResumeCallCount += 1
    }

    /// Overrides `suspend()` to increment `didSuspendCallCount`.
    override public func suspend() {
        didSuspendCallCount += 1
    }
}
