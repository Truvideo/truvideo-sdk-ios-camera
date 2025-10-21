//
// Copyright © 2025 TruVideo. All rights reserved.
//

internal import AWSS3
import Utilities

/// Represents the possible states of an upload task during its lifecycle.
///
/// This enum defines the complete state machine for upload operations, providing
/// a clear and predictable way to track the progress and control upload tasks.
/// Each state represents a specific phase in the upload lifecycle, from initialization
/// to completion or cancellation.
///
/// ## State Lifecycle
///
/// ```
/// initialized → resumed → suspended → resumed → finished
///      ↓           ↓         ↓         ↓
///   cancelled   cancelled  cancelled  cancelled
/// ```
///
/// ## State Descriptions
///
/// - **initialized**: The upload task has been created but not yet started
/// - **resumed**: The upload is actively running and transferring data
/// - **suspended**: The upload is paused and can be resumed later
/// - **finished**: The upload completed successfully
/// - **cancelled**: The upload was cancelled and cannot be resumed
///
/// ## Usage Example
///
/// ```swift
/// let uploadTask = cloudStorage.upload(data, fileName: "file.jpg", contentType: .jpeg)
///
/// // Monitor state changes
/// switch uploadTask.state {
/// case .initialized:
///     print("Upload task created, ready to start")
/// case .resumed:
///     print("Upload in progress...")
/// case .suspended:
///     print("Upload paused, can be resumed")
/// case .finished:
///     print("Upload completed successfully")
/// case .cancelled:
///     print("Upload was cancelled")
/// }
///
/// // Check if state transition is allowed
/// if uploadTask.state.canTransition(to: .suspended) {
///     uploadTask.pause()  // Safe to pause
/// }
/// ```
///
/// ## State Transition Rules
///
/// | Current State | Allowed Transitions | Description |
/// |---------------|-------------------|-------------|
/// | `initialized` | `resumed`, `cancelled`, `finished` | Can start, cancel, or complete immediately |
/// | `resumed` | `suspended`, `cancelled`, `finished` | Can pause, cancel, or complete |
/// | `suspended` | `resumed`, `cancelled` | Can resume or cancel |
/// | `finished` | None | Terminal state, no further transitions |
/// | `cancelled` | None | Terminal state, no further transitions |
///
/// ## Thread Safety
///
/// State transitions are thread-safe and can be checked from any thread.
/// However, actual state changes should be performed through the `UploadTask`
/// methods to ensure proper synchronization.
///
/// ## Error Handling
///
/// Use `canTransition(to:)` to validate state changes before attempting them:
///
/// ```swift
/// let uploadTask = cloudStorage.upload(data, fileName: "file.jpg", contentType: .jpeg)
///
/// // Safe state transition
/// if uploadTask.state.canTransition(to: .suspended) {
///     uploadTask.pause()
/// } else {
///     print("Cannot pause upload in current state: \(uploadTask.state)")
/// }
/// ```
public enum UploadTaskState: Sendable {
    /// The upload task has been explicitly cancelled and cannot proceed further.
    ///
    /// This is a terminal state that indicates the upload operation has been
    /// permanently stopped. Once cancelled, the upload cannot be resumed or
    /// restarted. Any partial data that may have been uploaded is typically
    /// cleaned up by the underlying storage service.
    ///
    /// ## Transition Rules
    /// - **From**: Any state
    /// - **To**: None (terminal state)
    /// - **Can Resume**: No
    /// - **Can Cancel**: No (already cancelled)
    case cancelled

    /// The upload task has successfully completed.
    ///
    /// This is a terminal state that indicates the upload operation finished
    /// successfully. All data has been transferred and verified by the storage
    /// service. The uploaded file is now available for access.
    ///
    /// ## Transition Rules
    /// - **From**: Any state
    /// - **To**: None (terminal state)
    /// - **Can Resume**: No
    /// - **Can Cancel**: No (already completed)
    case finished

    /// The upload task is in the process of finishing and completing its operation.
    ///
    /// This state represents the final phase of an upload task where the operation
    /// is being finalized, cleaned up, and prepared for completion. During this state,
    /// the task is transitioning from active processing to a completed state and
    /// should not accept new operations or data.
    ///
    /// ## Transition Rules
    ///
    /// - **From**: `.resumed`, `.suspended`
    /// - **To**: `.finished`, `.cancelled`
    /// - **Can Resume**: No (already in finalization process)
    /// - **Can Cancel**: Yes (can be cancelled during finalization)
    ///
    /// ## Characteristics
    ///
    /// - **Finalization Phase**: The task is performing cleanup and completion operations
    /// - **No New Operations**: The task cannot be resumed or accept new data
    /// - **Resource Cleanup**: System resources are being released and finalized
    /// - **Response Processing**: Final response processing and validation occurs
    /// - **Monitor Notifications**: Completion callbacks are being triggered
    ///
    /// ## Usage Context
    ///
    /// This state is typically reached when:
    /// - The upload operation has completed successfully
    /// - An error occurred and the task is being finalized
    /// - The task is being cancelled and needs cleanup
    /// - Final response processing is underway
    ///
    /// ## Thread Safety
    ///
    /// State transitions to `finishing` should be performed on the appropriate
    /// actor context to ensure thread-safe cleanup operations.
    case finishing

