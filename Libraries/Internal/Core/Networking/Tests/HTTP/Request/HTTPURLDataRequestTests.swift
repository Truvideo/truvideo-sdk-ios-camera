//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import NetworkingTesting
import Testing

@testable import Networking

struct HTTPURLDataRequestTests {
    // MARK: - Private Properties
    
    private let queue = DispatchQueue.global()
    private let url = "https://httpbin.org/"
    
    // MARK: - Tests
    
    @Test
    func testThatDidReceiveDataShouldAppendData() {
        // Given
        let session = HTTPURLSession()
        let sut = session.request(url.appending("get")) as! HTTPURLDataRequest

        // When
        sut.didReceive(data: Data())
        
        // Then
        #expect(sut.data != nil)
    }
    
    @Test
    func testThatResetShouldResetTheData() {
        // Given
        let session = HTTPURLSession()
        let sut = session.request(url.appending("get")) as! HTTPURLDataRequest

        // When
        sut.didReceive(data: Data())
        sut.reset()
        
        // Then
        #expect(sut.data == nil)
    }
    
    @Test
    func testThatSerializingShouldSucceed() async {
        // Given
        let session = HTTPURLSession()
        let sut = session.request(url.appending("get"))

        // When
        let response = await sut.serializing(TestResponse.self)
        
        // Then
        #expect(response.data != nil)
        #expect(response.value != nil)
    }
    
    @Test
    func testThatSerializingWithCustomEmptyStatusCodesShouldSucceed() async {
        // Given
        let session = HTTPURLSession()
        let sut = session.request(url.appending("status/200"))

        // When
        let response = await sut.serializing(Empty.self, emptyResponseCodes: [200])
        
        // Then
        #expect(response.data == nil)
        #expect(response.value != nil)
    }
    
    @Test
    func testThatSerializingWithCustomEmptyStatusCodesShouldFail() async {
        // Given
        let session = HTTPURLSession()
        let sut = session.request(url.appending("status/200"))

        // When
        let response = await sut.serializing(TestResponse.self, emptyResponseCodes: [305])
        
        // Then
        #expect(response.value == nil)
        #expect(response.error?.kind == .responseSerializationFailed)
    }
    
    @Test
    func testThatSerializingReturnsTheResponseAfterFinished() async {
        // Given
        let session = HTTPURLSession()
        let sut = session.request(url)

        // When
        _ = await sut.serializing(TestResponse.self)
        let response = await sut.serializingData()
        
        // Then
        #expect(response.data != nil)
        #expect(response.result.failure == nil)
        #expect(response.value != nil)
    }
    
    @Test
    func testThatSerializingDataShouldSucceed() async {
        // Given
        let session = HTTPURLSession()
        let sut = session.request(url)

        // When
        let response = await sut.serializingData()
        
        // Then
        #expect(response.data != nil)
        #expect(response.value != nil)
    }
    
    @Test
    func testThatSerializingDataWithCustomEmptyStatusCodesShouldSucceed() async {
        // Given
        let session = HTTPURLSession()
        let sut = session.request(url.appending("status/200"))

        // When
        let response = await sut.serializingData(emptyResponseCodes: [200])
        
        // Then
        #expect(response.data == nil)
        #expect(response.value != nil)
    }
    
    @Test
    func testThatSerializingDataWithCustomEmptyStatusCodesShouldFail() async {
        // Given
        let session = HTTPURLSession()
        let sut = session.request(url.appending("status/200"))

        // When
        let response = await sut.serializingData(emptyResponseCodes: [305])
        
        // Then
        #expect(response.value == nil)
        #expect(response.error?.kind == .responseSerializationFailed)
    }
    
    @Test
    func testThatSerializingDataReturnsTheResponseAfterFinished() async {
        // Given
        let session = HTTPURLSession()
        let sut = session.request(url)

        // When
        _ = await sut.serializingData()
        let response = await sut.serializingData()
        
        // Then
        #expect(response.data != nil)
        #expect(response.result.failure == nil)
        #expect(response.value != nil)
    }
    
    @Test
    func testThatSerializingStringShouldSucceed() async {
        // Given
        let session = HTTPURLSession()
        let sut = session.request(url)

        // When
        let response = await sut.serializingString()
        
        // Then
        #expect(response.data != nil)
        #expect(response.value != nil)
    }
    
