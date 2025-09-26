//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// Represents the response returned when retrieving a batch of upload parts.
///
/// This container is mainly for decoding and future extensibility. In most cases,
/// you will interact directly with the nested `Part` type, which contains the
/// presigned URL and sequence number required to upload each chunk.
struct UploadPartResponse: Codable, Sendable {
    /// The collection of uploadable parts for this batch.
    let uploadParts: [Part]
}
