//
//  URLProtocolMock.swift
//
//  Created by TruVideo on 8/08/23.
//  Copyright © TruVideo. All rights reserved.
//

import Foundation

@testable import Core

struct Mockito {
    /// The data which will be returned as the response based on the HTTP Method.
    let data: Data?

    /// The headers to send back with the response.
    let headers: [String: String]

    /// The http method for the mock.
    let method: HTTPMethod

    /// If set, the error that URLProtocol will report as a result rather than returning data from the mock
    let requestError: Error?

    /// The HTTP status code to return with the response.
    let statusCode: Int

    /// The URL to mock as set implicitely from the init.
    let url: String

    // MARK: Initializers

    /// Creates a `Mock` for the given URL.
    ///
    /// - Parameters:
    ///   - data: The data which will be returned as the response based on the HTTP Method.
    ///   - headers: Headers to be added to the response.
    ///   - method: The http method for the mock.
    ///   - statusCode: The HTTP status code to return with the response.
    ///   - url: The URL to match for and to return the mocked data for.
    ///   - requestError: The error that URLProtocol will report as a result rather than returning data from the mock.
    init(
        data: Data?,
        headers: [String: String],
        method: HTTPMethod,
        statusCode: Int,
        url: String,
        requestError: Error? = nil
    ) {

        self.data = data
        self.headers = headers
        self.method = method
        self.requestError = requestError
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
        url: String
    ) {

        let bundle = Bundle(for: HTTPApiClient.self)
        bundle.url(forResource: fileName, withExtension: "json")

        self.init(
            data: try? Data(contentsOf: bundle.bundleURL),
            headers: headers,
            method: method,
            statusCode: statusCode,
            url: url
        )
    }
}

class URLProtocolMock: URLProtocol {
    private static var stubs: [String: Mockito] = [:]

    enum MockError: Error {
        case explicitMockFailure(url: String)
        case missingMockedData(url: String)
    }

    // MARK: Class methods

    class func register(_ mock: Mockito) {
        stubs[mock.url] = mock
    }

    // MARK: URLProtocol

    /// Overrides needed to define a valid inheritance of URLProtocol.
    override public class func canInit(with request: URLRequest) -> Bool {
        guard let mock = Self.stubs[request.url?.absoluteString ?? ""] else {
            return false
        }

        return request.httpMethod == mock.method.rawValue
    }

    /// Simply sends back the passed request. Implementation is needed for a valid inheritance of URLProtocol.
    override public class func canonicalRequest(for request: URLRequest) -> URLRequest {
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
            ) else {

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
    override public func stopLoading() { }
}
