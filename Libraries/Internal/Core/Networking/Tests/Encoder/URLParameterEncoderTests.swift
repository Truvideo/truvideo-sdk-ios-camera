//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Testing

@testable import Networking

struct URLParameterEncoderTests {
    // MARK: - Tests

    @Test
    func testThatEncodeWithAutoDestinationAndDELETEHTTPMethodShouldEncodeParametersInQuery() throws {
        // Given
        let parameters = ["foo": "bar", "xyz": "abc"]
        var request = URLRequest(url: URL(string: "https://httpbin.org/")!)
        let sut = URLParameterEncoder()

        // When
        request.httpMethod = "DELETE"
        request = try sut.encode(parameters, into: request)

        // Then
        #expect(request.url?.query == "foo=bar&xyz=abc")
        #expect(request.httpBody == nil, "Expected httpBody to be nil")
        #expect(request.allHTTPHeaders["Content-Type"] == nil)
    }

    @Test
    func testThatEncodeWithAutoDestinationAndGETHTTPMethodShouldEncodeParametersInQuery() throws {
        // Given
        let parameters = ["foo": "bar", "xyz": "abc"]
        var request = URLRequest(url: URL(string: "https://httpbin.org/")!)
        let sut = URLParameterEncoder()

        // When
        request.httpMethod = "GET"
        request = try sut.encode(parameters, into: request)

        // Then
        #expect(request.url?.query == "foo=bar&xyz=abc")
        #expect(request.httpBody == nil)
        #expect(request.allHTTPHeaders["Content-Type"] == nil)
    }

    @Test
    func testThatEncodeWithAutoDestinationAndHEADHTTPMethodShouldEncodeParametersInQuery() throws {
        // Given
        let parameters = ["foo": "bar", "xyz": "abc"]
        var request = URLRequest(url: URL(string: "https://httpbin.org/")!)
        let sut = URLParameterEncoder()

        // When
        request.httpMethod = "HEAD"
        request = try sut.encode(parameters, into: request)

        // Then
        #expect(request.url?.query == "foo=bar&xyz=abc")
        #expect(request.httpBody == nil)
        #expect(request.allHTTPHeaders["Content-Type"] == nil)
    }

    @Test
    func testThatEncodeWithAutoDestinationAndPOSTHTTPMethodShouldEncodeParametersInBody() throws {
        // Given
        let parameters = ["foo": "bar", "xyz": "abc"]
        var request = URLRequest(url: URL(string: "https://httpbin.org/")!)
        let sut = URLParameterEncoder()

        // When
        request.httpMethod = "POST"
        request = try sut.encode(parameters, into: request)

        // Then
        #expect(request.url?.query == nil)
        #expect(String(data: request.httpBody!, encoding: .utf8) == "foo=bar&xyz=abc")
        #expect(request.allHTTPHeaders["Content-Type"] == "application/x-www-form-urlencoded")
    }

    @Test
    func testThatEncodeWithAutoDestinationAndPUTHTTPMethodShouldEncodeParametersInBody() throws {
        // Given
        let parameters = ["foo": "bar", "xyz": "abc"]
        var request = URLRequest(url: URL(string: "https://httpbin.org/")!)
        let sut = URLParameterEncoder()

        // When
        request.httpMethod = "PUT"
        request = try sut.encode(parameters, into: request)

        // Then
        #expect(request.url?.query == nil, "Expected url query to be equals to nil")
        #expect(String(data: request.httpBody!, encoding: .utf8) == "foo=bar&xyz=abc")
        #expect(request.allHTTPHeaders["Content-Type"] == "application/x-www-form-urlencoded")
    }

    @Test
    func testThatEncodeWithAutoDestinationAndTRACEHTTPMethodShouldEncodeParametersInBody() throws {
        // Given
        let parameters = ["foo": "bar", "xyz": "abc"]
        var request = URLRequest(url: URL(string: "https://httpbin.org/")!)
        let sut = URLParameterEncoder()

        // When
        request.httpMethod = "TRACE"
        request = try sut.encode(parameters, into: request)

        // Then
        #expect(request.url?.query == nil, "Expected url query to be equals to nil")
        #expect(String(data: request.httpBody!, encoding: .utf8) == "foo=bar&xyz=abc")
        #expect(request.allHTTPHeaders["Content-Type"] == "application/x-www-form-urlencoded")
    }

