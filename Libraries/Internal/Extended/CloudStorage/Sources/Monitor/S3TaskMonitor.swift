//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Utilities

/// A protocol that defines the contract for monitoring S3 upload task lifecycle events.
///
/// `S3TaskMonitor` provides a comprehensive monitoring system for observing and reacting
/// to key events throughout the lifecycle of S3 upload operations. Implementations can
/// use this protocol to build logging systems, analytics tracking, error monitoring,
/// performance measurement, and debugging tools for S3 upload functionality.
///
/// ## Purpose
///
/// This protocol enables comprehensive observability of S3 upload operations by providing
/// hooks for all significant events in the upload lifecycle. It supports monitoring of
/// different types of upload tasks including standard data uploads, streaming uploads,
/// and their individual components.
///
/// ## Key Features
///
/// - **Lifecycle Monitoring**: Complete coverage of upload task lifecycle events
/// - **Multi-Task Support**: Monitors different types of upload tasks (data, stream, parts)
/// - **Error Tracking**: Detailed error information for debugging and analytics
/// - **Performance Metrics**: Event timing and completion tracking
/// - **Thread Safety**: Sendable protocol for safe concurrent usage
/// - **Queue Management**: Configurable dispatch queue for callback execution
///
/// ## Monitoring Categories
///
/// The protocol provides monitoring capabilities for three main categories:
/// 1. **UploadTask Events**: General upload task lifecycle (cancel, finish, resume, suspend)
/// 2. **UploadDataTask Events**: Specific data upload events (creation failure, completion)
/// 3. **StreamUploadTask Events**: Streaming upload part events (cancel, complete, resume, suspend)
///
/// ## Implementation Guidelines
///
/// Conforming types should:
/// - Handle all protocol methods to ensure complete event coverage
/// - Use the provided `queue` property for thread-safe callback execution
/// - Implement efficient event processing to avoid performance impact
/// - Consider batching or filtering events for high-volume scenarios
/// - Provide meaningful logging and analytics data
///
/// ## Usage Context
///
/// This protocol is typically implemented by:
/// - Logging and analytics systems
/// - Performance monitoring tools
/// - Debugging and diagnostic utilities
/// - Error tracking and reporting systems
/// - Custom upload management solutions
///
/// ## Example Usage
///
/// ```swift
/// class MyS3Monitor: S3TaskMonitor {
///     private let logger: Logger
///     private let analytics: AnalyticsService
///
///     init(logger: Logger, analytics: AnalyticsService) {
///         self.logger = logger
///         self.analytics = analytics
///     }
///
///     func taskDidFinish(_ task: S3UploadTask) {
///         logger.info("Upload task completed: \(task.id)")
///         analytics.track("upload_completed", properties: [
///             "task_id": task.id,
///             "duration": task.duration
///         ])
///     }
///
///     func uploadDataTask(_ task: S3UploadDataTask, didFinishWithURL url: URL?, error: UtilityError?) {
///         if let error = error {
///             logger.error("Upload failed: \(error)")
///             analytics.track("upload_failed", properties: ["error": error.localizedDescription])
///         } else if let url = url {
///             logger.info("Upload succeeded: \(url)")
///             analytics.track("upload_succeeded", properties: ["url": url.absoluteString])
///         }
///     }
/// }
/// ```
public protocol S3TaskMonitor: Sendable {
    /// The dispatch queue on which monitor callback methods are executed.
    ///
    /// This property specifies the dispatch queue that will be used for executing
    /// all monitor callback methods. The queue ensures thread-safe execution of
    /// monitoring operations and allows implementations to control the execution
    /// context for their monitoring logic.
    ///
    /// ## Default Implementation
    ///
    /// The default implementation returns the main queue (`.main`), ensuring that
    /// monitoring callbacks are executed on the main thread. This is suitable for
    /// most monitoring implementations that need to update UI or perform operations
    /// that should occur on the main thread.
    ///
    /// ## Custom Implementation
    ///
    /// Implementations can override this property to use custom queues for specific
    /// monitoring needs, such as:
    /// - Background queues for heavy processing
    /// - Serial queues for ordered event processing
    /// - Concurrent queues for parallel event handling
    ///
    /// ## Thread Safety
    ///
    /// All monitor callback methods will be executed on the queue specified by this
    /// property, ensuring consistent and thread-safe execution of monitoring operations.
    var queue: DispatchQueue { get }

    // MARK: - UploadTask monitoring

