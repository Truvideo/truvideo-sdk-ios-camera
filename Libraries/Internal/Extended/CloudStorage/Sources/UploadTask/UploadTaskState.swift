//
// Copyright © 2025 TruVideo. All rights reserved.
//

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
        case (.initialized, .suspended),
            (.initialized, .cancelled),
            (.initialized, .finished):

            return true

        case (.resumed, .cancelled),
            (.suspended, .cancelled),
            (.resumed, .suspended),
            (.suspended, .resumed),
            (_, .finished):

            return true

        case (_, .initialized),
            (.cancelled, _),
            (.finished, _),
            (.suspended, .suspended),
            (.resumed, .resumed):

            return false

        default:
            return false
        }
    }
}
