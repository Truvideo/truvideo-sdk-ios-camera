//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

extension ErrorReason {
    /// A collection of error reasons related to the storage operations.
    ///
    /// The `FileWriterErrorReason` struct provides a set of static constants representing various errors that can occur
    /// during interactions with the external storages.
    public struct FileWriterErrorReason: Sendable {
        /// Error reason indicating that file removal at a specific URL failed.
        public static let removeAtURLFailed = ErrorReason(rawValue: "REMOVE_AT_URL_FAILED")

        /// Error indicating that writing to a file has failed.
        public static let writeToFileFailed = ErrorReason(rawValue: "WRITE_TO_FILE_FAILED")
    }
}
