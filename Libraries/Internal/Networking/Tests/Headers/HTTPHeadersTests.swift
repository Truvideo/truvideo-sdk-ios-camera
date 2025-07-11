//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Testing

@testable import Networking

struct HTTPHeadersTests {
    
    // MARK: - Tests
    
    @Test func testThatDefaultHeaders() {
        // Given
        let sut = HTTPHeaders.default

        // When, Then
        #expect(sut == [.defaultAcceptLanguage], "Expected to be initialized with default accept language")
    }
    
    @Test func testThatDictionaryValues() {
        // Given
        let expectedDictionary = [
            "Accept-Language": "pt-BR",
            "Authorization": "foo"
        ]
        
        let sut = HTTPHeaders(array: [
            .acceptLanguage("pt-BR"),
            .authorization("foo")
        ])

        // When, Then
        #expect(sut.dictionary == expectedDictionary, "Expected to be equals to \(expectedDictionary)")
    }
    
    @Test func testThatHeadersShouldReturnNilHeaderIfDoesNotExists() {
        // Given
        let sut = HTTPHeaders(array: [])

        // When, Then
        #expect(sut["foo"] == nil, "Expected to be nil")
    }
    
    @Test func testThatRemoveHeaderShouldRemoveHeaderIfNilValueIsAssigned() {
        // Given
        var sut = HTTPHeaders(array: [.authorization("foo")])

        // When
        sut["Authorization"] = nil
        
        // Then
        #expect(sut["Authorization"] == nil, "Expected to be nil")
    }
    
    @Test func testThatHeadersAreStoreUniquelyFromArray() {
        // Given
        let sut = HTTPHeaders(array: [
            HTTPHeader(name: "key", value: "foo"),
            HTTPHeader(name: "Key", value: "foo"),
            HTTPHeader(name: "KEY", value: "foo")
        ])

        // When, Then
        #expect(sut.count == 1, "Expected 1 unique header")
    }
    
    @Test func testThatHeadersAreStoreUniquelyFromArrayLiteral() {
        // Given
        let sut: HTTPHeaders = [
            HTTPHeader(name: "key", value: "foo"),
            HTTPHeader(name: "Key", value: "foo"),
            HTTPHeader(name: "KEY", value: "foo")
        ]

        // When, Then
        #expect(sut.count == 1, "Expected 1 unique header")
    }

    @Test func testThatHeadersAreStoreUniquelyFromDictionaryLiteral() {
        // Given
        let sut: HTTPHeaders = ["key": "foo", "Key": "foo", "KEY": "foo"]

        // When, Then
        #expect(sut.count == 1, "Expected 1 unique header")
    }

    @Test func testThatHeadersAreStoreUniquelyFromDictionary() {
        // Given
        let sut = HTTPHeaders(dictionary: ["key": "foo", "Key": "foo", "KEY": "foo"])

        // When, Then
        #expect(sut.count == 1, "Expected 1 unique header")
    }

    @Test func testThatHeadersCanSetAndGetCaseInsentitiveBySubscript() {
        // Given
        var sut = HTTPHeaders()

        // When
        sut["key"] = "foo"

        // Then
        #expect(sut["Key"] == "foo", "Expected header to be case-insensitive")
    }
    
    @Test func testThatAppendHeaderShouldInsertANewValue() {
        // Given
        var sut = HTTPHeaders()

        // When
        #expect(sut["Authorization"] == nil, "Expected Authorization header to be equals to nil")
        
        sut.append(.authorization("foo"))

        // Then
        #expect(sut["Authorization"] == "foo", "Expected header to be equals to foo")
    }
    
    @Test func testThatAppendHeaderShouldReplaceExistingHeaderValue() {
        // Given
        var sut = HTTPHeaders(array: [.authorization("foo")])

        // When
        #expect(sut["Authorization"] == "foo", "Expected header to be equals to foo")
        
        sut.append(.authorization("bar"))

        // Then
        #expect(sut["Authorization"] == "bar", "Expected header to be equals to bar")
    }
    
    @Test func testThatSetHeaderShouldInsertANewValue() {
        // Given
        var sut = HTTPHeaders()

        // When
        #expect(sut["Key"] == nil, "Expected Key header to be equals to nil")
        
        sut.setHeader("foo", forKey: "Key")

        // Then
        #expect(sut["Key"] == "foo", "Expected header to be equals to foo")
    }
    
    @Test func testThatSetHeaderShouldReplaceExistingHeaderValue() {
        // Given
        var sut = HTTPHeaders(array: [HTTPHeader.authorization("foo")])

        // When
        #expect(sut["Authorization"] == "foo", "Expected Authorization header to be equals to foo")
        
        sut.setHeader("bar", forKey: "Authorization")

        // Then
        #expect(sut["Authorization"] == "bar", "Expected header to be equals to bar")
    }
    
    @Test func testThatGetHeaderByIndex() {
        // Given
        let sut = HTTPHeaders(array: [HTTPHeader.authorization("foo")])

        // When, Then
        #expect(sut[0] == HTTPHeader.authorization("foo"), "Expected header to be equals to Authorization header")
    }
    
    @Test func testThatMakeIterator() {
        // Given
        let sut = HTTPHeaders(array: [HTTPHeader.authorization("foo")])

        // When, Then
        #expect(sut.makeIterator().count(where: { _ in true }) == 1, "Expected count to be equals to 1")
    }
    
    @Test func testThatAdditionOperator() {
        // Given
        let lhs = HTTPHeaders(array: [HTTPHeader.authorization("foo")])
        let rhs = HTTPHeaders(array: [HTTPHeader.acceptLanguage("foo")])
        
        // When
        let combined = lhs + rhs
        
        // Then
        #expect(combined["Authorization"] == "foo", "Expected Authorization to be equals to foo")
        #expect(combined["Accept-Language"] == "foo", "Expected Accept-Language to be equals to foo")
    }
    
    @Test func testThatAdditionOperatorShouldCombineHeadersByKeepingRHSValues() {
        // Given
        let lhs = HTTPHeaders(array: [HTTPHeader.authorization("foo")])
        let rhs = HTTPHeaders(array: [HTTPHeader.authorization("bar")])
        
        // When
        let combined = lhs + rhs
        
        // Then
        #expect(combined.count == 1, "Expected headers count to be equals to 1")
        #expect(combined["Authorization"] == "bar", "Expected Authorization to be equals to bar")        
    }
}
