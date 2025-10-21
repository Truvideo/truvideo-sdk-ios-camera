//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import NetworkingTesting
import Testing

@testable import Networking

struct CompositeMonitorTests {
    // MARK: - Private Properties

    private let request = DataRequestMock()
    private let sessionTaskMetrics = URLSessionTaskMetrics()
    private let url = URL(string: "https://httpbin.org/")!

    // MARK: - Tests

    @Test
    func testThatRequestDidResumeShouldCallMonitors() async {
        // Given
        var didResumeCallCount = 0
        let monitor = MonitorMock()
        let sut = CompositeMonitor(monitors: [monitor, CustomMonitor()])

        // When
        await withCheckedContinuation { continuation in
            monitor.requestDidResumeCallback = {
                didResumeCallCount += 1
                continuation.resume()
            }

            sut.requestDidResume(request)
        }

        // Then
        #expect(didResumeCallCount == 1)
    }

    @Test
    func testThatDidCancelShouldCallMonitors() async {
        // Given
        var didCancelCallCount = 0
        let monitor = MonitorMock()
        let sut = CompositeMonitor(monitors: [monitor, CustomMonitor()])

        // When
        await withCheckedContinuation { continuation in
            monitor.requestDidCancelCallback = {
                didCancelCallCount += 1
                continuation.resume()
            }

            sut.requestDidCancel(request)
        }

        // Then
        #expect(didCancelCallCount == 1)
    }

    @Test
    func testThatRequestDidFinishShouldCallMonitors() async {
        // Given
        var didFinishCallCount = 0
        let monitor = MonitorMock()
        let sut = CompositeMonitor(monitors: [monitor, CustomMonitor()])

        // When
        await withCheckedContinuation { continuation in
            monitor.requestDidFinishCallback = {
                didFinishCallCount += 1
                continuation.resume()
            }

            sut.requestDidFinish(request)
        }

        // Then
        #expect(didFinishCallCount == 1)
    }

    @Test
    func testThatDidSuspendShouldCallMonitors() async {
        // Given
        var didSuspendCallCount = 0
        let monitor = MonitorMock()
        let sut = CompositeMonitor(monitors: [monitor, CustomMonitor()])

        // When
        await withCheckedContinuation { continuation in
            monitor.requestDidSuspendCallback = {
                didSuspendCallCount += 1
                continuation.resume()
            }

            sut.requestDidSuspend(request)
        }

        // Then
        #expect(didSuspendCallCount == 1)
    }

    @Test
    func testThatRequestIsPreparingShouldCallMonitors() async {
        // Given
        let monitor = MonitorMock()
        let sut = CompositeMonitor(monitors: [monitor, CustomMonitor()])

        // When
        await withCheckedContinuation { continuation in
            monitor.requestIsPreparingCallback = {
                continuation.resume()
            }

            sut.requestIsPreparing(request)
        }

        // Then
        #expect(monitor.requestIsPreparingCallCount == 1)
    }

    @Test
    func testThatRequestIsRetryingShouldCallMonitors() async {
        // Given
        var requestIsRetryingCallCount = 0
        let monitor = MonitorMock()
        let sut = CompositeMonitor(monitors: [monitor, CustomMonitor()])

        // When
        await withCheckedContinuation { continuation in
            monitor.requestIsRetryingCallback = { _ in
                requestIsRetryingCallCount += 1
                continuation.resume()
            }

            sut.requestIsRetrying(request)
        }

        // Then
        #expect(requestIsRetryingCallCount == 1)
    }

    @Test
    func testThatRequestDidParseResponseShouldCallMonitors() async {
        // Given
        var didParseResponseCallCount = 0
        let monitor = MonitorMock()
        let sut = CompositeMonitor(monitors: [monitor, CustomMonitor()])

        // When
        await withCheckedContinuation { continuation in
            monitor.requestDidParseResponseCallback = {
                didParseResponseCallCount += 1
                continuation.resume()
            }

            sut.request(
                request,
                didParseResponse: Response(
                    data: Data(),
                    metrics: nil,
                    request: nil,
                    response: nil,
                    result: .success(nil),
                    type: .localCache
                )
            )
        }

        // Then
        #expect(didParseResponseCallCount == 1)
    }

