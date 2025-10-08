//
// Copyright © 2025 TruVideo. All rights reserved.
//

/// A single uploadable part from the retrieve parts response.
///
/// Each part includes the `partNumber` and its corresponding `presignedUrl`.
/// Use the `presignedUrl` to upload the chunk (HTTP PUT), and then record
/// `{ partNumber, eTag }` for the `finalize` step.
public struct Part: Codable, Sendable {
    /// Expiration of the presigned URL. After this time, the URL is no longer valid.
    public let expiresAt: String

    /// Presigned URL to upload this chunk (HTTP `PUT`) directly to storage.
    public let presignedUrl: String
}
