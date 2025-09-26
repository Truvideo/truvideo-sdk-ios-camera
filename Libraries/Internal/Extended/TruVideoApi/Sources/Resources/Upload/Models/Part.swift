//
// Copyright © 2025 TruVideo. All rights reserved.
//

/// A single uploadable part from the retrieve parts response.
///
/// Each part includes the `partNumber` and its corresponding `presignedUrl`.
/// Use the `presignedUrl` to upload the chunk (HTTP PUT), and then record
/// `{ partNumber, eTag }` for the `finalize` step.
public struct Part: Codable, Sendable {
    /// Presigned URL to PUT this chunk to the storage service.
    public let presignedUrl: String

    /// The sequence number of this part (starting at 1).
    ///
    /// The order must match the one defined when the upload was initialized.
    public let partNumber: Int

    // MARK: - CodingKeys

    enum CodingKeys: String, CodingKey {
        case presignedUrl = "uploadPresignedUrl"
        case partNumber
    }
}
