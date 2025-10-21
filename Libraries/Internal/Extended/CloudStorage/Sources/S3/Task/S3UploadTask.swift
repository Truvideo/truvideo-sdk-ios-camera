//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Utilities

/// A global actor that provides thread-safe isolation for S3 upload operations.
///
/// `S3UploadTaskActor` serves as a concurrency boundary for all S3 upload
/// related operations, ensuring thread-safe access to shared state and preventing
/// data races during concurrent upload operations. It provides a centralized point
/// of coordination for multiple upload tasks that may be running simultaneously.
@globalActor
actor S3UploadTaskActor {
    /// The shared global actor instance used to isolate S3 upload operations.
    static let shared = S3UploadTaskActor()
}

/// A protocol that defines the contract for handling S3 upload task completion events.
///
/// `S3UploadTaskDelegate` provides a mechanism for objects to be notified when an S3 upload
/// task completes, enabling cleanup operations, retry logic, and other post-completion
/// processing. This delegate pattern allows for loose coupling between upload tasks and
/// their management systems.
///
/// ## Purpose
///
/// The delegate pattern is used to notify interested parties when an upload task reaches
/// its final state (either completed successfully or failed). This enables:
/// - Resource cleanup and management
/// - Retry logic implementation
/// - Task lifecycle tracking
/// - Integration with higher-level upload management systems
///
/// ## Thread Safety
///
/// This protocol conforms to `Sendable` to ensure that delegate methods can be safely
/// called from any thread context, including actor-isolated contexts.
///
/// ## Usage Example
///
/// ```swift
/// class UploadManager: S3UploadTaskDelegate {
///     private var activeTasks: Set<S3UploadTask> = []
///
///     func startUpload(payload: S3DataPayload) {
///         let task = S3UploadDataTask(
///             payload: payload,
///             delegate: self,
///             monitor: nil
///         )
///         activeTasks.insert(task)
///     }
///
///     func taskDidComplete(_ task: S3UploadTask) {
///         // Clean up completed task
///         activeTasks.remove(task)
///
///         // Handle completion logic
///         if let error = task.error {
///             handleUploadFailure(task, error: error)
///         } else {
///             handleUploadSuccess(task)
///         }
///     }
/// }
/// ```
protocol S3UploadTaskDelegate: AnyObject, Sendable {
    /// Notifies the delegate that an upload task has completed.
    ///
    /// This method is called when an upload task reaches its final state, regardless of
    /// whether it completed successfully or failed. The delegate can use this opportunity
    /// to perform cleanup operations, update internal state, or trigger retry logic.
    ///
    /// - Parameter task: The `S3UploadTask` that has completed. Check the task's `error`
    ///                   property to determine if the upload succeeded or failed.
    func taskDidComplete(_ task: S3UploadTask)
}

/// A base class for managing S3 upload operations with comprehensive state management and monitoring.
///
/// `S3UploadTask` serves as the foundation for all S3 upload operations, providing core functionality
/// for state management, lifecycle control, and monitoring capabilities. This class implements the
/// `Identifiable` protocol and provides a robust framework for tracking upload progress, handling
/// errors, and managing completion callbacks.
///
/// ## Key Features
///
/// - **State Management**: Comprehensive state tracking with thread-safe transitions
/// - **Lifecycle Control**: Built-in support for pause, resume, and cancel operations
/// - **Error Handling**: Robust error management with detailed error information
/// - **Monitoring**: Optional monitoring support for observing upload events
/// - **Completion Handling**: Flexible completion callback system
/// - **Thread Safety**: Actor-based concurrency model for safe multi-threaded operations
///
/// ## Upload Lifecycle
///
/// The upload process follows these stages:
/// 1. **Initialization**: Task is created with unique identifier and configuration
/// 2. **Execution**: Upload begins and progresses through various states
/// 3. **State Transitions**: Task moves through states based on operations and external factors
/// 4. **Completion**: Final result (success or failure) is processed and callbacks are invoked
/// 5. **Cleanup**: Resources are cleaned up and final state is set
///
/// ## State Management
///
/// The task maintains its state throughout the upload lifecycle:
/// - `.initialized`: Task created but not yet started
/// - `.resumed`: Upload is actively in progress
/// - `.suspended`: Upload is paused and can be resumed
/// - `.finishing`: Upload completed, processing final callbacks
/// - `.finished`: Upload fully completed and cleaned up
/// - `.cancelled`: Upload was cancelled and cannot be resumed
///
/// ## Thread Safety
///
/// This class uses Swift's actor model with `S3UploadTaskActor` to ensure thread-safe
/// access to internal state. All state modifications and completion processing are properly
/// isolated to prevent data races during concurrent operations.
///
/// ## Usage Context
///
/// This class is typically used as a base class for specific upload implementations such as:
/// - `S3UploadDataTask` for uploading binary data
/// - `S3StreamUploadTask` for streaming uploads
/// - Custom upload task implementations
///
/// ## Example Usage
///
/// ```swift
/// // Create upload task (typically done by concrete implementations)
/// let uploadTask = S3UploadDataTask(
///     payload: payload,
///     delegate: self,
///     monitor: monitor
/// )
///
/// // Monitor state changes
/// if uploadTask.state == .resumed {
///     print("Upload in progress...")
/// }
///
/// // Check for errors
/// if let error = uploadTask.error {
///     print("Upload failed: \(error)")
/// }
///
/// // Access response when available
/// if let response = uploadTask.response {
///     print("Upload completed with status: \(response.statusCode)")
/// }
/// ```
public class S3UploadTask: Identifiable {
    // MARK: - Private Properties