    @Test
    func testThatSerializingStringWithCustomEmptyStatusCodesShouldSucceed() async {
        // Given
        let session = HTTPURLSession()
        let sut = session.request(url.appending("status/200"))

        // When
        let response = await sut.serializingString(emptyResponseCodes: [200])
        
        // Then
        #expect(response.data == nil)
        #expect(response.value != nil)
    }
    
    @Test
    func testThatSerializingStringWithCustomEmptyStatusCodesShouldFail() async {
        // Given
        let session = HTTPURLSession()
        let sut = session.request(url.appending("status/200"))

        // When
        let response = await sut.serializingString(emptyResponseCodes: [305])
        
        // Then
        #expect(response.value == nil)
        #expect(response.error?.kind == .responseSerializationFailed)
    }
    
    @Test
    func testThatSerializingStringReturnsTheResponseAfterFinished() async {
        // Given
        let session = HTTPURLSession()
        let sut = session.request(url)

        // When
        _ = await sut.serializingString()
        let response = await sut.serializingString()
        
        // Then
        #expect(response.data != nil)
        #expect(response.result.failure == nil)
        #expect(response.value != nil)
    }
    
    @Test
    func testThatDidFailToCreateURLRequestShouldRetryTheRequestOnRetryPolicy() async {
        // Given
        let error = NetworkingError(kind: .explicitlyCancelled)
        let monitor = MonitorMock()
        let requestRetrier = RequestRetrierMock()
        let session = HTTPURLSession()
        let sut = session.request(url) as! HTTPURLDataRequest

        // When
        sut.state = .resumed
        requestRetrier.retry = .retry(0)
        
        await withCheckedContinuation { continuation in
            monitor.requestDidFinishCallback = {
                continuation.resume()
            }
           
            queue.async {
                sut.didFailToCreateURLRequest(with: error)
            }
        }
        
        // Then
        #expect(sut.retryCount == 1)
        #expect(monitor.requestDidFinishCallCount == 1)
        #expect(monitor.requestIsRetryingCallCount == 1)
        #expect(monitor.didFailToCreateURLRequestWithErrorCallCount == 1)
    }
    
    @Test
    func testThatDidFailToCreateURLRequestShouldNotRetryTheRequestOnRetryPolicy() async {
        // Given
        let error = NetworkingError(kind: .explicitlyCancelled)
        let monitor = MonitorMock()
        let requestRetrier = RequestRetrierMock()
        let session = HTTPURLSession(middleware: Middleware(interceptors: [], retriers: [requestRetrier]))
        let sut = session.request(url) as! HTTPURLDataRequest

        // When
        sut.state = .resumed
        requestRetrier.retry = .doNotRetryWithError(error)
        
        await withCheckedContinuation { continuation in
            monitor.requestDidFinishCallback = {
                continuation.resume()
            }
           
            queue.async {
                sut.didFailToCreateURLRequest(with: error)
            }
        }
        
        // Then
        #expect(sut.error?.kind == .requestRetryFailed)
        #expect(sut.error?.underlyingError is HTTPURLSession.RetryError)
    }
    
    @Test
    func testThatValidateShouldSucceed() async {
        // Given
        let session = HTTPURLSession()
        let sut = session.request(url)

        // When
        let response = await sut
            .validate { _, _, _ in }
            .serializingData()
        
        // Then
        #expect(response.data != nil)
        #expect(response.error == nil)
        #expect(response.value != nil)
    }
    
    @Test
    func testThatValidateWithCustomValidatorShouldFailTheRequest() async {
        // Given
        let session = HTTPURLSession()
        let sut = session.request(url)

        // When
        let response = await sut
            .validate { _, _, _ in
                throw NetworkingError(kind: .responseValidationFailed)
            }
            .serializingData()
        
        // Then
        #expect(response.data != nil)
        #expect(response.error?.kind == .responseValidationFailed)
        #expect(response.error?.underlyingError == nil)
        #expect(response.value == nil)
    }
    
    @Test
    func testThatValidateWithCustomValidatorAndCustomErrorShouldFailTheRequest() async {
        // Given
        let session = HTTPURLSession()
        let sut = session.request(url)

        // When
        let response = await sut
            .validate { _, _, _ in
                throw NSError(domain: "", code: 0)
            }
            .serializingData()
        
        // Then
        #expect(response.data != nil)
        #expect(response.error?.kind == .responseValidationFailed)
        #expect(response.error?.underlyingError is NSError)
        #expect(response.value == nil)
    }
    
