//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Utilities

extension ErrorReason {
    /// A collection of error reasons related to the uploader operations.
    ///
    /// The `UploaderErrorReason` struct provides a set of static constants representing various errors that can occur
    /// during interactions with the external storages.
    public struct UploaderErrorReason: Sendable {
        /// Error indicating that uploading a file has failed.
        public static let uploadFileFailed = ErrorReason(rawValue: "UPLOADING_A_FILE_FAILED")
    }
}
