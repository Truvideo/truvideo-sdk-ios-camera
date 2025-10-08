//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// Context returned when initializing a multipart media upload.
///
/// This model is produced by the initialize endpoint and contains the unique
/// `uploadId` and the list of parts to upload. Each part includes a presigned
/// URL that must be used to PUT the corresponding chunk directly to storage.
public struct UploadSession: Codable, Sendable {
    /// The unique identifier of the multipart upload, received during initialization.
    public let uploadId: String

    /// The identifier of the media resource associated with this upload.
    public let mediaId: String
}
