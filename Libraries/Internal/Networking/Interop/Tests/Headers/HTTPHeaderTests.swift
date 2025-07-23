//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Testing

@testable import NetworkingInterop

struct HTTPHeaderTests {
    
    // MARK: - Tests
    
    @Test
    func testThatHeaderInitialization() {
        // Given
        let sut = HTTPHeader(name: "key", value: "foo")

        // When, Then
        #expect(sut.name == "key", "Expeced name to be equals to Key")
        #expect(sut.value == "foo", "Expeced value to be equals to foo")
    }
    
    @Test
    func testThatAcceptLanguageHeader() {
        // Given
        let sut = HTTPHeader.acceptLanguage("foo")
        
        // When, Then
        #expect(sut.name == "Accept-Language", "Expected name to be equals to Accept-Language")
        #expect(sut.value == "foo", "Expected value to be equals to foo")
    }
    
    @Test
    func testThatDefaultAcceptLanguageHeader() {
        // Given
        let preferredLanguage = Locale.preferredLanguages.prefix(6).qualityEncoded()
        let sut = HTTPHeader.defaultAcceptLanguage
        
        // When, Then
        #expect(sut.name == "Accept-Language", "Expected name to be equals to Accept-Language")
        #expect(sut.value == preferredLanguage, "Expected value to be equals to \(preferredLanguage)")
    }
    
    @Test
    func testThatAuthorizationLanguageHeader() {
        // Given
        let sut = HTTPHeader.authorization("foo")
        
        // When, Then
        #expect(sut.name == "Authorization", "Expected name to be equals to Authorization")
        #expect(sut.value == "foo", "Expected value to be equals to foo")
    }
    
    @Test
    func testThatBearerTokenHeader() {
        // Given
        let sut = HTTPHeader.bearerToken("foo")
        
        // When, Then
        #expect(sut.name == "Authorization", "Expected name to be equals to Authorization")
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
