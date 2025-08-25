//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

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
///
/// ## Error Handling
///
/// Control methods should handle errors gracefully and maintain consistent state
/// even when operations fail. Failed operations should not leave the task in
/// an inconsistent state.
public protocol UploadTask: Sendable {
    
    /// The current state of the upload task.
    ///
    /// This property reflects the current status of the upload operation and
    /// can be used to determine what actions are available or appropriate
    /// at any given time. The state may change as a result of calling control
    /// methods or due to external factors like network conditions.
    ///
    /// ## State Values
    ///
    /// - **`.ready`**: Task is created and ready to start
    /// - **`.uploading`**: Upload is currently in progress
    /// - **`.paused`**: Upload is temporarily suspended
    /// - **`.completed`**: Upload finished successfully
    /// - **`.cancelled`**: Upload was cancelled
    /// - **`.failed`**: Upload failed with an error
    ///
    /// ## State Transitions
    ///
    /// State changes follow these typical patterns:
    /// - `ready` → `uploading` (when upload starts)
    /// - `uploading` → `paused` (when pause is called)
    /// - `paused` → `uploading` (when resume is called)
    /// - `uploading` → `completed` (when upload succeeds)
    /// - `uploading` → `cancelled` (when cancel is called)
    /// - `uploading` → `failed` (when upload fails)
    ///
    /// ## Thread Safety
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
    /// ## Behavior
    ///
    /// - **Immediate Effect**: Cancellation should take effect immediately
    /// - **State Change**: Task state should transition to `.cancelled`
    /// - **Resource Cleanup**: Any network connections or resources should be released
    /// - **Data Loss**: Partial upload data may be lost and cannot be recovered
    ///
    /// ## Return Value
    ///
    /// Returns `self` to enable method chaining. This allows for fluent
    /// API usage where multiple operations can be chained together.
    ///
    /// ## Thread Safety
    ///
    /// This method should be thread-safe and handle concurrent calls appropriately.
    /// Multiple calls to cancel should be idempotent and not cause errors.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// // Cancel upload
    /// uploadTask.cancel()
    ///
    /// // Chain with other operations
    /// uploadTask
    ///     .pause()
    ///     .resume()
    ///     .cancel()
    /// ```
    ///
    /// - Returns: The upload task instance for method chaining
    func cancel() -> Self
    
    /// Pauses the upload operation and returns the task instance.
    ///
    /// This method temporarily suspends the upload operation, allowing it to
    /// be resumed later. The upload state transitions to paused, and network
    /// activity is suspended while maintaining the current upload progress.
    ///
    /// ## Behavior
    ///
    /// - **Suspension**: Upload activity is suspended but not terminated
    /// - **State Change**: Task state should transition to `.paused`
    /// - **Progress Preservation**: Current upload progress should be maintained
    /// - **Resource Management**: Network connections may be kept alive for resumption
    ///
    /// ## Resumption
    ///
    /// A paused upload can be resumed by calling the `resume()` method. The
    /// upload should continue from where it was paused without losing progress.
    ///
    /// ## Return Value
    ///
    /// Returns `self` to enable method chaining. This allows for fluent
    /// API usage where multiple operations can be chained together.
    ///
    /// ## Thread Safety
    ///
    /// This method should be thread-safe and handle concurrent calls appropriately.
    /// Multiple calls to pause should be idempotent and not cause errors.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// // Pause upload
    /// uploadTask.pause()
    ///
    /// // Chain with other operations
    /// uploadTask
    ///     .pause()
    ///     .resume()
    ///     .cancel()
    /// ```
    ///
    /// - Returns: The upload task instance for method chaining
    func pause() -> Self
    
