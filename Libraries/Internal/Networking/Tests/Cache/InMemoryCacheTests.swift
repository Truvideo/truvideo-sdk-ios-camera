//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Testing

@testable import Networking

struct InMemoryURLCacheTests {
    // MARK: - Private Properties
    
    private let session = Session(queue: .global())
    private let url = "https://httpbin.org/"
    
    // MARK: - Tests

    @Test func testThatCacheResponseForRequestShouldNotReturnAResponseIfDoesNotExists() {
        // Given
        let request = session.request(url)
        let sut = InMemoryURLCache()

        // When, Then
        #expect(sut.cachedResponse(for: request) == nil, "Expected response to be nil")
    }
    
    @Test func testThatCacheResponseForRequestShouldNotReturnAResponseIfRequestIsInvalid() {
        // Given
        let request = session.request(url)
        let response = URLCachedResponse(data: Data(), response: HTTPURLResponse())
        let sut = InMemoryURLCache()

        // When
        sut.cache(response, for: request)
        
        // Then
        #expect(sut.cachedResponse(for: request) == nil, "Expected response to be nil")
    }
    
    @Test func testThatCacheResponseForRequestShouldReturnAResponseIfExists() throws {
        // Given
        let request = session.request(url)
        let response = URLCachedResponse(data: Data(), response: HTTPURLResponse())
        let urlRequest = try URLRequest(url: "https://httpbin.org/", method: .get)
        let sut = InMemoryURLCache()

        // When
        session.queue.sync {
            request.didCreateInitial(request: urlRequest)
        }
        
        sut.cache(response, for: request)
        
        // Then
        #expect(sut.cachedResponse(for: request) != nil, "Expected response to not be nil")
    }
    
    @Test func testThatStaticVarInitialization() {
        // Given
        let sut: InMemoryURLCache = .inMemory
        
        // When, Then
        #expect(
            sut.memoryCapacity == ProcessInfo.processInfo.physicalMemory / 5,
            "Expected memoryCapacity to be the 25% of the physical memory"
        )
    }
    
    @Test func testThatStaticFunctionInitialization() {
        // Given
        let sut: InMemoryURLCache = .inMemory(capacity: 1)
        
        // When, Then
        #expect(sut.memoryCapacity == 1, "Expected memoryCapacity to be the equals to 1")
    }
    
    @Test func testThatRemoveCacheResponseForRequest() throws {
        // Given
        let request = session.request(url)
        let response = URLCachedResponse(data: Data(), response: HTTPURLResponse())
        var results: [Bool] = []
        let urlRequest = try URLRequest(url: "https://httpbin.org/", method: .get)
        let sut = InMemoryURLCache()

        // When
        session.queue.sync {
            request.didCreateInitial(request: urlRequest)
        }
        
        sut.cache(response, for: request)
        results.append(sut.cachedResponse(for: request) != nil)
        
        sut.removeCachedResponse(for: request)
        results.append(sut.cachedResponse(for: request) != nil)
        
        // Then
        #expect(results == [true, false], "Expected results to be equals to [true, false]")
    }
}