    /// The upload task has been initialized but has not yet started execution.
    ///
    /// This is the initial state of an upload task. The task has been created
    /// and configured but the actual upload process has not begun. The task
    /// is ready to start transferring data when resumed.
    ///
    /// ## Transition Rules
    /// - **From**: None (initial state)
    /// - **To**: `resumed`, `cancelled`, `finished`
    /// - **Can Resume**: Yes (starts the upload)
    /// - **Can Cancel**: Yes
    case initialized

    /// The upload task is actively running and transferring data.
    ///
    /// This state indicates that the upload is in progress and actively
    /// transferring data to the storage service. Progress callbacks will
    /// be invoked during this state to report upload progress.
    ///
    /// ## Transition Rules
    /// - **From**: `initialized`, `suspended`
    /// - **To**: `suspended`, `cancelled`, `finished`
    /// - **Can Resume**: No (already running)
    /// - **Can Cancel**: Yes
    case resumed

    /// The upload task is temporarily paused and can be resumed later.
    ///
    /// This state indicates that the upload has been paused but can be
    /// resumed from where it left off. Partial upload progress is preserved,
    /// and resuming will continue from the last successful transfer point.
    ///
    /// ## Transition Rules
    /// - **From**: `resumed`
    /// - **To**: `resumed`, `cancelled`
    /// - **Can Resume**: Yes (continues from pause point)
    /// - **Can Cancel**: Yes
    case suspended

    // MARK: - Instance methods

    /// Determines whether a transition from the current state to a given state is valid.
    ///
    /// This function implements the state machine logic by evaluating whether
    /// transitioning from the current state to the target state is allowed
    /// according to the predefined transition rules. It ensures that only
    /// legal state transitions occur, preventing invalid operations.
    ///
    /// ## Transition Logic
    ///
    /// The function uses a comprehensive switch statement to handle all
    /// possible state combinations:
    ///
    /// - **From `initialized`**: Can transition to any state (flexible starting point)
    /// - **From `resumed`**: Can pause, cancel, or finish
    /// - **From `suspended`**: Can resume or cancel
    /// - **From `finished`**: No transitions allowed (terminal state)
    /// - **From `cancelled`**: No transitions allowed (terminal state)
    ///
    /// ## Usage Examples
    ///
    /// ```swift
    /// let uploadTask = cloudStorage.upload(data, fileName: "file.jpg", contentType: .jpeg)
    ///
    /// // Check if we can pause the upload
    /// if uploadTask.state.canTransition(to: .suspended) {
    ///     uploadTask.pause()
    /// }
    ///
    /// // Check if we can resume a paused upload
    /// if uploadTask.state.canTransition(to: .resumed) {
    ///     uploadTask.resume()
    /// }
    ///
    /// // Always allow cancellation
    /// if uploadTask.state.canTransition(to: .cancelled) {
    ///     uploadTask.cancel()
    /// }
    /// ```
    ///
    /// ## Error Prevention
    ///
    /// Use this method to prevent invalid state transitions:
    ///
    /// ```swift
    /// func safePauseUpload(_ uploadTask: UploadTask) {
    ///     guard uploadTask.state.canTransition(to: .suspended) else {
    ///         print("Cannot pause upload in state: \(uploadTask.state)")
    ///         return
    ///     }
    ///     uploadTask.pause()
    /// }
    /// ```
    ///
    /// - Parameter state: The target `UploadTaskState` to which a transition is being requested.
    /// - Returns: `true` if the transition is allowed according to the state machine rules, `false` otherwise.
    func canTransition(to state: UploadTaskState) -> Bool {
        switch (self, state) {
        case (.initialized, _),
             (.finishing, .finished),
             (.finishing, .cancelled),
             (.resumed, .cancelled),
             (.resumed, .finishing),
             (.resumed, .suspended),
             (.suspended, .cancelled),
             (.suspended, .finishing),
             (.suspended, .resumed),
             (_, .finished):
            true

        case (_, .initialized),
             (.cancelled, _),
             (.finished, _),
             (.finishing, .finishing),
             (.finishing, .resumed),
             (.finishing, .suspended),
             (.suspended, .suspended),
             (.resumed, .resumed):
            false
        }
    }
}

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
