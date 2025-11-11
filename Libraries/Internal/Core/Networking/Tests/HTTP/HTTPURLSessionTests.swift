//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Networking
import NetworkingTesting
import Testing

@testable import Networking

struct SessionTests {
    // MARK: - Properties

    let url = "https://httpbin.org/"

    // MARK: - Tests

    @Test
    func testInitializerWithDefaultArguments() {
        // Given
        let sut = HTTPURLSession()

        // When, Then
        #expect(sut.session.delegate != nil)
        #expect(sut.delegate === sut.session.delegate)
    }

    @Test
    func testInitializerWithCustomArguments() {
        // Given
        let configuration = URLSessionConfiguration.default
        let delegate = HTTPURLSessionDelegate()
        let queue = DispatchQueue(label: "underlyingQueue")

        // When
        let sut = HTTPURLSession(configuration: configuration, delegate: delegate, queue: queue)

        // Then
        #expect(sut.session.delegate != nil)
        #expect(sut.delegate === sut.session.delegate)
    }

    // MARK: - DataRequest

    @Test
    func testThatCancelAllRequests() async throws {
        // Given
        let sut = HTTPURLSession()

        // When
        _ = sut.request(url)

        try await Task.sleep(nanoseconds: 1_000)

        sut.cancelAllRequests()

        // Then
        #expect(sut.activeRequests.count == 0)
    }

    @Test
    func testThatReleasingSessionWithPendingRequestsDeinitializesSuccessfully() async {
        // Given
        let monitor = MonitorMock()
        var sut: HTTPURLSession? = HTTPURLSession(monitors: [monitor])
        weak var weakSession = sut

        // When
        let request = sut?.request(url) as! HTTPURLDataRequest

        await withCheckedContinuation { continuation in
            monitor.requestDidCreateTaskCallback = { _ in
                sut = nil

                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    continuation.resume()
                }
            }
        }

