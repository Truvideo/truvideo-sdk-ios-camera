//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

extension Optional {
    /// Unwraps the optional value or returns an error.
    ///
    /// - Parameter error: A closure to use when the value is nil.
    /// - Returns: The `WrappedType`.
    public func unwrap(or error: @autoclosure () -> Error) throws -> Wrapped {
        switch self {
        case .none:
            throw error()

        case let .some(wrapped):
            return wrapped
        }
    }
}
