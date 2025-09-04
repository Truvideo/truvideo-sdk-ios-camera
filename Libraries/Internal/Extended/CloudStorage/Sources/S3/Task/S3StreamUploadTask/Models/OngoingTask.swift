//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Networking

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
struct OngoingTask: Identifiable {
    let id: UUID
    
    /// The raw binary data for the video chunk being uploaded.
    let partBody: Data

    /// The sequential part number of this chunk in the multipart upload.
    let partNumber: Int

    /// The `UploadRequest` instance handling the network operation for this part.
    let task: any UploadRequest
    
    // MARK: - Initializer
    
    init(id: UUID = UUID(), partBody: Data, partNumber: Int, task: any UploadRequest) {
        self.id = id
        self.partBody = partBody
        self.partNumber = partNumber
        self.task = task
    }
}

extension OngoingTask: Equatable {
    
    // MARK: - Equatable
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
