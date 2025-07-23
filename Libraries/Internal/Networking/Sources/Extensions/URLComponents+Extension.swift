//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

extension URLComponents: URLConvertible {
    /// Converts the conforming instance into a `URL`.
    ///
    /// - Throws: An error if the conversion fails. The specific error thrown depends on the implementation.
    /// - Returns: A valid `URL` instance representing the conforming type.
    public func asURL() throws -> URL {
        guard let url, !url.absoluteString.isEmpty else {
            throw NetworkingError(kind: .invalidURL, failureReason: "Cannot convert string \(self) to URL.")
        }

        return url
    }
}