    @Test
    func testThatDidFailToCreateURLRequestShouldNotRetryTheRequestOnRetryPolicyWithCustomError() async {
        // Given
        let error = NetworkingError(kind: .explicitlyCancelled)
        let monitor = MonitorMock()
        let requestRetrier = RequestRetrierMock()
        let session = HTTPURLSession(middleware: Middleware(interceptors: [], retriers: [requestRetrier]))
        let sut = session.request(url) as! HTTPURLDataRequest

        // When
        sut.state = .resumed
        requestRetrier.retry = .doNotRetryWithError(NSError(domain: "", code: 0))
        
        await withCheckedContinuation { continuation in
            monitor.requestDidFinishCallback = {
                continuation.resume()
            }
           
            queue.async {
                sut.didFailToCreateURLRequest(with: error)
            }
        }
        
        // Then
        #expect(sut.error?.kind == .requestRetryFailed)
        #expect(sut.error?.underlyingError is NSError)
    }
    
    @Test
    func testThatDataRequestShouldReturnCachedDataOnReturnCacheDataDontLoadPolicy() async throws {
        // Given
        let cache = InMemoryURLCache()
        let session = HTTPURLSession(cache: cache)
        let urlRequest = try URLRequest(url: url, method: .get)
        let response = URLCachedResponse(data: Data(), response: HTTPURLResponse())
        let request = session.request(url, cachePolicy: .returnCacheDataDontLoad) as! HTTPURLDataRequest

        // When
        session.queue.sync {
            request.didCreate(urlRequest: urlRequest)
        }
        
        cache.cache(response, for: request)
                
        let sut = session.request(url, cachePolicy: .returnCacheDataDontLoad) as! HTTPURLDataRequest
        let result = await sut.serializingData()
        
        // Then
        #expect(sut.state == .finished)
        #expect(sut.request == nil)
        #expect(result.data != nil)
        #expect(result.response != nil)
        #expect(result.type == .localCache)
    }
    
    @Test
    func testThatDataRequestShouldReturnCachedDataAndDontLoadOnReturnCacheDataDontLoadPolicy() async {
        // Given
        let session = HTTPURLSession()
        let sut = session.request(url.appending("/get")) as! HTTPURLDataRequest

        // When
        let result = await sut.serializingData()
        
        // Then
        #expect(sut.state == .finished)
        #expect(sut.request == nil)
        #expect(result.data == nil)
        #expect(result.response == nil)
        #expect(result.type == .localCache)
    }
    
    @Test
    func testThatDataRequestShouldReturnCachedDataAndDontLoadOnReturnCacheDataElseLoadPolicy() async throws {
        // Given
        let cache = InMemoryURLCache()
        let urlRequest = try URLRequest(url: url, method: .get)
        let response = URLCachedResponse(data: Data(), response: HTTPURLResponse())
        let session = HTTPURLSession(cache: cache)
        let request = session.request(
            url.appending("/200"),
            cachePolicy: .returnCacheDataDontLoad
        ) as! HTTPURLDataRequest

        // When
        session.queue.sync {
            request.didCreate(urlRequest: urlRequest)
        }
        
        cache.cache(response, for: request)
                
        let sut = session.request(
            url.appending("/200"),
            cachePolicy: .returnCacheDataDontLoad
        ) as! HTTPURLDataRequest
        
        let result = await sut.serializingData()
        
        // Then
        #expect(sut.state == .finished)
        #expect(sut.request == nil)
        #expect(result.data != nil)
        #expect(result.response != nil)
        #expect(result.type == .localCache)
    }
    
    @Test
    func testThatDataRequestShouldLoadDataOnReloadIgnoringLocalCacheDataPolicy() async throws {
        // Given
        let cache = InMemoryURLCache()
        let session = HTTPURLSession(cache: cache)
        let urlRequest = try URLRequest(url: url, method: .get)
        let response = URLCachedResponse(data: Data(), response: HTTPURLResponse())
        let request = session.request(url, cachePolicy: .reloadIgnoringLocalCacheData) as! HTTPURLDataRequest

        // When
        session.queue.sync {
            request.didCreate(urlRequest: urlRequest)
        }
        
        cache.cache(response, for: request)
                
        let sut = session.request(url) as! HTTPURLDataRequest
        let result = await sut.serializingData()
        
        // Then
        #expect(sut.state == .finished)
        #expect(!sut.tasks.isEmpty)
        #expect(result.data != nil)
        #expect(result.response != nil)
        #expect(result.type == .networkLoad)
    }
    
