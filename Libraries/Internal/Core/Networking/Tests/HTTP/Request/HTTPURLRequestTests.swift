//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import NetworkingTesting
import Testing

@testable import Networking

struct HTTPURLRequestTests {
    // MARK: - Private Properties

    private let queue = DispatchQueue.global()
    private let request = URLRequest(url: URL(string: "https://httpbin.org/")!)

    // MARK: - Tests

    @Test
    func testThatCancelShouldCallMonitor() async {
        // Given
        let monitor = MonitorMock()
        let sut = HTTPURLRequest(delegate: nil, middleware: nil, monitor: monitor, queue: queue)

        // When
        await withCheckedContinuation { continuation in
            monitor.requestDidCancelCallback = {
                continuation.resume()
            }

            queue.async {
                sut.didCancel()
            }
        }

        // Then
        #expect(monitor.requestDidCancelCallCount == 1)
    }

    @Test
    func testThatDidCancelTaskShouldCallMonitor() async {
        // Given
        let monitor = MonitorMock()
        let task = URLSession.shared.dataTask(with: request)
        let sut = HTTPURLRequest(delegate: nil, middleware: nil, monitor: monitor, queue: queue)

        // When
        await withCheckedContinuation { continuation in
            monitor.requestDidCancelTaskCallback = {
                continuation.resume()
            }

            queue.async {
                sut.didCancel(task: task)
            }
        }

        // Then
        #expect(monitor.requestDidCancelTaskCallCount == 1)
    }

    @Test
    func testThatDidCompleteShouldRunValidatorsAndSetError() async {
        // Given
        let error = NetworkingError(kind: .explicitlyCancelled)
        let task = URLSession.shared.dataTask(with: request)
        let sut = HTTPURLRequest(delegate: nil, middleware: nil, monitor: nil, queue: queue)

        // When
        await withCheckedContinuation { continuation in
            sut.validators.append {
                continuation.resume()
            }

            queue.async {
                sut.didComplete(task: task, error: error)
            }
        }

        // Then
        #expect(sut.error?.kind == .explicitlyCancelled)
    }

    @Test
    func testThatDidCreateInitialRequestShouldCallMonitorAndAppendRequest() async {
        // Given
        let monitor = MonitorMock()
        let sut = HTTPURLRequest(delegate: nil, middleware: nil, monitor: monitor, queue: queue)

        // When
        await withCheckedContinuation { continuation in
            monitor.requestDidCreateInitialURLRequestCallback = {
                continuation.resume()
            }

            queue.async {
                sut.didCreateInitial(request: request)
            }
        }

        // Then
        #expect(sut.requests.count == 1)
        #expect(monitor.requestDidCreateInitialURLRequestCallCount == 1)
    }

    @Test
    func testThatDidCreateTaskShouldCallMonitorAndAppendTask() async {
        // Given
        let monitor = MonitorMock()
        let task = URLSession.shared.dataTask(with: request)
        let sut = HTTPURLRequest(delegate: nil, middleware: nil, monitor: monitor, queue: queue)

        // When
        await withCheckedContinuation { continuation in
            monitor.requestDidCreateTaskCallback = { _ in
                continuation.resume()
            }

            queue.async {
                sut.didCreate(task: task)
            }
        }

        // Then
        #expect(sut.tasks.count == 1)
        #expect(monitor.requestDidCreateTaskCallCount == 1)
    }

    @Test
    func testThatDidCreateTaskWhenRequestIsCancelledShouldResumeAndCancelTheTask() async {
        // Given
        let monitor = MonitorMock()
        let task = URLSession.shared.dataTask(with: request)
        let sut = HTTPURLRequest(delegate: nil, middleware: nil, monitor: monitor, queue: queue)

        // When
        sut.cancel()

        await withCheckedContinuation { continuation in
            monitor.requestDidCancelTaskCallback = {
                continuation.resume()
            }

            queue.async {
                sut.didCreate(task: task)
            }
        }

        // Then
        #expect(sut.tasks.count == 1)
        #expect(monitor.requestDidCancelTaskCallCount == 1)
    }

    @Test
    func testThatDidCreateTaskWhenRequestIsResumedShouldResumeTheTask() async {
        // Given
        let monitor = MonitorMock()
        let task = URLSession.shared.dataTask(with: request)
        let sut = HTTPURLRequest(delegate: nil, middleware: nil, monitor: monitor, queue: queue)

        // When
        sut.state = .resumed

        await withCheckedContinuation { continuation in
            monitor.requestDidResumeTaskCallback = {
                continuation.resume()
            }

            queue.async {
                sut.didCreate(task: task)
            }
        }

        // Then
        #expect(sut.tasks.count == 1)
        #expect(monitor.requestDidResumeTaskCallCount == 1)
    }

