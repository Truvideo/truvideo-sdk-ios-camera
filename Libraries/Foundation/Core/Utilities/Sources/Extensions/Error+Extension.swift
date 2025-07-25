//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

extension Error {
    /// Converts the current error to a `FoundationError` if possible, otherwise returns a default `FoundationError`.
    ///
    /// - Parameter defaultError: A closure that produces a default NetworkError if the conversion fails
    /// - Returns: The current error as a NetworkError, or the provided default NetworkError
    func asFoundationError(or defaultError: @autoclosure () -> UtilityError) -> UtilityError {
        self as? UtilityError ?? defaultError()
    }
}
