//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AWSS3
import Foundation
import Utilities

/// Global actor that provides thread-safe isolation for S3 upload task operations.
///
/// The S3UploadTaskActor provides a centralized execution context for managing
/// AWS S3 upload tasks, ensuring that all upload operations, state management,
/// and task coordination occur on a single, well-defined executor. This actor
/// prevents data races and ensures consistent state when working with multiple
/// upload tasks, pause/resume operations, and progress tracking. Use this actor
/// to isolate S3 upload-related code and maintain thread safety across upload
/// operations.
@globalActor
actor S3UploadTaskActor {
    /// The shared global actor instance used to isolate device operations.
    static let shared = S3UploadTaskActor()
}

/// Represents an upload task to Amazon S3.
///
/// `S3UploadTask` manages the lifecycle of an upload operation to an S3 bucket,
/// including starting, pausing, resuming, and tracking its progress.
///
/// This class conforms to `UploadTask` and provides functionality for controlling
/// and monitoring the upload process, as well as retrieving the final result
/// once the upload completes.
public class S3UploadTask: UploadTask, Identifiable {
    // MARK: - Typealias

    /// Represents the result of an upload operation.
    typealias UploadCompletion = (Result<URL, UtilityError>) -> Void

    /// Represents the progress of an upload operation as a value between `0.0` and `1.0`.
    typealias UploadProgress = (Progress) -> Void

    // MARK: - Private Properties

    private var completions: [UploadCompletion] = []
    private var error: UtilityError?
    private let monitor: S3UploadMonitor?
    private var progresses: [UploadProgress] = []
    private var response: HTTPURLResponse?
    private weak var task: AWSS3TransferUtilityUploadTask?

    // MARK: - Properties

    /// A new upload expression for configuring S3 transfer utility upload behavior.
    let expression = AWSS3TransferUtilityUploadExpression()

    /// Represents the data package required for uploading an object to Amazon S3.
    let payload: S3DataPayload

    // MARK: - Public Properties

    /// A unique identifier for the upload task.
    public let id: UUID

    /// The current state of the upload task.
    ///
    /// This property reflects the current status of the upload operation and
    /// can be used to determine what actions are available or appropriate
    /// at any given time. The state may change as a result of calling control
    /// methods or due to external factors like network conditions.
    ///
    /// This property should be thread-safe and provide consistent values
    /// across multiple threads accessing the same upload task.
    public private(set) var state = UploadTaskState.initialized

    // MARK: - Initializer

    /// Creates a new upload task instance with the specified configuration and data.
    ///
    /// This initializer sets up an upload task using the provided S3 bucket, binary data,
    /// content type, destination path, and transfer utility. These parameters define
    /// where the data will be stored, what type of content it is, and how the upload will be managed.
    ///
    /// - Parameters:
    ///   - id: The unique identifier of the request
    ///   - payload: Represents the data package required for uploading an object to Amazon S3.
    ///   - monitor: An optional `S3UploadMonitor` for observing request events.
    init(id: UUID = UUID(), payload: S3DataPayload, monitor: S3UploadMonitor?) {
        self.id = id
        self.payload = payload
        self.monitor = monitor

        expression.progressBlock = { [weak self] _, progress in
            Task { @S3UploadTaskActor in
                if let self {
                    self.progresses.forEach { $0(progress) }
                }
            }
        }
    }

    // MARK: - LifeCycle methods

    /// Handles the cancellation of the task.
    ///
    /// This method ensures the task is properly marked as cancelled,
    /// setting the appropriate error if it has not already been assigned.
    @S3UploadTaskActor
    func didCancel() {
        error =
            error
            ?? UtilityError(
                kind: .CloudStorageErrorReason.explicitlyCancelled,
                failureReason: "Upload Request Explicitly Cancelled"
            )

        monitor?.uploadDidCancel(self)
        finish(with: error)
    }

    /// Handles the cancellation of a `AWSS3TransferUtilityUploadTask`.
    ///
    /// This method is called when a upload task is explicitly cancelled. It ensures that the cancellation
    /// is processed on the appropriate dispatch queue to maintain thread safety and informs the associated
    /// request monitor of the cancellation event.
    ///
    /// The cancellation of a task might occur due to user actions, timeouts, or manual intervention.
    /// Notifying the monitor allows for logging, debugging, or any additional side effects needed upon cancellation.
    ///
    /// - Parameter task: The `AWSS3TransferUtilityUploadTask` instance that was cancelled.
    @S3UploadTaskActor
    func didCancel(task: AWSS3TransferUtilityUploadTask) {
        monitor?.upload(self, didCancelTask: task)
    }

    /// Finalizes the lifecycle of an upload operation.
    ///
    /// This method is the definitive completion point for any upload task, regardless of whether
    /// it completed successfully, failed, or was cancelled. It ensures the upload state is
    /// transitioned to `finished`, triggers the appropriate completion callbacks, and records
    /// relevant monitoring data.
    ///
    /// - Parameters:
    ///   - task: The `AWSS3TransferUtilityUploadTask` associated with the upload, or `nil` if the task
    ///           was never created (e.g., creation failure) or was cancelled before starting.
    ///   - error: An optional error describing why the upload failed or was cancelled. `nil` if the
    ///            upload completed successfully.
    @S3UploadTaskActor
    func didComplete(task: AWSS3TransferUtilityTask, error: UtilityError? = nil) {
        if let error {
            self.error = error
        }

        self.response = task.response

        monitor?.upload(self, didCompleteTask: task, with: self.error)
        finish(with: self.error)
    }

