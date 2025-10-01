//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Utilities

/// Represents an asynchronous upload operation that can be monitored and controlled.
///
/// `UploadDataTask` extends the behavior of `UploadTask` by providing hooks for
/// observing **completion** and **progress** updates. This allows clients to react to
/// the outcome of an upload (success or failure), and to receive fine-grained updates
/// on its progress while it is running.
public protocol UploadDataTask: UploadTask {
    /// Registers a completion handler to be called when the upload finishes.
    ///
    /// - Parameter completion: Closure that receives a `Result` containing either:
    ///   - `.success(URL)` – The remote URL where the data was uploaded.
    ///   - `.failure(UtilityError)` – The error that caused the upload to fail.
    ///
    /// - Returns: The current task instance, enabling fluent method chaining.
    @discardableResult
    func onComplete(_ completion: @escaping (Result<URL, UtilityError>) -> Void) -> Self

    /// Registers a progress handler to be called as the upload progresses.
    ///
    /// - Parameter progress: Closure that receives a `Progress` object containing:
    ///   - `completedUnitCount` – The number of bytes uploaded so far.
    ///   - `totalUnitCount` – The total number of bytes to upload.
    ///   - `fractionCompleted` – A normalized `Double` between `0.0` and `1.0`.
    ///
    /// - Returns: The current task instance, enabling fluent method chaining.
    @discardableResult
    func onProgress(_ progress: @escaping (Progress) -> Void) -> Self
}
