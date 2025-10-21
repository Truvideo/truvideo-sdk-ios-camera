//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Networking
import Utilities

extension Error {
    /// Converts the error to a `UtilityError` with enhanced error information.
    ///
    /// - Parameter kind: The fallback error kind to use if the underlying error is not a `ResponseError`
    /// - Returns: A `UtilityError` with either enhanced information from `ResponseError` or fallback information
    func asUtilityError(or kind: ErrorReason) -> UtilityError {
        guard
            /// The networking error thrown.
            let error = self as? NetworkingError,

            /// The underlying response error.
            let underlyingError = error.underlyingError as? RequestValidator.ResponseError
        else {
            return UtilityError(kind: kind, underlyingError: self)
        }

        return UtilityError(
            kind: ErrorReason(rawValue: underlyingError.message ?? ErrorReason.unknown.rawValue),
            failureReason: underlyingError.detail
        )
    }
}
