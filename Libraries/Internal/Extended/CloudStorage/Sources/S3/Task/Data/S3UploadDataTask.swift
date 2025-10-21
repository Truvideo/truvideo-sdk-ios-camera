//
// Copyright © 2025 TruVideo. All rights reserved.
//

internal import AWSS3
import Foundation
import Utilities

/// A global actor that provides thread-safe isolation for S3 upload data operations.
///
/// `S3UploadDataTaskActor` serves as a concurrency boundary for all S3 upload data
/// related operations, ensuring thread-safe access to shared state and preventing
/// data races during concurrent upload operations. It provides a centralized point
/// of coordination for multiple upload data tasks that may be running simultaneously.
@globalActor
actor S3UploadDataTaskActor {
    /// The shared global actor instance used to isolate S3 upload data operations.
    static let shared = S3UploadDataTaskActor()
}

/// A concrete implementation of an upload task for uploading data to Amazon S3.
///
/// `S3UploadDataTask` manages the complete lifecycle of a data upload operation to an S3 bucket,
/// providing comprehensive control over the upload process including starting, pausing, resuming,
/// and cancelling operations. This class extends the base `S3UploadTask` functionality by
/// implementing the `UploadDataTask` protocol, which adds support for monitoring upload progress
/// and handling completion callbacks.
///
/// ## Key Features
///
/// - **Progress Monitoring**: Real-time progress tracking with detailed byte-level information
/// - **Lifecycle Control**: Full control over upload operations (pause, resume, cancel)
/// - **Completion Handling**: Robust error handling and success/failure callbacks
/// - **Thread Safety**: Actor-based concurrency model for safe multi-threaded operations
/// - **AWS Integration**: Direct integration with AWS S3 Transfer Utility
///
/// ## Upload Lifecycle
///
/// The upload process follows these stages:
/// 1. **Initialization**: Task is created with data payload and configuration
/// 2. **Execution**: Upload begins and progresses through the network
/// 3. **Monitoring**: Progress callbacks provide real-time updates
/// 4. **Completion**: Final result (success or failure) is delivered via completion handlers
///
/// ## State Management
///
/// The task maintains its state throughout the upload lifecycle:
/// - `.initialized`: Task created but not yet started
/// - `.resumed`: Upload is actively in progress
/// - `.suspended`: Upload is paused and can be resumed
/// - `.cancelled`: Upload was cancelled and cannot be resumed
/// - `.finishing`: Upload completed, processing final callbacks
/// - `.finished`: Upload fully completed and cleaned up
///
/// ## Thread Safety
///
/// This class uses Swift's actor model with `S3UploadDataTaskActor` to ensure thread-safe
/// access to internal state. All state modifications and AWS SDK interactions are properly
/// isolated to prevent data races during concurrent operations.
///
/// ## Example Usage
///
/// ```swift
/// // Create upload task
/// let payload = S3DataPayload(
///     bucket: "my-bucket",
///     contentType: .videoMp4,
///     data: videoData,
///     path: "uploads/video.mp4"
/// )
/// let uploadTask = S3UploadDataTask(
///     payload: payload,
///     delegate: self,
///     monitor: monitor
/// )
///
/// // Monitor progress
/// uploadTask.onProgress { progress in
///     let percentage = progress.fractionCompleted * 100
///     print("Upload progress: \(percentage)%")
/// }
///
/// // Handle completion
/// uploadTask.onComplete { result in
///     switch result {
///     case .success(let url):
///         print("Upload completed: \(url)")
///     case .failure(let error):
///         print("Upload failed: \(error)")
///     }
/// }
///
/// // Control upload
/// uploadTask.pause()   // Pause upload
/// uploadTask.resume()  // Resume upload
/// uploadTask.cancel()  // Cancel upload
/// ```
public class S3UploadDataTask: S3UploadTask, UploadDataTask {
    // MARK: - Typealiases

    /// A closure type representing the completion handler for upload operations.
    ///
    /// This typealias defines the signature for completion handlers that are called
    /// when an upload operation finishes, providing either a success result with the
    /// remote URL or a failure result with the error details.
    typealias UploadCompletion = (Result<URL, UtilityError>) -> Void

    /// A closure type representing progress handlers for upload operations.
    ///
    /// This typealias defines the signature for progress handlers that are called
    /// periodically during upload operations to report the current progress status,
    /// including bytes transferred and completion percentage.
    typealias UploadProgress = (Progress) -> Void

    // MARK: - Private Properties

    private var progresses: [UploadProgress] = []
    private var task: AWSS3TransferUtilityUploadTask?

    // MARK: - Properties

