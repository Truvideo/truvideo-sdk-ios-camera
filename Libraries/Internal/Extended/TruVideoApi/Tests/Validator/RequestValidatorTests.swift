//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Testing
import Utilities

@testable import TruVideoApi

struct RequestValidatorTests {
    // MARK: - Private Properties

    private let response = HTTPURLResponse(
        url: URL(string: "https://api.example.com")!,
        statusCode: 400,
        httpVersion: nil,
        headerFields: nil
    )!

    // MARK: - Tests

    @Test
    func testThatValidateWithEmptyDataDoesNotThrowAnError() throws {
        // Given, When, Then
        try RequestValidator.validate(request: nil, response: response, data: Data())
    }

    @Test
    func testThatValidateWithNilDataDoesNotThrowAnError() throws {
        // Given, When, Then
        try RequestValidator.validate(request: nil, response: response, data: nil)
    }

    @Test
    func testThatValidateWithValidErrorResponseThrowsAnUtilityError() throws {
        // Given
        let data = """
        {
            "type": "about:blank",
            "title": "Unsupported Media Type",
            "message": "error.invalidApiKey",
            "status": 415,
            "detail": "not supported.",
            "instance": "/api/device"
        } 
        """.data(using: .utf8)!

        // When, Then
        #expect {
            try RequestValidator.validate(request: nil, response: response, data: data)
        } throws: { error in
            let error = error as! RequestValidator.ResponseError

            return error.detail == "not supported." && error.message == "error.invalidApiKey"
        }
    }

    @Test
    func testThatValidateWithInvalidJSONDoesNotThrowAnError() throws {
        // Given
        let data = "invalid json data".data(using: .utf8)!

        // When, Then
        try RequestValidator.validate(request: nil, response: response, data: data)
    }

    @Test
    func testThatValidateWithNonStringDetailFieldDoesNotThrow() throws {
        // Given
        let data = """
        {
            "detail": 123,
            "message": "INVALID_API_KEY"
        }
        """.data(using: .utf8)!

        // When, Then
        try RequestValidator.validate(request: nil, response: response, data: data)
    }

    @Test
    func testThatValidateShouldPassIfStatusCodeIsValid() throws {
        // Given
        let response = HTTPURLResponse(
            url: URL(string: "https://api.example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        let data = """
        {
            "type": "about:blank",
            "title": "Unsupported Media Type",
            "message": "error.invalidApiKey",
            "status": 415,
            "detail": "not supported.",
            "instance": "/api/device"
        } 
        """.data(using: .utf8)!

        // When, Then
        try RequestValidator.validate(request: nil, response: response, data: data)
    }
}
