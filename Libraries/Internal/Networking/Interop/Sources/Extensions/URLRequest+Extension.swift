//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

extension URLRequest {
    /// Returns the `HTTPHeaders` representation.
    public var allHTTPHeaders: HTTPHeaders {
        get {
            allHTTPHeaderFields.map(HTTPHeaders.init) ?? .init()
        }

        set {
            allHTTPHeaderFields = newValue.dictionary
        }
    }

    /// The HTTP method associated with the request, represented as an `HTTPMethod` enum.
    public var method: HTTPMethod {
        guard let httpMethod, !httpMethod.isEmpty else {
            return .get
        }

        return HTTPMethod(rawValue: httpMethod)
    }

    // MARK: - Public methods

    /// Creates an instance with the specified `url`, `method`, and `headers`.
    ///
    /// - Parameters:
    ///   - url:     The `URLConvertible` value.
    ///   - method:  The `HTTPMethod`.
    ///   - headers: The `HTTPHeaders`, `nil` by default.
    /// - Throws:    Any error thrown while converting the `URLConvertible` to a `URL`.
    public init(url: URLConvertible, method: HTTPMethod, headers: HTTPHeaders? = nil) throws {
        let url = try url.asURL()

        self.init(url: url)

        httpMethod = method.rawValue
        allHTTPHeaderFields = headers?.dictionary
    }
}