    /// The AWS S3 Transfer Utility upload expression for configuring upload behavior.
    ///
    /// This expression object is used to configure various aspects of the S3 upload operation,
    /// including progress monitoring callbacks, metadata, and other upload-specific settings.
    /// The progress block is automatically configured during initialization to forward
    /// progress updates to registered progress handlers.
    let expression = AWSS3TransferUtilityUploadExpression()

    /// The data payload containing all information required for the S3 upload operation.
    ///
    /// This payload encapsulates the binary data to upload, the target S3 bucket,
    /// the content type, and the destination path within the bucket. It serves as
    /// a single source of truth for all upload-related data and configuration.
    let payload: S3DataPayload

    // MARK: - Initializer

    /// Creates a new S3 upload data task instance with the specified configuration and data.
    ///
    /// This initializer sets up an upload task using the provided S3 data payload, delegate,
    /// and optional monitoring configuration. The task is initialized in the `.initialized` state
    /// and will be ready to begin upload operations once the underlying AWS Transfer Utility
    /// task is created and started.
    ///
    /// The initializer configures the AWS S3 Transfer Utility upload expression with a progress
    /// block that forwards progress updates to all registered progress handlers. This ensures
    /// that progress monitoring is properly set up before the upload begins.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the upload task. If not provided, a new UUID will be generated.
    ///   - payload: The `S3DataPayload` containing the data to upload, target bucket, content type, and destination
    /// path.
    ///   - delegate: An optional delegate that will be notified when the task completes. Used for cleanup and retry
    /// logic.
    ///   - monitor: An optional `S3TaskMonitor` for observing and logging upload task events throughout the lifecycle.
    init(
        id: String = UUID().uuidString,
        payload: S3DataPayload,
        delegate: S3UploadTaskDelegate?,
        monitor: S3TaskMonitor?
    ) {
        self.payload = payload

        super.init(id: id, delegate: delegate, monitor: monitor)

        expression.progressBlock = { [weak self] _, progress in
            if let self {
                self.progresses.forEach { $0(progress) }
            }
        }
    }

    // MARK: - LifeCycle methods

    /// Finalizes the lifecycle of an upload operation and processes completion.
    ///
    /// This method is the definitive completion point for any upload task, regardless of whether
    /// it completed successfully, failed, or was cancelled. It handles the final state transition,
    /// stores the response data, processes any completion callbacks, and ensures proper cleanup.
    ///
    /// The method is thread-safe and runs on the `S3UploadDataTaskActor` to ensure atomic
    /// state updates and prevent race conditions during concurrent access.
    ///
    /// - Parameters:
    ///   - task: The `AWSS3TransferUtilityTask` associated with the upload operation. Contains
    ///           the HTTP response and metadata from the AWS S3 service.
    ///   - error: An optional `UtilityError` describing why the upload failed or was cancelled.
    ///            If `nil`, the upload is considered successful.
    @S3UploadDataTaskActor
    func didComplete(task: AWSS3TransferUtilityTask, error: UtilityError? = nil) async {
        if let error {
            self.error = error
        }

        self.response = task.response

        monitor?.uploadDataTask(self, didFinishWithURL: response?.url, error: self.error)

        await finish(error: error)
    }

    /// Handles the creation and initialization of a new AWS S3 Transfer Utility upload task.
    ///
    /// This method is called when the underlying AWS S3 Transfer Utility task is successfully
    /// created and is ready to begin the upload operation. It stores the AWS task reference
    /// and applies the current task state to ensure the AWS task is in the correct state
    /// (running, suspended, or cancelled) based on the current upload task state.
    ///
    /// The method ensures that state transitions are properly synchronized between the
    /// high-level upload task and the underlying AWS SDK task.
    ///
    /// - Parameter task: The `AWSS3TransferUtilityUploadTask` that was created by the AWS SDK.
    @S3UploadTaskActor
    func didCreate(task: AWSS3TransferUtilityUploadTask) {
        if self.task == nil {
            self.task = task

            switch state {
            case .initialized, .finished, .finishing:
                break

            case .cancelled:
                task.cancel()

            case .resumed:
                task.resume()

            case .suspended:
                task.suspend()
            }
        }
    }

    /// Handles a failure encountered during AWS S3 Transfer Utility task creation.
    ///
    /// This method is called when the initialization of an `AWSS3TransferUtilityUploadTask`
    /// cannot be completed due to an error. It records the error, notifies the monitor,
    /// and transitions the task to a finished state with the failure information.
    ///
    /// This method runs on the `S3UploadDataTaskActor` to ensure thread-safe error handling
    /// and proper state management during task creation failures.
    ///
    /// - Parameter error: The `UtilityError` describing why the upload task could not be created.
    ///                   Common causes include network connectivity issues, invalid credentials,
    ///                   or malformed request parameters.
    @S3UploadDataTaskActor
    func didFailToCreateUploadTask(with error: UtilityError) async {
        self.error = error

        monitor?.uploadDataTask(self, didFailToCreateUploadTaskWith: error)

        await finish(error: error)
    }

