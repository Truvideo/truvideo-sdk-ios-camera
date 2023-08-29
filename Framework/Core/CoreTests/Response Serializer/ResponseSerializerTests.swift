//
//  ResponseSerializerTests.swift
//
//  Created by TruVideo on 8/08/23.
//  Copyright © TruVideo. All rights reserved.
//

import XCTest

@testable import Core

final class ResponseSerializerTests: CoreTests {

    // MARK: Overriden methods
    
    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    // MARK: Tests

    func createResponse() -> HTTPURLResponse {
        return HTTPURLResponse(
            url: URL(string: "https://www.example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
    }

    func testSerializeWithData() {
        // Given
        let data = Data("Hello, world!".utf8)
        let response = createResponse()

        // When
        let serializer: (URLRequest?, HTTPURLResponse?, Data?, Error?) throws -> String = { _, _, _, _ in
            return "CustomSerializedObject"
        }
        
        let responseSerializer = ResponseSerializer(serializer)
        let result = try? responseSerializer.serialize(request: nil, response: response, data: data, error: nil)

        // Then
        XCTAssertEqual(result, "CustomSerializedObject")
    }
}
