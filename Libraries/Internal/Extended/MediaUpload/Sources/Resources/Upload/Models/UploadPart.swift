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
    ///   - eTag: The ETag string returned by storage for this part upload.
    ///   - partNumber: The 1-based index of this part within the multipart session.
    public init(eTag: String, partNumber: Int) {
        self.eTag = eTag
        self.partNumber = partNumber
    }
}
