//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Utilities

extension ErrorReason {
    /// A collection of error reasons related to the storage operations.
    ///
    /// The `TelemetryErrorReason` struct provides a set of static constants representing various errors that can occur
    /// during interactions with the external storages.
    public struct TelemetryErrorReason: Sendable {
        /// Error indicating that clearing the storage has failed.
        public static let clearStorageFailed = ErrorReason(rawValue: "CLEAR_STORAGE_FAILED")

        /// Error indicating that deleting a value from the storage has failed.
        public static let deleteFromStorageFailed = ErrorReason(rawValue: "DELETE_FROM_STORAGE_FAILED")

        /// Error indicating that reading a value from the storage has failed.
        public static let readValueFromStorageFailed = ErrorReason(rawValue: "READ_VALUE_FROM_STORAGE_FAILED")

        /// Error indicating that uploading a file has failed.
        public static let uploadFileFailed = ErrorReason(rawValue: "UPLOADING_A_FILE_FAILED")

        /// Error indicating that writing a value to the storage has failed.
        public static let writeToStorageFailed = ErrorReason(rawValue: "WRITE_TO_STORAGE_FAILED")
    }
}
