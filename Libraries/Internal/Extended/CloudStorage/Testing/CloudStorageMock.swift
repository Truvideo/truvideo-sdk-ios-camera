//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

@testable import CloudStorageKit

/// A mock implementation of `CloudStorage` used for unit testing.
public final class CloudStorageMock: CloudStorage {
    // MARK: - Properties

    /// The content type passed in the last `upload` call.
    public private(set) var contentType: ContentType?

    /// The `Data` value passed in the last `upload` call.
    public private(set) var data: Data?

    /// The file name passed in the last `upload` call.
    public private(set) var fileName: String?

    /// Number of times `upload(_:fileName:contentType:)` was invoked.
    public private(set) var uploadCallCount = 0

    /// The mock upload task returned when `upload` is invoked.
    public var uploadDataTask: UploadDataTaskMock?

    /// The mock stream upload task returned when `streamUpload` is invoked.
    public var streamUploadTask: (any StreamUploadTask)?

    // MARK: - Initializer

    public init() {}

    // MARK: - CloudStorage

    /// Simulates stream uploading data to cloud storage.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the upload task, typically associated with the file
    ///     or resource being uploaded.
    ///   - contentType: The MIME type of the data being uploaded (e.g., `.videoMp4`, `.imageJpeg`).
    ///
    /// - Returns: A `StreamUploadTask` instance that enables incremental, chunk-based
    ///   uploading with full control over the streaming lifecycle.
    public func streamUpload(with id: String, contentType: ContentType) -> any StreamUploadTask {
        streamUploadTask!
    }

    /// Simulates uploading data to cloud storage.
    ///
    /// - Parameters:
    ///   - data: The data to be uploaded.
    ///   - fileName: The file name to associate with the upload.
    ///   - contentType: The MIME type of the file being uploaded.
    /// - Returns: The configured `UploadTaskMock`.
    public func upload(_ data: Data, fileName: String, contentType: ContentType) -> any UploadDataTask {
        uploadCallCount += 1
        self.data = data
        self.fileName = fileName
        self.contentType = contentType

        return uploadDataTask!
    }
}
