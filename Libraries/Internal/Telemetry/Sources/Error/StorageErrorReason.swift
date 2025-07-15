//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Utilities

extension ErrorReason {
    /// A collection of error reasons related to the storage operations.
    ///
    /// The `StorageErrorReason` struct provides a set of static constants representing various errors that can occur
    /// during interactions with the external storages.
    public struct StorageErrorReason: Sendable {
        /// Error indicating that clearing the storage has failed.
        public static let clearFailed = ErrorReason(rawValue: "STORAGE_CLEAR_FAILED")

        /// Error indicating that deleting a value from the storage has failed.
        public static let deleteFailed = ErrorReason(rawValue: "STORAGE_DELETION_FAILED")

        /// Error indicating that reading a value from the storage has failed.
        public static let readValueFailed = ErrorReason(rawValue: "STORAGE_READ_FAILED")

        /// Error indicating that writing a value to the storage has failed.
        public static let writeFailed = ErrorReason(rawValue: "STORAGE_WRITE_FAILED")
    }
}