    @Test
    func testThatRequestDidParseResponseObjectShouldCallMonitors() async {
        // Given
        var didParseResponseCallCount = 0
        let monitor = MonitorMock()
        let sut = CompositeMonitor(monitors: [monitor, CustomMonitor()])

        // When
        await withCheckedContinuation { continuation in
            monitor.requestDidParseResponseCallback = {
                didParseResponseCallCount += 1
                continuation.resume()
            }

            sut.request(
                request,
                didParseResponse: Response<Empty, NetworkingError>(
                    data: Data(),
                    metrics: nil,
                    request: nil,
                    response: nil,
                    result: .success(Empty.value),
                    type: .localCache
                )
            )
        }

        // Then
        #expect(didParseResponseCallCount == 1)
    }

    @Test
    func testThatRequestDidCollectMetricsShouldCallMonitors() async {
        // Given
        var didCollectMetricsCallCount = 0
        let monitor = MonitorMock()
        let sut = CompositeMonitor(monitors: [monitor, CustomMonitor()])

        // When
        await withCheckedContinuation { continuation in
            monitor.requestDidGatherMetricsCallback = { _ in
                didCollectMetricsCallCount += 1
                continuation.resume()
            }

            sut.request(request, didGatherMetrics: sessionTaskMetrics)
        }

        // Then
        #expect(didCollectMetricsCallCount == 1)
    }

    @Test
    func testThatRequestDidCompleteTaskShouldCallMonitors() async {
        // Given
        var didCompleteTaskCallCount = 0
        let monitor = MonitorMock()
        let task = URLSession.shared.dataTask(with: URLRequest(url: url))
        let sut = CompositeMonitor(monitors: [monitor, CustomMonitor()])

        // When
        await withCheckedContinuation { continuation in
            monitor.requestDidCompleteTaskCallback = { _, _ in
                didCompleteTaskCallCount += 1
                continuation.resume()
            }

            sut.request(request, didCompleteTask: task, with: nil)
        }

        // Then
        #expect(didCompleteTaskCallCount == 1)
    }

    @Test
    func testThatRequestDidCreateSessionTaskShouldCallMonitors() async {
        // Given
        var didCreateTaskCallCount = 0
        let monitor = MonitorMock()
        let task = URLSession.shared.dataTask(with: URLRequest(url: url))
        let sut = CompositeMonitor(monitors: [monitor, CustomMonitor()])

        // When
        await withCheckedContinuation { continuation in
            monitor.requestDidCreateTaskCallback = { _ in
                didCreateTaskCallCount += 1
                continuation.resume()
            }

            sut.request(request, didCreateTask: task)
        }

        // Then
        #expect(didCreateTaskCallCount == 1)
    }

    @Test
    func testThatRequestDidCreateURLRequestShouldCallMonitors() async {
        // Given
        var didCreateURLRequestCallCount = 0
        let monitor = MonitorMock()
        let sut = CompositeMonitor(monitors: [monitor, CustomMonitor()])

        // When
        await withCheckedContinuation { continuation in
            monitor.requestDidCreateURLRequestCallback = { _ in
                didCreateURLRequestCallCount += 1
                continuation.resume()
            }

            sut.request(request, didCreateURLRequest: try! URLRequest(url: url, method: .get))
        }

        // Then
        #expect(didCreateURLRequestCallCount == 1)
    }

    @Test
    func testThatRequestDidFailToCreateURLRequestShouldCallMonitors() async throws {
        // Given
        var didFailToCreateURLRequestCallCount = 0
        let monitor = MonitorMock()
        let sut = CompositeMonitor(monitors: [monitor, CustomMonitor()])

        // When
        await withCheckedContinuation { continuation in
            monitor.requestDidFailToCreateURLRequestCallback = { _ in
                didFailToCreateURLRequestCallCount += 1
                continuation.resume()
            }

            sut.request(request, didFailToCreateURLRequestWithError: .init(kind: .explicitlyCancelled))
        }

        // Then
        #expect(didFailToCreateURLRequestCallCount == 1)
    }

