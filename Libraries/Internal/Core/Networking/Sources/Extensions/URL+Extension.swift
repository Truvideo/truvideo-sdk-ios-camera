//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

extension URL: URLConvertible {
    /// Converts the conforming instance into a `URL`.
    ///
    /// - Throws: An error if the conversion fails. The specific error thrown depends on the implementation.
    /// - Returns: A valid `URL` instance representing the conforming type.
    public func asURL() throws -> URL {
        self
    }
}
