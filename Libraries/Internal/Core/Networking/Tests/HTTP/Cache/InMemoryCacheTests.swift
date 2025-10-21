//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import NetworkingTesting
import Testing

@testable import Networking

struct InMemoryURLCacheTests {
    // MARK: - Private Properties

    private let queue = DispatchQueue.global()

    // MARK: - Tests

    @Test
    func testThatCacheResponseForRequestShouldNotReturnAResponseIfDoesNotExists() {
        // Given
        let sut = InMemoryURLCache()
        let request = HTTPURLDataRequest(
            requestBuilder: RequestBuilderMock(),
            cache: nil,
            cachePolicy: .reloadIgnoringLocalCacheData,
            delegate: nil,
            middleware: nil,
            monitor: nil,
            queue: queue
        )

        // When, Then
        #expect(sut.cachedResponse(for: request) == nil)
    }

    @Test
    func testThatCacheResponseForRequestShouldNotReturnAResponseIfRequestIsInvalid() {
        // Given
        let response = URLCachedResponse(data: Data(), response: HTTPURLResponse())
        let sut = InMemoryURLCache()
        let request = HTTPURLDataRequest(
            requestBuilder: RequestBuilderMock(),
            cache: nil,
            cachePolicy: .reloadIgnoringLocalCacheData,
            delegate: nil,
            middleware: nil,
            monitor: nil,
            queue: queue
        )

        // When
        sut.cache(response, for: request)

        // Then
        #expect(sut.cachedResponse(for: request) == nil)
    }

    @Test
    func testThatCacheResponseForRequestShouldReturnAResponseIfExists() throws {
        // Given
        let response = URLCachedResponse(data: Data(), response: HTTPURLResponse())
        let urlRequest = try URLRequest(url: "https://httpbin.org/", method: .get)
        let sut = InMemoryURLCache()
        let request = HTTPURLDataRequest(
            requestBuilder: RequestBuilderMock(),
            cache: nil,
            cachePolicy: .reloadIgnoringLocalCacheData,
            delegate: nil,
            middleware: nil,
            monitor: nil,
            queue: queue
        )

        // When
        queue.sync {
            request.didCreateInitial(request: urlRequest)
        }

        sut.cache(response, for: request)

        // Then
        #expect(sut.cachedResponse(for: request) != nil)
    }

    @Test
    func testThatStaticVarInitialization() {
        // Given
        let sut: InMemoryURLCache = .inMemory

        // When, Then
        #expect(
            sut.memoryCapacity == ProcessInfo.processInfo.physicalMemory / 5,
            "Expected memoryCapacity to be the 25% of the physical memory"
        )
    }

    @Test
    func testThatStaticFunctionInitialization() {
        // Given
        let sut: InMemoryURLCache = .inMemory(capacity: 1)

        // When, Then
        #expect(sut.memoryCapacity == 1)
    }

    @Test
    func testThatRemoveCacheResponseForRequest() throws {
        // Given
        let response = URLCachedResponse(data: Data(), response: HTTPURLResponse())
        var results: [Bool] = []
        let urlRequest = try URLRequest(url: "https://httpbin.org/", method: .get)
        let sut = InMemoryURLCache()
        let request = HTTPURLDataRequest(
            requestBuilder: RequestBuilderMock(),
            cache: nil,
            cachePolicy: .reloadIgnoringLocalCacheData,
            delegate: nil,
            middleware: nil,
            monitor: nil,
            queue: queue
        )

        // When
        queue.sync {
            request.didCreateInitial(request: urlRequest)
        }

        sut.cache(response, for: request)
        results.append(sut.cachedResponse(for: request) != nil)

        sut.removeCachedResponse(for: request)
        results.append(sut.cachedResponse(for: request) != nil)

        // Then
        #expect(results == [true, false])
    }
}
