//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

extension Task where Failure == Never {
    /// Executes an asynchronous operation after a specified delay in milliseconds.
    ///
    /// This function creates a new task that waits for the specified duration before executing
    /// the provided async operation. The delay is implemented using `Task.sleep` and the operation
    /// is executed in a new task context to avoid blocking the current execution.
    ///
    /// - Parameters:
    ///   - duration: The delay duration in milliseconds before executing the operation.
    ///   - operation: The async operation to execute after the delay.
    @discardableResult
    public static func delayed(
        milliseconds duration: TimeInterval,
        @_implicitSelfCapture operation: @escaping @isolated(any) () async -> Success
    ) -> Task<Success, Never> {
        Task {
            try? await Task<Never, Never>.sleep(nanoseconds: UInt64(duration) * 1_000_000)
            return await operation()
        }
    }
}
