//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Utilities

extension ErrorReason {
    /// A struct that defines common core-data-related error reasons.
    public enum CoreDataKitErrorReason {
        /// A predefined error reason indicating the failure of model initialization within the TruVideo Foundation.
        ///
        /// This static constant represents a specific error reason that occurs when the initialization of a model
        /// fails.
        /// It uses the `ErrorReason` type and is identified by a unique error code.
        public static let failedModelInitialization = ErrorReason(rawValue: "FAILED_MODEL_INITIALIZATION")

        /// This error occurs when attempting to work with an invalid or non-existent Core Data entity name.
        public static let invalidEntityName = ErrorReason(rawValue: "INVALID_ENTITY_NAME")
    }
}
