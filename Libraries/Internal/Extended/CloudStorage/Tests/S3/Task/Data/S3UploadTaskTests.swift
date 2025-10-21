//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AWSS3
import CloudStorageKitTesting
import Foundation
import Testing
import Utilities

@testable import CloudStorageKit

struct S3UploadTaskTests {
    // MARK: - Properties

    let id = "test"
    let monitor = S3TaskMonitorMock()
    let payload = S3DataPayload(
        bucket: "bucket_test",
        contentType: .jpeg,
        data: Data("fake".utf8),
        path: "fileName"
    )

    // MARK: - Tests

    @Test
    func testThatS3UploadTaskInitializer() async {
        // Given, When
        let sut = S3UploadDataTask(id: id, payload: payload, delegate: nil, monitor: monitor)

        // Then
        #expect(await sut.state == .initialized)
    }

    @Test
    func testThatProgressBlockInvokesCallbacks() async throws {
        // Given
        let sut = S3UploadDataTask(id: id, payload: payload, delegate: nil, monitor: monitor)
        var receivedProgress: Progress?
        let fakeProgress = Progress(totalUnitCount: 100)
        fakeProgress.completedUnitCount = 42

        // When
        sut.onProgress { progress in
            receivedProgress = progress
        }

        sut.expression.progressBlock?(AWSS3TransferUtilityTask(), fakeProgress)

        try await Task.sleep(nanoseconds: 5_000_000)

        // Then
        #expect(receivedProgress?.fractionCompleted == 0.42)
        #expect(sut.state == .initialized)
    }

    @Test
    func testThatDidCompleteCallsMonitorAndSetsError() async {
        // Given
        let sut = S3UploadDataTask(id: id, payload: payload, delegate: nil, monitor: monitor)

        // When
        await sut.didComplete(
            task: AWSS3TransferUtilityUploadTask(),
            error: UtilityError(
                kind: .CloudStorageErrorReason.explicitlyCancelled,
                failureReason: "test"
            )
        )

        // Then
        #expect(monitor.didFinishUploadTaskCallCount == 1)
    }

    @Test
    func testThatDidFinishCallMonitor() async throws {
        // Given
        let sut = S3UploadDataTask(id: id, payload: payload, delegate: nil, monitor: monitor)

        // When
        await sut.didCreate(task: AWSS3TransferUtilityUploadTask())

        try await Task.sleep(nanoseconds: 5_000_000)

        await sut.finish()

        // Then
        #expect(monitor.taskDidFinishCallCount == 1)
    }

    @Test
    func testThatDidFailToCreateUploadTaskCallMonitor() async throws {
        // Given
        let sut = S3UploadDataTask(id: id, payload: payload, delegate: nil, monitor: monitor)

        // When
        await sut.didCreate(task: AWSS3TransferUtilityUploadTask())

        try await Task.sleep(nanoseconds: 5_000_000)

        await sut.didFailToCreateUploadTask(
            with: UtilityError(
                kind: .CloudStorageErrorReason.explicitlyCancelled,
                failureReason: "test"
            )
        )

        // Then
        #expect(monitor.didFailToCreateUploadTaskCallCount == 1)
    }

    @Test
    func testThatDidResumeCallsMonitor() async throws {
        // Given
        let sut = S3UploadDataTask(id: id, payload: payload, delegate: nil, monitor: monitor)

        // When
        await sut.didCreate(task: AWSS3TransferUtilityUploadTask())

        try await Task.sleep(nanoseconds: 5_000_000)

        sut.didResume()

        // Then
        #expect(monitor.taskDidResumeCallCount == 1)
    }

    @Test
    func testThatDidResumeCallsMonitorWithoutTask() async throws {
        // Given
        let sut = S3UploadDataTask(id: id, payload: payload, delegate: nil, monitor: monitor)

        // When
        await sut.didCreate(task: AWSS3TransferUtilityUploadTask())

        try await Task.sleep(nanoseconds: 5_000_000)

        sut.didResume()

        // Then
        #expect(monitor.taskDidResumeCallCount == 1)
    }

