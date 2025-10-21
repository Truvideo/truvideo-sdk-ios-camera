//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A custom `URLProtocol` subclass used for mocking network requests during testing.
///
/// `URLProtocolMock` allows you to intercept and mock network requests by providing predefined responses.
/// This is particularly useful for unit testing network layers without relying on actual network calls.
///
/// Mocks are registered with associated URLs and expected HTTP methods. When a matching request is intercepted,
/// it returns the predefined response, headers, and data.
///
/// ### Example Usage:
/// ```swift
/// // Define a mock response
/// let mockData = "{\"success\": true}".data(using: .utf8)
/// let mock = Mockito(url: "https://api.example.com/test", method: .get, statusCode: 200, headers: nil, data: mockData)
///
/// // Register the mock
/// URLProtocolMock.register(mock)
///
/// // Set up a URLSession using the mock protocol
/// let config = URLSessionConfiguration.ephemeral
/// config.protocolClasses = [URLProtocolMock.self]
/// let session = URLSession(configuration: config)
///
/// // Perform a request
/// let url = URL(string: "https://api.example.com/test")!
/// let task = session.dataTask(with: url) { data, response, error in
///     guard let data = data else { return }
///     print("Mocked Response: \(String(data: data, encoding: .utf8)!)")
/// }
/// task.resume()
/// ```
final class URLProtocolMock: URLProtocol {
    // MARK: - Static Properties

    private nonisolated(unsafe) static var stubs: [String: URLMock] = [:]

    // MARK: - Types

    /// Enum representing possible errors during mock handling.
    enum MockError: Error {
        /// Error for explicitly triggered mock failure.
        case explicitMockFailure(url: String)

        /// Error thrown when mocked data for the given URL is missing.
        case missingMockedData(url: String)
    }

    // MARK: - Class methods

    /// Registers a mock for a given URL.
    ///
    /// - Parameter mock: A `URLMock` object containing the mock configuration for the request.
    class func register(_ mock: URLMock) {
        stubs[mock.url] = mock
    }

    // MARK: - URLProtocol

    /// Overrides needed to define a valid inheritance of URLProtocol.
    override class func canInit(with request: URLRequest) -> Bool {
        guard let mock = stubs[request.url?.absoluteString ?? ""] else {
            return false
        }

        return request.httpMethod == mock.method.rawValue
    }

    /// Simply sends back the passed request. Implementation is needed for a valid inheritance of URLProtocol.
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    /// Starts protocol-specific loading of a request.
    override func startLoading() {
        guard
            // The stored mock for the request
            let mock = Self.stubs[request.url?.absoluteString ?? ""],

            // The mock url
            let url = URL(string: mock.url),

            // The HTTPURLResponse
            let response = HTTPURLResponse(
                url: url,
                statusCode: mock.statusCode,
                httpVersion: "HTTP/1.1",
                headerFields: mock.headers
            )
        else {
            client?.urlProtocol(
                self,
                didFailWithError: MockError.missingMockedData(url: request.url?.absoluteString ?? "")
            )

            return
        }

        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
        if let data = mock.data {
            client?.urlProtocol(self, didLoad: data)
        }
        client?.urlProtocolDidFinishLoading(self)
    }

    /// Implementation does nothing, but is needed for a valid inheritance of URLProtocol.
    override func stopLoading() {}
}