    /// Notifies the monitor that an upload task has been cancelled.
    ///
    /// This method is called when an upload task is explicitly cancelled by the user
    /// or due to external factors such as network issues or system constraints.
    /// The task will not be resumable after cancellation.
    ///
    /// - Parameter task: The `S3UploadTask` that was cancelled. The task's state
    ///                   will be `.cancelled` and may contain error information
    ///                   in the `error` property.
    func taskDidCancel(_ task: S3UploadTask)

    /// Notifies the monitor that an upload task has finished processing.
    ///
    /// This method is called when an upload task reaches its final state, regardless
    /// of whether it completed successfully or failed. It indicates that all
    /// processing for the task has been completed and no further state changes
    /// will occur.
    ///
    /// - Parameter task: The `S3UploadTask` that has finished. Check the task's
    ///                   `error` property to determine if the upload succeeded
    ///                   or failed.
    func taskDidFinish(_ task: S3UploadTask)

    /// Notifies the monitor that an upload task has been resumed.
    ///
    /// This method is called when a previously suspended upload task is resumed
    /// and begins transferring data again. It indicates that the upload operation
    /// is now active and progressing.
    ///
    /// - Parameter request: The `S3UploadTask` that has been resumed. The task's
    ///                      state will be `.resumed` and it will begin transferring
    ///                      data from where it was previously paused.
    func taskDidResume(_ request: S3UploadTask)

    /// Notifies the monitor that an upload task has been suspended.
    ///
    /// This method is called when an upload task is paused and temporarily stops
    /// transferring data. The task can be resumed later to continue from where
    /// it was paused.
    ///
    /// - Parameter request: The `S3UploadTask` that has been suspended. The task's
    ///                      state will be `.suspended` and it will stop transferring
    ///                      data until resumed.
    func taskDidSuspend(_ request: S3UploadTask)

    /// Notifies the monitor that an upload task is transitioning to a finishing state.
    ///
    /// This method is called when an upload task begins its finalization process,
    /// before the `taskDidFinish` method is called. It indicates that the task
    /// is completing its operations and preparing for final state transition.
    ///
    /// - Parameter task: The `S3UploadTask` that is finishing. The task's state
    ///                   will be `.finishing` and it is in the process of
    ///                   completing its operations.
    func taskIsFinishing(_ task: S3UploadTask)

    // MARK: - UploadDataTask monitoring

    /// Notifies the monitor that an upload data task failed to create the underlying AWS upload task.
    ///
    /// This method is called when the system is unable to create the underlying AWS S3
    /// Transfer Utility upload task for a data upload operation. This typically occurs
    /// due to configuration issues, authentication problems, or AWS service unavailability.
    ///
    /// - Parameters:
    ///   - task: The `S3UploadDataTask` that failed to create its underlying AWS task.
    ///            The task will be in an error state and cannot proceed with the upload.
    ///   - didFailToCreateUploadTaskWith: The `UtilityError` describing why the AWS
    ///                                    upload task could not be created. This error
    ///                                    contains detailed information about the failure
    ///                                    cause and can be used for debugging and error
    ///                                    reporting.
    func uploadDataTask(_ task: S3UploadDataTask, didFailToCreateUploadTaskWith: UtilityError)

    /// Notifies the monitor that an upload data task has finished with a result.
    ///
    /// This method is called when an upload data task completes, providing the final
    /// result of the upload operation. The method includes both success and failure
    /// outcomes, allowing the monitor to handle both scenarios appropriately.
    ///
    /// - Parameters:
    ///   - task: The `S3UploadDataTask` that has finished. The task's state will be
    ///            `.finished` and it contains the final result of the upload operation.
    ///   - url: The remote URL where the data was successfully uploaded, or `nil` if
    ///          the upload failed. This URL can be used to access the uploaded file
    ///          or share it with other services.
    ///   - error: The error that caused the upload to fail, or `nil` if the upload
    ///            succeeded. This error contains detailed information about the failure
    ///            and can be used for debugging, retry logic, or user notification.
    func uploadDataTask(_ task: S3UploadDataTask, didFinishWithURL url: URL?, error: UtilityError?)

    // MARK: - StreamUploadTask monitoring

    /// Notifies the monitor that a specific part of a stream upload task has been cancelled.
    ///
    /// This method is called when an individual part of a streaming upload operation
    /// is cancelled. Stream uploads are divided into multiple parts for efficient
    /// transfer, and each part can be managed independently.
    ///
    /// - Parameters:
    ///   - task: The `S3StreamUploadTask` that contains the cancelled part.
    ///   - number: The part number that was cancelled. Part numbers start from 1
    ///             and increment for each part in the stream upload.
    func streamUpload(_ task: S3StreamUploadTask, didCancelPart number: Int)