    @Test
    func testThatDidCreateTaskWhenRequestIsSuspendedShouldSuspendTheTask() async {
        // Given
        let monitor = MonitorMock()
        let task = URLSession.shared.dataTask(with: request)
        let sut = HTTPURLRequest(delegate: nil, middleware: nil, monitor: monitor, queue: queue)

        // When
        sut.state = .suspended

        await withCheckedContinuation { continuation in
            monitor.requestDidSuspendTaskCallback = {
                continuation.resume()
            }

            queue.async {
                sut.didCreate(task: task)
            }
        }

        // Then
        #expect(sut.tasks.count == 1)
        #expect(monitor.requestDidSuspendTaskCallCount == 1)
    }

    @Test
    func testThatDidFailTaskShouldCallMonitorAndSetError() async {
        // Given
        let error = NetworkingError(kind: .explicitlyCancelled)
        let monitor = MonitorMock()
        let task = URLSession.shared.dataTask(with: request)
        let sut = HTTPURLRequest(delegate: nil, middleware: nil, monitor: monitor, queue: queue)

        // When
        await withCheckedContinuation { continuation in
            monitor.requestDidFailTaskWithErrorCallback = {
                continuation.resume()
            }

            queue.async {
                sut.didFail(task: task, with: error)
            }
        }

        // Then
        #expect(sut.error?.kind == .explicitlyCancelled)
        #expect(sut.tasks.count == 0)
        #expect(monitor.requestDidFailTaskCallCount == 1)
    }

    @Test
    func testThatDidCreateURLRequestShouldCallMonitor() async {
        // Given
        let monitor = MonitorMock()
        let sut = HTTPURLRequest(delegate: nil, middleware: nil, monitor: monitor, queue: queue)

        // When
        await withCheckedContinuation { continuation in
            monitor.requestDidCreateURLRequestCallback = { _ in
                continuation.resume()
            }

            queue.async {
                sut.didCreate(urlRequest: request)
            }
        }

        // Then
        #expect(monitor.requestDidCreateURLRequestCallCount == 1)
    }

    @Test
    func testThatDidFailToCreateURLRequestShouldCallMonitorAndFinishTheRequest() async {
        // Given
        let error = NetworkingError(kind: .explicitlyCancelled)
        let monitor = MonitorMock()
        let sut = HTTPURLRequest(delegate: nil, middleware: nil, monitor: monitor, queue: queue)

        // When
        await withCheckedContinuation { continuation in
            monitor.requestDidFinishCallback = {
                continuation.resume()
            }

            queue.async {
                sut.didFailToCreateURLRequest(with: error)
            }
        }

        // Then
        #expect(sut.error?.kind == .explicitlyCancelled)
        #expect(monitor.requestDidFinishCallCount == 1)
        #expect(monitor.didFailToCreateURLRequestWithErrorCallCount == 1)
    }

    @Test
    func testThatDidFailToCreateURLRequestShouldCallMonitor() async {
        // Given
        let error = NetworkingError(kind: .explicitlyCancelled)
        let monitor = MonitorMock()
        let sut = HTTPURLRequest(delegate: nil, middleware: nil, monitor: monitor, queue: queue)

        // When
        sut.state = .cancelled

        await withCheckedContinuation { continuation in
            monitor.requestDidFailToCreateURLRequestCallback = { _ in
                continuation.resume()
            }

            queue.async {
                sut.didFailToCreateURLRequest(with: error)
            }
        }

        // Then
        #expect(sut.error?.kind == .explicitlyCancelled)
        #expect(monitor.requestDidFinishCallCount == 0)
        #expect(monitor.didFailToCreateURLRequestWithErrorCallCount == 1)
    }

    @Test
    func testThatResetShouldClearTheRequest() async throws {
        // Given
        let monitor = MonitorMock()
        let sut = HTTPURLRequest(delegate: nil, middleware: nil, monitor: monitor, queue: queue)

        // When
        sut.error = NetworkingError(kind: .explicitlyCancelled)
        sut.state = .cancelled
        sut.appendResponseSerializer {}

        sut.reset()

        // Then
        #expect(sut.error == nil)
    }