    private var hasProcessedCompletions = false

    // MARK: - Properties

    /// The delegate responsible for handling task completion events and cleanup operations.
    ///
    /// This delegate is notified when the upload task completes, enabling the delegate
    /// to perform cleanup operations, retry logic, or other post-completion processing.
    /// The delegate is held as a weak reference to prevent retain cycles.
    private(set) weak var delegate: S3UploadTaskDelegate?

    /// An optional monitor for observing and logging upload task events throughout the lifecycle.
    ///
    /// The monitor provides hooks for tracking upload progress, state changes, and completion
    /// events. This is particularly useful for debugging, analytics, and monitoring upload
    /// performance across the application.
    let monitor: S3TaskMonitor?

    /// An array of completion handlers that will be invoked when the upload task finishes.
    ///
    /// These closures are called during the finalization process to handle upload completion.
    /// Multiple completion handlers can be registered, and all will be executed when the
    /// task reaches its final state. The handlers are automatically cleared after execution.
    var completions: [() -> Void] = []

    // MARK: - Public Properties

    /// A unique identifier for the upload task.
    ///
    /// This identifier is used to distinguish between different upload tasks and is
    /// typically generated as a UUID if not explicitly provided during initialization.
    /// The identifier is used for task tracking, debugging, and hash-based operations.
    public let id: String

    /// The error associated with the upload task, if any.
    ///
    /// This property contains detailed error information if the upload operation failed
    /// or was cancelled. The error provides information about the failure reason and
    /// can be used for error handling, retry logic, and user notification.
    public internal(set) var error: UtilityError?

    /// The HTTP response received from the S3 service upon completion.
    ///
    /// This property contains the full HTTP response from the S3 service, including
    /// status codes, headers, and other metadata. It is only available after the
    /// upload operation completes, whether successfully or with an error.
    public internal(set) var response: HTTPURLResponse?

    /// The current state of the upload task.
    ///
    /// This property reflects the current status of the upload operation and
    /// can be used to determine what actions are available or appropriate
    /// at any given time. The state may change as a result of calling control
    /// methods or due to external factors like network conditions.
    ///
    /// This property should be thread-safe and provide consistent values
    /// across multiple threads accessing the same upload task.
    public internal(set) var state = UploadTaskState.initialized

    // MARK: - Initializer

    /// Creates a new S3 upload task instance with the specified configuration.
    ///
    /// This initializer sets up a new upload task with a unique identifier, optional delegate,
    /// and optional monitoring configuration. The task is initialized in the `.initialized` state
    /// and is ready to begin upload operations once the underlying AWS Transfer Utility task
    /// is created and started.
    ///
    /// The initializer establishes the basic structure for the upload task, including state
    /// management, completion handling, and monitoring capabilities. Subclasses should call
    /// this initializer to ensure proper setup of the base functionality.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the upload task. If not provided, a new UUID will be generated.
    ///         This identifier is used for task tracking, debugging, and hash-based operations.
    ///   - delegate: An optional delegate that will be notified when the task completes. Used for
    ///              cleanup operations, retry logic, and task lifecycle management.
    ///   - monitor: An optional `S3TaskMonitor` for observing and logging upload task events
    ///             throughout the lifecycle. Useful for debugging, analytics, and monitoring.
    init(id: String = UUID().uuidString, delegate: S3UploadTaskDelegate?, monitor: S3TaskMonitor?) {
        self.id = id
        self.delegate = delegate
        self.monitor = monitor
    }