    /// Handles the creation of a new `AWSS3TransferUtilityUploadTask` for the request.
    ///
    /// - Parameter task: The `AWSS3TransferUtilityUploadTask` that was created.
    @S3UploadTaskActor
    func didCreate(task: AWSS3TransferUtilityUploadTask) {
        self.task = task
        monitor?.upload(self, didCreateTask: task)

        switch state {
        case .initialized, .finished:
            break

        case .cancelled:
            task.cancel()

            didCancel(task: task)

        case .resumed:
            task.resume()

            didResume(task: task)

        case .suspended:
            task.suspend()

            didSuspend(task: task)
        }
    }

    /// Handles a failure encountered by a `AWSS3TransferUtilityUploadTask`.
    ///
    /// This method is called when an upload task fails, ensuring the error is recorded and notifying the monitor.
    ///
    /// - Parameters:
    ///   - task: The `AWSS3TransferUtilityUploadTask` that failed.
    ///   - error: The `Error` describing why the upload failed.
    @S3UploadTaskActor
    func didFail(task: AWSS3TransferUtilityUploadTask, with error: UtilityError) {
        self.error = error
        monitor?.upload(self, didFailTask: task, with: error)
    }

    /// Handles a failure encountered by a `AWSS3TransferUtilityUploadTask`.
    ///
    /// This method is called when the initialization of an `AWSS3TransferUtilityUploadTask`
    /// cannot be completed due to an error, ensuring the error is recorded and notifying the monitor.
    ///
    /// - Parameter error: The error describing why the upload task could not be created.
    @S3UploadTaskActor
    func didFailToCreateUploadTask(with error: UtilityError) {
        self.error = error
        monitor?.upload(self, didFailToCreateUploadTaskWith: error)
        finish(with: error)
    }

    /// Called when a paused upload task has been resumed.
    ///
    /// This method notifies the monitor that the upload has resumed execution.
    @S3UploadTaskActor
    func didResume() {
        monitor?.uploadDidResume(self)
    }

    /// Called when a paused upload task has been resumed.
    ///
    /// - Parameter task: The `AWSS3TransferUtilityUploadTask` that was resumed.
    @S3UploadTaskActor
    func didResume(task: AWSS3TransferUtilityUploadTask) {
        monitor?.upload(self, didResumeTask: task)
    }

    /// Called when an active upload task has been suspended.
    ///
    /// This method notifies the monitor that the request has been paused.
    @S3UploadTaskActor
    func didSuspend() {
        monitor?.uploadDidSuspend(self)
    }

    /// Called when an active upload task has been suspended.
    ///
    /// - Parameter task: The `AWSS3TransferUtilityUploadTask` that was suspended.
    @S3UploadTaskActor
    func didSuspend(task: AWSS3TransferUtilityUploadTask) {
        monitor?.upload(self, didSuspendTask: task)
    }

    /// Finalizes the request and marks it as finishing.
    ///
    /// This method ensures that the request is transitioning to a finishing state
    /// before running response serializers and notifying the monitor.
    ///
    /// - Parameter error: An optional `Error` encountered before finishing.
    @S3UploadTaskActor
    func finish(with error: UtilityError? = nil) {
        if state.canTransition(to: .finished) {
            state = .finished

            defer { progresses.removeAll() }

            guard let url = response?.url else {
                let error =
                    error
                    ?? UtilityError(
                        kind: .CloudStorageErrorReason.missingUploadURL,
                        failureReason: "Upload finished but no URL returned."
                    )

                if let task {
                    didFail(task: task, with: error)
                }

                processCompletions(with: .failure(error))
                return
            }

            processCompletions(with: .success(url))
            monitor?.uploadDidFinish(self)
        }
    }

    // MARK: - UploadTask

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

            Task { @S3UploadTaskActor in
                if let task, task.status != .completed {
                    task.cancel()

                    didCancel()
                    didCancel(task: task)
                }
            }
        }

        return self
    }

    /// Sets a completion callback to be invoked when the upload operation has finished.
    ///
    /// This callback is triggered once the upload process completes, regardless of
    /// whether it ended successfully or with an error. It provides the final outcome
    /// of the operation so that you can handle post-upload actions such as updating
    /// the UI, notifying the user, or performing cleanup tasks.
    ///
    /// - Parameter completion: A closure that will be called when the upload finishes.
    /// - Returns: The upload task instance for method chaining.
    @discardableResult
    public func onComplete(_ completion: @escaping (Result<URL, UtilityError>) -> Void) -> Self {
        completions.append(completion)
        return self
    }

    /// Sets a progress callback for monitoring upload progress and returns the task instance.
    ///
    /// This method allows you to monitor the upload progress in real-time by providing
    /// a callback that will be invoked whenever the upload progress changes. The progress
    /// callback provides detailed information about the current upload status, including
    /// bytes uploaded, total bytes, and completion percentage.
    ///
    /// - Parameter progress: A closure that receives progress updates during the upload operation
    /// - Returns: The upload task instance for method chaining
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

            Task { @S3UploadTaskActor in
                if let task, task.status != .completed {
                    task.suspend()

                    didSuspend()
                    didSuspend(task: task)
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

            Task { @S3UploadTaskActor in
                didResume()

                if let task, task.status != .completed {
                    task.resume()

                    didResume(task: task)
                }
            }
        }

        return self
    }

    // MARK: - Private methods

    private func processCompletions(with result: Result<URL, UtilityError>) {
        completions.forEach { $0(result) }
        completions.removeAll()
    }
}

extension S3UploadTask: Equatable {
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: S3UploadTask, rhs: S3UploadTask) -> Bool {
        lhs.id == rhs.id
    }
}

extension S3UploadTask: Hashable {
    /// Hashes the essential components of this value by feeding them into the
    /// given hasher.
    ///
    /// - Parameter hasher: The hasher to use when combining the components of this instance.
    public func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}
