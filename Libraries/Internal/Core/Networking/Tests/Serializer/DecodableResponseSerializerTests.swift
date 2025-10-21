//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Testing

@testable import Networking

struct DecodableResponseSerializerTests {
    // MARK: - Properties

    private let url = URL(string: "https://httpbin.org/")!

    // MARK: - Tests

    @Test
    func testThatSerializeShouldReturnAValidObject() throws {
        // Given
        let test = Test(name: "foo")
        let sut = DecodableResponseSerializer<Test>()

        // When
        let serializedObject = try sut.serialize(
            request: nil,
            response: nil,
            data: JSONEncoder().encode(test),
            error: nil
        )

        // Then
        #expect(serializedObject == test)
    }

    @Test
    func testThatSerializeShouldReturnEmptyOnCustomEmptyResponseCodes() throws {
        // Given
        let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)
        let sut = DecodableResponseSerializer<Empty>(emptyResponseCodes: [500])

        // When
        let serializedObject = try sut.serialize(request: nil, response: response, data: nil, error: nil)

        // Then
        #expect(serializedObject == Empty.value)
    }

    @Test
    func testThatSerializeShouldThrowAnErrorIfSentErrorIsNotNil() throws {
        // Given
        let error = NetworkingError(kind: .explicitlyCancelled)
        let sut = DecodableResponseSerializer<Test>()

        // When, Then
        #expect(throws: Error.self) {
            try sut.serialize(request: nil, response: nil, data: nil, error: error)
        }
    }

    @Test
    func testThatSerializeShouldThrowAnErrorIfDataIsEmptyAndStatusCodeIsNotAllowed() throws {
        // Given
        let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)
        let sut = DecodableResponseSerializer<Test>()

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
        let sut = DecodableResponseSerializer<Test>(emptyResponseCodes: [500])

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
    func testThatSerializeShouldThrowAnErrorIfExpectedTypeIsNotValidForAnEmptyValue() throws {
        // Given
        let response = HTTPURLResponse(url: url, statusCode: 204, httpVersion: nil, headerFields: nil)
        let sut = DecodableResponseSerializer<Test>()

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
    func testThatSerializeShouldThrowAnErrorIfDecoderIsNotAbleToDeserializeTheData() throws {
        // Given
        let data = "Foo".data(using: .utf8)
        let sut = DecodableResponseSerializer<Test>()

        // When, Then
        #expect {
            try sut.serialize(request: nil, response: nil, data: data, error: nil)
        } throws: { error in
            guard let error = error as? NetworkingError else {
                return false
            }

            return error.kind == .responseSerializationFailed
        }
    }
}

private struct Test: Codable, Equatable {
    let name: String
}
