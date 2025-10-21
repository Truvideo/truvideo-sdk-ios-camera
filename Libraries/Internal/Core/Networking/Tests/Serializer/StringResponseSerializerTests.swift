//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Testing

@testable import Networking

struct StringResponseSerializerTests {
    // MARK: - Properties

    private let url = URL(string: "https://httpbin.org/")!

    // MARK: - Tests

    @Test
    func testThatSerializeShouldReturnAValidString() throws {
        // Given
        let data = "Foo".data(using: .utf8)
        let sut = StringResponseSerializer()

        // When
        let serializedObject = try sut.serialize(request: nil, response: nil, data: data, error: nil)

        // Then
        #expect(serializedObject == "Foo")
    }

    @Test
    func testThatSerializeShouldReturnAStringOnCustomEmptyResponseCodes() throws {
        // Given
        let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)
        let sut = StringResponseSerializer(emptyResponseCodes: [500])

        // When
        let serializedObject = try sut.serialize(request: nil, response: response, data: nil, error: nil)

        // Then
        #expect(serializedObject == "")
    }

    @Test
    func testThatSerializeShouldThrowAnErrorIfSentErrorIsNotNil() throws {
        // Given
        let error = NetworkingError(kind: .explicitlyCancelled)
        let sut = StringResponseSerializer()

        // When, Then
        #expect(throws: Error.self) {
            try sut.serialize(request: nil, response: nil, data: nil, error: error)
        }
    }

    @Test
    func testThatSerializeShouldThrowAnErrorIfDataIsEmptyAndStatusCodeIsNotAllowed() throws {
        // Given
        let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)
        let sut = StringResponseSerializer()

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
        let sut = StringResponseSerializer(emptyResponseCodes: [500])

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
    func testThatSerializeShouldThrowAnErrorOnInvalidUTF8StringData() throws {
        // Given
        let data = Data([0xD8, 0x00])
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        let sut = StringResponseSerializer(emptyResponseCodes: [500])

        // When, Then
        #expect {
            try sut.serialize(request: nil, response: response, data: data, error: nil)
        } throws: { error in
            guard let error = error as? NetworkingError else {
                return false
            }

            return error.kind == .responseSerializationFailed
        }
    }
}