        // Then
        #expect([.canceling, .completed].contains(request.tasks.last?.state))
        #expect(sut == nil, "Expect session should be nil")
        #expect(weakSession == nil, "Expect weak session should be nil")
    }

    @Test
    func testThatReleasingSessionWithPendingCanceledRequestDeinitializesSuccessfully() {
        // Given
        var sut: HTTPURLSession? = HTTPURLSession()

        // When
        let request = sut?.request(url) as! HTTPURLDataRequest

        request.cancel()
        sut = nil

        // Then
        #expect(request.state == .cancelled, "Expect state should be .cancelled")
        #expect(sut == nil, "Expect session should be nil")
    }

    @Test
    func testThatDataRequestWithInvalidURLStringThrowsAnError() async {
        // Given
        let sut = HTTPURLSession()

        // When
        let response = await sut.request("").serializingData()

        // Then
        #expect(response.request == nil, "Expect request to be nil")
        #expect(response.response == nil, "Expect response to be nil")
        #expect(response.data == nil, "Expect data to be nil")
        #expect(response.error?.kind == .invalidURL, "Expect error to be .invalidURL")
    }

    @Test
    func testThatDataRequestWithRequestMiddleware() async {
        // Given
        let middleware = Middleware(interceptors: [], retriers: [])
        let sut = HTTPURLSession()

        // When
        let request = sut.request(url, middleware: middleware) as! HTTPURLDataRequest

        // Then
        #expect(request.middleware != nil, "Expect middleware to not be nil")
    }

    @Test
    func testThatDataRequestWithCustomRequestBuilderShouldThrowAnError() async {
        // Given
        let requestBuilder = TestRequestBuilder()
        let sut = HTTPURLSession()

        // When
        let response = await sut.request(requestBuilder).serializingData()

        // Then
        #expect(response.request == nil, "Expect request to be nil")
        #expect(response.response == nil, "Expect response to be nil")
        #expect(response.data == nil, "Expect data to be nil")
        #expect(response.error?.kind == .requestCreationFailed, "Expect error to be .invalidURL")
    }

    @Test
    func testThatSessionCallsMonitorsWhenCreatingDataRequest() async {
        // Given
        let requestInterceptor = RequestInterceptorMock()
        let monitor = MonitorMock()
        let sut = HTTPURLSession(monitors: [monitor])

        // When
        await withCheckedContinuation { continuation in
            monitor.requestDidCreateTaskCallback = { _ in
                continuation.resume()
            }

            _ = sut.request(url, middleware: Middleware(interceptors: [requestInterceptor], retriers: []))
        }

        // Then
        #expect(monitor.requestDidCreateTaskCallCount == 1)
        #expect(monitor.requestDidCreateURLRequestCallCount == 1)
        #expect(monitor.requestDidInterceptURLRequestCallCount == 1)
        #expect(monitor.requestDidFailToInterceptURLRequestCallCount == 0)
        #expect(monitor.requestDidCreateInitialURLRequestCallCount == 1)
    }

    @Test
    func testThatSessionCallsMonitorsWhenCreatingDataRequestWithFailedInterception() async {
        // Given
        let requestInterceptor = RequestInterceptorMock()
        let monitor = MonitorMock()
        let sut = HTTPURLSession(monitors: [monitor])

        // When
        requestInterceptor.error = NSError(domain: "", code: 0)

        await withCheckedContinuation { continuation in
            monitor.requestDidFailToInterceptURLRequestCallback = { _ in
                continuation.resume()
            }

            _ = sut.request(url, middleware: Middleware(interceptors: [requestInterceptor], retriers: []))
        }

        // Then
        #expect(monitor.requestDidCreateTaskCallCount == 0)
        #expect(monitor.requestDidCreateURLRequestCallCount == 0)
        #expect(monitor.requestDidInterceptURLRequestCallCount == 0)
        #expect(monitor.requestDidFailToInterceptURLRequestCallCount == 1)
        #expect(monitor.requestDidCreateInitialURLRequestCallCount == 1)
    }

    @Test
    func testThatSessionCallsMonitorsWhenCreatingDataRequestWithCancelledRequest() async throws {
        // Given
        let monitor = MonitorMock()
        let sut = HTTPURLSession(monitors: [monitor], queue: .main)
        let request = sut.request(url)

        // When
        request.cancel()
        await withCheckedContinuation { continuation in
            monitor.requestDidCreateInitialURLRequestCallback = {
                continuation.resume()
            }
        }

        // Then
        #expect(monitor.requestDidCancelCallCount == 1)
        #expect(monitor.requestDidCreateTaskCallCount == 0)
        #expect(monitor.requestDidCreateURLRequestCallCount == 0)
        #expect(monitor.requestDidInterceptURLRequestCallCount == 0)
        #expect(monitor.requestDidFailToInterceptURLRequestCallCount == 0)
        #expect(monitor.requestDidCreateInitialURLRequestCallCount == 1)
    }

    @Test
    func testThatSuccessfulRequestCallsAllMonitorsEvents() async throws {
        // Given
        let requestInterceptor = RequestInterceptorMock()
        let middleware = Middleware(interceptors: [requestInterceptor], retriers: [])
        let monitor = MonitorMock()
        let sut = HTTPURLSession(middleware: middleware, monitors: [monitor])

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

        try await Task.sleep(nanoseconds: 1_000)

        // Then
        #expect(monitor.requestDidCreateTaskCallCount == 1)
        #expect(monitor.requestDidCompleteTaskCallCount == 1)
        #expect(monitor.requestDidResumeTaskCallCount == 1)
        #expect(monitor.requestDidCreateURLRequestCallCount == 1)
        #expect(monitor.requestDidFinishCallCount == 1)
        #expect(monitor.requestDidGatherMetricsCallCount == 1)
        #expect(monitor.requestDidParseResponseCallCount == 1)
        #expect(monitor.requestDidResumeCallCount == 1)
        #expect(monitor.requestDidValidateCallCount == 1)
        #expect(monitor.requestIsFinishingCallCount == 1)
        #expect(monitor.requestDidInterceptURLRequestCallCount == 1)
        #expect(monitor.requestDidFailToInterceptURLRequestCallCount == 0)
        #expect(monitor.requestDidCreateInitialURLRequestCallCount == 1)
    }

    @Test func testThatRequestShouldRetryOnFailure() async {
        // Given
        let requestRetrier = RequestRetrierMock()
        let middleware = Middleware(interceptors: [], retriers: [requestRetrier])
        let monitor = MonitorMock()
        let sut = HTTPURLSession(middleware: middleware, monitors: [monitor])

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
        let sut = HTTPURLSession(middleware: middleware)
        let request = sut.request(url, middleware: middleware) as! HTTPURLDataRequest
        let expectedLocalizedDescription = """
        Request retry failed with retry error: \(error.localizedDescription), \
        original error: \(originalError.localizedDescription)
        """
        // When
        requestRetrier.retry = .doNotRetryWithError(error)

        let retryPolicy = await sut.retry(request: request, failedWith: originalError)

        // Then
        switch retryPolicy {
        case let .doNotRetryWithError(error):
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
        let sut = HTTPURLSession(middleware: middleware)
        let request = sut.request(url, middleware: middleware) as! HTTPURLDataRequest

        // When
        requestRetrier.retry = .retry(1)

        let retryPolicy = await sut.retry(request: request, failedWith: error)

        // Then
        switch retryPolicy {
        case let .retry(delay):
            #expect(delay == 1, "Expect delay to be equals to 1")

        default:
            fatalError("Should not be called")
        }
    }

    @Test func testThatSessionBecameInvalidShouldFinishRequestsWithError() async {
        // Given
        let error = NetworkingError(kind: .sessionInvalidated)
        let monitor = MonitorMock()
        let sut = HTTPURLSession(monitors: [monitor])
        let request = sut.request(url) as! HTTPURLDataRequest

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
        #expect(request.error?.kind == .sessionInvalidated)
        #expect(request.state == .finished)
    }

    // MARK: - UploadRequest

    @Test
    func testThatUploadDataRequestShouldThrowAnErrorOnCreatingUploadable() async {
        // Given
        let sut = HTTPURLSession()
        let uploadData = Data()
        let request = sut.upload(uploadData, to: url) as! HTTPURLUploadRequest

        // When
        let response = await request.serializingData()

        // Then
        #expect(request.uploadable == nil)
        #expect(response.request == nil, "Expect request to be nil")
        #expect(response.response == nil, "Expect response to be nil")
        #expect(response.data == nil, "Expect data to be nil")
        #expect(response.error?.kind == .createUploadableFailed, "Expect error to be .createUploadableFailed")
    }

    @Test
    func testThatUploadDataRequestWithCustomRequestBuilderShouldThrowAnError() async {
        // Given
        let requestBuilder = TestRequestBuilder()
        let sut = HTTPURLSession()
        let uploadData = Data("upload data".utf8)
        let request = sut.upload(uploadData, with: requestBuilder) as! HTTPURLUploadRequest

        // When
        let response = await request.serializingData()

        // Then
        #expect(request.uploadable != nil)
        #expect(response.request == nil, "Expect request to be nil")
        #expect(response.response == nil, "Expect response to be nil")
        #expect(response.data == nil, "Expect data to be nil")
        #expect(response.error?.kind == .requestCreationFailed, "Expect error to be .requestCreationFailed")
    }

    @Test
    func testThatSessionCallsMonitorsWhenCreatingUploadDataRequest() async {
        // Given
        let requestInterceptor = RequestInterceptorMock()
        let middleware = Middleware(interceptors: [requestInterceptor], retriers: [])
        let monitor = MonitorMock()
        let sut = HTTPURLSession(monitors: [monitor])
        let uploadData = Data("upload data".utf8)

        // When
        await withCheckedContinuation { continuation in
            monitor.requestDidCreateTaskCallback = { _ in
                continuation.resume()
            }

            _ = sut.upload(uploadData, to: url, middleware: middleware)
        }

        // Then
        #expect(monitor.requestDidCreateTaskCallCount == 1)
        #expect(monitor.requestDidCreateURLRequestCallCount == 1)
        #expect(monitor.requestDidInterceptURLRequestCallCount == 1)
        #expect(monitor.requestDidFailToInterceptURLRequestCallCount == 0)
        #expect(monitor.requestDidCreateInitialURLRequestCallCount == 1)
    }

    @Test
    func testThatSessionCallsMonitorsWhenCreatingUploadDataRequestWithFailedInterception() async {
        // Given
        let requestInterceptor = RequestInterceptorMock()
        let middleware = Middleware(interceptors: [requestInterceptor], retriers: [])
        let monitor = MonitorMock()
        let sut = HTTPURLSession(monitors: [monitor])
        let uploadData = Data("upload data".utf8)

        // When
        requestInterceptor.error = NSError(domain: "", code: 0)

        await withCheckedContinuation { continuation in
            monitor.requestDidFailToInterceptURLRequestCallback = { _ in
                continuation.resume()
            }

            _ = sut.upload(uploadData, to: url, middleware: middleware)
        }

        // Then
        #expect(monitor.requestDidCreateTaskCallCount == 0)
        #expect(monitor.requestDidCreateURLRequestCallCount == 0)
        #expect(monitor.requestDidInterceptURLRequestCallCount == 0)
        #expect(monitor.requestDidFailToInterceptURLRequestCallCount == 1)
        #expect(monitor.requestDidCreateInitialURLRequestCallCount == 1)
    }

    @Test
    func testThatSessionCallsMonitorsWhenCreatingUploadDataRequestWithCancelledRequest() async throws {
        // Given
        let monitor = MonitorMock()
        let sut = HTTPURLSession(monitors: [monitor], queue: .main)
        let uploadData = Data("upload data".utf8)
        let request = sut.upload(uploadData, to: url)

        // When
        request.cancel()
        await withCheckedContinuation { continuation in
            monitor.requestDidCreateInitialURLRequestCallback = {
                continuation.resume()
            }
        }

        // Then
        #expect(monitor.requestDidCancelCallCount == 1)
        #expect(monitor.requestDidCreateTaskCallCount == 0)
        #expect(monitor.requestDidCreateURLRequestCallCount == 0)
        #expect(monitor.requestDidInterceptURLRequestCallCount == 0)
        #expect(monitor.requestDidFailToInterceptURLRequestCallCount == 0)
        #expect(monitor.requestDidCreateInitialURLRequestCallCount == 1)
    }

    @Test
    func testThatSuccessfulUploadDataRequestCallsAllMonitorsEvents() async throws {
        // Given
        let requestInterceptor = RequestInterceptorMock()
        let middleware = Middleware(interceptors: [requestInterceptor], retriers: [])
        let monitor = MonitorMock()
        let sut = HTTPURLSession(middleware: middleware, monitors: [monitor])
        let uploadData = Data("upload data".utf8)

        // When
        Task {
            _ = await sut.upload(uploadData, to: url.appending("get"))
                .validate()
                .serializingData()
        }

        await withCheckedContinuation { continuation in
            monitor.requestDidFinishCallback = {
                continuation.resume()
            }
        }

        try await Task.sleep(nanoseconds: 1_000)

        // Then
        #expect(monitor.requestDidCreateTaskCallCount == 1)
        #expect(monitor.requestDidCompleteTaskCallCount == 1)
        #expect(monitor.requestDidResumeTaskCallCount == 1)
        #expect(monitor.requestDidCreateURLRequestCallCount == 1)
        #expect(monitor.requestDidFinishCallCount == 1)
        #expect(monitor.requestDidGatherMetricsCallCount == 1)
        #expect(monitor.requestDidParseResponseCallCount == 1)
        #expect(monitor.requestDidResumeCallCount == 1)
        #expect(monitor.requestDidValidateCallCount == 1)
        #expect(monitor.requestIsFinishingCallCount == 1)
        #expect(monitor.requestDidInterceptURLRequestCallCount == 1)
        #expect(monitor.requestDidFailToInterceptURLRequestCallCount == 0)
        #expect(monitor.requestDidCreateInitialURLRequestCallCount == 1)
    }

    @Test
    func testThatUploadDataRequestShouldRetryOnFailure() async {
        // Given
        let requestRetrier = RequestRetrierMock()
        let middleware = Middleware(interceptors: [], retriers: [requestRetrier])
        let monitor = MonitorMock()
        let sut = HTTPURLSession(middleware: middleware, monitors: [monitor])
        let uploadData = Data("upload data".utf8)

        // When
        requestRetrier.maxNumberOfRetries = 1

        Task {
            _ = await sut.upload(uploadData, to: url.appending("status/500"), middleware: middleware)
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
}

private struct TestRequestBuilder: RequestBuilder {
    func build() throws -> URLRequest {
        throw NSError(domain: "", code: 0)
    }
}
