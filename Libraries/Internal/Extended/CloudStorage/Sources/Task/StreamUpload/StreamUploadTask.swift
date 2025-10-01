//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Utilities

/// A specialized protocol for managing streaming-based upload operations.
///
/// `StreamUploadTask` extends the capabilities of `UploadTask` to represent uploads
/// that are sourced from a continuous or chunked data stream rather than a single
/// in-memory `Data` object or a static file. This protocol maintains the same lifecycle
/// and state management defined by `UploadTask`, while providing a semantic distinction
/// for stream-oriented uploads.
///
/// ## Purpose
///
/// Some upload scenarios require sending data in a streaming fashion, such as large
/// media files, live-generated content, or dynamically produced data chunks. Using
/// `StreamUploadTask` makes it explicit that the upload implementation is designed
/// to handle streaming data sources.
///
/// ## Relationship to `UploadTask`
///
/// `StreamUploadTask` inherits all control methods (`pause`, `resume`, `cancel`)
/// and monitoring callbacks (`onProgress`, `onComplete`) from `UploadTask`. This
/// ensures consistent API behavior across all upload types while allowing
/// implementations of `StreamUploadTask` to optimize for stream-based data handling.
///
/// ## Control Flow
///
/// Streaming uploads follow the same lifecycle as regular uploads:
/// 1. **Initial State**: Task is created and prepared to receive stream input
/// 2. **Active State**: Stream data is actively being uploaded
/// 3. **Paused State**: Streaming is temporarily suspended
/// 4. **Completed State**: Upload finished successfully once the stream ends
/// 5. **Cancelled State**: Upload was cancelled before completion
/// 6. **Error State**: Upload failed with an error
///
/// ## Example Usage
///
/// ```swift
/// // Create a streaming upload task
/// let streamTask: StreamUploadTask = uploadManager.createStreamUploadTask(key: "video.mp4")
///
/// // Monitor progress
/// streamTask.onProgress { progress in
///     print("Uploaded \(progress.completedUnitCount) of \(progress.totalUnitCount)")
/// }
///
/// // Start, pause, and resume
/// streamTask.resume()
/// streamTask.pause()
///
/// // Cancel if needed
/// streamTask.cancel()
/// ```
///
/// ## Thread Safety
///
/// Just like `UploadTask`, implementations of `StreamUploadTask` should be thread-safe.
/// Concurrent calls to control methods must be handled gracefully, and state changes
/// should remain atomic and predictable.
///
/// ## Extensibility
///
/// While `StreamUploadTask` does not currently add new requirements beyond `UploadTask`,
/// it provides a semantic foundation for future stream-specific extensions such as
/// appending data chunks or finalizing the stream.
public protocol StreamUploadTask: UploadTask {
    /// Finalizes the stream upload, signaling that no further data will be added.
    ///
    /// This method is typically invoked once all data parts have been uploaded.
    /// It allows the task to perform any required closing operations, such as
    /// sending a "complete multipart upload" request to the server.
    ///
    /// - Returns: The current instance of `Self` to enable method chaining.
    @discardableResult
    func finalize() -> Self

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
    func onComplete(_ completion: @escaping (Result<StreamUploadResponse, UtilityError>) -> Void) -> Self

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
    func upload(_ data: Data, to url: URL) -> Self
}
