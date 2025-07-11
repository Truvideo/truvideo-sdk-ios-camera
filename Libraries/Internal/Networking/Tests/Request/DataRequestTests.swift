//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import NetworkingTesting
import Testing

@testable import Networking

struct DataRequestTests {
    // MARK: - Private Properties
    
    private let queue = DispatchQueue.global()
    private let url = "https://httpbin.org/"
    
    // MARK: - Tests
    
    @Test func testThatDidReceiveDataShouldAppendData() {
        // Given
        let session = Session()
        let sut = session.request(url)

        // When
        sut.didReceive(data: Data())
        
        // Then
        #expect(sut.data != nil, "Expected data should not be nil")
    }
    
    @Test func testThatResetShouldResetTheData() {
        // Given
        let session = Session()
        let sut = session.request(url)

        // When
        sut.didReceive(data: Data())
        sut.reset()
        
        // Then
        #expect(sut.data == nil, "Expected data should to be nil")
    }
    
    @Test func testThatSerializingShouldSucceed() async {
        // Given
        let session = Session()
        let sut = session.request(url.appending("get"))

        // When
        let response = await sut.serializing(TestResponse.self)
        
        // Then
        #expect(response.data != nil, "Expected data should not be nil")
        #expect(response.value != nil, "Expected value should not be nil")
    }
    
    @Test func testThatSerializingWithCustomEmptyStatusCodesShouldSucceed() async {
        // Given
        let session = Session()
        let sut = session.request(url.appending("status/200"))

        // When
        let response = await sut.serializing(Empty.self, emptyResponseCodes: [200])
        
        // Then
        #expect(response.data == nil, "Expected data should to be nil")
        #expect(response.value != nil, "Expected value should not be nil")
    }
    