    /// Notifies the monitor that a specific part of a stream upload task has completed.
    ///
    /// This method is called when an individual part of a streaming upload operation
    /// finishes, either successfully or with an error. The completion of all parts
    /// is required for the overall stream upload to succeed.
    ///
    /// - Parameters:
    ///   - task: The `S3StreamUploadTask` that contains the completed part.
    ///   - number: The part number that completed. Part numbers start from 1
    ///             and increment for each part in the stream upload.
    ///   - error: The error that caused the part to fail, or `nil` if the part
    ///            completed successfully. This error contains detailed information
    ///            about the failure and can be used for debugging and retry logic.
    func streamUpload(_ task: S3StreamUploadTask, didCompletePart number: Int, error: UtilityError?)

    /// Notifies the monitor that a specific part of a stream upload task has been resumed.
    ///
    /// This method is called when an individual part of a streaming upload operation
    /// is resumed after being suspended. The part will continue transferring data
    /// from where it was previously paused.
    ///
    /// - Parameters:
    ///   - task: The `S3StreamUploadTask` that contains the resumed part.
    ///   - number: The part number that was resumed. Part numbers start from 1
    ///             and increment for each part in the stream upload.
    func streamUpload(_ task: S3StreamUploadTask, didResumePart number: Int)

    /// Notifies the monitor that a specific part of a stream upload task has been suspended.
    ///
    /// This method is called when an individual part of a streaming upload operation
    /// is paused and temporarily stops transferring data. The part can be resumed
    /// later to continue from where it was paused.
    ///
    /// - Parameters:
    ///   - task: The `S3StreamUploadTask` that contains the suspended part.
    ///   - number: The part number that was suspended. Part numbers start from 1
    ///             and increment for each part in the stream upload.
    func streamUpload(_ task: S3StreamUploadTask, didSuspendPart number: Int)
}

extension S3TaskMonitor {
    /// The default dispatch queue for monitor callbacks.
    ///
    /// This extension provides a default implementation of the `queue` property,
    /// returning the main dispatch queue. This ensures that monitor callbacks
    /// are executed on the main thread by default, which is suitable for most
    /// monitoring implementations that need to update UI or perform operations
    /// that should occur on the main thread.
    ///
    /// ## Customization
    ///
    /// Implementations can override this property to use custom queues for specific
    /// monitoring needs, such as background processing or specialized event handling.
    public var queue: DispatchQueue { .main }

    // MARK: - UploadTask monitoring

    /// Notifies the monitor that an upload task has been cancelled.
    ///
    /// This method is called when an upload task is explicitly cancelled by the user
    /// or due to external factors such as network issues or system constraints.
    /// The task will not be resumable after cancellation.
    ///
    /// - Parameter task: The `S3UploadTask` that was cancelled. The task's state
    ///                   will be `.cancelled` and may contain error information
    ///                   in the `error` property.
    public func taskDidCancel(_ task: S3UploadTask) {}

    /// Notifies the monitor that an upload task has finished processing.
    ///
    /// This method is called when an upload task reaches its final state, regardless
    /// of whether it completed successfully or failed. It indicates that all
    /// processing for the task has been completed and no further state changes
    /// will occur.
    ///
    /// - Parameter task: The `S3UploadTask` that has finished. Check the task's
    ///                   `error` property to determine if the upload succeeded
    ///                   or failed.
    public func taskDidFinish(_ task: S3UploadTask) {}

    /// Notifies the monitor that an upload task has been resumed.
    ///
    /// This method is called when a previously suspended upload task is resumed
    /// and begins transferring data again. It indicates that the upload operation
    /// is now active and progressing.
    ///
    /// - Parameter request: The `S3UploadTask` that has been resumed. The task's
    ///                      state will be `.resumed` and it will begin transferring
    ///                      data from where it was previously paused.
    public func taskDidResume(_ request: S3UploadTask) {}

    /// Notifies the monitor that an upload task has been suspended.
    ///
    /// This method is called when an upload task is paused and temporarily stops
    /// transferring data. The task can be resumed later to continue from where
    /// it was paused.
    ///
    /// - Parameter request: The `S3UploadTask` that has been suspended. The task's
    ///                      state will be `.suspended` and it will stop transferring
    ///                      data until resumed.
    public func taskDidSuspend(_ request: S3UploadTask) {}

