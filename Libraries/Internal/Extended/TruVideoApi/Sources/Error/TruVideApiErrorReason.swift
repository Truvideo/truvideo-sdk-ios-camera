//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Utilities

extension ErrorReason {
    /// A collection of error reasons related to the signer.
    ///
    /// The `SignerErrorReason` struct provides a set of static constants representing various errors that can occur
    /// during interactions with the external storages.
    public struct TruVideApiErrorReason: Sendable {
        /// Error indicating that signin the context has failed.
        public static let signFailed = ErrorReason(rawValue: "SIGN_FAILED")
    }
}
