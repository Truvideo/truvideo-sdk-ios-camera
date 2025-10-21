//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Testing

@testable import Networking

struct HTTPHeaderTests {
    // MARK: - Tests

    @Test
    func testThatHeaderInitialization() {
        // Given
        let sut = HTTPHeader(name: "key", value: "foo")

        // When, Then
        #expect(sut.name == "key")
        #expect(sut.value == "foo")
    }

    @Test
    func testThatAcceptLanguageHeader() {
        // Given
        let sut = HTTPHeader.acceptLanguage("foo")

        // When, Then
        #expect(sut.name == "Accept-Language")
        #expect(sut.value == "foo")
    }

    @Test
    func testThatDefaultAcceptLanguageHeader() {
        // Given
        let preferredLanguage = Locale.preferredLanguages.prefix(6).qualityEncoded()
        let sut = HTTPHeader.defaultAcceptLanguage

        // When, Then
        #expect(sut.name == "Accept-Language")
        #expect(sut.value == preferredLanguage)
    }

    @Test
    func testThatAuthorizationLanguageHeader() {
        // Given
        let sut = HTTPHeader.authorization("foo")

        // When, Then
        #expect(sut.name == "Authorization")
        #expect(sut.value == "foo")
    }

    @Test
    func testThatBearerTokenHeader() {
        // Given
        let sut = HTTPHeader.bearerToken("foo")

        // When, Then
        #expect(sut.name == "Authorization")
        #expect(sut.value == "Bearer foo")
    }

    @Test
    func testThatContentTypeHeader() {
        // Given
        let sut = HTTPHeader.contentType("foo")

        // When, Then
        #expect(sut.name == "Content-Type")
        #expect(sut.value == "foo")
    }
}
