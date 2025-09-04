//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AWSS3
import Utilities

/// A protocol that defines the contract for managing upload operations with state control.
///
/// `UploadTask` provides a standardized interface for controlling upload operations,
/// allowing clients to monitor the upload state and control the upload lifecycle through
/// pause, resume, and cancel operations. This protocol enables fine-grained control
/// over upload processes while maintaining a consistent API across different upload
/// implementations.
///
/// ## Purpose
///
/// Upload tasks often need to be managed dynamically based on user interactions,
/// network conditions, or application state changes. This protocol provides the
/// necessary methods to control upload operations without needing to know the
/// underlying implementation details.
///
/// ## State Management
///
/// The upload task can be in various states that reflect the current status of
/// the upload operation. State changes are typically triggered by calling the
/// control methods or by external factors like network interruptions.
///
/// ## Control Flow
///
/// Upload tasks follow a typical lifecycle:
/// 1. **Initial State**: Task is created and ready to start
/// 2. **Active State**: Upload is in progress
/// 3. **Paused State**: Upload is temporarily suspended
/// 4. **Completed State**: Upload finished successfully
/// 5. **Cancelled State**: Upload was cancelled
/// 6. **Error State**: Upload failed with an error
///
/// ## Example Usage
///
/// ```swift
/// // Create and start an upload task
/// let uploadTask = uploadManager.createUploadTask(for: data, key: "file.txt")
///
/// // Monitor upload state
/// if uploadTask.state == .uploading {
///     print("Upload in progress...")
/// }
///
/// // Control upload lifecycle
/// uploadTask.pause()  // Pause upload
/// uploadTask.resume() // Resume upload
/// uploadTask.cancel() // Cancel upload
///
/// // Chain operations
/// uploadTask
///     .pause()
///     .resume()
///     .cancel()
/// ```
///
/// ## Thread Safety
///
/// Implementations should be thread-safe and handle concurrent calls to control
/// methods appropriately. State changes should be atomic and consistent across
/// multiple threads.
public protocol UploadTask {
    /// The current state of the upload task.
    ///
    /// This property reflects the current status of the upload operation and
    /// can be used to determine what actions are available or appropriate
    /// at any given time. The state may change as a result of calling control
    /// methods or due to external factors like network conditions.
    ///
    /// This property should be thread-safe and provide consistent values
    /// across multiple threads accessing the same upload task.
    var state: UploadTaskState { get }

    /// Cancels the upload operation and returns the task instance.
    ///
    /// This method stops the upload operation immediately and transitions the
    /// task to the cancelled state. Once cancelled, the upload cannot be
    /// resumed and any partial upload data may be discarded.
    ///
    /// - Returns: The upload task instance for method chaining
    @discardableResult
    func cancel() -> Self

    /// Pauses the upload operation and returns the task instance.
    ///
    /// This method temporarily suspends the upload operation, allowing it to
    /// be resumed later. The upload state transitions to paused, and network
    /// activity is suspended while maintaining the current upload progress.
    ///
    /// - Returns: The upload task instance for method chaining
    @discardableResult
    func pause() -> Self

    /// Resumes a paused upload operation and returns the task instance.
    ///
    /// This method restarts a previously paused upload operation, continuing
    /// from where it was paused. The upload state transitions back to uploading,
    /// and network activity resumes.
    ///
    /// - Returns: The upload task instance for method chaining
    @discardableResult
    func resume() -> Self
}
