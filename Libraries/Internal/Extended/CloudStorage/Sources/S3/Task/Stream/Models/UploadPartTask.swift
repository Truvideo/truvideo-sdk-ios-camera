//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
internal import Networking

/// Represents an ongoing upload task for a multipart stream upload.
///
/// `OngoingTask` is used to keep track of a specific upload part,
/// storing both the binary data of the video chunk being uploaded,
/// its associated part number, and the underlying `UploadRequest`
/// responsible for performing the upload.
///
/// Once the upload finishes (successfully or with failure),
/// the corresponding task can be removed from the active registry.
///
/// This helps in:
/// - Reconstructing the correct multipart upload sequence.
/// - Passing the original `Data` along to the final `UploadPartResponse`.
/// - Managing retries or error handling at the task level.
struct UploadPartTask: Identifiable {
    /// The stable identity of the entity associated with this instance.
    let id: UUID

    /// The raw binary data for the video chunk being uploaded.
    let partBody: Data

    /// The sequential part number of this chunk in the multipart upload.
    let partNumber: Int

    /// The `UploadRequest` instance handling the network operation for this part.
    let request: any UploadRequest

    // MARK: - Initializer

    /// Creates a new ongoing upload task for multipart stream upload.
    ///
    /// This initializer creates an `OngoingTask` instance that represents a single
    /// part of a multipart upload operation. It encapsulates all the necessary
    /// information needed to track, manage, and complete the upload of a specific
    /// data chunk within a larger file upload.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for this upload task (defaults to a new UUID)
    ///   - partBody: The binary data of the video chunk to be uploaded
    ///   - partNumber: The sequential number of this part in the multipart upload sequence
    ///   - request: The upload request instance that handles the network operation for this part
    init(id: UUID = UUID(), partBody: Data, partNumber: Int, request: any UploadRequest) {
        self.id = id
        self.partBody = partBody
        self.partNumber = partNumber
        self.request = request
    }
}

extension UploadPartTask: Hashable {

    // MARK: - Hashable

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    /// Hashes the essential components of this value by feeding them into the
    /// given hasher.
    ///
    /// - Parameter hasher: The hasher to use when combining the components
    ///   of this instance.
    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}
