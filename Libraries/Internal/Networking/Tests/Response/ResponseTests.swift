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

    @Test func testThatResponseShouldHasAnError() throws {
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
        #expect(sut.data != nil, "Expected data to not be nil")
        #expect(!sut.debugDescription.isEmpty, "Expected debug description to not be empty")
        #expect(sut.error?.kind == .parameterEncodingFailed, "Expected kind to be equals to parameterEncodingFailed")
        #expect(sut.metrics == nil, "Expected metrics to be nil")
        #expect(sut.request == nil, "Expected request to be nil")
        #expect(sut.value == nil, "Expected value to be nil")
        #expect(sut.type == .networkLoad, "Expected type to be equals to networkLoad")
    }

    @Test func testThatResponseShouldHasAValue() throws {
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
        #expect(sut.data != nil, "Expected data to not be nil")
        #expect(sut.description == "success(\"Test\")", "Expected description to be equals to success(\"Test\")")
        #expect(!sut.debugDescription.isEmpty, "Expected debug description to not be empty")
        #expect(sut.error == nil, "Expected error to be equals to nil")
        #expect(sut.metrics == nil, "Expected metrics to be nil")
        #expect(sut.request != nil, "Expected request to not be nil")
        #expect(sut.type == .networkLoad, "Expected type to be equals to networkLoad")
        #expect(sut.value == "Test", "Expected value to be equals to Test")
    }
    
    @Test func testThatMapTransformsSuccessValue() {
        // Given
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        let sut =  Response<String, Error>(
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
        #expect(newResponse.data != nil, "Expected data to not be nil")
        #expect(
            newResponse.description == "success(\"new value\")",
            "Expected description to be equals to success(\"new value\")"
        )
        #expect(!newResponse.debugDescription.isEmpty, "Expected debug description to not be empty")
        #expect(newResponse.error == nil, "Expected error to be equals to nil")
        #expect(newResponse.metrics == nil, "Expected metrics to be nil")
        #expect(newResponse.request != nil, "Expected request to not be nil")
        #expect(sut.type == .localCache, "Expected type to be equals to localCache")
        #expect(newResponse.value == "new value", "Expected value to be equals to new value")
    }
}
