//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Testing

@testable import Networking
@testable import NetworkingTesting

struct HTTPURLDataRequestTests {
    // MARK: - Private Properties
    
    private let monitor = MonitorMock()
    private let requestRetrier = RequestRetrierMock()
    private let config = URLSessionConfiguration.ephemeral
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
        let urlMock = URLMock(
            data: """
        { "url": "https://mock.test", "headers": {}, "args": {}, "origin": "127.0.0.1" }
        """.data(using: .utf8),
            headers: ["Content-Type": "application/json"],
            method: .get,
            statusCode: 200,
            url: url
        )
        URLProtocolMock.register(urlMock)
        let session = HTTPURLSession(configuration: config)
        let sut = session.request(url.appending("get"))

        // When
        config.protocolClasses = [URLProtocolMock.self]
        let response = await sut.serializing(TestResponse.self)

        // Then
        #expect(response.data != nil)
        #expect(response.value != nil)
        #expect(response.error == nil)
    }
    
    @Test
    func testThatSerializingWithCustomEmptyStatusCodesShouldSucceed() async {
        // Given
        let urlMock = URLMock(
            data: "".data(using: .utf8),
            headers: [:],
            method: .get,
            statusCode: 200,
            url: url
        )
        URLProtocolMock.register(urlMock)
        let session = HTTPURLSession(configuration: config)
        let sut = session.request(url.appending("status/200"))

        // When
        config.protocolClasses = [URLProtocolMock.self]
        let response = await sut.serializing(Empty.self, emptyResponseCodes: [200])
        
        // Then
        #expect(response.data == nil)
        #expect(response.value == Empty())
    }
    
    @Test
    func tesThattUploadWithRequestBuilderShouldSucceed() async {
        // Given
        let sut = HTTPURLSession()
        let data = "Test".data(using: .utf8)!
        let requestBuilder = RequestBuilderMock()
        
        // When
        let result = sut.upload(data, with: requestBuilder, middleware: nil)
        
        // Then
        #expect(result != nil)
    }
    
    @Test
    func tesThatUploadWithURLAndMethodShouldSucceed() async {
        // Given
        let sut = HTTPURLSession()
        let data = "Test".data(using: .utf8)!
        let url = URLConvertibleMock()
        
        // When
        let result = sut.upload(
            data,
            to: url,
            method: .post,
            headers: nil,
            middleware: nil
        )
        
        // Then
        #expect(result != nil)
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
        let urlMock = URLMock(
            data: nil,
            headers: [:],
            method: .get,
            statusCode: 200,
            url: url
        )
        URLProtocolMock.register(urlMock)
        let session = HTTPURLSession(configuration: config)
        let sut = session.request(url)

        // When
        config.protocolClasses = [URLProtocolMock.self]
        let response = await sut.serializingData(emptyResponseCodes: [200])

        // Then
        #expect(response.data != nil)
        #expect(response.value != nil)
        #expect(response.error == nil)
    }

    @Test
    func testThatSerializingDataWithCustomEmptyStatusCodesShouldFail() async {
        // Given
        let session = HTTPURLSession()
        let sut = session.request(url.appending("status/200"))

        // When
        let response = await sut.serializingData(emptyResponseCodes: [200])
        
        // Then
        #expect(response.value != nil)
        #expect(response.error == nil)
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
        let urlMock = URLMock(
            data: "Hello world".data(using: .utf8),
            headers: [:],
            method: .get,
            statusCode: 200,
            url: url
        )
        URLProtocolMock.register(urlMock)
        config.protocolClasses = [URLProtocolMock.self]
        let session = HTTPURLSession(configuration: config)
        let sut = session.request(url)

        // When
        let response = await sut.serializingString(emptyResponseCodes: [305])
        
        // Then
        #expect(response.value == "Hello world")
        #expect(response.error == nil)
    }
    
    @Test
    func testThatSerializingStringWithCustomEmptyStatusCodesShouldFail() async {
        // Given
        let urlMock = URLMock(
            data: Data(),
            headers: [:],
            method: .get,
            statusCode: 305,
            url: url
        )
        URLProtocolMock.register(urlMock)
        config.protocolClasses = [URLProtocolMock.self]
        let session = HTTPURLSession(configuration: config)
        let sut = session.request(url)

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
        let session = HTTPURLSession(
            middleware: Middleware(interceptors: [], retriers: [requestRetrier]),
            monitors: [monitor],
            queue: queue
        )
        let sut = session.request(url) as! HTTPURLDataRequest

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
        let session = HTTPURLSession(
            middleware: Middleware(interceptors: [], retriers: [requestRetrier]), monitors: [monitor],
            queue: queue
        )
        let sut = session.request(url) as! HTTPURLDataRequest

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
        let session = HTTPURLSession(
            middleware: Middleware(interceptors: [], retriers: [requestRetrier]), monitors: [monitor],
            queue: queue
        )
        let sut = session.request(url) as! HTTPURLDataRequest

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
        #expect(sut.request != nil)
        #expect(result.data != nil)
        #expect(result.response != nil)
        #expect(result.type == .localCache)
    }
    
    @Test
    func testThatDataRequestShouldReturnCachedDataAndDontLoadOnReturnCacheDataDontLoadPolicy() async {
        // Given
        let cache = InMemoryURLCache()
        let session = HTTPURLSession(cache: cache)
        let sut = session.request(
            url.appending("/get"),
            cachePolicy: .returnCacheDataDontLoad
        ) as! HTTPURLDataRequest

        // When
        let result = await sut.serializingData()
        
        // Then
        #expect(sut.state == .finished)
        #expect(sut.request != nil)
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
        #expect(sut.request != nil)
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
        let cache = InMemoryURLCache()
        let session = HTTPURLSession(cache: cache)
        let sut = session.request(url.appending("/200"),
            cachePolicy: .returnCacheDataElseLoad
        ) as! HTTPURLDataRequest

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
        let mock = URLMock(
            data: Data(),
            headers: [:],
            method: .get,
            statusCode: 400,
            url: url.appending("status/400")
        )
        URLProtocolMock.register(mock)
        let middleware = Middleware(interceptors: [], retriers: [requestRetrier])
        let session = HTTPURLSession(
            configuration: config,
            middleware: middleware,
            monitors: [monitor],
            queue: queue
        )
        let sut = session.request(url.appending("status/400"))

        // When
        config.protocolClasses = [URLProtocolMock.self]
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

private struct RequestBuilderMock: RequestBuilder {
    func build() throws -> URLRequest {
        URLRequest(url: URL(string: "https://example.com")!)
    }
}

private struct TestResponse: Decodable {
    let url: URL
}

private struct URLConvertibleMock: URLConvertible {
    func asURL() throws -> URL {
        URL(string: "https://test")!
    }
}
