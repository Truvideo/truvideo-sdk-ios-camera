//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Testing

@testable import Networking

struct HTTPMethodTests {
    
    // MARK: - Tests
    
    @Test func testThatHTTPMethodInitialization() {
        // Given
        let sut = HTTPMethod(rawValue: "foo")

        // When, Then
        #expect(sut.rawValue == "foo", "Expected raw value to be equals to foo")
    }
    
    @Test func testThatDeletetHTTPMethod() {
        // Given
        let sut = HTTPMethod.delete

        // When, Then
        #expect(sut.rawValue == "DELETE", "Expected raw value to be equals to DELETE")
    }
    
    @Test func testThatGetHTTPMethod() {
        // Given
        let sut = HTTPMethod.get

        // When, Then
        #expect(sut.rawValue == "GET", "Expected raw value to be equals to GET")
    }
    
    @Test func testThatHeadHTTPMethod() {
        // Given
        let sut = HTTPMethod.head

        // When, Then
        #expect(sut.rawValue == "HEAD", "Expected raw value to be equals to HEAD")
    }
    
    @Test func testThatOptionsHTTPMethod() {
        // Given
        let sut = HTTPMethod.options

        // When, Then
        #expect(sut.rawValue == "OPTIONS", "Expected raw value to be equals to OPTIONS")
    }
    
    @Test func testThatPatchHTTPMethod() {
        // Given
        let sut = HTTPMethod.patch

        // When, Then
        #expect(sut.rawValue == "PATCH", "Expected raw value to be equals to PATCH")
    }
    
    @Test func testThatPostHTTPMethod() {
        // Given
        let sut = HTTPMethod.post

        // When, Then
        #expect(sut.rawValue == "POST", "Expected raw value to be equals to POST")
    }
    
    @Test func testThatPutHTTPMethod() {
        // Given
        let sut = HTTPMethod.put

        // When, Then
        #expect(sut.rawValue == "PUT", "Expected raw value to be equals to PUT")
    }
    
    @Test func testThatTraceHTTPMethod() {
        // Given
        let sut = HTTPMethod.trace

        // When, Then
        #expect(sut.rawValue == "TRACE", "Expected raw value to be equals to TRACE")
    }
}