    @Test
    func testThatCancelShouldCallMonitorAndSetTheStateToCancelled() async {
        // Given
        let monitor = MonitorMock()
        let sut = HTTPURLRequest(delegate: nil, middleware: nil, monitor: monitor, queue: queue)

        // When
        await withCheckedContinuation { continuation in
            monitor.requestDidCancelCallback = {
                continuation.resume()
            }

            sut.cancel()
        }

        // Then
        #expect(sut.state == .cancelled)
        #expect(monitor.requestDidCancelCallCount == 1)
    }

    @Test
    func testThatResumeShouldCallMonitorAndSetTheStateToResumed() async {
        // Given
        let monitor = MonitorMock()
        let sut = HTTPURLRequest(delegate: nil, middleware: nil, monitor: monitor, queue: queue)

        // When
        await withCheckedContinuation { continuation in
            monitor.requestDidResumeCallback = {
                continuation.resume()
            }

            sut.resume()
        }

        // Then
        #expect(sut.state == .resumed)
        #expect(monitor.requestDidResumeCallCount == 1)
    }

    @Test
    func testThatResumeShouldCallMonitorAndResumeTheTask() async {
        // Given
        let monitor = MonitorMock()
        let task = URLSession.shared.dataTask(with: request)
        let sut = HTTPURLRequest(delegate: nil, middleware: nil, monitor: monitor, queue: queue)

        // When
        queue.async {
            sut.didCreate(task: task)
        }

        await withCheckedContinuation { continuation in
            monitor.requestDidResumeTaskCallback = {
                continuation.resume()
            }

            sut.resume()
        }

        // Then
        #expect(sut.state == .resumed)
        #expect(monitor.requestDidResumeCallCount == 1)
        #expect(monitor.requestDidResumeTaskCallCount == 1)
    }

    @Test
    func testThatSuspendShouldCallMonitorAndSetTheStateToSuspended() async {
        // Given
        let monitor = MonitorMock()
        let sut = HTTPURLRequest(delegate: nil, middleware: nil, monitor: monitor, queue: queue)

        // When
        await withCheckedContinuation { continuation in
            monitor.requestDidSuspendCallback = {
                continuation.resume()
            }

            sut.suspend()
        }

        // Then
        #expect(sut.state == .suspended)
        #expect(monitor.requestDidSuspendCallCount == 1)
    }

    @Test
    func testThatSuspendShouldCallMonitorAndSuspendTheTask() async {
        // Given
        let monitor = MonitorMock()
        let task = URLSession.shared.dataTask(with: request)
        let sut = HTTPURLRequest(delegate: nil, middleware: nil, monitor: monitor, queue: queue)

        // When
        await withCheckedContinuation { continuation in
            monitor.requestDidSuspendTaskCallback = {
                continuation.resume()
            }

            queue.async {
                sut.didCreate(task: task)
                sut.suspend()
            }
        }

        // Then
        #expect(sut.state == .suspended)
        #expect(monitor.requestDidSuspendCallCount == 1)
        #expect(monitor.requestDidSuspendTaskCallCount == 1)
    }

    @Test
    func testThatAppendResponseSerializerShouldResumeTheRequest() async {
        // Given
        let monitor = MonitorMock()
        let task = URLSession.shared.dataTask(with: request)
        let sut = HTTPURLRequest(delegate: nil, middleware: nil, monitor: monitor, queue: queue)

        // When
        await withCheckedContinuation { continuation in
            queue.async {
                sut.didCreate(task: task)
                continuation.resume()
            }
        }

        await withCheckedContinuation { continuation in
            monitor.requestDidResumeCallback = {
                continuation.resume()
            }

            sut.appendResponseSerializer {}
        }

        // Then
        #expect(sut.responseSerializers.count == 1)
        #expect(sut.state == .resumed)
    }

    @Test
    func testThatDebugDescriptionShouldReturnCURLRepresentation() async {
        // Given
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpAdditionalHeaders = ["foo1": "bar"]

        let session = HTTPURLSession(configuration: configuration)
        let sut = session.request(request.url!, headers: ["foo": "bar"])

        // When
        _ = await sut.serializingData()

        // Then
        #expect(sut.debugDescription != "")
    }

    @Test
    func testThatDebugDescriptionShouldNotBeAbleToCreateCURLDescription() async {
        // Given
        let expectedDescription = "$ curl command could not be created"
        let sut = HTTPURLRequest(delegate: nil, middleware: nil, monitor: nil, queue: queue)

        // When, Then
        #expect(sut.debugDescription == expectedDescription)
    }
}