    /// Notifies the monitor that an upload task is transitioning to a finishing state.
    ///
    /// This method is called when an upload task begins its finalization process,
    /// before the `taskDidFinish` method is called. It indicates that the task
    /// is completing its operations and preparing for final state transition.
    ///
    /// - Parameter task: The `S3UploadTask` that is finishing. The task's state
    ///                   will be `.finishing` and it is in the process of
    ///                   completing its operations.
    public func taskIsFinishing(_ task: S3UploadTask) {}

    // MARK: - UploadDataTask monitoring

    /// Notifies the monitor that an upload data task failed to create the underlying AWS upload task.
    ///
    /// This method is called when the system is unable to create the underlying AWS S3
    /// Transfer Utility upload task for a data upload operation. This typically occurs
    /// due to configuration issues, authentication problems, or AWS service unavailability.
    ///
    /// - Parameters:
    ///   - task: The `S3UploadDataTask` that failed to create its underlying AWS task.
    ///            The task will be in an error state and cannot proceed with the upload.
    ///   - didFailToCreateUploadTaskWith: The `UtilityError` describing why the AWS
    ///                                    upload task could not be created. This error
    ///                                    contains detailed information about the failure
    ///                                    cause and can be used for debugging and error
    ///                                    reporting.
    public func uploadDataTask(_ task: S3UploadDataTask, didFailToCreateUploadTaskWith: UtilityError) {}

    /// Notifies the monitor that an upload data task has finished with a result.
    ///
    /// This method is called when an upload data task completes, providing the final
    /// result of the upload operation. The method includes both success and failure
    /// outcomes, allowing the monitor to handle both scenarios appropriately.
    ///
    /// - Parameters:
    ///   - task: The `S3UploadDataTask` that has finished. The task's state will be
    ///            `.finished` and it contains the final result of the upload operation.
    ///   - url: The remote URL where the data was successfully uploaded, or `nil` if
    ///          the upload failed. This URL can be used to access the uploaded file
    ///          or share it with other services.
    ///   - error: The error that caused the upload to fail, or `nil` if the upload
    ///            succeeded. This error contains detailed information about the failure
    ///            and can be used for debugging, retry logic, or user notification.
    public func uploadDataTask(_ task: S3UploadDataTask, didFinishWithURL url: URL?, error: UtilityError?) {}

    // MARK: - StreamUploadTask monitoring

    /// Notifies the monitor that a specific part of a stream upload task has been cancelled.
    ///
    /// This method is called when an individual part of a streaming upload operation
    /// is cancelled. Stream uploads are divided into multiple parts for efficient
    /// transfer, and each part can be managed independently.
    ///
    /// - Parameters:
    ///   - task: The `S3StreamUploadTask` that contains the cancelled part.
    ///   - number: The part number that was cancelled. Part numbers start from 1
    ///             and increment for each part in the stream upload.
    public func streamUpload(_ task: S3StreamUploadTask, didCancelPart number: Int) {}

    /// Notifies the monitor that a specific part of a stream upload task has completed.
    ///
    /// This method is called when an individual part of a streaming upload operation
    /// finishes, either successfully or with an error. The completion of all parts
    /// is required for the overall stream upload to succeed.
    ///
    /// - Parameters:
    ///   - task: The `S3StreamUploadTask` that contains the completed part.
    ///   - number: The part number that completed. Part numbers start from 1
    ///             and increment for each part in the stream upload.
    ///   - error: The error that caused the part to fail, or `nil` if the part
    ///            completed successfully. This error contains detailed information
    ///            about the failure and can be used for debugging and retry logic.
    public func streamUpload(_ task: S3StreamUploadTask, didCompletePart number: Int, error: UtilityError?) {}

    /// Notifies the monitor that a specific part of a stream upload task has been resumed.
    ///
    /// This method is called when an individual part of a streaming upload operation
    /// is resumed after being suspended. The part will continue transferring data
    /// from where it was previously paused.
    ///
    /// - Parameters:
    ///   - task: The `S3StreamUploadTask` that contains the resumed part.
    ///   - number: The part number that was resumed. Part numbers start from 1
    ///             and increment for each part in the stream upload.
    public func streamUpload(_ task: S3StreamUploadTask, didResumePart number: Int) {}

    /// Notifies the monitor that a specific part of a stream upload task has been suspended.
    ///
    /// This method is called when an individual part of a streaming upload operation
    /// is paused and temporarily stops transferring data. The part can be resumed
    /// later to continue from where it was paused.
    ///
    /// - Parameters:
    ///   - task: The `S3StreamUploadTask` that contains the suspended part.
    ///   - number: The part number that was suspended. Part numbers start from 1
    ///             and increment for each part in the stream upload.
    public func streamUpload(_ task: S3StreamUploadTask, didSuspendPart number: Int) {}
}