    @Test
    func testThatRequestDidFailToInterceptURLRequestShouldCallMonitors() async {
        // Given
        var didFailToInterceptURLRequestCallCount = 0
        let monitor = MonitorMock()
        let sut = CompositeMonitor(monitors: [monitor, CustomMonitor()])

        // When
        await withCheckedContinuation { continuation in
            monitor.requestDidFailToInterceptURLRequestCallback = { _ in
                didFailToInterceptURLRequestCallCount += 1
                continuation.resume()
            }

            sut.request(
                request,
                didFailToIntercept: try! URLRequest(url: url, method: .get),
                with: .init(kind: .explicitlyCancelled)
            )
        }

        // Then
        #expect(didFailToInterceptURLRequestCallCount == 1)
    }

    @Test
    func testThatRequestDidInterceptURLRequestShouldCallMonitors() async {
        // Given
        var didInterceptURLRequestlCallCount = 0
        let monitor = MonitorMock()
        let sut = CompositeMonitor(monitors: [monitor, CustomMonitor()])

        // When
        await withCheckedContinuation { continuation in
            monitor.requestDidInterceptURLRequestCallback = { _, _ in
                didInterceptURLRequestlCallCount += 1
                continuation.resume()
            }

            sut.request(
                request,
                didIntercept: try! URLRequest(url: url, method: .get),
                to: try! URLRequest(url: url, method: .get)
            )
        }

        // Then
        #expect(didInterceptURLRequestlCallCount == 1)
    }

    @Test
    func testThatRequestDidValidateRequestShouldCallMonitors() async {
        // Given
        var didValidateRequestCallCount = 0
        let monitor = MonitorMock()
        let sut = CompositeMonitor(monitors: [monitor, CustomMonitor()])

        // When
        await withCheckedContinuation { continuation in
            monitor.didValidateRequestCallback = {
                didValidateRequestCallCount += 1
                continuation.resume()
            }

            sut.request(request, didValidate: nil, data: nil, error: NetworkingError(kind: .explicitlyCancelled))
        }

        // Then
        #expect(didValidateRequestCallCount == 1)
    }

    @Test
    func testThatDidFailToInterceptURLRequestShouldCallMonitors() async {
        // Given
        var didFailToInterceptURLRequestCallCount = 0
        let monitor = MonitorMock()
        let sut = CompositeMonitor(monitors: [monitor, CustomMonitor()])

        // When
        await withCheckedContinuation { continuation in
            monitor.requestDidFailToInterceptURLRequestCallback = { _ in
                didFailToInterceptURLRequestCallCount += 1
                continuation.resume()
            }

            sut.request(
                request,
                didFailToIntercept: try! URLRequest(url: url, method: .get),
                with: NetworkingError(kind: .explicitlyCancelled)
            )
        }

        // Then
        #expect(didFailToInterceptURLRequestCallCount == 1)
    }

    @Test
    func testThatRequestDidCancelTaskShouldCallMonitors() async {
        // Given
        var didCancelTaskCallCount = 0
        let monitor = MonitorMock()
        let task = URLSession.shared.dataTask(with: URLRequest(url: url))
        let sut = CompositeMonitor(monitors: [monitor, CustomMonitor()])

        // When
        await withCheckedContinuation { continuation in
            monitor.requestDidCancelTaskCallback = {
                didCancelTaskCallCount += 1
                continuation.resume()
            }

            sut.request(request, didCancelTask: task)
        }

        // Then
        #expect(didCancelTaskCallCount == 1)
    }

    @Test
    func testThatRequestIsFinishingShouldCallMonitors() async {
        // Given
        var requestIsFinishingCallCount = 0
        let monitor = MonitorMock()
        let sut = CompositeMonitor(monitors: [monitor, CustomMonitor()])

        // When
        await withCheckedContinuation { continuation in
            monitor.requestIsFinishingCallback = {
                requestIsFinishingCallCount += 1
                continuation.resume()
            }

            sut.requestIsFinishing(request)
        }

        // Then
        #expect(requestIsFinishingCallCount == 1)
    }

    @Test
    func testThatRequestDidFailTaskWithErrorShouldCallMonitors() async {
        // Given
        var didFailTaskWithErrorCallCount = 0
        let task = URLSession.shared.dataTask(with: URLRequest(url: url))
        let monitor = MonitorMock()
        let sut = CompositeMonitor(monitors: [monitor, CustomMonitor()])

        // When
        await withCheckedContinuation { continuation in
            monitor.requestDidFailTaskWithErrorCallback = {
                didFailTaskWithErrorCallCount += 1
                continuation.resume()
            }

            sut.request(request, didFailTask: task, with: NetworkingError(kind: .explicitlyCancelled))
        }

        // Then
        #expect(didFailTaskWithErrorCallCount == 1)
    }

