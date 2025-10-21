//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Testing

@testable import Networking

struct DataResponseSerializerTests {
    // MARK: - Properties

    private let url = URL(string: "https://httpbin.org/")!

    // MARK: - Tests

    @Test
    func testThatSerializeShouldReturnValidData() throws {
        // Given
        let data = "Foo".data(using: .utf8)
        let sut = DataResponseSerializer()

        // When
        let serializedObject = try sut.serialize(request: nil, response: nil, data: data, error: nil)

        // Then
        #expect(serializedObject == data)
    }

    @Test
    func testThatSerializeShouldReturnDataOnCustomEmptyResponseCodes() throws {
        // Given
        let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)
        let sut = DataResponseSerializer(emptyResponseCodes: [500])

        // When
        let serializedObject = try sut.serialize(request: nil, response: response, data: nil, error: nil)

        // Then
        #expect(serializedObject == Data())
    }

    @Test
    func testThatSerializeShouldThrowAnErrorIfSentErrorIsNotNil() throws {
        // Given
        let error = NetworkingError(kind: .explicitlyCancelled)
        let sut = DataResponseSerializer()

        // When, Then
        #expect(throws: Error.self) {
            try sut.serialize(request: nil, response: nil, data: nil, error: error)
        }
    }

    @Test
    func testThatSerializeShouldThrowAnErrorIfDataIsEmptyAndStatusCodeIsNotAllowed() throws {
        // Given
        let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)
        let sut = DataResponseSerializer()

        // When, Then
        #expect {
            try sut.serialize(request: nil, response: response, data: nil, error: nil)
        } throws: { error in
            guard let error = error as? NetworkingError else {
                return false
            }

            return error.kind == .responseSerializationFailed
        }
    }

    @Test
    func testThatSerializeShouldThrowAnErrorIfDataIsEmptyWithCustomEmptyResponseCodes() throws {
        // Given
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        let sut = DataResponseSerializer(emptyResponseCodes: [500])

        // When, Then
        #expect {
            try sut.serialize(request: nil, response: response, data: nil, error: nil)
        } throws: { error in
            guard let error = error as? NetworkingError else {
                return false
            }

            return error.kind == .responseSerializationFailed
        }
    }
}
