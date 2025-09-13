//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Networking
import Utilities

/// Represents a streaming upload task to Amazon S3.
///
/// `S3StreamUploadTask` handles uploads where data is provided as a stream,
/// making it suitable for large files or dynamically generated content.
///
/// This class conforms to `StreamUploadTask`, offering the
/// same lifecycle control (`pause`, `resume`, `cancel`) and monitoring callbacks
/// (`onProgress`, `onComplete`) as other upload tasks, while optimized for
/// streaming scenarios.
///
/// This class conforms to `StreamUploadTask` and provides functionality for controlling
/// and monitoring the upload process, as well as retrieving the final result
/// once the upload completes.
public class S3StreamUploadTask: StreamUploadTask {
    // MARK: - Typealias

    /// Represents the result of an stream upload operation.
    typealias StreamUploadCompletion = (Result<StreamUploadResponse<String>, UtilityError>) -> Void

    // MARK: - Private Properties

    private var completions: [StreamUploadCompletion] = []
    private var completedTasks: [UploadPartResponse<String>] = []
    private let contentType: ContentType
    private var failedTasks: [UploadPartResponse<String>] = []
    private let monitor: S3TaskMonitor?
    private var ongoingTasks: [OngoingTask] = []
    private var partNumber: Int = 0
    private let session: Session

    // MARK: - Public Properties

    /// A unique identifier for the upload task.
    public let id: String

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

    // MARK: - Private Static Properties

    private static let awsHeaderETag = "ETag"
    private static let awsHeaderRequestId = "x-amz-request-id"
    private static let emptyResponseCodes: Set<Int> = [200, 201, 202, 204, 205]

    // MARK: - Initializer

    /// Creates a new streaming upload task instance.
    ///
    /// Use this initializer to configure the task with the necessary metadata and
    /// session context required to perform a multipart streaming upload to S3.
    ///
    /// - Parameters:
    ///   - id: The unique identifier of the request
    ///   - contentType: The type of content being uploaded, used to set appropriate headers and metadata for the upload.
    ///   - monitor: An optional `S3UploadMonitor` for observing request events.
    ///   - session: The active `Session` instance responsible for handling requests, authentication, and networking during the upload process.
    init(id: String, contentType: ContentType, monitor: S3TaskMonitor?, session: Session) {
        self.id = id
        self.contentType = contentType
        self.monitor = monitor
        self.session = session
    }

    // MARK: - LifeCycle methods

    /// Handles the cancellation of the overall upload process.
    ///
    /// This method ensures that the upload task is marked as cancelled and triggers any
    /// necessary monitoring callbacks for all tasks.
    func didCancel() {
        monitor?.uploadDidCancel(self)
    }

    /// Handles the cancellation of a specific task.
    ///
    /// This method is called when an individual `UploadRequest` is explicitly cancelled.
    /// Notifying the monitor allows logging, debugging, or any additional side effects.
    ///
    /// - Parameters:
    ///   - task: The `UploadRequest` instance that was cancelled.
    ///   - partNumber: The identifier of the task in the multipart upload sequence.
    func didCancel(task: any UploadRequest, for partNumber: Int) {
        monitor?.upload(self, didCancelTask: task, for: partNumber)
    }

