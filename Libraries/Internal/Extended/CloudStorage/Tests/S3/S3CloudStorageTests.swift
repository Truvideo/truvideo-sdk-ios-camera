//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AWSS3
import CloudStorageTesting
import Utilities
import Testing

@testable import CloudStorage

struct S3CloudStorageTests {
    
    // MARK: - Properties
    
    let monitor = S3UploadMonitorMock()
    let transferUtility = S3TransferUtilityProtocolMock()

    // MARK: - Tests
    
    @Test
    func testThatInitializerSucceedsWithValidConfiguration() throws {
        // Given
        let sut = try S3CloudStorage(
            awsRegion: .APSouth1,
            bucketName: "bucketName_test",
            poolId: "poolId-test",
            isAccelerateModeEnabled: false
        )
        
        // When, Then
        #expect(sut.transferUtility is AWSS3TransferUtility)
    }
    
    @Test
    func testThatCancelAllUploadsCallCancelOnTask() async throws {
        // Given
        var states: [UploadTaskState] = []
        let sut = S3CloudStorage(
            bucketName: "bucketName_test",
            monitor: monitor,
            transferUtility: transferUtility
        )
        
        // When
        transferUtility.result = AWSTask(result: AWSS3TransferUtilityUploadTask())

        let task = sut.upload(Data("fake".utf8), fileName: "fileName", contentType: .jpeg)
        
        try await Task.sleep(nanoseconds: 5_000_000)
        
        states.append(task.state)
        sut.cancelAllUploads()
        
        try await Task.sleep(nanoseconds: 5_000_000)
        
        states.append(task.state)
        
        // Then
        #expect(states == [.initialized, .finished])
    }
    
    @Test
    func testThatUploadCreatedNewTask() async throws {
        // Given
        let sut = S3CloudStorage(
            bucketName: "bucketName_test",
            monitor: monitor,
            transferUtility: transferUtility
        )
        
        // When
        transferUtility.result = AWSTask(result: AWSS3TransferUtilityUploadTask())

        let task = sut.upload(Data("fake".utf8), fileName: "fileName", contentType: .jpeg)
        
        try await Task.sleep(nanoseconds: 5_000_000)
        
        // Then
        #expect(await sut.activeUploadTasks.count == 1)
        #expect(task.state == .initialized)
    }
    
    @Test
    func testUploadDidCompleteRemovesTaskFromActiveUploadTasks() async throws {
        // Given
        var states: [UploadTaskState] = []
        let sut = S3CloudStorage(
            bucketName: "bucketName_test",
            monitor: monitor,
            transferUtility: transferUtility
        )
        
        // When
        transferUtility.result = AWSTask(result: AWSS3TransferUtilityUploadTask())

        let task = sut.upload(Data("fake".utf8), fileName: "fileName", contentType: .jpeg)
        
        try await Task.sleep(nanoseconds: 5_000_000)
        states.append(task.state)
        
        transferUtility.completionHandler?(AWSS3TransferUtilityUploadTask(), UtilityError(kind: .unknown))
        
        try await Task.sleep(nanoseconds: 5_000_000)
        states.append(task.state)

        // Then
        #expect(await sut.activeUploadTasks.count == 0)
        #expect(await monitor.uploadDidCompleteTaskCallCount == 1)
        #expect(states == [.initialized, .finished])
    }
    
    @Test
    func testDidCreateWhenStateIsInitializedDoesNotChangeTaskState() async throws {
        // Given
        let sut = S3CloudStorage(
            bucketName: "bucketName_test",
            monitor: monitor,
            transferUtility: transferUtility
        )
        
        // When
        transferUtility.result = AWSTask(result: AWSS3TransferUtilityUploadTask())

        let task = sut.upload(Data("fake".utf8), fileName: "file-init", contentType: .jpeg)
        
        try await Task.sleep(nanoseconds: 5_000_000)

        // Then
        #expect(await task.state == .initialized)
        #expect(monitor.uploadDidCreateTaskCallCount == 1)
    }
    
    @Test
    func testThatUploadTaskPause() async throws {
        // Given
        var states: [UploadTaskState] = []
        let sut = S3CloudStorage(bucketName: "bucket", monitor: monitor, transferUtility: transferUtility)
        let awsTask = AWSS3TransferUtilityUploadTask()

        // When
        transferUtility.result = AWSTask(result: awsTask)

        let uploadTask = sut.upload(Data("data".utf8), fileName: "file", contentType: .jpeg)
        
        states.append(uploadTask.state)
        
        uploadTask.pause()

        try await Task.sleep(nanoseconds: 5_000_000)
        states.append(uploadTask.state)

        // Then
        #expect(monitor.uploadDidCreateTaskCallCount == 1)
        #expect(states == [.initialized, .suspended])
    }
    
    @Test
    func testThatUploadTaskPausesAndResumes() async throws {
        // Given
        var states: [UploadTaskState] = []
        let sut = S3CloudStorage(bucketName: "bucket", monitor: monitor, transferUtility: transferUtility)
        let awsTask = AWSS3TransferUtilityUploadTask()

        // When
        transferUtility.result = AWSTask(result: awsTask)

        let uploadTask = sut.upload(Data("data".utf8), fileName: "file", contentType: .jpeg)
        states.append(uploadTask.state)

        uploadTask.pause()
        try await Task.sleep(nanoseconds: 5_000_000)
        states.append(uploadTask.state)

        uploadTask.resume()
        try await Task.sleep(nanoseconds: 5_000_000)
        states.append(uploadTask.state)

        // Then
        #expect(monitor.uploadDidCreateTaskCallCount == 1)
        #expect(monitor.uploadDidResumeTaskCallCount == 1)
        #expect(states == [.initialized, .suspended, .resumed])
    }
    
    @Test
    func testThatUploadFailsWhenAWSTaskHasNoResult() async throws {
        // Given
        var states: [UploadTaskState] = []
        let sut = S3CloudStorage(
            bucketName: "bucketName_test",
            monitor: monitor,
            transferUtility: transferUtility
        )

        // When
        transferUtility.result = AWSTask(error: NSError(domain: "test", code: 1))

        let task = sut.upload(Data("fake".utf8), fileName: "file", contentType: .jpeg)
        states.append(task.state)

        try await Task.sleep(nanoseconds: 5_000_000)
        states.append(task.state)

        // Then
        #expect(await sut.activeUploadTasks.count == 1)
        #expect(states == [.initialized, .finished])
    }
    
    // MARK: - UploadTaskState Tests
    
    @Test
    func testThatTransitionToInitializedIsInvalidFromInitialized() async throws {
        // Given, When, Then
        #expect(UploadTaskState.initialized.canTransition(to: .initialized) == false)
    }
    
    @Test
    func testThatTransitionToInitializedIsInvalidFromResumed() async throws {
        // Given, When, Then
        #expect(UploadTaskState.resumed.canTransition(to: .initialized) == false)
    }
    
    @Test
    func testThatTransitionToInitializedIsInvalidFromSuspended() async throws {
        // Given, When, Then
        #expect(UploadTaskState.suspended.canTransition(to: .initialized) == false)
    }
    
    @Test
    func testThatTransitionToInitializedIsInvalidFromCancelled() async throws {
        // Given, When, Then
        #expect(UploadTaskState.cancelled.canTransition(to: .initialized) == false)
    }
    
    @Test
    func testThatTransitionFromInitializedToResumedFallsIntoDefaultAndIsInvalid() async throws {
        // Given, When, Then
        #expect(UploadTaskState.initialized.canTransition(to: .resumed) == false)
    }
}