    // MARK: - Public methods

    /// Cancels the upload operation and returns the task instance.
    ///
    /// This method stops the upload operation immediately and transitions the
    /// task to the cancelled state. Once cancelled, the upload cannot be
    /// resumed and any partial upload data may be discarded.
    ///
    /// - Returns: The upload task instance for method chaining
    @discardableResult
    public func cancel() -> Self {
        if state.canTransition(to: .cancelled) {
            state = .cancelled

            Task { @S3UploadDataTaskActor in
                if let task, task.status != .completed {
                    task.cancel()

                    await didCancel()
                }
            }
        }

        return self
    }

    /// Registers a completion handler to be called when the upload operation finishes.
    ///
    /// This method allows you to register a callback that will be invoked when the upload
    /// process completes, regardless of whether it ended successfully or with an error.
    /// The completion handler provides the final outcome of the operation, enabling you
    /// to handle post-upload actions such as updating the UI, notifying the user,
    /// or performing cleanup tasks.
    ///
    /// Multiple completion handlers can be registered for the same upload task, and all
    /// will be called when the upload finishes. The completion handlers are called on
    /// the main queue to ensure UI updates can be performed safely.
    ///
    /// - Parameter completion: A closure that receives a `Result` containing either:
    ///   - `.success(URL)`: The remote URL where the data was successfully uploaded
    ///   - `.failure(UtilityError)`: The error that caused the upload to fail
    ///
    /// - Returns: The current task instance, enabling fluent method chaining.
    @discardableResult
    public func onComplete(_ completion: @escaping (Result<URL, UtilityError>) -> Void) -> Self {
        completions.append { [weak self] in
            if let self {
                guard let url = response?.url else {
                    let error =
                        error
                            ?? UtilityError(
                                kind: .CloudStorageErrorReason.missingUploadURL,
                                failureReason: "Upload finished but no URL returned."
                            )

                    completion(.failure(error))
                    return
                }

                completion(.success(url))
            }
        }

        return self
    }

    /// Registers a progress handler to be called as the upload progresses.
    ///
    /// This method allows you to monitor the upload progress in real-time by providing
    /// a callback that will be invoked whenever the upload progress changes. The progress
    /// handler provides detailed information about the current upload status, including
    /// bytes uploaded, total bytes, and completion percentage.
    ///
    /// Multiple progress handlers can be registered for the same upload task, and all
    /// will be called when progress updates are received. Progress updates are provided
    /// by the AWS S3 Transfer Utility and represent the actual bytes transferred over
    /// the network.
    ///
    /// - Parameter progress: A closure that receives a `Progress` object containing:
    ///   - `completedUnitCount`: The number of bytes uploaded so far
    ///   - `totalUnitCount`: The total number of bytes to upload
    ///   - `fractionCompleted`: A normalized `Double` between `0.0` and `1.0` representing completion percentage
    ///
    /// - Returns: The current task instance, enabling fluent method chaining.
    @discardableResult
    public func onProgress(_ progress: @escaping (Progress) -> Void) -> Self {
        progresses.append(progress)
        return self
    }

    /// Pauses the upload operation and returns the task instance.
    ///
    /// This method temporarily suspends the upload operation, allowing it to
    /// be resumed later. The upload state transitions to paused, and network
    /// activity is suspended while maintaining the current upload progress.
    ///
    /// - Returns: The upload task instance for method chaining
    @discardableResult
    public func pause() -> Self {
        if state.canTransition(to: .suspended) {
            state = .suspended

            Task { @S3UploadDataTaskActor in
                if let task, task.status != .completed {
                    task.suspend()

                    didSuspend()
                }
            }
        }

        return self
    }

    /// Resumes a paused upload operation and returns the task instance.
    ///
    /// This method restarts a previously paused upload operation, continuing
    /// from where it was paused. The upload state transitions back to uploading,
    /// and network activity resumes.
    ///
    /// - Returns: The upload task instance for method chaining
    @discardableResult
    public func resume() -> Self {
        if state.canTransition(to: .resumed) {
            state = .resumed

            Task { @S3UploadDataTaskActor in
                didResume()

                if let task, task.status != .completed {
                    task.resume()
                }
            }
        }

        return self
    }
}