    @Test
    func testThatEncodeWithAutoDestinationAndOPTIONSHTTPMethodShouldEncodeParametersInBody() throws {
        // Given
        let parameters = ["foo": "bar", "xyz": "abc"]
        var request = URLRequest(url: URL(string: "https://httpbin.org/")!)
        let sut = URLParameterEncoder()

        // When
        request.httpMethod = "OPTIONS"
        request = try sut.encode(parameters, into: request)

        // Then
        #expect(request.url?.query == nil, "Expected url query to be equals to nil")
        #expect(String(data: request.httpBody!, encoding: .utf8) == "foo=bar&xyz=abc")
        #expect(request.allHTTPHeaders["Content-Type"] == "application/x-www-form-urlencoded")
    }

    @Test
    func testThatEncodeShouldNotEncodeIfParametersAreNil() throws {
        // Given
        var request = URLRequest(url: URL(string: "https://httpbin.org/")!)
        let sut = URLParameterEncoder()

        // When
        request = try sut.encode(nil, into: request)

        // Then
        #expect(request.url?.query == nil)
        #expect(request.httpBody == nil)
        #expect(request.allHTTPHeaders["Content-Type"] == nil)
    }

    @Test
    func testThatEncodeWithBodyDestinationShouldEncodeParametersInBody() throws {
        // Given
        let parameters = ["foo": "bar", "xyz": "abc"]
        var request = URLRequest(url: URL(string: "https://httpbin.org/")!)
        let sut = URLParameterEncoder(destination: .body)

        // When
        request.httpMethod = "GET"
        request = try sut.encode(parameters, into: request)

        // Then
        #expect(request.url?.query == nil, "Expected url query to be equals to nil")
        #expect(String(data: request.httpBody!, encoding: .utf8) == "foo=bar&xyz=abc")
        #expect(request.allHTTPHeaders["Content-Type"] == "application/x-www-form-urlencoded")
    }

    @Test
    func testThatEncodeWithQueryDestinationShouldEncodeParametersInQuery() throws {
        // Given
        let parameters = ["foo": "bar", "xyz": "abc"]
        var request = URLRequest(url: URL(string: "https://httpbin.org/")!)
        let sut = URLParameterEncoder(destination: .query)

        // When
        request.httpMethod = "POST"
        request = try sut.encode(parameters, into: request)

        // Then
        #expect(request.url?.query == "foo=bar&xyz=abc")
        #expect(request.httpBody == nil)
        #expect(request.allHTTPHeaders["Content-Type"] == nil)
    }

    @Test
    func testThatEncodeComplexParametersInURL() throws {
        // Given
        var request = URLRequest(url: URL(string: "https://httpbin.org/")!)
        let sut = URLParameterEncoder()
        let expectedQuery = "array%5B0%5D=value&array%5B1%5D=value1&dictionary%5Bkey%5D=false&foo=bar&xyz=abc"
        let parameters: Parameters = [
            "foo": "bar",
            "xyz": "abc",
            "array": [
                "value",
                "value1"
            ],
            "dictionary": [
                "key": false
            ]
        ]

        // When
        request = try sut.encode(parameters, into: request)

        // Then
        #expect(request.url?.query == expectedQuery)
        #expect(request.httpBody == nil)
        #expect(request.allHTTPHeaders["Content-Type"] == nil)
    }

    @Test
    func testThatEncodeComplexParametersInBody() throws {
        // Given
        var request = URLRequest(url: URL(string: "https://httpbin.org/")!)
        let sut = URLParameterEncoder(destination: .body)
        let expectedBody = "another=1&array[0]=value&array[1]=value1&dictionary[key]=true&foo=bar&xyz=abc"
        let parameters: Parameters = [
            "foo": "bar",
            "xyz": "abc",
            "another": 1,
            "array": [
                "value",
                "value1"
            ],
            "dictionary": [
                "key": true
            ]
        ]

        // When
        request = try sut.encode(parameters, into: request)

        // Thenanother
        #expect(request.url?.query == nil)
        #expect(String(data: request.httpBody!, encoding: .utf8) == expectedBody)
        #expect(request.allHTTPHeaders["Content-Type"] == "application/x-www-form-urlencoded")
    }

    @Test
    func testThatUrlStaticProperty() {
        // Given, When, Then
        #expect(URLParameterEncoder.url != nil, "Expected to not be nil")
    }
}
