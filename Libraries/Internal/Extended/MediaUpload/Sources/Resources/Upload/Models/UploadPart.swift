//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// Descriptor of an **already uploaded** part used in `register` and `complete`.
///
/// After uploading a chunk to its `presignedUrl`, storage returns an `ETag`.
public struct UploadPart: Codable, Sendable {
    /// Storage ETag returned after the successful `PUT` of this part.
    public let eTag: String

    /// Index of this part within the multipart session (1..N).
    public let partNumber: Int

    // MARK: - Initializer

    /// Creates a new uploaded-part descriptor.
    ///
    /// - Parameters:
    ///   - partNumber: The 1-based index of this part within the multipart session.
    ///   - eTag: The ETag string returned by storage for this part upload.
    public init(partNumber: Int, eTag: String) {
        self.eTag = eTag
        self.partNumber = partNumber
    }
}