    @Test func testThatSerializingWithCustomEmptyStatusCodesShouldFail() async {
        // Given
        let session = Session()
        let sut = session.request(url.appending("status/200"))

        // When
        let response = await sut.serializing(TestResponse.self, emptyResponseCodes: [305])
        
        // Then
        #expect(response.value == nil, "Expected value should to be nil")
        #expect(
            response.error?.kind == .responseSerializationFailed,
            "Expected error to be responseSerializationFailed"
        )
    }
    
    @Test func testThatSerializingReturnsTheResponseAfterFinished() async {
        // Given
        let session = Session()
        let sut = session.request(url)

        // When
        _ = await sut.serializing(TestResponse.self)
        let response = await sut.serializingData()
        
        // Then
        #expect(response.data != nil, "Expected data count not be nil")
        #expect(response.result.failure == nil, "Expected failure to be nil")
        #expect(response.value != nil, "Expected value not be nil")
    }
    
    @Test func testThatSerializingDataShouldSucceed() async {
        // Given
        let session = Session()
        let sut = session.request(url)

        // When
        let response = await sut.serializingData()
        
        // Then
        #expect(response.data != nil, "Expected data should not be nil")
        #expect(response.value != nil, "Expected value should not be nil")
    }
    
    @Test func testThatSerializingDataWithCustomEmptyStatusCodesShouldSucceed() async {
        // Given
        let session = Session()
        let sut = session.request(url.appending("status/200"))

        // When
        let response = await sut.serializingData(emptyResponseCodes: [200])
        
        // Then
        #expect(response.data == nil, "Expected data to be nil")
        #expect(response.value != nil, "Expected value should not be nil")
    }
    
    @Test func testThatSerializingDataWithCustomEmptyStatusCodesShouldFail() async {
        // Given
        let session = Session()
        let sut = session.request(url.appending("status/200"))

        // When
        let response = await sut.serializingData(emptyResponseCodes: [305])
        
        // Then
        #expect(response.value == nil, "Expected value should to be nil")
        #expect(
            response.error?.kind == .responseSerializationFailed,
            "Expected error to be responseSerializationFailed"
        )
    }
    
    @Test func testThatSerializingDataReturnsTheResponseAfterFinished() async {
        // Given
        let session = Session()
        let sut = session.request(url)

        // When
        _ = await sut.serializingData()
        let response = await sut.serializingData()
        
        // Then
        #expect(response.data != nil, "Expected data count not be nil")
        #expect(response.result.failure == nil, "Expected failure to be nil")
        #expect(response.value != nil, "Expected value not be nil")
    }
    
    @Test func testThatSerializingStringShouldSucceed() async {
        // Given
        let session = Session()
        let sut = session.request(url)

        // When
        let response = await sut.serializingString()
        
        // Then
        #expect(response.data != nil, "Expected data should not be nil")
        #expect(response.value != nil, "Expected value should not be nil")
    }
    
    @Test func testThatSerializingStringWithCustomEmptyStatusCodesShouldSucceed() async {
        // Given
        let session = Session()
        let sut = session.request(url.appending("status/200"))

        // When
        let response = await sut.serializingString(emptyResponseCodes: [200])
        
        // Then
        #expect(response.data == nil, "Expected data should to be nil")
        #expect(response.value != nil, "Expected value should not be nil")
    }
    
    @Test func testThatSerializingStringWithCustomEmptyStatusCodesShouldFail() async {
        // Given
        let session = Session()
        let sut = session.request(url.appending("status/200"))

        // When
        let response = await sut.serializingString(emptyResponseCodes: [305])
        
        // Then
        #expect(response.value == nil, "Expected value should to be nil")
        #expect(
            response.error?.kind == .responseSerializationFailed,
            "Expected error to be responseSerializationFailed"
        )
    }
    
    @Test func testThatSerializingStringReturnsTheResponseAfterFinished() async {
        // Given
        let session = Session()
        let sut = session.request(url)

        // When
        _ = await sut.serializingString()
        let response = await sut.serializingString()
        
        // Then
        #expect(response.data != nil, "Expected data count not be nil")
        #expect(response.result.failure == nil, "Expected failure to be nil")
        #expect(response.value != nil, "Expected value not be nil")
    }
    
    @Test func testThatDidFailToCreateURLRequestShouldRetryTheRequestOnRetryPolicy() async {
        // Given
        let error = NetworkingError(kind: .explicitlyCancelled)
        let monitor = MonitorMock()
        let requestRetrier = RequestRetrierMock()
        let middleware = Middleware(interceptors: [], retriers: [requestRetrier])
        let session = Session(middleware: middleware, monitors: [monitor], queue: queue)
        let sut = session.request(url)

        // When
        sut.state = .resumed
        requestRetrier.retry = .retry(0)
        
        await withCheckedContinuation { continuation in
            monitor.requestDidFinishCallback = {
                continuation.resume()
            }
           
            session.queue.async {
                sut.didFailToCreateURLRequest(with: error)
            }
        }
        
        // Then
        #expect(sut.retryCount == 1, "Expected retryCount to be equals to 1")
        #expect(monitor.requestDidFinishCallCount == 1, "Expected requestDidFinishCallCount to be equals to 1")
        #expect(monitor.requestIsRetryingCallCount == 1, "Expected requestIsRetryingCallCount to be equals to 1")
        #expect(
            monitor.didFailToCreateURLRequestWithErrorCallCount == 1,
            "Expected didFailToCreateURLRequestWithErrorCallCount to be equals to 1"
        )
    }
    
    @Test func testThatDidFailToCreateURLRequestShouldNotRetryTheRequestOnRetryPolicy() async {
        // Given
        let error = NetworkingError(kind: .explicitlyCancelled)
        let monitor = MonitorMock()
        let requestRetrier = RequestRetrierMock()
        let middleware = Middleware(interceptors: [], retriers: [requestRetrier])
        let session = Session(middleware: middleware, monitors: [monitor], queue: queue)
        let sut = session.request(url)

        // When
        sut.state = .resumed
        requestRetrier.retry = .doNotRetryWithError(error)
        
        await withCheckedContinuation { continuation in
            monitor.requestDidFinishCallback = {
                continuation.resume()
            }
           
            session.queue.async {
                sut.didFailToCreateURLRequest(with: error)
            }
        }
        
        // Then
        #expect(sut.error?.kind == .requestRetryFailed, "Expected error to be equals to requestRetryFailed")
        #expect(sut.error?.underlyingError is Session.RetryError, "Expected underlyingError to be a RetryError")
    }
    
    @Test func testThatValidateShouldSucceed() async {
        // Given
        let session = Session()
        let sut = session.request(url)

        // When
        let response = await sut
            .validate { _, _, _ in }
            .serializingData()
        
        // Then
        #expect(response.data != nil, "Expected data should not be nil")
        #expect(response.error == nil, "Expected error to be nil")
        #expect(response.value != nil, "Expected value should not be nil")
    }
    
    @Test func testThatValidateWithCustomValidatorShouldFailTheRequest() async {
        // Given
        let session = Session()
        let sut = session.request(url)

        // When
        let response = await sut
            .validate { _, _, _ in
                throw NetworkingError(kind: .responseValidationFailed)
            }
            .serializingData()
        
        // Then
        #expect(response.data != nil, "Expected data should not be nil")
        #expect(response.error?.kind == .responseValidationFailed, "Expected error to be responseValidationFailed")
        #expect(response.error?.underlyingError == nil, "Expected underlyingError to be nil")
        #expect(response.value == nil, "Expected value should be nil")
    }
    
    @Test func testThatValidateWithCustomValidatorAndCustomErrorShouldFailTheRequest() async {
        // Given
        let session = Session()
        let sut = session.request(url)

        // When
        let response = await sut
            .validate { _, _, _ in
                throw NSError(domain: "", code: 0)
            }
            .serializingData()
        
        // Then
        #expect(response.data != nil, "Expected data should not be nil")
        #expect(response.error?.kind == .responseValidationFailed, "Expected error to be responseValidationFailed")
        #expect(response.error?.underlyingError is NSError, "Expected underlyingError to be NSError")
        #expect(response.value == nil, "Expected value should be nil")
    }
    
    @Test func testThatDidFailToCreateURLRequestShouldNotRetryTheRequestOnRetryPolicyWithCustomError() async {
        // Given
        let error = NetworkingError(kind: .explicitlyCancelled)
        let monitor = MonitorMock()
        let requestRetrier = RequestRetrierMock()
        let middleware = Middleware(interceptors: [], retriers: [requestRetrier])
        let session = Session(middleware: middleware, monitors: [monitor], queue: queue)
        let sut = session.request(url)

        // When
        sut.state = .resumed
        requestRetrier.retry = .doNotRetryWithError(NSError(domain: "", code: 0))
        
        await withCheckedContinuation { continuation in
            monitor.requestDidFinishCallback = {
                continuation.resume()
            }
           
            session.queue.async {
                sut.didFailToCreateURLRequest(with: error)
            }
        }
        
        // Then
        #expect(sut.error?.kind == .requestRetryFailed, "Expected error to be equals to requestRetryFailed")
        #expect(sut.error?.underlyingError is NSError, "Expected underlyingError to be a NSError")
    }
    
    @Test func testThatDataRequestShouldReturnCachedDataOnReturnCacheDataDontLoadPolicy() async throws {
        // Given
        let cache = InMemoryURLCache()
        let session = Session(cache: cache)
        let urlRequest = try URLRequest(url: url, method: .get)
        let response = URLCachedResponse(data: Data(), response: HTTPURLResponse())
        let request = session.request(url, cachePolicy: .returnCacheDataDontLoad)

        // When
        session.queue.sync {
            request.didCreate(urlRequest: urlRequest)
        }
        
        cache.cache(response, for: request)
                
        let sut = session.request(url, cachePolicy: .returnCacheDataDontLoad)
        let result = await sut.serializingData()
        
        // Then
        #expect(sut.state == .finished, "Expected state to be equals to finished")
        #expect(sut.tasks.isEmpty, "Expected tasks to be empty when response is from cache")
        #expect(result.data != nil, "Expected data to not be nil")
        #expect(result.response != nil, "Expected response to not be nil")
        #expect(result.type == .localCache, "Expected type to be equals to localCache")
    }
    
    @Test func testThatDataRequestShouldReturnCachedDataAndDontLoadOnReturnCacheDataDontLoadPolicy() async {
        // Given
        let session = Session(cache: InMemoryURLCache())
        let sut = session.request(url, cachePolicy: .returnCacheDataDontLoad)

        // When
        let result = await sut.serializingData()
        
        // Then
        #expect(sut.state == .finished, "Expected state to be equals to finished")
        #expect(sut.tasks.isEmpty, "Expected tasks to be empty when response is from cache")
        #expect(result.data == nil, "Expected data to be nil")
        #expect(result.response == nil, "Expected response to be nil")
        #expect(result.type == .localCache, "Expected type to be equals to localCache")
    }
    
    @Test func testThatDataRequestShouldReturnCachedDataAndDontLoadOnReturnCacheDataElseLoadPolicy() async throws {
        // Given
        let cache = InMemoryURLCache()
        let session = Session(cache: cache)
        let urlRequest = try URLRequest(url: url, method: .get)
        let response = URLCachedResponse(data: Data(), response: HTTPURLResponse())
        let request = session.request(url)

        // When
        session.queue.sync {
            request.didCreate(urlRequest: urlRequest)
        }
        
        cache.cache(response, for: request)
                
        let sut = session.request(url, cachePolicy: .returnCacheDataElseLoad)
        let result = await sut.serializingData()
        
        // Then
        #expect(sut.state == .finished, "Expected state to be equals to finished")
        #expect(sut.tasks.isEmpty, "Expected tasks to be empty when response is from cache")
        #expect(result.data != nil, "Expected data to not be nil")
        #expect(result.response != nil, "Expected response to not be nil")
        #expect(result.type == .localCache, "Expected type to be equals to localCache")
    }
    
    @Test func testThatDataRequestShouldLoadDataOnReloadIgnoringLocalCacheDataPolicy() async throws {
        // Given
        let cache = InMemoryURLCache()
        let session = Session(cache: cache)
        let urlRequest = try URLRequest(url: url, method: .get)
        let response = URLCachedResponse(data: Data(), response: HTTPURLResponse())
        let request = session.request(url, cachePolicy: .reloadIgnoringLocalCacheData)

        // When
        session.queue.sync {
            request.didCreate(urlRequest: urlRequest)
        }
        
        cache.cache(response, for: request)
                
        let sut = session.request(url)
        let result = await sut.serializingData()
        
        // Then
        #expect(sut.state == .finished, "Expected state to be equals to finished")
        #expect(!sut.tasks.isEmpty, "Expected tasks to not be empty")
        #expect(result.data != nil, "Expected data to not be nil")
        #expect(result.response != nil, "Expected response to not be nil")
        #expect(result.type == .networkLoad, "Expected type to be equals to localCache")
    }
    
    @Test func testThatDataRequestShouldLoadDataOnReturnCacheDataElseLoadPolicy() async throws {
        // Given
        let session = Session(cache: InMemoryURLCache())
        let sut = session.request(url, cachePolicy: .returnCacheDataElseLoad)

        // When
        let result = await sut.serializingData()
        
        // Then
        #expect(sut.state == .finished, "Expected state to be equals to finished")
        #expect(!sut.tasks.isEmpty, "Expected tasks to not be empty when response is from cache")
        #expect(result.data != nil, "Expected data to not be nil")
        #expect(result.response != nil, "Expected response to not be nil")
        #expect(result.type == .networkLoad, "Expected type to be equals to networkLoad")
    }
    
    @Test func testThatDataRequestShoulDoNotRetryRequest() async {
        // Given
        let requestRetrier = RequestRetrierMock()
        let middleware = Middleware(interceptors: [], retriers: [requestRetrier])
        let session = Session(middleware: middleware, queue: queue)
        let sut = session.request(url.appending("/status/500"))

        // When
        requestRetrier.retry = .doNotRetry
        _ = await sut.serializingData()
        
        // Then
        #expect(sut.state == .finished, "Expected state to be equals to finished")
        #expect(sut.retryCount == 0, "Expected retryCount to be equals to 0")
    }
    
    @Test func testThatDataRequestShoulDoNotRetryAndReturnFailedResponseOnDoNotRetryWithError() async {
        // Given
        let requestRetrier = RequestRetrierMock()
        let middleware = Middleware(interceptors: [], retriers: [requestRetrier])
        let session = Session(middleware: middleware, queue: queue)
        let sut = session.request(url.appending("/status/500"))

        // When
        requestRetrier.retry = .doNotRetryWithError(NSError(domain: "", code: 0))
        
        let response = await sut.validate().serializingData()
        
        // Then
        #expect(response.error?.kind == .requestRetryFailed, "Expected error to be equals to requestRetryFailed")
        #expect(response.error?.underlyingError != nil, "Expected underlyingError to not be nil")
        #expect(sut.retryCount == 0, "Expected retryCount to be equals to 0")
    }
    
    @Test func testThatDataRequestShouldRetryRequest() async {
        // Given
        let monitor = MonitorMock()
        let requestRetrier = RequestRetrierMock()
        let middleware = Middleware(interceptors: [], retriers: [requestRetrier])
        let session = Session(middleware: middleware, monitors: [monitor], queue: queue)
        let sut = session.request(url.appending("/status/500"))

        // When
        let response = await sut.validate().serializingData()
        
        // Then
        #expect(response.error?.underlyingError == nil, "Expected underlyingError to be nil")
        #expect(
            response.error?.kind == .responseValidationFailed,
            "Expected error to be equals to responseValidationFailed"
        )
        
        #expect(
            sut.retryCount == requestRetrier.maxNumberOfRetries,
            "Expected retryCount to be equals to \(requestRetrier.maxNumberOfRetries)"
        )
    }
    
    @Test func testThatValidationWithCustomStatusCodesShouldSucceed() async {
        // Given
        let monitor = MonitorMock()
        let requestRetrier = RequestRetrierMock()
        let middleware = Middleware(interceptors: [], retriers: [requestRetrier])
        let session = Session(middleware: middleware, monitors: [monitor], queue: queue)
        let sut = session.request(url.appending("status/400"))

        // When
        let response = await sut
            .validate(acceptableStatusCodes: [400])
            .serializingData(emptyResponseCodes: [400])
        
        // Then
        #expect(response.error == nil, "Expected error to be nil")
        #expect(response.value != nil, "Expected value to not be nil")
    }
    
    @Test func testThatValidationWithCustomStatusCodesShouldFail() async {
        // Given
        let monitor = MonitorMock()
        let requestRetrier = RequestRetrierMock()
        let middleware = Middleware(interceptors: [], retriers: [requestRetrier])
        let session = Session(middleware: middleware, monitors: [monitor], queue: queue)
        let sut = session.request(url)

        // When
        let response = await sut
            .validate(acceptableStatusCodes: [400])
            .serializingData()
        
        // Then
        #expect(response.error != nil, "Expected error to not be nil")
        #expect(response.value == nil, "Expected value to be nil")
    }
}

private struct TestResponse: Decodable {
    let url: URL
}