    @Test
    func testThatDataRequestShouldLoadDataOnReturnCacheDataElseLoadPolicy() async throws {
        // Given
        let session = HTTPURLSession(cache: InMemoryURLCache())
        let cache = InMemoryURLCache()
        let urlRequest = try URLRequest(url: url, method: .get)
        let response = URLCachedResponse(data: Data(), response: HTTPURLResponse())
        let sut = session.request(url.appending("/200"), cachePolicy: .returnCacheDataElseLoad) as! HTTPURLDataRequest

        // When
        let result = await sut.serializingData()
        
        // Then
        #expect(sut.state == .finished)
        #expect(sut.request != nil)
        #expect(result.data != nil)
        #expect(result.response != nil)
        #expect(result.type == .networkLoad)
    }
    
    @Test
    func testThatDataRequestShoulDoNotRetryRequest() async {
        // Given
        let requestRetrier = RequestRetrierMock()
        let middleware = Middleware(interceptors: [], retriers: [requestRetrier])
        let session = HTTPURLSession(middleware: middleware, queue: queue)
        let sut = session.request(
            url.appending("/status/500"),
            cachePolicy: .returnCacheDataElseLoad
        ) as! HTTPURLDataRequest

        // When
        requestRetrier.retry = .doNotRetry
        _ = await sut.serializingData()
        
        // Then
        #expect(sut.state == .finished)
        #expect(sut.retryCount == 0)
    }
    
    @Test
    func testThatDataRequestShoulDoNotRetryAndReturnFailedResponseOnDoNotRetryWithError() async {
        // Given
        let requestRetrier = RequestRetrierMock()
        let middleware = Middleware(interceptors: [], retriers: [requestRetrier])
        let session = HTTPURLSession(middleware: middleware, queue: queue)
        let sut = session.request(url.appending("/status/500"))

        // When
        requestRetrier.retry = .doNotRetryWithError(NSError(domain: "", code: 0))
        
        let response = await sut.validate().serializingData()
        
        // Then
        #expect(response.error?.kind == .requestRetryFailed)
        #expect(response.error?.underlyingError != nil)
        #expect(sut.retryCount == 0)
    }
    
    @Test
    func testThatDataRequestShouldRetryRequest() async {
        // Given
        let monitor = MonitorMock()
        let requestRetrier = RequestRetrierMock()
        let middleware = Middleware(interceptors: [], retriers: [requestRetrier])
        let session = HTTPURLSession(middleware: middleware, monitors: [monitor], queue: queue)
        let sut = session.request(url.appending("/status/500"))

        // When
        let response = await sut.validate().serializingData()
        
        // Then
        #expect(response.error?.underlyingError == nil)
        #expect(response.error?.kind == .responseValidationFailed)
        #expect(sut.retryCount == requestRetrier.maxNumberOfRetries)
    }
    
    @Test
    func testThatValidationWithCustomStatusCodesShouldSucceed() async {
        // Given
        let monitor = MonitorMock()
        let requestRetrier = RequestRetrierMock()
        let middleware = Middleware(interceptors: [], retriers: [requestRetrier])
        let session = HTTPURLSession(middleware: middleware, monitors: [monitor], queue: queue)
        let sut = session.request(url.appending("status/400"))

        // When
        let response = await sut
            .validate(acceptableStatusCodes: [400])
            .serializingData(emptyResponseCodes: [400])
        
        // Then
        #expect(response.error == nil)
        #expect(response.value != nil)
    }
    
    @Test
    func testThatValidationWithCustomStatusCodesShouldFail() async {
        // Given
        let monitor = MonitorMock()
        let requestRetrier = RequestRetrierMock()
        let middleware = Middleware(interceptors: [], retriers: [requestRetrier])
        let session = HTTPURLSession(middleware: middleware, monitors: [monitor], queue: queue)
        let sut = session.request(url)

        // When
        let response = await sut
            .validate(acceptableStatusCodes: [400])
            .serializingData()
        
        // Then
        #expect(response.error != nil)
        #expect(response.value == nil)
    }
}

private struct TestResponse: Decodable {
    let url: URL
}
