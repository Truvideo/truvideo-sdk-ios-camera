//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Utilities

/// Represents the outcome of uploading a single part in a multipart upload.
///
/// `UploadPartResponse` contains all relevant metadata and the result of the
/// upload attempt, including the raw data sent, the part index, the unique
/// request identifier, and the server response details.
///
/// Example usage:
/// ```swift
/// let response = UploadPartResponse<String, UploadError>(
///     data: chunk,
///     partNumber: 1,
///     requestId: "req-5678",
///     result: .success("eTag-123"),
///     statusCode: 200,
///     url: URL(string: "https://bucket.s3.amazonaws.com/file")!
/// )
///
/// switch response.result {
/// case .success(let eTag):
///     print("Part \(response.partNumber) uploaded successfully with ETag: \(eTag)")
/// case .failure(let error):
///     print("Part \(response.partNumber) failed: \(error)")
/// }
///
/// ```
public struct UploadPartResponse {
    /// The raw `Data` that was uploaded for this part.
    public let data: Data

    /// The index of the part in the multipart upload.
    public let partNumber: Int

    /// The unique identifier for this request, provided by the server.
    public let requestId: String?

    /// The result of the upload attempt, containing either success or failure.
    public let result: Result<String, UtilityError>

    /// The HTTP status code returned by the server.
    public let statusCode: Int?

    /// The destination URL where this part was uploaded.
    public let url: URL?
}
