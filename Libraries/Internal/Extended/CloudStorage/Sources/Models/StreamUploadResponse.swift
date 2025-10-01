//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// Represents the result of a multipart stream upload.
///
/// `StreamUploadResponse` groups all the individual part upload responses,
/// separating those that completed successfully from those that failed.
/// It also provides the `uploadId` used to identify the multipart upload
/// operation with the server.
///
/// Example usage:
/// ```swift
/// let response = StreamUploadResponse<String, Error>(
///     completedTasks: [part1Response, part2Response],
///     failedTasks: [part3Response],
///     uploadId: "upload-12345"
/// )
///
/// ```
public struct StreamUploadResponse {
    /// Successfully uploaded parts.
    public let completedTasks: [UploadPartResponse]

    /// Parts that failed to upload.
    public let failedTasks: [UploadPartResponse]
}
