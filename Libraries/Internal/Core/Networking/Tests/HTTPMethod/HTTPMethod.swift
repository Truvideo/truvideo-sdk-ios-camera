//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Testing

@testable import Networking

struct HTTPMethodTests {
    // MARK: - Tests

    @Test
    func testThatHTTPMethodInitialization() {
        // Given
        let sut = HTTPMethod(rawValue: "foo")

        // When, Then
        #expect(sut.rawValue == "foo")
    }

    @Test
    func testThatDeletetHTTPMethod() {
        // Given
        let sut = HTTPMethod.delete

        // When, Then
        #expect(sut.rawValue == "DELETE")
    }

    @Test
    func testThatGetHTTPMethod() {
        // Given
        let sut = HTTPMethod.get

        // When, Then
        #expect(sut.rawValue == "GET")
    }

    @Test
    func testThatHeadHTTPMethod() {
        // Given
        let sut = HTTPMethod.head

        // When, Then
        #expect(sut.rawValue == "HEAD")
    }

    @Test
    func testThatOptionsHTTPMethod() {
        // Given
        let sut = HTTPMethod.options

        // When, Then
        #expect(sut.rawValue == "OPTIONS")
    }

    @Test
    func testThatPatchHTTPMethod() {
        // Given
        let sut = HTTPMethod.patch

        // When, Then
        #expect(sut.rawValue == "PATCH")
    }

    @Test
    func testThatPostHTTPMethod() {
        // Given
        let sut = HTTPMethod.post

        // When, Then
        #expect(sut.rawValue == "POST")
    }

    @Test
    func testThatPutHTTPMethod() {
        // Given
        let sut = HTTPMethod.put

        // When, Then
        #expect(sut.rawValue == "PUT")
    }

    @Test
    func testThatTraceHTTPMethod() {
        // Given
        let sut = HTTPMethod.trace

        // When, Then
        #expect(sut.rawValue == "TRACE")
    }
}
