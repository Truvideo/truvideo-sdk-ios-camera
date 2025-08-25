//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AWSS3
import CloudStorageTesting
import Testing
import Utilities

@testable import CloudStorage

struct S3UploadTaskTests {
    
    // MARK: - Properties
    
    let id = UUID()
    let monitor = S3UploadMonitorMock()
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
        let sut = S3UploadTask(id: id, payload: payload, monitor: monitor)

        // Then
        #expect(await sut.state == .initialized)
    }
    
    @Test
    func testThatProgressBlockInvokesCallbacks() async throws {
        // Given
        let sut = S3UploadTask(id: id, payload: payload, monitor: monitor)
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
    func testThatCancelShouldCallMonitor() async {
        // Given
        let sut = S3UploadTask(id: id, payload: payload, monitor: monitor)

        // When
        await sut.didCancel()
        
        // Then
        #expect(monitor.uploadDidCancelCallCount == 1)
    }
    
    @Test
    func testThatDidCancelTaskCallsMonitor() async {
        // Given
        let sut = S3UploadTask(id: id, payload: payload, monitor: monitor)

        // When
        await sut.didCancel(task: AWSS3TransferUtilityUploadTask())

        // Then
        #expect(monitor.uploadDidCancelTaskCallCount == 1)
    }
    
    @Test
    func testThatDidCompleteCallsMonitorAndSetsError() async {
        // Given
        let sut = S3UploadTask(id: id, payload: payload, monitor: monitor)

        // When
        await sut.didComplete(
            task: AWSS3TransferUtilityUploadTask(),
            error: UtilityError(
                kind: .CloudStorageErrorReason.explicitlyCancelled,
                failureReason: "test"
            )
        )

        // Then
        #expect(monitor.uploadDidCompleteTaskCallCount == 1)
    }
    
    @Test
    func testThatDidCreateCallMonitor() async {
        // Given
        let sut = S3UploadTask(id: id, payload: payload, monitor: monitor)

        // When
        await sut.didCreate(task: AWSS3TransferUtilityUploadTask())

        // Then
        #expect(monitor.uploadDidCreateTaskCallCount == 1)
    }
    
    @Test
    func testThatDidFinishCallMonitor() async {
        // Given
        let sut = S3UploadTask(id: id, payload: payload, monitor: monitor)

        // When
        await sut.didFail(
            task: AWSS3TransferUtilityUploadTask(),
            with: UtilityError(
                kind: .CloudStorageErrorReason.explicitlyCancelled,
                failureReason: "test"
            )
        )

        // Then
        #expect(monitor.uploadDidFailTaskCallCount == 1)
    }
    
    @Test
    func testThatDidFailToCreateUploadTaskCallMonitor() async {
        // Given
        let sut = S3UploadTask(id: id, payload: payload, monitor: monitor)

        // When
        await sut.didFailToCreateUploadTask(
            with: UtilityError(
                kind: .CloudStorageErrorReason.explicitlyCancelled,
                failureReason: "test"
            )
        )

        // Then
        #expect(monitor.uploadDidFailToCreateUploadTaskCallCount == 1)
    }
    
    @Test
    func testThatDidResumeCallsMonitor() async {
        // Given
        let sut = S3UploadTask(id: id, payload: payload, monitor: monitor)

        // When
        await sut.didResume()

        // Then
        #expect(monitor.uploadDidResumeCallCount == 1)
    }
    
    @Test
    func testThatDidResumeCallsMonitorWithoutTask() async {
        // Given
        let sut = S3UploadTask(id: id, payload: payload, monitor: monitor)

        // When
        await sut.didResume(task: AWSS3TransferUtilityUploadTask())

        // Then
        #expect(monitor.uploadDidResumeTaskCallCount == 1)
    }
    
    @Test
    func testThatDidSuspendCallsMonitor() async {
        // Given
        let sut = S3UploadTask(id: id, payload: payload, monitor: monitor)

        // When
        await sut.didSuspend()

        // Then
        #expect(monitor.uploadDidSuspendCallCount == 1)
    }
    
    @Test
    func testThatDidSuspendCallsMonitorWithoutTask() async {
        // Given
        let sut = S3UploadTask(id: id, payload: payload, monitor: monitor)

        // When
        await sut.didSuspend(task: AWSS3TransferUtilityUploadTask())

        // Then
        #expect(monitor.uploadDidSuspendTaskCallCount == 1)
    }
    
    @Test
    func testThatFinishCallsMonitor() async {
        // Given
        let sut = S3UploadTask(id: id, payload: payload, monitor: monitor)

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
        let sut = S3UploadTask(id: id, payload: payload, monitor: monitor)
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
        #expect(monitor.uploadDidFinishCallCount == 2)
    }
    
    @Test
    func testThatFinishInvokesDidFailWhenTaskExistsAndNotURL() async throws {
        // Given
        var states: [UploadTaskState] = []
        let sut = S3UploadTask(id: id, payload: payload, monitor: monitor)
        let task = AWSS3TransferUtilityUploadTask()

        // When
        await sut.didCreate(task: task)
        states.append(sut.state)
    
        try await Task.sleep(nanoseconds: 5_000_000)

        await sut.didFail(
            task: AWSS3TransferUtilityUploadTask(),
            with: UtilityError(
                kind: .CloudStorageErrorReason.explicitlyCancelled,
                failureReason: "test"
            )
        )
        
        try await Task.sleep(nanoseconds: 5_000_000)
        
        await sut.finish()
        states.append(sut.state)
        
        try await Task.sleep(nanoseconds: 5_000_000)

        // Then
        #expect(states == [.initialized, .finished])
        #expect(monitor.uploadDidFailTaskCallCount == 2)
    }
    
    @Test
    func testThatCancelNotifiesMonitorAndCallbacks() async throws {
        // Given
        var states: [UploadTaskState] = []
        let sut = S3UploadTask(id: id, payload: payload, monitor: monitor)
        let fakeTask = AWSS3TransferUtilityUploadTask()

        // When
        await sut.didCreate(task: fakeTask)
        states.append(sut.state)
        
        try await Task.sleep(nanoseconds: 5_000_000)
        
        sut.cancel()
        try await Task.sleep(nanoseconds: 5_000_000)
        states.append(sut.state)

        // Then
        #expect(states == [.initialized, .finished])
        #expect(monitor.uploadDidCancelCallCount == 1)
    }
    
    @Test
    func testThatPauseCallsMonitorWhenTaskIsCreated() async throws {
        // Given
        var states: [UploadTaskState] = []
        let sut = S3UploadTask(id: id, payload: payload, monitor: monitor)
        let fakeTask = AWSS3TransferUtilityUploadTask()

        // When
        await sut.didCreate(task: fakeTask)
        states.append(sut.state)
        
        try await Task.sleep(nanoseconds: 5_000_000)
        
        sut.pause()
        
        try await Task.sleep(nanoseconds: 5_000_000)
        states.append(sut.state)

        // Then
        #expect(monitor.uploadDidSuspendTaskCallCount == 1)
        #expect(states == [.initialized, .suspended])
    }
    
    @Test
    func testThatTwoTasksWithSameIDAreEqual() async {
        // Given
        let s3UploadTask1 = S3UploadTask(id: id, payload: payload, monitor: monitor)
        let s3UploadTask2 = S3UploadTask(id: id, payload: payload, monitor: monitor)

        // Then
        #expect(s3UploadTask1 == s3UploadTask2)
        #expect(s3UploadTask1.hashValue == s3UploadTask2.hashValue)
    }
    
    @Test
    func testThatTwoTasksWithDifferentIDsAreNotEqual() async {
        // Given
        let s3UploadTask1 = S3UploadTask(id: UUID(), payload: payload, monitor: monitor)
        let s3UploadTask2 = S3UploadTask(id: UUID(), payload: payload, monitor: monitor)

        // Then
        #expect(s3UploadTask1 != s3UploadTask2)
        #expect(s3UploadTask1.hashValue != s3UploadTask2.hashValue)
    }
}
