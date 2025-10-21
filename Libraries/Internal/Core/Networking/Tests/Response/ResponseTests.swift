//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Testing

@testable import Networking

struct ResponseTests {
    // MARK: - Properties

    private let url = URL(string: "https://httpbin.org/")!
    private var request: URLRequest {
        var request = URLRequest(url: url)
        request.httpBody = "Test".data(using: .utf8)

        return request
    }

    // MARK: - Tests

    @Test
    func testThatResponseShouldHasAnError() throws {
        // Given
        let error = NetworkingError(kind: .parameterEncodingFailed)
        let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)
        let sut = Response<Void, NetworkingError>(
            data: Data(),
            metrics: nil,
            request: nil,
            response: response,
            result: .failure(error),
            type: .networkLoad
        )

        // When, Then
        #expect(sut.data != nil)
        #expect(!sut.debugDescription.isEmpty)
        #expect(sut.error?.kind == .parameterEncodingFailed)
        #expect(sut.metrics == nil)
        #expect(sut.request == nil)
        #expect(sut.value == nil)
        #expect(sut.type == .networkLoad)
    }

    @Test
    func testThatResponseShouldHasAValue() throws {
        // Given
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        let sut = Response<String, Error>(
            data: Data(),
            metrics: nil,
            request: request,
            response: response,
            result: .success("Test"),
            type: .networkLoad
        )

        // When, Then
        #expect(sut.data != nil)
        #expect(sut.description == "success(\"Test\")")
        #expect(!sut.debugDescription.isEmpty)
        #expect(sut.error == nil)
        #expect(sut.metrics == nil)
        #expect(sut.request != nil)
        #expect(sut.type == .networkLoad)
        #expect(sut.value == "Test")
    }

    @Test
    func testThatMapTransformsSuccessValue() {
        // Given
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        let sut = Response<String, Error>(
            data: Data(),
            metrics: nil,
            request: request,
            response: response,
            result: .success("Test"),
            type: .localCache
        )

        // When
        let newResponse = sut.map { _ in "new value" }

        // Then
        #expect(newResponse.data != nil)
        #expect(newResponse.description == "success(\"new value\")")
        #expect(!newResponse.debugDescription.isEmpty)
        #expect(newResponse.error == nil)
        #expect(newResponse.metrics == nil)
        #expect(newResponse.request != nil)
        #expect(sut.type == .localCache)
        #expect(newResponse.value == "new value")
    }
}
