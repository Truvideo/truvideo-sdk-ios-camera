//
// Copyright © 2025 TruVideo. All rights reserved.
//

@testable import Telemetry

final class UploaderMock: Uploader {
    // MARK: - Properties

    var fileName: String?
    var contentType: Telemetry.ContentType?
    var data: Data?

    // MARK: - Uploader

    /// Uploads raw `Data` to an S3 bucket using the specified file name and content type.
    ///
    /// This method performs an asynchronous upload operation using AWS S3.
    /// It throws an error if the upload fails or is interrupted.
    ///
    /// - Parameters:
    ///   - data: The binary data to be uploaded to S3.
    ///   - fileName: The key (path/name) under which the file will be stored in the S3 bucket.
    ///   - contentType: The type of the data (e.g., "image/jpeg", "application/json").
    /// - Throws: An error of type `CommonUtilityError` if the upload fails.
    func upload(_ data: Data, fileName: String, contentType: Telemetry.ContentType) async throws {
        self.fileName = fileName
        self.contentType = contentType
        self.data = data
    }
}
