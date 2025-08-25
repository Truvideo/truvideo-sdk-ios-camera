//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// Represents the data package required for uploading an object to Amazon S3.
///
/// This struct encapsulates all the necessary information for an S3 upload,
/// including the target bucket, object path, content type, and the raw binary data.
/// It is designed to serve as a single source of truth when initiating an upload task.
public struct S3DataPayload {
    /// The name of the S3 bucket where the object will be stored.
    public let bucket: String

    /// The MIME type of the object being uploaded.
    public let contentType: ContentType

    /// The raw binary data representing the content of the object to upload.
    public let data: Data

    /// The destination path (key) within the bucket, including directories if applicable.
    public let path: String
}
