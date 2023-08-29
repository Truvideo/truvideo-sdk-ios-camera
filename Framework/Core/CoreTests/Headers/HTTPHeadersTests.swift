//
//  HTTPHeadersTests.swift
//
//  Created by TruVideo on 8/08/23.
//  Copyright © TruVideo. All rights reserved.
//

import XCTest
@testable import Core

class HTTPHeadersTests: CoreTests {

    // MARK: Tests

    func testHeadersAreStoreUniquelyFromArray() {
        // Given
        let sut = HTTPHeaders(array: [
            HTTPHeader(name: "key", value: "foo"),
            HTTPHeader(name: "Key", value: "foo"),
            HTTPHeader(name: "KEY", value: "foo")
        ])

        // When, Then
        XCTAssertEqual(sut.count, 1)
    }

    func testHeadersAreStoreUniquelyFromArrayLiteral() {
        // Given
        let sut: HTTPHeaders = [
            HTTPHeader(name: "key", value: "foo"),
            HTTPHeader(name: "Key", value: "foo"),
            HTTPHeader(name: "KEY", value: "foo")
        ]

        // When, Then
        XCTAssertEqual(sut.count, 1)
    }

    func testHeadersAreStoreUniquelyFromDictionaryLiteral() {
        // Given
        let sut: HTTPHeaders = ["key": "foo", "Key": "foo", "KEY": "foo"]

        // When, Then
        XCTAssertEqual(sut.count, 1)
    }

    func testHeadersAreStoreUniquelyFromDictionary() {
        // Given
        let sut = HTTPHeaders(dictionary: ["key": "foo", "Key": "foo", "KEY": "foo"])

        // When, Then
        XCTAssertEqual(sut.count, 1)
    }

    func testHeadersCanSetAndGetCaseInsentitiveBySubscript() {
        // Given
        var sut = HTTPHeaders()

        // When
        sut["key"] = "foo"

        // Then
        XCTAssertEqual(sut["Key"], "foo")
    }

    func testThatRetrieveByIndex() {
        // Given
        let sut = HTTPHeaders(dictionary: ["key": "foo", "Key2": "foo2", "KEY3": "foo3"])

        // When
        let secondHeader = sut[2]
        let thirdHeader = sut[""]

        // Then
        XCTAssertEqual(sut.count, 3)
        XCTAssertNotNil(secondHeader)
        XCTAssertNil(thirdHeader)
        XCTAssertEqual(sut.makeIterator().first {$0.name == "key"}?.value, "foo")
    }

    func testThatSetHeader() {
        // Given
        var sut = HTTPHeaders(dictionary: ["key": "foo", "Key2": "foo2", "KEY3": "foo3"])

        // When
        sut.setHeader("bar", forKey: "key")
        sut.setHeader("bar", forKey: "bar")

        // Then
        XCTAssertEqual(sut.count, 4)
        XCTAssertEqual(sut.makeIterator().first {$0.name == "key"}?.value, "bar")
        XCTAssertEqual(sut.makeIterator().first {$0.name == "bar"}?.value, "bar")
    }

    func testThatRemoveHeader() {
        // Given
        var sut = HTTPHeaders(dictionary: ["key": "foo", "Key2": "foo2", "KEY3": "foo3"])

        // When
        sut.removeHeader(forKey: "key")
        sut.removeHeader(forKey: "")

        // Then
        XCTAssertEqual(sut.count, 2)
        XCTAssertEqual(sut.makeIterator().first {$0.name == "Key2"}?.value, "foo2")
        XCTAssertEqual(sut.makeIterator().first {$0.name == "KEY3"}?.value, "foo3")
    }

    func testThatAppend() {
        // Given
        var sut = HTTPHeaders(dictionary: ["key": "foo", "Key2": "foo2", "KEY3": "foo3"])

        // When
        sut.append(HTTPHeader(name: "foo", value: "bar"))

        // Then
        XCTAssertEqual(sut.count, 4)
        XCTAssertEqual(sut.makeIterator().first {$0.name == "foo"}?.value, "bar")
    }

    func testThatContentType() {
        // Given
        let sut = HTTPHeader.contentType("foo")

        // When, Then
        XCTAssertEqual(sut.name, "Content-Type")
    }

    func testThatBearerToken() {
        // Given
        let sut = HTTPHeader.bearerToken("token")

        // When, Then
        XCTAssertEqual(sut.name, "Authorization")
        XCTAssertEqual(sut.value, "Bearer token")
    }

    func testThatAuthorization() {
        // Given
        let sut = HTTPHeader.authorization("foo")

        // When, Then
        XCTAssertEqual(sut.name, "Authorization")
    }
}
