//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Networking

/// A mock implementation of the `RequestBuilder` protocol for testing.
public struct RequestBuilderMock: RequestBuilder {
    // MARK: - Private Properties

    private let path: String

    // MARK: - Initializer

    /// Creates a new instance of the `RequestBuilder`.
    public init(path: String = "") {
        self.path = path
    }

    // MARK: - RequestBuilder

    /// Builds and returns a configured `URLRequest` instance.
    ///
    /// This method should be implemented by conforming types to provide the necessary logic for constructing
    /// a valid HTTP request. The request should include all necessary details such as the URL, HTTP method,
    /// headers, query parameters, and body content.
    ///
    /// - Throws: An error if the request cannot be constructed. This may occur due to invalid URL components,
    /// serialization issues, or missing required fields.
    /// - Returns: A fully configured `URLRequest` instance ready for execution.
    public func build() throws -> URLRequest {
        try URLRequest(url: "https://httpbin.org" + path, method: .get)
    }
}
