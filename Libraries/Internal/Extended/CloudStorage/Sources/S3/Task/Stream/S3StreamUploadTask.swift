//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
import Foundation
internal import Networking
import Utilities

/// A global actor that provides thread-safe isolation for S3 stream upload operations.
///
/// `S3StreamUploadTaskActor` serves as a concurrency boundary for all S3 stream upload
/// related operations, ensuring thread-safe access to shared state and preventing
/// data races during concurrent upload operations. It provides a centralized point
/// of coordination for multiple upload tasks that may be running simultaneously.
@globalActor
actor S3StreamUploadTaskActor {
    /// The shared global actor instance used to isolate S3 stream upload operations.
    static let shared = S3StreamUploadTaskActor()
}

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
public final class S3StreamUploadTask: S3UploadTask, StreamUploadTask {
    // MARK: - Typealias

    /// Represents the result of an stream upload operation.
    typealias StreamUploadCompletion = (Result<StreamUploadResponse, UtilityError>) -> Void

    // MARK: - Private Properties

    private var completedTasks: [UploadPartResponse] = []
    private let contentType: ContentType
    private var failedTasks: [UploadPartResponse] = []
    private var partNumber: Int = 0
    private var uploadTasks: Set<UploadPartTask> = []

    // MARK: - Dependencies

    @Dependency(\.session)
    private var session: Session

    // MARK: - Private Static Properties

    private static let awsHeaderETag = "ETag"
    private static let awsHeaderRequestId = "x-amz-request-id"

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
    init(id: String, contentType: ContentType, delegate: S3UploadTaskDelegate, monitor: S3TaskMonitor?) {
        self.contentType = contentType

        super.init(id: id, delegate: delegate, monitor: monitor)
    }

    // MARK: - LifeCycle methods

    /// Handles the cancellation of a specific task.
    ///
    /// This method is called when an individual `UploadRequest` is explicitly cancelled.
    /// Notifying the monitor allows logging, debugging, or any additional side effects.
    ///
    /// - Parameters:
    ///   - task: The `UploadPartTask` instance that was cancelled.
    ///   - partNumber: The identifier of the task in the multipart upload sequence.
    func didCancel(task: UploadPartTask) {
        monitor?.streamUpload(self, didCancelPart: task.partNumber)
    }

    /// Finalizes the lifecycle of a specific task.
    ///
    /// This method is called when an individual task completes its upload, either successfully
    /// or with an error. It updates the state, triggers monitoring callbacks, and ensures
    /// proper tracking of the task within the multipart upload sequence.
    ///
    /// - Parameters:
    ///   - task: The `UploadPartTask` instance that completed.
    ///   - error: An optional `UtilityError` describing why the task failed. `nil` if successful.
    @S3StreamUploadTaskActor
    func didComplete(task: UploadPartTask, with error: UtilityError? = nil) {
        uploadTasks.remove(task)

        let result: Result<String, UtilityError> = {
            if let error {
                return .failure(error)
            }

            guard let eTag = task.request.response?.allHeaderFields[Self.awsHeaderETag] as? String else {
                let error = UtilityError(
                    kind: .CloudStorageErrorReason.missingETag,
                    failureReason: "Upload operation finished, but the expected ETag header is missing in the response"
                )

                return .failure(error)
            }

            return .success(eTag)
        }()

        let response = UploadPartResponse(
            data: task.partBody,
            partNumber: task.partNumber,
            requestId: task.request.response?.allHeaderFields[Self.awsHeaderRequestId] as? String,
            result: result,
            statusCode: task.request.response?.statusCode,
            url: task.request.response?.url
        )

        switch result {
        case .success:
            completedTasks.append(response)

        case .failure:
            failedTasks.append(response)
        }

        monitor?.streamUpload(self, didCompletePart: task.partNumber, error: nil)
    }

    /// Handles a failure encountered by a specific task.
    ///
    /// This method records the error and triggers monitoring callbacks to ensure
    /// proper tracking of the failure.
    ///
    /// - Parameters:
    ///   - request: The `UploadRequest` that failed.
    ///   - error: The `UtilityError` describing the failure.
    func didFail(request: any UploadRequest, with error: UtilityError) {
        monitor?.streamUpload(self, didCompletePart: partNumber, error: error)
    }

    /// Called when a specific task is resumed.
    ///
    /// - Parameters:
    ///   - request: The `UploadRequest` that was resumed.
    ///   - partNumber: The identifier of the resumed task.
    func didResume(request: any UploadRequest, for partNumber: Int) {
        monitor?.streamUpload(self, didResumePart: partNumber)
    }

    /// Called when a specific task is suspended.
    ///
    /// - Parameters:
    ///   - request: The `UploadRequest` that was suspended.
    ///   - partNumber: The identifier of the suspended task.
    func didSuspend(task: UploadPartTask) {
        monitor?.streamUpload(self, didSuspendPart: task.partNumber)
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

            Task {
                for uploadTask in uploadTasks {
                    uploadTask.request.cancel()

                    await didCancel()
                    didCancel(task: uploadTask)
                }
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
        Task {
            await finish()
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
    public func onComplete(_ completion: @escaping (Result<StreamUploadResponse, UtilityError>) -> Void) -> Self {
        completions.append { [weak self] in
            if let self {
                guard let error else {
                    let completedTasks = completedTasks.sorted { $0.partNumber < $1.partNumber }
                    let failedTasks = failedTasks.sorted { $0.partNumber < $1.partNumber }
                    let response = StreamUploadResponse(completedTasks: completedTasks, failedTasks: failedTasks)

                    completion(.success(response))
                    return
                }

                completion(.failure(error))
            }
        }

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

            for uploadTask in uploadTasks {
                uploadTask.request.suspend()

                didSuspend(task: uploadTask)
            }

            didSuspend()
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

            for uploadTask in uploadTasks {
                uploadTask.request.resume()

                monitor?.streamUpload(self, didResumePart: uploadTask.partNumber)
            }

            didResume()
        }

        return self
    }

    // MARK: - StreamUploadTask

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
        let headers = HTTPHeaders(array: [HTTPHeader.contentType(contentType.rawValue)])
        let request = session.upload(data, to: url, method: .put, headers: headers)

        Task {
            let uploadTask = await uploadTask(for: request, with: data)

            do {
                _ = try await request
                    .validate()
                    .serializing(Empty.self)
                    .result
                    .get()

                await didComplete(task: uploadTask)
            } catch {
                guard state == .cancelled else {
                    let error = UtilityError(kind: .CloudStorageErrorReason.failedToUploadData, underlyingError: error)

                    await didComplete(task: uploadTask, with: error)
                    return
                }

                let errorReason = ErrorReason.CloudStorageErrorReason.explicitlyCancelled
                let error = UtilityError(kind: errorReason, failureReason: "Upload Request Explicitly Cancelled")

                await finish(error: error)
            }
        }

        return self
    }

    // MARK: - Private methods

    @S3StreamUploadTaskActor
    private func uploadTask(for request: any UploadRequest, with body: Data) -> UploadPartTask {
        partNumber += 1

        let uploadPartTask = UploadPartTask(partBody: body, partNumber: partNumber, request: request)

        uploadTasks.insert(uploadPartTask)

        return uploadPartTask
    }
}
