//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import NetworkingTesting
import Testing

@testable import Networking

struct SessionTests {
    // MARK: - Properties
    
    let url = "https://httpbin.org/"
    
    // MARK: - Tests
    
    @Test func testInitializerWithDefaultArguments() {
        // Given
        let sut = Session()
        
        // When, Then
        #expect(sut.session.delegate != nil, "Expected session delegate should not be nil")
        #expect(sut.delegate === sut.session.delegate, "Expected manager delegate should equal session delegate")
    }
    
    func testInitializerWithCustomArguments() {
        // Given
        let configuration = URLSessionConfiguration.default
        let delegate = SessionDelegate()
        let queue = DispatchQueue(label: "underlyingQueue")
        
        // When
        let sut = Session(configuration: configuration, delegate: delegate, queue: queue)
        
        // Then
        #expect(sut.session.delegate != nil, "Expect session delegate should not be nil")
        #expect(sut.delegate === sut.session.delegate, "Expect manager delegate should equal session delegate")
    }
    
    @Test func testThatCancelAllRequests() async throws {
        // Given
        let sut = Session()
        
        // When
        _ = sut.request(url)
        
        try await Task.sleep(for: .milliseconds(1000))
        
        sut.cancelAllRequests()
        
        try await Task.sleep(for: .milliseconds(1000))
        
        // Then
        #expect(sut.activeRequests.first?.state == .cancelled, "Expect state to be cancelled")
    }
    
    @Test func testThatReleasingSessionWithPendingRequestsDeinitializesSuccessfully() async {
        // Given
        let monitor = MonitorMock()
        var sut: Session? = Session(monitors: [monitor])
        weak var weakSession = sut
                
        // When
        let request = sut?.request(url)
        
        await withCheckedContinuation { continuation in
            monitor.requestDidCreateTaskCallback = { _ in
                sut = nil
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    continuation.resume()
                }
            }
        }
        