    @Test
    func testThatDidSuspendCallsMonitor() async throws {
        // Given
        let sut = S3UploadDataTask(id: id, payload: payload, delegate: nil, monitor: monitor)

        // When
        await sut.didCreate(task: AWSS3TransferUtilityUploadTask())

        try await Task.sleep(nanoseconds: 5_000_000)

        sut.didSuspend()

        // Then
        #expect(monitor.taskDidSuspendCallCount == 1)
    }

    @Test
    func testThatFinishCallsMonitor() async {
        // Given
        let sut = S3UploadDataTask(id: id, payload: payload, delegate: nil, monitor: monitor)

        // When
        var completionResult: Result<URL, UtilityError>?
        sut.onComplete { result in
            completionResult = result
        }

        await sut.finish()

        // Then
        #expect(await sut.state == .finished)
        #expect(completionResult != nil)
    }

    @Test
    func testThatFinishNotifiesMonitorAndCompletesSuccessfully() async throws {
        // Given
        var states: [UploadTaskState] = []
        let sut = S3UploadDataTask(id: id, payload: payload, delegate: nil, monitor: monitor)
        let awsTask = TransferUtilityTaskMock()
        let response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        // When
        awsTask.setMockResponse(response)

        states.append(sut.state)

        await sut.didComplete(task: awsTask)

        try await Task.sleep(nanoseconds: 5_000_000)

        await sut.finish()
        states.append(sut.state)

        // Then
        #expect(states == [.initialized, .finished])
        #expect(await awsTask.response == response)
        #expect(monitor.taskDidFinishCallCount == 1)
    }

    @Test
    func testThatFinishInvokesDidFailWhenTaskExistsAndNotURL() async throws {
        // Given
        var states: [UploadTaskState] = []
        let sut = S3UploadDataTask(id: id, payload: payload, delegate: nil, monitor: monitor)
        let task = AWSS3TransferUtilityUploadTask()

        // When
        await sut.didCreate(task: task)
        states.append(sut.state)

        try await Task.sleep(nanoseconds: 5_000_000)

        await sut.didFailToCreateUploadTask(with: UtilityError(
            kind: .CloudStorageErrorReason.explicitlyCancelled,
            failureReason: "test"
        ))

        try await Task.sleep(nanoseconds: 5_000_000)

        await sut.finish()
        states.append(sut.state)

        try await Task.sleep(nanoseconds: 5_000_000)

        // Then
        #expect(states == [.initialized, .finished])
        #expect(monitor.didFailToCreateUploadTaskCallCount == 1)
    }

    @Test
    func testThatCancelNotifiesMonitorAndCallbacks() async throws {
        // Given
        var states: [UploadTaskState] = []
        let sut = S3UploadDataTask(id: id, payload: payload, delegate: nil, monitor: monitor)
        let fakeTask = AWSS3TransferUtilityUploadTask()

        // When
        await sut.didCreate(task: fakeTask)
        states.append(sut.state)

        try await Task.sleep(nanoseconds: 5_000_000)

        sut.cancel()
        try await Task.sleep(nanoseconds: 5_000_000)
        states.append(sut.state)

        // Then
        #expect(states == [.initialized, .cancelled])
        #expect(monitor.taskDidCancelCallCount == 1)
    }

    @Test
    func testThatPauseCallsMonitorWhenTaskIsCreated() async throws {
        // Given
        var states: [UploadTaskState] = []
        let sut = S3UploadDataTask(id: id, payload: payload, delegate: nil, monitor: monitor)
        let fakeTask = AWSS3TransferUtilityUploadTask()

        // When
        await sut.didCreate(task: fakeTask)
        states.append(sut.state)

        try await Task.sleep(nanoseconds: 5_000_000)

        sut.pause()

        try await Task.sleep(nanoseconds: 5_000_000)
        states.append(sut.state)

        // Then
        #expect(monitor.taskDidSuspendCallCount == 1)
        #expect(states == [.initialized, .suspended])
    }
}