    // MARK: - LifeCycle methods

    /// Handles the cancellation of the upload task and notifies the monitor.
    ///
    /// This method is called when the upload task is cancelled, either explicitly by the user
    /// or due to external factors. It ensures the task is properly marked as cancelled by
    /// setting the appropriate error if one hasn't already been assigned, and notifies
    /// the monitor of the cancellation event.
    ///
    /// The method runs on the `S3UploadTaskActor` to ensure thread-safe state management
    /// and proper coordination with other lifecycle methods.
    @S3UploadTaskActor
    func didCancel() {
        error =
            error
                ?? UtilityError(
                    kind: .CloudStorageErrorReason.explicitlyCancelled,
                    failureReason: "Request Explicitly Cancelled"
                )

        monitor?.taskDidCancel(self)
    }

    /// Handles when the upload task is resumed and notifies the monitor.
    ///
    /// This method is called when the upload task transitions from a suspended state
    /// back to an active state. It notifies the monitor that the task has resumed
    /// execution, enabling proper tracking of upload lifecycle events.
    ///
    /// The method is thread-safe and can be called from any context to ensure
    /// consistent monitoring behavior across different thread contexts.
    func didResume() {
        monitor?.taskDidResume(self)
    }

    /// Handles when the upload task is suspended and notifies the monitor.
    ///
    /// This method is called when the upload task transitions from an active state
    /// to a suspended state. It notifies the monitor that the task has been paused,
    /// enabling proper tracking of upload lifecycle events and state changes.
    ///
    /// The method is thread-safe and can be called from any context to ensure
    /// consistent monitoring behavior across different thread contexts.
    func didSuspend() {
        monitor?.taskDidSuspend(self)
    }

    /// Finalizes the upload task and processes completion handlers.
    ///
    /// This method handles the final phase of the upload task lifecycle, transitioning
    /// the task to the `.finishing` state and processing all completion handlers.
    /// It ensures proper cleanup, notifies the monitor of the finishing state,
    /// and coordinates the final state transition to `.finished`.
    ///
    /// The method runs on the `S3UploadTaskActor` to ensure thread-safe completion
    /// processing and proper coordination with other lifecycle methods.
    ///
    /// - Parameter error: An optional `UtilityError` encountered during the upload operation.
    ///                   If provided, this error will be stored and made available through
    ///                   the task's `error` property.
    @S3UploadTaskActor
    func finish(error: UtilityError? = nil) {
        if state.canTransition(to: .finishing) {
            state = .finishing

            monitor?.taskIsFinishing(self)

            if let error {
                self.error = error
            }

            processCompletions()
            monitor?.taskDidFinish(self)
        }
    }

    // MARK: - Private methods

    /// Processes all registered completion handlers and performs final cleanup.
    ///
    /// This private method handles the execution of all completion handlers that have been
    /// registered with the upload task. It ensures that each handler is called exactly once,
    /// clears the handlers array to prevent duplicate execution, notifies the delegate
    /// of task completion, and transitions the task to the final `.finished` state.
    ///
    /// The method includes protection against multiple executions using the
    /// `hasProcessedCompletions` flag to ensure idempotent behavior.
    private func processCompletions() {
        let completions = completions

        hasProcessedCompletions = true
        completions.forEach { $0() }

        self.completions.removeAll()
        delegate?.taskDidComplete(self)

        if state.canTransition(to: .finished) {
            state = .finished
        }
    }
}

extension S3UploadTask: Hashable {
    // MARK: - Hashable

    /// Returns a Boolean value indicating whether two upload tasks are equal.
    ///
    /// Two upload tasks are considered equal if they have the same unique identifier.
    /// This equality check is used for task comparison, set operations, and hash-based
    /// collections where upload tasks are stored.
    ///
    /// - Parameters:
    ///   - lhs: The first upload task to compare.
    ///   - rhs: The second upload task to compare.
    /// - Returns: `true` if both tasks have the same identifier, `false` otherwise.
    public static func == (lhs: S3UploadTask, rhs: S3UploadTask) -> Bool {
        lhs.id == rhs.id
    }

    /// Hashes the essential components of this upload task by feeding them into the given hasher.
    ///
    /// This method enables the upload task to be used as a key in hash-based collections
    /// such as `Set` and `Dictionary`. The hash is based solely on the task's unique
    /// identifier, ensuring consistent hashing behavior across different task instances.
    ///
    /// - Parameter hasher: The hasher to use when combining the components of this instance.
    public func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}