    @Test
    func testThatRequestDidFailToCreateTaskWithErrorShouldCallMonitors() async {
        // Given
        var didFailToCreateTaskWithErrorCallCount = 0
        let monitor = MonitorMock()
        let sut = CompositeMonitor(monitors: [monitor, CustomMonitor()])

        // When
        await withCheckedContinuation { continuation in
            monitor.requestDidFailToCreateTaskWithErrorCallback = { _ in
                didFailToCreateTaskWithErrorCallCount += 1
                continuation.resume()
            }

            sut.request(request, didFailToCreateTaskWithError: .init(kind: .explicitlyCancelled))
        }

        // Then
        #expect(didFailToCreateTaskWithErrorCallCount == 1)
    }

    @Test
    func testThatRequestDidCreateUploadableShouldCallMonitors() async {
        // Given
        var didCreateUploadableCallCount = 0
        let monitor = MonitorMock()
        let sut = CompositeMonitor(monitors: [monitor, CustomMonitor()])
        let uploadable = HTTPURLUploadRequest.Uploadable.data(Data("foo-bar".utf8))

        // When
        await withCheckedContinuation { continuation in
            monitor.uploadRequestDidCreateUploadableCallback = { _ in
                didCreateUploadableCallCount += 1
                continuation.resume()
            }

            sut.request(request, didCreateUploadable: uploadable)
        }

        // Then
        #expect(didCreateUploadableCallCount == 1)
    }

    @Test
    func testThatRequestDidFailToCreateUploadableWithErrorShouldCallMonitors() async {
        // Given
        var didFailToCreateUploadableWithErrorCallCount = 0
        let monitor = MonitorMock()
        let sut = CompositeMonitor(monitors: [monitor, CustomMonitor()])

        // When
        await withCheckedContinuation { continuation in
            monitor.uploadRequestDidFailToCreateUploadableCallback = { _ in
                didFailToCreateUploadableWithErrorCallCount += 1
                continuation.resume()
            }

            sut.request(request, didFailToCreateUploadableWithError: .init(kind: .explicitlyCancelled))
        }

        // Then
        #expect(didFailToCreateUploadableWithErrorCallCount == 1)
    }

    @Test
    func testThatRequestDidResumeTaskShouldCallMonitors() async {
        // Given
        var didResumeTaskCallCount = 0
        let task = URLSession.shared.dataTask(with: URLRequest(url: url))
        let monitor = MonitorMock()
        let sut = CompositeMonitor(monitors: [monitor, CustomMonitor()])

        // When
        await withCheckedContinuation { continuation in
            monitor.requestDidResumeTaskCallback = {
                didResumeTaskCallCount += 1
                continuation.resume()
            }

            sut.request(request, didResumeTask: task)
        }

        // Then
        #expect(didResumeTaskCallCount == 1)
    }

    @Test
    func testThatRequestDidSuspendTaskShouldCallMonitors() async {
        // Given
        var didSuspendTaskCallCount = 0
        let task = URLSession.shared.dataTask(with: URLRequest(url: url))
        let monitor = MonitorMock()
        let sut = CompositeMonitor(monitors: [monitor, CustomMonitor()])

        // When
        await withCheckedContinuation { continuation in
            monitor.requestDidSuspendTaskCallback = {
                didSuspendTaskCallCount += 1
                continuation.resume()
            }

            sut.request(request, didSuspendTask: task)
        }

        // Then
        #expect(didSuspendTaskCallCount == 1)
    }

    @Test
    func testThatRequestDidCreateInitialURLRequestShouldCallMonitors() async {
        // Given
        var didCreateInitialURLRequestCallCount = 0
        let monitor = MonitorMock()
        let sut = CompositeMonitor(monitors: [monitor, CustomMonitor()])

        // When
        await withCheckedContinuation { continuation in
            monitor.requestDidCreateInitialURLRequestCallback = {
                didCreateInitialURLRequestCallCount += 1
                continuation.resume()
            }

            sut.request(request, didCreateInitialURLRequest: URLRequest(url: url))
        }

        // Then
        #expect(didCreateInitialURLRequestCallCount == 1)
    }