    /// Resumes a paused upload operation and returns the task instance.
    ///
    /// This method restarts a previously paused upload operation, continuing
    /// from where it was paused. The upload state transitions back to uploading,
    /// and network activity resumes.
    ///
    /// ## Behavior
    ///
    /// - **Resumption**: Upload activity resumes from the paused state
    /// - **State Change**: Task state should transition to `.uploading`
    /// - **Progress Continuation**: Upload should continue from the previous progress
    /// - **Network Reconnection**: Network connections should be re-established if needed
    ///
    /// ## Prerequisites
    ///
    /// The upload task must be in the `.paused` state for resumption to be
    /// effective. Attempting to resume a task that is not paused may have
    /// no effect or may cause an error.
    ///
    /// ## Return Value
    ///
    /// Returns `self` to enable method chaining. This allows for fluent
    /// API usage where multiple operations can be chained together.
    ///
    /// ## Thread Safety
    ///
    /// This method should be thread-safe and handle concurrent calls appropriately.
    /// Multiple calls to resume should be idempotent and not cause errors.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// // Resume paused upload
    /// uploadTask.resume()
    ///
    /// // Chain with other operations
    /// uploadTask
    ///     .pause()
    ///     .resume()
    ///     .cancel()
    /// ```
    ///
    /// - Returns: The upload task instance for method chaining
    func resume() -> Self
    
    /// Sets a progress callback for monitoring upload progress and returns the task instance.
    ///
    /// This method allows you to monitor the upload progress in real-time by providing
    /// a callback that will be invoked whenever the upload progress changes. The progress
    /// callback provides detailed information about the current upload status, including
    /// bytes uploaded, total bytes, and completion percentage.
    ///
    /// ## Progress Information
    ///
    /// The progress callback receives a `Progress` object containing:
    /// - **`completedUnitCount`**: Number of bytes uploaded so far
    /// - **`totalUnitCount`**: Total number of bytes to upload
    /// - **`fractionCompleted`**: Progress as a value between 0.0 and 1.0
    /// - **`localizedDescription`**: Human-readable progress description
    /// - **`localizedAdditionalDescription`**: Additional progress details
    ///
    /// ## Callback Invocation
    ///
    /// The progress callback is invoked:
    /// - **During upload**: As data is being uploaded to the server
    /// - **On state changes**: When upload state transitions occur
    /// - **On completion**: When upload finishes (success or failure)
    /// - **On cancellation**: When upload is cancelled
    ///
    /// ## Thread Safety
    ///
    /// The progress callback may be invoked on background threads. If you need to
    /// update UI elements, ensure you dispatch to the main thread within the callback.
    ///
    /// ## Memory Management
    ///
    /// The progress callback is retained by the upload task for the duration of the
    /// upload operation. The callback will be automatically released when the upload
    /// completes, is cancelled, or fails.
    ///
    /// ## Multiple Progress Handlers
    ///
    /// Calling this method multiple times will replace the previous progress handler.
    /// Only the most recently set progress handler will receive progress updates.
    ///
    /// ## Return Value
    ///
    /// Returns `self` to enable method chaining. This allows for fluent
    /// API usage where multiple operations can be chained together.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// // Set progress handler
    /// uploadTask.uploadProgress { progress in
    ///     let percentage = Int(progress.fractionCompleted * 100)
    ///     print("Upload progress: \(percentage)%")
    ///     print("Bytes uploaded: \(progress.completedUnitCount)")
    ///     print("Total bytes: \(progress.totalUnitCount)")
    /// }
    ///
    /// // Chain with other operations
    /// uploadTask
    ///     .uploadProgress { progress in
    ///         updateProgressBar(progress.fractionCompleted)
    ///     }
    ///     .pause()
    ///     .resume()
    /// ```
    ///
    /// ## UI Integration Example
    ///
    /// ```swift
    /// uploadTask.uploadProgress { progress in
    ///     DispatchQueue.main.async {
    ///         self.progressView.progress = Float(progress.fractionCompleted)
    ///         self.progressLabel.text = "\(Int(progress.fractionCompleted * 100))%"
    ///         self.bytesLabel.text = "\(progress.completedUnitCount) / \(progress.totalUnitCount) bytes"
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter progress: A closure that receives progress updates during the upload operation
    /// - Returns: The upload task instance for method chaining
    @discardableResult
    func uploadProgress(_ progress: @escaping (Progress) -> Void) -> Self
}