    /// Finalizes the lifecycle of a specific task.
    ///
    /// This method is called when an individual task completes its upload, either successfully
    /// or with an error. It updates the state, triggers monitoring callbacks, and ensures
    /// proper tracking of the task within the multipart upload sequence.
    ///
    /// - Parameters:
    ///   - task: The `UploadRequest` instance that completed.
    ///   - partNumber: The identifier of this task within the multipart upload sequence.
    ///   - error: An optional `UtilityError` describing why the task failed. `nil` if successful.
    func didComplete(task: any UploadRequest, for partNumber: Int, with error: UtilityError? = nil) {
        guard let ongoingTask = ongoingTasks.first(where: { $0.partNumber == partNumber }) else {
            return
        }

        let result: Result<String, UtilityError> = {
            if let error {
                return .failure(error)
            }

            guard let eTag = ongoingTask.task.response?.allHeaderFields[Self.awsHeaderETag] as? String else {
                let error = UtilityError(
                    kind: .CloudStorageErrorReason.missingETag,
                    failureReason: "Upload operation finished, but the expected ETag header is missing in the response"
                )

                return .failure(error)
            }

            return .success(eTag)
        }()

        let response = UploadPartResponse(
            data: ongoingTask.partBody,
            partNumber: ongoingTask.partNumber,
            requestId: ongoingTask.task.response?.allHeaderFields[Self.awsHeaderRequestId] as? String,
            result: result,
            statusCode: ongoingTask.task.response?.statusCode,
            url: ongoingTask.task.response?.url
        )

        switch result {
        case .success:
            completedTasks.append(response)

        case .failure:
            failedTasks.append(response)
        }

        ongoingTasks = ongoingTasks.filter { $0.partNumber != partNumber }

        monitor?.upload(self, didCompleteTask: task, for: partNumber, with: error)
    }

    /// Handles the creation and tracking of a new task in a multipart upload.
    ///
    /// This method is invoked whenever a new `UploadRequest` is initialized for a specific
    /// part of the overall upload. It registers the task in the `ongoingTasks` dictionary,
    /// storing the associated `partBody` data, part number, and request object. This ensures
    /// that the upload manager can track progress, handle completion or failure, and retry
    /// individual parts if necessary.
    ///
    /// - Parameters:
    ///   - task: The `UploadRequest` instance responsible for uploading this part.
    ///   - partNumber: The sequential index of the part within the multipart upload.
    ///   - partBody: The raw data of the part being uploaded, stored for later reference upon completion.
    func didCreate(task: any UploadRequest, for partNumber: Int, with partBody: Data) {
        let ongoingTask = OngoingTask(partBody: partBody, partNumber: partNumber, task: task)
        ongoingTasks.append(ongoingTask)

        monitor?.upload(self, didCreateTask: task, for: partNumber)
    }

    /// Handles a failure encountered by a specific task.
    ///
    /// This method records the error and triggers monitoring callbacks to ensure
    /// proper tracking of the failure.
    ///
    /// - Parameters:
    ///   - task: The `UploadRequest` that failed.
    ///   - error: The `UtilityError` describing the failure.
    func didFail(task: any UploadRequest, with error: UtilityError) {
        monitor?.upload(self, didFailTask: task, with: error)
    }

    /// Called when the overall upload process is resumed.
    ///
    /// This method notifies the monitor that the upload process has resumed execution.
    func didResume() {
        monitor?.uploadDidResume(self)
    }

    /// Called when a specific task is resumed.
    ///
    /// - Parameters:
    ///   - task: The `UploadRequest` that was resumed.
    ///   - partNumber: The identifier of the resumed task.
    func didResume(task: any UploadRequest, for partNumber: Int) {
        monitor?.upload(self, didResumeTask: task, for: partNumber)
    }

    /// Called when the overall upload process is suspended.
    ///
    /// This method notifies the monitor that the upload has been paused.
    func didSuspend() {
        monitor?.uploadDidSuspend(self)
    }

    /// Called when a specific task is suspended.
    ///
    /// - Parameters:
    ///   - task: The `UploadRequest` that was suspended.
    ///   - partNumber: The identifier of the suspended task.
    func didSuspend(task: any UploadRequest, for partNumber: Int) {
        monitor?.upload(self, didSuspendTask: task, for: partNumber)
    }