        // Then
        #expect([.canceling, .completed].contains(request?.tasks.last?.state))
        #expect(sut == nil, "Expect session should be nil")
        #expect(weakSession == nil, "Expect weak session should be nil")
    }
    
    @Test func testThatReleasingSessionWithPendingCanceledRequestDeinitializesSuccessfully() {
        // Given
        var sut: Session? = Session()
        
        // When
        let request = sut?.request(url)
        
        request?.cancel()
        sut = nil
        
        // Then
        #expect(request?.state == .cancelled, "Expect state should be .cancelled")
        #expect(sut == nil, "Expect session should be nil")
    }
    
    @Test func testThatDataRequestWithInvalidURLStringThrowsAnError() async {
        // Given
        let sut = Session()
        
        // When
        let response = await sut.request("").serializingData()
        
        // Then
        #expect(response.request == nil, "Expect request to be nil")
        #expect(response.response == nil, "Expect response to be nil")
        #expect(response.data == nil, "Expect data to be nil")
        #expect(response.error?.kind == .invalidURL, "Expect error to be .invalidURL")
    }
    
    @Test func testThatDataRequestWithRequestMiddleware() async {
        // Given
        let middleware = Middleware(interceptors: [], retriers: [])
        let sut = Session()
        
        // When
        let request = sut.request(url, middleware: middleware)
        
        // Then
        #expect(request.middleware != nil, "Expect middleware to not be nil")
    }
    
    @Test func testThatDataRequestWithCustomRequestBuilderShouldThrowAnError() async {
        // Given
        let requestBuilder = TestRequestBuilder()
        let sut = Session()
        
        // When
        let response = await sut.request(requestBuilder).serializingData()
        
        // Then
        #expect(response.request == nil, "Expect request to be nil")
        #expect(response.response == nil, "Expect response to be nil")
        #expect(response.data == nil, "Expect data to be nil")
        #expect(response.error?.kind == .requestCreationFailed, "Expect error to be .invalidURL")
    }
    
    @Test func testThatSessionCallsMonitorsWhenCreatingDataRequest() async {
        // Given
        let requestInterceptor = RequestInterceptorMock()
        let monitor = MonitorMock()
        let sut = Session(monitors: [monitor])
        
        // When
        await withCheckedContinuation { continuation in
            monitor.requestDidCreateTaskCallback = { _ in
                continuation.resume()
            }
            
            _ = sut.request(url, middleware: Middleware(interceptors: [requestInterceptor], retriers: []))
        }
        
        // Then
        #expect(monitor.requestDidCreateTaskCallCount == 1, "Expect requestDidCreateTaskCallCount to be 1")
        #expect(monitor.requestDidCreateURLRequestCallCount == 1, "Expect requestDidCreateURLRequestCallCount to be 1")
        #expect(
            monitor.requestDidInterceptURLRequestCallCount == 1,
            "Expect requestDidInterceptURLRequestCallCount to be 1"
        )
        #expect(
            monitor.requestDidFailToInterceptURLRequestCallCount == 0,
            "Expect requestDidFailToInterceptURLRequestCallCount to be 0"
        )
        #expect(
            monitor.requestDidCreateInitialURLRequestCallCount == 1,
            "Expect requestDidCreateInitialURLRequestCallCount to be 1"
        )
    }
    
    @Test func testThatSessionCallsMonitorsWhenCreatingDataRequestWithFailedInterception() async {
        // Given
        let requestInterceptor = RequestInterceptorMock()
        let monitor = MonitorMock()
        let sut = Session(monitors: [monitor])
        
        // When
        requestInterceptor.error = NSError(domain: "", code: 0)
        
        await withCheckedContinuation { continuation in
            monitor.requestDidFailToInterceptURLRequestCallback = { _ in
                continuation.resume()
            }
            
            _ = sut.request(url, middleware: Middleware(interceptors: [requestInterceptor], retriers: []))
        }
        
        // Then
        #expect(monitor.requestDidCreateTaskCallCount == 0, "Expect requestDidCreateTaskCallCount to be 0")
        #expect(monitor.requestDidCreateURLRequestCallCount == 0, "Expect requestDidCreateURLRequestCallCount to be 0")
        #expect(
            monitor.requestDidInterceptURLRequestCallCount == 0,
            "Expect requestDidInterceptURLRequestCallCount to be 0"
        )
        #expect(
            monitor.requestDidFailToInterceptURLRequestCallCount == 1,
            "Expect requestDidFailToInterceptURLRequestCallCount to be 1"
        )
        #expect(
            monitor.requestDidCreateInitialURLRequestCallCount == 1,
            "Expect requestDidCreateInitialURLRequestCallCount to be 1"
        )
    }
    
    @Test func testThatSessionCallsMonitorsWhenCreatingDataRequestWithCancelledRequest() async throws {
        // Given
        let monitor = MonitorMock()
        let sut = Session(monitors: [monitor], queue: .main)
        let request = sut.request(url)
        
        // When
        request.cancel()
        await withCheckedContinuation { continuation in
            monitor.requestDidCreateInitialURLRequestCallback = {
                continuation.resume()
            }
        }
        
        // Then
        #expect(monitor.requestDidCancelCallCount == 1, "Expect requestDidCancelCallCount to be 1")
        #expect(monitor.requestDidCreateTaskCallCount == 0, "Expect requestDidCreateTaskCallCount to be 0")
        #expect(monitor.requestDidCreateURLRequestCallCount == 0, "Expect requestDidCreateURLRequestCallCount to be 0")
        #expect(
            monitor.requestDidInterceptURLRequestCallCount == 0,
            "Expect requestDidInterceptURLRequestCallCount to be 0"
        )
        #expect(
            monitor.requestDidFailToInterceptURLRequestCallCount == 0,
            "Expect requestDidFailToInterceptURLRequestCallCount to be 1"
        )
        #expect(
            monitor.requestDidCreateInitialURLRequestCallCount == 1,
            "Expect requestDidCreateInitialURLRequestCallCount to be 1"
        )
    }
    
    @Test func testThatSuccessfulRequestCallsAllMonitorsEvents() async throws {
        // Given
        let requestInterceptor = RequestInterceptorMock()
        let middleware = Middleware(interceptors: [requestInterceptor], retriers: [])
        let monitor = MonitorMock()
        let sut = Session(middleware: middleware, monitors: [monitor])
        
        // When
        Task {
            _ = await sut.request(url.appending("get"), middleware: middleware)
                .validate()
                .serializingData()
        }
        
        await withCheckedContinuation { continuation in
            monitor.requestDidFinishCallback = {
                continuation.resume()
            }
        }
        
        try await Task.sleep(for: .milliseconds(500))
        
        // Then
        #expect(monitor.requestDidCreateTaskCallCount == 1, "Expect requestDidCreateTaskCallCount to be 1")
        #expect(monitor.requestDidCompleteTaskCallCount == 1, "Expect requestDidCompleteTaskCallCount to be 1")
        #expect(monitor.requestDidResumeTaskCallCount == 1, "Expect requestDidResumeTaskCallCount to be 1")
        #expect(monitor.requestDidCreateURLRequestCallCount == 1, "Expect requestDidCreateURLRequestCallCount to be 1")
        #expect(monitor.requestDidFinishCallCount == 1, "Expect requestDidFinishCallCount to be 1")
        #expect(monitor.requestDidGatherMetricsCallCount == 1, "Expect requestDidGatherMetricsCallCount to be 1")
        #expect(monitor.requestDidParseResponseCallCount == 1, "Expect requestDidParseResponseCallCount to be 1")
        #expect(monitor.requestDidResumeCallCount == 1, "Expect requestDidResumeCallCount to be 1")
        #expect(monitor.requestDidValidateCallCount == 1, "Expect requestDidValidateCallCount to be 1")
        #expect(monitor.requestIsFinishingCallCount == 1, "Expect requestIsFinishingCallCount to be 1")
        #expect(
            monitor.requestDidInterceptURLRequestCallCount == 1,
            "Expect requestDidInterceptURLRequestCallCount to be 1"
        )
        #expect(
            monitor.requestDidFailToInterceptURLRequestCallCount == 0,
            "Expect requestDidFailToInterceptURLRequestCallCount to be 0"
        )
        #expect(
            monitor.requestDidCreateInitialURLRequestCallCount == 1,
            "Expect requestDidCreateInitialURLRequestCallCount to be 1"
        )
    }
    
    @Test func testThatRequestShouldRetryOnFailure() async {
        // Given
        let requestRetrier = RequestRetrierMock()
        let middleware = Middleware(interceptors: [], retriers: [requestRetrier])
        let monitor = MonitorMock()
        let sut = Session(middleware: middleware, monitors: [monitor])
        
        // When
        requestRetrier.maxNumberOfRetries = 1
        
        Task {
            _ = await sut.request(url.appending("status/500"), middleware: middleware)
                .validate()
                .serializingData()
        }
        
        await withCheckedContinuation { continuation in
            monitor.requestIsRetryingCallback = { _ in
                continuation.resume()
            }
        }
        
        // Then
        #expect(monitor.requestIsRetryingCallCount == 1, "Expect requestIsFinishingCallCount to be 1")
    }
    
    @Test func testThatRetryWithDoNotRetryWithErrorShouldReturnOriginalErrorAndError() async {
        // Given
        let requestRetrier = RequestRetrierMock()
        let middleware = Middleware(interceptors: [], retriers: [requestRetrier])
        let originalError = NetworkingError(kind: .invalidURL)
        let error = NSError(domain: "", code: 0)
        let sut = Session(middleware: middleware)
        let request = sut.request(url, middleware: middleware)
        let expectedLocalizedDescription = """
                                    Request retry failed with retry error: \(error.localizedDescription), \
                                    original error: \(originalError.localizedDescription)
                                    """
        // When
        requestRetrier.retry = .doNotRetryWithError(error)
        
        let retryPolicy = await sut.retry(request: request, failedWith: originalError)
        
        // Then
        switch retryPolicy {
        case .doNotRetryWithError(let error):
            #expect(
                error.localizedDescription == expectedLocalizedDescription,
                "Expect localizedDescription to be equals to \(expectedLocalizedDescription)"
            )
            
        default:
            fatalError("Should not be called")
        }
    }
    
    @Test func testThatRetryShouldReturnTheOriginalRetryPolicy() async {
        // Given
        let requestRetrier = RequestRetrierMock()
        let middleware = Middleware(interceptors: [], retriers: [requestRetrier])
        let error = NetworkingError(kind: .invalidURL)
        let sut = Session(middleware: middleware)
        let request = sut.request(url, middleware: middleware)
                                    
        // When
        requestRetrier.retry = .retry(1)
        
        let retryPolicy = await sut.retry(request: request, failedWith: error)
        
        // Then
        switch retryPolicy {
        case .retry(let delay):
            #expect(delay == 1, "Expect delay to be equals to 1")
            
        default:
            fatalError("Should not be called")
        }
    }
    
    @Test func testThatSessionBecameInvalidShouldFinishRequestsWithError() async {
        // Given
        let error = NetworkingError(kind: .sessionInvalidated)
        let monitor = MonitorMock()
        let sut = Session(monitors: [monitor])
        let request = sut.request(url)
        
        // When
        Task {
            _ = await request.validate()
                .serializingData()
        }
        
        await withCheckedContinuation { continuation in
            monitor.requestDidCreateInitialURLRequestCallback = {
                continuation.resume()
            }
        }
        
        await withCheckedContinuation { continuation in
            monitor.requestDidFinishCallback = {
                continuation.resume()
            }
            
            sut.queue.async {
                sut.sessionDidBecomeInvalid(with: error)
            }
        }
        
        // Then
        #expect(request.error?.kind == .sessionInvalidated, "Expect error to be sessionInvalidated")
        #expect(request.state == .finished, "Expect state to be finished")
    }
}

private struct TestRequestBuilder: RequestBuilder {
    func build() throws -> URLRequest {
        throw NSError(domain: "", code: 0)
    }
}
