//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Networking

/// A structure used to define mock HTTP responses for testing network requests.
///
/// `URLMock` allows you to simulate HTTP responses for specific URLs and HTTP methods.
/// This is particularly useful for unit testing network layers without making real network requests.
///
/// You can define the HTTP response data, status code, headers, and simulate network errors.
///
/// ### Example Usage:
/// ```swift
/// // Creating mock data
/// let mockData = "{\"success\": true}".data(using: .utf8)
///
/// // Initializing a mock response
/// let mock = URLMock(
///     data: mockData,
///     headers: ["Content-Type": "application/json"],
///     method: .get,
///     statusCode: 200,
///     url: "https://api.example.com/test"
/// )
///
/// // Using the mock in tests
/// URLProtocolMock.register(mock)
/// ```
struct URLMock {
    /// The data which will be returned as the response based on the HTTP Method.
    let data: Data?

    /// The headers to send back with the response.
    let headers: [String: String]

    /// The http method for the mock.
    let method: HTTPMethod

    /// The HTTP status code to return with the response.
    let statusCode: Int

    /// The URL to mock as set implicitely from the init.
    let url: String

    // MARK: - Initializers

    /// Creates a `Mock` for the given URL.
    ///
    /// - Parameters:
    ///   - data: The data which will be returned as the response based on the HTTP Method.
    ///   - headers: Headers to be added to the response.
    ///   - method: The http method for the mock.
    ///   - statusCode: The HTTP status code to return with the response.
    ///   - url: The URL to match for and to return the mocked data for.
    init(
        data: Data?,
        headers: [String: String],
        method: HTTPMethod,
        statusCode: Int,
        url: String
    ) {
        self.data = data
        self.headers = headers
        self.method = method
        self.statusCode = statusCode
        self.url = url
    }

    /// Creates a `Mock` for the given URL with the response data from
    /// the given file name.
    ///
    /// - Parameters:
    ///   - fileName: The name of the json file containing the response to use.
    ///   - headers: Headers to be added to the response.
    ///   - method: The http method for the mock.
    ///   - statusCode: The HTTP status code to return with the response.
    ///   - url: The URL to match for and to return the mocked data for.
    ///   - requestError: The error that URLProtocol will report as a result rather than returning data from the mock.
    init(
        fileName: String,
        headers: [String: String],
        method: HTTPMethod,
        statusCode: Int,
        url: String,
        bundle: Bundle
    ) {
        guard let resourceURL = bundle.url(forResource: fileName, withExtension: "json") else {
            fatalError("Resource not found.")
        }

        self.init(
            data: try? Data(contentsOf: resourceURL),
            headers: headers,
            method: method,
            statusCode: statusCode,
            url: url
        )
    }
}
