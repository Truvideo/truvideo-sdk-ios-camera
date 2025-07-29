//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Utilities

extension ErrorReason {
    /// A collection of error reasons related to the file writer.
    ///
    /// The `FileWriterErrorReason` struct provides a set of static constants representing various errors that can occur
    /// during interactions with external storages.
    public struct FileWriterErrorReason: Sendable {
        /// Error indicating that writing the file has failed.
        public static let writeFailed = ErrorReason(rawValue: "WRITE_FAILED")
    }

    /// A collection of error reasons related to the uploader operations.
    ///
    /// The `UploaderErrorReason` struct provides a set of static constants representing various errors that can occur
    /// during interactions with external storages.
    public struct UploaderErrorReason: Sendable {
        /// Error indicating that uploading a file has failed.
        public static let uploadFileFailed = ErrorReason(rawValue: "UPLOADING_A_FILE_FAILED")
    }
}