    @Test
    func testThatSessionDataTaskDidReceiveDataShouldCallMonitors() async {
        // Given
        var sessionDataTaskDidReceiveDataCallCount = 0
        let task = URLSession.shared.dataTask(with: URLRequest(url: url))
        let monitor = MonitorMock()
        let sut = CompositeMonitor(monitors: [monitor, CustomMonitor()])

        // When
        await withCheckedContinuation { continuation in
            monitor.urlSessionDataTaskDidReceiveDataCallback = {
                sessionDataTaskDidReceiveDataCallCount += 1
                continuation.resume()
            }

            sut.urlSession(URLSession.shared, dataTask: task, didReceive: Data())
        }

        // Then
        #expect(sessionDataTaskDidReceiveDataCallCount == 1)
    }

    @Test
    func testThatSessionDataTaskDidReceiveResponseShouldCallMonitors() async {
        // Given
        var sessionDataTaskDidReceiveResponseCallCount = 0
        let task = URLSession.shared.dataTask(with: URLRequest(url: url))
        let monitor = MonitorMock()
        let sut = CompositeMonitor(monitors: [monitor, CustomMonitor()])

        // When
        await withCheckedContinuation { continuation in
            monitor.urlSessionDataTaskDidReceiveResponseCallback = {
                sessionDataTaskDidReceiveResponseCallCount += 1
                continuation.resume()
            }

            sut.urlSession(URLSession.shared, dataTask: task, didReceive: URLResponse())
        }

        // Then
        #expect(
            sessionDataTaskDidReceiveResponseCallCount == 1,
            "Expect sessionDataTaskDidReceiveResponseCallCount to be 1"
        )
    }

    @Test
    func testThatSessionDataTaskDidBecomeInvalidWithErrorShouldCallMonitors() async {
        // Given
        var sessionDataTaskDidBecomeInvalidWithErrorCallCount = 0
        let monitor = MonitorMock()
        let sut = CompositeMonitor(monitors: [monitor, CustomMonitor()])

        // When
        await withCheckedContinuation { continuation in
            monitor.urlSessionDidBecomeInvalidCallback = {
                sessionDataTaskDidBecomeInvalidWithErrorCallCount += 1
                continuation.resume()
            }

            sut.urlSession(URLSession.shared, didBecomeInvalidWithError: NetworkingError(kind: .explicitlyCancelled))
        }

        // Then
        #expect(
            sessionDataTaskDidBecomeInvalidWithErrorCallCount == 1,
            "Expect sessionDataTaskDidBecomeInvalidWithErrorCallCount to be 1"
        )
    }

    @Test
    func testThatSessionDataTaskDidCompleteWithErrorShouldCallMonitors() async {
        // Given
        var sessionDataTaskDidCompleteWithErrorMetricsCallCount = 0
        let task = URLSession.shared.dataTask(with: URLRequest(url: url))
        let monitor = MonitorMock()
        let sut = CompositeMonitor(monitors: [monitor, CustomMonitor()])

        // When
        await withCheckedContinuation { continuation in
            monitor.urlSessionTaskDidCompletedWithErrorCallback = {
                sessionDataTaskDidCompleteWithErrorMetricsCallCount += 1
                continuation.resume()
            }

            sut.urlSession(URLSession.shared, task: task, didCompleteWithError: nil)
        }

        // Then
        #expect(sessionDataTaskDidCompleteWithErrorMetricsCallCount == 1)
    }

    @Test
    func testThatSessionDataTaskDidFinishCollectingMetricsShouldCallMonitors() async {
        // Given
        var sessionDataTaskDidFinishCollectingMetricsCallCount = 0
        let task = URLSession.shared.dataTask(with: URLRequest(url: url))
        let monitor = MonitorMock()
        let sut = CompositeMonitor(monitors: [monitor, CustomMonitor()])

        // When
        await withCheckedContinuation { continuation in
            monitor.urlSessionTaskDidFinishCollectingMetricsCallback = {
                sessionDataTaskDidFinishCollectingMetricsCallCount += 1
                continuation.resume()
            }

            sut.urlSession(URLSession.shared, task: task, didFinishCollecting: sessionTaskMetrics)
        }

        // Then
        #expect(sessionDataTaskDidFinishCollectingMetricsCallCount == 1)
    }
}

private struct CustomMonitor: Monitor {}
extension DataRequestMock: @retroactive UploadRequest {}
