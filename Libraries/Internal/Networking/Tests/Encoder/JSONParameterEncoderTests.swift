//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Testing

@testable import Networking

struct JSONParameterEncoderTests {
    // MARK: - Private Properties
    
    private let request = URLRequest(url: URL(string: "https://httpbin.org/")!)
    
    // MARK: - Tests
    
    @Test func testThatPrettyPrintedJSONParameterEncoder() throws {
        // Given
        let parameters = ["foo": "bar", "xyz": "abc"]
        let sut = JSONParameterEncoder.prettyPrinted
        
        // When
        let request = try sut.encode(parameters, into: request)

        // Then
        #expect(request.url?.query() == nil, "Expected url query to be nil")
        #expect(request.httpBody != nil, "Expected httpBody to not be nil")
        #expect(
            request.allHTTPHeaders["Content-Type"] == "application/json",
            "Expected Content-Type to be equals to application/json"
        )
    }
    
    @Test func testThatSortedKeysJSONParameterEncoder() throws {
        // Given
        let parameters = ["xyz": "abc", "foo": "bar"]
        let expectedJSONString = "{\"foo\":\"bar\",\"xyz\":\"abc\"}"
        let sut = JSONParameterEncoder.sortedKeys
        
        // When
        let request = try sut.encode(parameters, into: request)

        // Then
        #expect(request.url?.query() == nil, "Expected url query to be nil")
        #expect(String(data: request.httpBody!, encoding: .utf8) == expectedJSONString,
            "Expected serializedObject to be equals to \(expectedJSONString)"
        )
        #expect(
            request.allHTTPHeaders["Content-Type"] == "application/json",
            "Expected Content-Type to be equals to application/json"
        )
    }
    
    @Test func testThatEncodeShouldNotEncodeIfParametersAreNil() throws {
        // Given
        let sut = JSONParameterEncoder()
        
        // When
        let request = try sut.encode(nil, into: request)

        // Then
        #expect(request.url?.query() == nil, "Expected url query to be nil")
        #expect(request.httpBody == nil, "Expected httpBody to be nil")
        #expect(request.allHTTPHeaders["Content-Type"] == nil, "Expected Content-Type to be equals to nil")
    }
    
    @Test func testThatEncodeShouldThrowAnErrorIfJSONObjectIsInvalid() throws {
        // Given
        let sut = JSONParameterEncoder()
        let parameters: Parameters = [
            "foo": "bar",
            "date": Date()
        ]
                        
        // When, Then
        #expect {
            _ = try sut.encode(parameters, into: request)
        } throws: { error in
            guard let error = error as? NetworkingError else {
                return false
            }
            
            return error.kind == .parameterEncodingFailed
        }
    }
    
    @Test func testThatJSONStaticProperty() {
        // Given, When, Then
        #expect(JSONParameterEncoder.json != nil, "Expected to not be nil")
    }
    
    @Test func testThatJSONStaticFunction() {
        // Given, When, Then
        #expect(JSONParameterEncoder.json(options: .prettyPrinted) != nil, "Expected to not be nil")
    }
}
