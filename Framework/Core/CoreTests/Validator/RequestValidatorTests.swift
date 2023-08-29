//
//  RequestValidatorTests.swift
//  
//  Created by TruVideo on 8/08/23.
//  Copyright © TruVideo. All rights reserved.
//

import XCTest
@testable import Core

private extension Result {
    /// Returns whether the instance is `.success`.
    var isSuccess: Bool {
        guard case .success = self else { return false }
        return true
    }
}

final class RequestValidatorTests: CoreTests {
    private let url = URL(string: "http://httpbin.org/")!

    // MARK: Overriden methods

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    // MARK: Tests

    func testThatValidatorShouldBeAnErrorWhenJSONErrorIsReturned() throws {
        // Given
        let result: Result<Void, Error>
        let response = URLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        let parameters = [
            "fault": [
                "type": "InvalidAuthorizationHeaderException",
                "message": "The request is unauthorized. In the 'Authorization' header, the 'Bearer <access token>' is expected."
            ]
        ]

        let data = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)

        // When
        result = RequestValidator.validate(request: nil, response: response, data: data)

        // Then
        switch result {
        case .failure(let error):
            guard let error = error as? RequestValidator.ErrorEntry else {
                XCTFail("Invalid error type.")
                return
            }

            XCTAssertEqual(error.fault.type, "InvalidAuthorizationHeaderException")
            XCTAssertEqual(
                error.localizedDescription,
                "The request is unauthorized. In the 'Authorization' header, the 'Bearer <access token>' is expected."
            )

            XCTAssertEqual(
                error.fault.localizedDescription,
                "The request is unauthorized. In the 'Authorization' header, the 'Bearer <access token>' is expected."
            )

            XCTAssertEqual(
                error.fault.message,
                "The request is unauthorized. In the 'Authorization' header, the 'Bearer <access token>' is expected."
            )

        case .success:
            XCTFail("Should be a failure")
        }
    }

    func testThatValidatorShouldBeASuccessIfDataIsEmpty() throws {
        // Given
        let result: Result<Void, Error>
        let response = URLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)

        // When
        result = RequestValidator.validate(request: nil, response: response, data: Data())

        // Then
        XCTAssertTrue(result.isSuccess)
    }

    func testThatValidatorShouldBeASuccessIfJSONDataIsInADifferentFormat() throws {
        // Given
        let result: Result<Void, Error>
        let response = URLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        let parameters = [
            "random": "401 UNAUTHORIZED",
            "random_message": "Token expired."
        ]

        let data = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)

        // When
        result = RequestValidator.validate(request: nil, response: response, data: data)

        // Then
        XCTAssertTrue(result.isSuccess)
    }
    
    func testThatValidatorShouldContainsArguments() throws {
        // Given
        let result: Result<Void, Error>
        let response = URLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        let parameters: [String: Any] = [
            "fault": [
                "type": "InvalidAuthorizationHeaderException",
                "message": "The request is unauthorized. In the 'Authorization' header, the 'Bearer <access token>' is expected.",
                "arguments" : [
                    "statusCode": "008"
                ]
            ] as [String : Any]
        ]

        let data = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)

        // When
        result = RequestValidator.validate(request: nil, response: response, data: data)

        // Then
        switch result {
        case .failure(let error):
            guard let error = error as? RequestValidator.ErrorEntry else {
                XCTFail("Invalid error type.")
                return
            }

            XCTAssertEqual(error.fault.type, "InvalidAuthorizationHeaderException")
            XCTAssertNotNil(error.fault.arguments)
            XCTAssertEqual(
                error.localizedDescription,
                "The request is unauthorized. In the 'Authorization' header, the 'Bearer <access token>' is expected."
            )

            XCTAssertEqual(
                error.fault.localizedDescription,
                "The request is unauthorized. In the 'Authorization' header, the 'Bearer <access token>' is expected."
            )

            XCTAssertEqual(
                error.fault.message,
                "The request is unauthorized. In the 'Authorization' header, the 'Bearer <access token>' is expected."
            )

        case .success:
            XCTFail("Should be a failure")
        }
    }
}
