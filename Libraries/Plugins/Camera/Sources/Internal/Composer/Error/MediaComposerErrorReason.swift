//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
internal import Utilities

extension ErrorReason {
    /// A collection of error reasons related to the media composer operations.
    ///
    /// The `MediaComposerErrorReason` struct provides a set of static constants representing various errors that can occur
    /// during media processing.
    struct MediaComposerErrorReason: Sendable {
        /// Indicates that the media composition operation failed.
        ///
        /// This error reason is used when the media composer encounters a failure
        /// during the composition process, such as invalid input assets, insufficient
        /// permissions, or processing errors.
        static let composeFailed = ErrorReason(rawValue: "COMPOSE_FAILED")
    }
}