    /// Finalizes the entire upload task lifecycle.
    ///
    /// This method ensures that the upload task is transitioned to a finished state, triggers completion callbacks, and logs any errors encountered.
    /// - Parameter error: An optional `UtilityError` if the upload task failed or was cancelled.
    func finish(with error: UtilityError? = nil) {
        if state.canTransition(to: .finished) {
            state = .finished

            if let error {
                if let ongoingTask = ongoingTasks.first(where: { $0.partNumber == partNumber }) {
                    didFail(task: ongoingTask.task, with: error)
                }

                processCompletions(with: .failure(error))
                ongoingTasks.removeAll()
                return
            }

            let response = StreamUploadResponse(completedTasks: completedTasks, failedTasks: failedTasks)

            processCompletions(with: .success(response))
            monitor?.uploadDidFinish(self)
        }
    }

    // MARK: - StreamUploadTask

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

            for ongoingTask in ongoingTasks {
                ongoingTask.task.cancel()

                didCancel()
                didCancel(task: ongoingTask.task, for: ongoingTask.partNumber)
            }
        }

        return self
    }

    /// Finalizes the stream upload, signaling that no further data will be added.
    ///
    /// This method is typically invoked once all data parts have been uploaded.
    /// It allows the task to perform any required closing operations, such as
    /// sending a "complete multipart upload" request to the server.
    ///
    /// - Returns: The current instance of `Self` to enable method chaining.
    @discardableResult
    public func finalize() -> Self {
        finish()
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
    public func onComplete(
        _ completion: @escaping (Result<StreamUploadResponse<String>, UtilityError>) -> Void
    ) -> Self {
        completions.append(completion)
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

            for ongoingTask in ongoingTasks {
                ongoingTask.task.suspend()

                didSuspend()
                didSuspend(task: ongoingTask.task, for: ongoingTask.partNumber)
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

            for ongoingTask in ongoingTasks {
                ongoingTask.task.resume()

                didResume()
                didResume(task: ongoingTask.task, for: ongoingTask.partNumber)
            }
        }

        return self
    }

    /// Initiates the upload of a single data part to the specified URL using the current session.
    ///
    /// This method increments the `partNumber` counter, creates an `uploadRequest`,
    /// and tracks its lifecycle by notifying the `didCreate` and `didComplete` hooks.
    /// The upload is validated, and upon success, the server's ETag is returned.
    /// If the upload fails, the error is wrapped in a `UtilityError` and reported.
    /// In case the overall upload process has already been cancelled, the method finalizes
    /// the entire task with a cancellation error.
    ///
    /// - Parameters:
    ///   - data: The data chunk to upload.
    ///   - url: The server endpoint where the data should be uploaded.
    /// - Returns: The current instance of `Self` to allow method chaining.
    @discardableResult
    public func upload(_ data: Data, to url: URL) -> Self {
        partNumber += 1

        var headers = HTTPHeaders(array: [HTTPHeader.contentType(contentType.rawValue)])
        let uploadRequest = session.upload(data, to: url, method: .put, headers: headers)

        Task {
            didCreate(task: uploadRequest, for: partNumber, with: data)

            do {
                _ =
                    try await uploadRequest
                    .validate()
                    .serializingString(emptyResponseCodes: Self.emptyResponseCodes)
                    .result
                    .get()

                didComplete(task: uploadRequest, for: partNumber)
            } catch {
                // If an error occurs because the overall upload was cancelled, wrap it and finalize the entire task.
                if state == .cancelled {
                    let error = UtilityError(
                        kind: .CloudStorageErrorReason.explicitlyCancelled,
                        failureReason: "Upload Request Explicitly Cancelled"
                    )

                    finish(with: error)
                    return
                }

                let error = UtilityError(
                    kind: .CloudStorageErrorReason.failedToUploadData,
                    underlyingError: error
                )

                didComplete(task: uploadRequest, for: partNumber, with: error)
            }
        }

        return self
    }

    // MARK: - Private methods

    private func processCompletions(with result: Result<StreamUploadResponse<String>, UtilityError>) {
        completions.forEach { $0(result) }
        completions.removeAll()
    }
}
