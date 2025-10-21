//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AWSS3
import CloudStorageKitTesting
import DI
import Foundation
import Networking
import NetworkingTesting
import Testing
import Utilities

@testable import CloudStorageKit

struct S3CloudStorageTests {
    // MARK: - Properties

    let monitor = S3TaskMonitorMock()
    let transferUtility = S3TransferUtilityProtocolMock()
    let session = SessionMock()
    let uploadTaskMock = UploadTaskMock()

    // MARK: - Tests

    @Test
    func testThatInitializerSucceedsWithValidConfiguration() throws {
        // Given
        let sut = try S3CloudStorage(
            region: .usWest2,
            bucketName: "bucketName_test",
            poolId: "poolId-test",
            isAccelerateModeEnabled: false
        )

        // When, Then
        #expect(sut.transferUtility is AWSS3TransferUtility)
    }

    // MARK: - StreamUploadTask

    @Test
    func testThatStreamUploadCreatedNewTask() async throws {
        await withDependencyValues { dependencyValues in
            // Given
            let sut = S3CloudStorage(
                bucketName: "bucketName_test",
                transferUtility: transferUtility,
                monitor: monitor
            )

            // When
            dependencyValues.session = session

            let streamTask = sut.streamUpload(with: "123", contentType: .jpeg)

            // Then
            #expect(streamTask is S3StreamUploadTask)
            #expect((streamTask as? S3StreamUploadTask)?.state == .initialized)
        }
    }

    @Test
    func testThatStreamUploadCancelNotifiesMonitor() async throws {
        try await withDependencyValues { dependencyValues in
            // Given
            let uploadRequest = UploadRequestMock(responseDelay: 2_000_000)
            let session = SessionMock()
            let sut = S3CloudStorage(bucketName: "bucket_test", transferUtility: transferUtility, monitor: monitor)

            // When
            uploadRequest.error = NetworkingError(kind: .invalidURL, failureReason: "")
            session.uploadRequestMock = uploadRequest
            dependencyValues.session = session

            let streamTask = sut.streamUpload(with: "123", contentType: .jpeg)

            streamTask.upload(Data(), to: URL(string: "https://test.com")!)

            try await Task.sleep(nanoseconds: 500_00)

            streamTask.cancel()

            try await Task.sleep(nanoseconds: 1_000_000)

            // Then
            #expect((streamTask as? S3StreamUploadTask)?.state == .cancelled)
            #expect(monitor.streamUploadCancelPartCallCount == 1)
        }
    }

    @Test
    func testThatStreamUploadDidFailNotifiesMonitor() async throws {
        await withDependencyValues { dependencyValues in
            // Given
            let sut = S3CloudStorage(bucketName: "bucket_test", transferUtility: transferUtility, monitor: monitor)
            let request = UploadRequestMock()

            // When
            dependencyValues.session = session

            let streamTask = sut.streamUpload(with: "123", contentType: .jpeg) as? S3StreamUploadTask

            streamTask?
                .didFail(
                    request: request,
                    with: UtilityError(
                        kind: .CloudStorageErrorReason.failedToUploadData
                    )
                )

            // Then
            #expect(monitor.streamUploadCancelPartCallCount == 0)
        }
    }

    @Test
    func testThatStreamUploadDidResumeNotifiesMonitor() async throws {
        // Given
        await withDependencyValues { dependencyValues in
            let sut = S3CloudStorage(bucketName: "bucket_test", transferUtility: transferUtility, monitor: monitor)
            let request = UploadRequestMock()

            // When
            dependencyValues.session = session

            let streamTask = sut.streamUpload(with: "123", contentType: .jpeg) as? S3StreamUploadTask

            streamTask?.didResume(request: request, for: 1)

            // Then
            #expect(monitor.streamUploadCancelPartCallCount == 0)
        }
    }

    @Test
    func testThatStreamUploadDidCompleteSucceedsWhenETagExists() async throws {
        try await withDependencyValues { dependencyValues in
            // Given
            let request = UploadRequestMock()
            let sut = S3CloudStorage(
                bucketName: "bucketName_test",
                transferUtility: transferUtility,
                monitor: monitor
            )

            // When
            dependencyValues.session = session

            let streamTask = sut.streamUpload(with: "123", contentType: .jpeg) as? S3StreamUploadTask

            request.response = HTTPURLResponse(
                url: URL(string: "https://test.com")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["ETag": "etag123"]
            )

            await streamTask?.didComplete(
                task: UploadPartTask(
                    partBody: Data(),
                    partNumber: 2,
                    request: request
                )
            )

            try await Task.sleep(nanoseconds: 5_000_000)

            // Then
            #expect(monitor.streamUploadCompletePartCallCount == 1)
            #expect(streamTask?.state == .initialized)
            #expect(streamTask?.error == nil)
        }
    }

    @Test
    func testThatStreamUploadDidCompleteFailsWhenETagIsMissing() async throws {
        try await withDependencyValues { dependencyValues in
            // Given
            let request = UploadRequestMock()
            let sut = S3CloudStorage(
                bucketName: "bucketName_test",
                transferUtility: transferUtility,
                monitor: monitor
            )

            // When
            dependencyValues.session = session

            let streamTask = sut.streamUpload(with: "123", contentType: .jpeg) as? S3StreamUploadTask

            request.response = HTTPURLResponse(
                url: URL(string: "https://test.com")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )

            await streamTask?.didComplete(
                task: UploadPartTask(
                    partBody: Data(),
                    partNumber: 2,
                    request: request
                )
            )

            try await Task.sleep(nanoseconds: 5_000_000)

            // Then
            #expect(monitor.streamUploadCompletePartCallCount == 1)
        }
    }

    @Test
    func testThatStreamUploadDidCompleteFailsWhenExplicitErrorIsProvided() async throws {
        try await withDependencyValues { dependencyValues in
            // Given
            let request = UploadRequestMock()
            let sut = S3CloudStorage(
                bucketName: "bucketName_test",
                transferUtility: transferUtility,
                monitor: monitor
            )

            // When
            dependencyValues.session = session

            let streamTask = sut.streamUpload(with: "123", contentType: .jpeg) as? S3StreamUploadTask

            let expectedError = UtilityError(
                kind: .CloudStorageErrorReason.failedToUploadData,
                failureReason: "Simulated failure"
            )

            await streamTask?.didComplete(
                task: UploadPartTask(
                    partBody: Data(),
                    partNumber: 1,
                    request: request
                ),
                with: expectedError
            )

            try await Task.sleep(nanoseconds: 5_000_000)

            // Then
            #expect(monitor.streamUploadCompletePartCallCount == 1)
        }
    }

    @Test
    func testThatStreamUploadFinalizeNotifiesMonitorTaskDidFinish() async throws {
        try await withDependencyValues { dependencyValues in
            // Given
            let sut = S3CloudStorage(
                bucketName: "bucketName_test",
                transferUtility: transferUtility,
                monitor: monitor
            )

            // When
            dependencyValues.session = session

            let streamTask = sut.streamUpload(with: "123", contentType: .jpeg) as? S3StreamUploadTask

            streamTask?.finalize()

            try await Task.sleep(nanoseconds: 5_000_000)

            // Then
            #expect(monitor.taskDidFinishCallCount == 1)
        }
    }

    @Test
    func testThatStreamUploadOnCompleteReturnsCompletedTasksInOrder() async throws {
        await withDependencyValues { dependencyValues in
            // Given
            let sut = S3CloudStorage(bucketName: "bucket_test", transferUtility: transferUtility, monitor: monitor)
            let part1Request = UploadRequestMock()
            let part2Request = UploadRequestMock()
            var capturedResult: Result<StreamUploadResponse, UtilityError>?

            // When
            dependencyValues.session = session

            let streamTask = sut.streamUpload(with: "123", contentType: .jpeg) as? S3StreamUploadTask

            part1Request.response = HTTPURLResponse(
                url: URL(string: "https://test.com")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["ETag": "etag1"]
            )

            part2Request.response = HTTPURLResponse(
                url: URL(string: "https://test.com")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["ETag": "etag2"]
            )

            await streamTask?.didComplete(
                task: UploadPartTask(partBody: Data(), partNumber: 1, request: part1Request)
            )

            await streamTask?.didComplete(
                task: UploadPartTask(partBody: Data(), partNumber: 2, request: part2Request)
            )

            streamTask?.onComplete { result in
                capturedResult = result
            }

            streamTask?.completions.forEach { $0() }

            // Then
            if case let .success(response) = capturedResult {
                let partNumbers = response.completedTasks.map(\.partNumber)
                #expect(partNumbers == [1, 2])
                #expect(response.failedTasks.isEmpty)
            }
        }
    }

    @Test
    func testThatStreamUploadOnCompleteReturnsFailureWhenErrorIsPresent() async throws {
        await withDependencyValues { dependencyValues in
            // Given
            let sut = S3CloudStorage(bucketName: "bucket_test", transferUtility: transferUtility, monitor: monitor)
            let expectedError = UtilityError(
                kind: .CloudStorageErrorReason.failedToUploadData,
                failureReason: "Simulated failure"
            )
            var capturedResult: Result<StreamUploadResponse, UtilityError>?

            // When
            dependencyValues.session = session

            let streamTask = sut.streamUpload(with: "123", contentType: .jpeg) as? S3StreamUploadTask
            streamTask?.error = expectedError
            streamTask?.onComplete { result in
                capturedResult = result
            }

            streamTask?.completions.forEach { $0() }

            // Then
            if case let .failure(error) = capturedResult {
                #expect(error.kind == expectedError.kind)
                #expect(error.failureReason == expectedError.failureReason)
            }
        }
    }

    @Test
    func testThatStreamUploadPauseNotifiesMonitor() async throws {
        try await withDependencyValues { dependencyValues in
            // Given
            let sut = S3CloudStorage(bucketName: "bucket_test", transferUtility: transferUtility, monitor: monitor)

            // When
            dependencyValues.session = session

            let streamTask = sut.streamUpload(with: "123", contentType: .jpeg) as? S3StreamUploadTask

            streamTask?.upload(Data(), to: URL(string: "https://test.com")!)

            try await Task.sleep(nanoseconds: 5_000_000)

            streamTask?.pause()

            try await Task.sleep(nanoseconds: 5_000_000)

            // Then
            #expect(monitor.taskDidSuspendCallCount == 1)
        }
    }

    @Test
    func testThatStreamUploadResumeNotifiesMonitor() async throws {
        try await withDependencyValues { dependencyValues in
            // Given
            let sut = S3CloudStorage(bucketName: "bucket_test", transferUtility: transferUtility, monitor: monitor)

            // When
            dependencyValues.session = session

            let streamTask = sut.streamUpload(with: "123", contentType: .jpeg) as? S3StreamUploadTask

            streamTask?.upload(Data(), to: URL(string: "https://test.com")!)

            try await Task.sleep(nanoseconds: 5_000_000)

            streamTask?.resume()

            try await Task.sleep(nanoseconds: 5_000_000)

            // Then
            #expect(monitor.taskDidResumeCallCount == 1)
        }
    }

    // MARK: - UploadTask

    @Test
    func testThatUploadTaskCreatedNewTask() async throws {
        // Given
        let sut = S3CloudStorage(
            bucketName: "bucketName_test",
            transferUtility: transferUtility,
            monitor: monitor
        )

        // When
        transferUtility.result = AWSTask(result: AWSS3TransferUtilityUploadTask())
        let task = sut.upload(Data("fake".utf8), fileName: "fileName", contentType: .jpeg) as? S3UploadDataTask

        try await Task.sleep(nanoseconds: 5_000_000)

        // Then
        #expect(sut.activeUploadTasks.count == 1)
        #expect(task?.state == .initialized)
    }

    @Test
    func testThatUploadTaskDidCompleteRemovesTaskFromActiveUploadTasks() async throws {
        // Given
        let sut = S3CloudStorage(
            bucketName: "bucketName_test",
            transferUtility: transferUtility,
            monitor: monitor
        )

        // When
        transferUtility.result = AWSTask(result: AWSS3TransferUtilityUploadTask())

        let task = sut.upload(Data("fake".utf8), fileName: "fileName", contentType: .jpeg) as? S3UploadDataTask

        try await Task.sleep(nanoseconds: 5_000_000)

        transferUtility.completionHandler?(AWSS3TransferUtilityUploadTask(), nil)

        try await Task.sleep(nanoseconds: 5_000_000)

        // Then
        #expect(sut.activeUploadTasks.count == 0)
        #expect(monitor.didFinishUploadTaskCallCount == 1)
        #expect(task?.state == .finished)
    }

    @Test
    func testThatUploadTaskOnCompleteFailsWhenURLIsMissing() async throws {
        // Given
        let sut = S3CloudStorage(
            bucketName: "bucket_test",
            transferUtility: transferUtility,
            monitor: monitor
        )
        var capturedResult: Result<URL, UtilityError>?

        // When
        transferUtility.result = AWSTask(result: AWSS3TransferUtilityUploadTask())

        let dataTask = sut.upload(Data("file".utf8), fileName: "test.png", contentType: .png) as? S3UploadDataTask

        dataTask?.response = nil
        dataTask?.error = nil

        dataTask?.onComplete { result in
            capturedResult = result
        }

        dataTask?.completions.forEach { $0() }

        // Then
        if case let .failure(error) = capturedResult {
            #expect(error.kind == .CloudStorageErrorReason.missingUploadURL)
            #expect(error.failureReason == "Upload finished but no URL returned.")
        }
    }

    @Test
    func testThatDidCreateUploadTaskShouldSucceedWhenStateIsResumed() async throws {
        // Given
        let sut = S3CloudStorage(bucketName: "bucket_test", transferUtility: transferUtility, monitor: monitor)
        let aWSS3Mock = AWSS3TransferUtilityUploadTaskMock()

        // When
        transferUtility.result = AWSTask(result: AWSS3TransferUtilityUploadTask())
        let dataTask = sut.upload(Data("file".utf8), fileName: "test.png", contentType: .png) as? S3UploadDataTask

        dataTask?.state = .resumed

        await dataTask?.didCreate(task: aWSS3Mock)

        // Then
        #expect(aWSS3Mock.didResumeCallCount == 1)
    }

    @Test
    func testThatDidCreateUploadTaskShouldSucceedWhenStateIsCancelled() async throws {
        // Given
        let sut = S3CloudStorage(bucketName: "bucket_test", transferUtility: transferUtility, monitor: monitor)
        let aWSS3Mock = AWSS3TransferUtilityUploadTaskMock()

        // When
        transferUtility.result = AWSTask(result: AWSS3TransferUtilityUploadTask())
        let dataTask = sut.upload(Data("file".utf8), fileName: "test.png", contentType: .png) as? S3UploadDataTask

        dataTask?.state = .cancelled

        await dataTask?.didCreate(task: aWSS3Mock)

        // Then
        #expect(aWSS3Mock.didCancelCallCount == 1)
    }

    @Test
    func testThatDidCreateUploadTaskShouldSucceedWhenStateIsSuspended() async throws {
        // Given
        let sut = S3CloudStorage(bucketName: "bucket_test", transferUtility: transferUtility, monitor: monitor)
        let aWSS3Mock = AWSS3TransferUtilityUploadTaskMock()

        // When
        transferUtility.result = AWSTask(result: AWSS3TransferUtilityUploadTask())
        let dataTask = sut.upload(Data("file".utf8), fileName: "test.png", contentType: .png) as? S3UploadDataTask

        dataTask?.state = .suspended

        await dataTask?.didCreate(task: aWSS3Mock)

        // Then
        #expect(aWSS3Mock.didSuspendCallCount == 1)
    }

    @Test
    func testThatUploadTaskOnCompleteSucceedsWhenURLIsPresent() async throws {
        // Given
        let sut = S3CloudStorage(
            bucketName: "bucket_test",
            transferUtility: transferUtility,
            monitor: monitor
        )
        var capturedResult: Result<URL, UtilityError>?
        let expectedURL = URL(string: "https://bucket_test.s3.amazonaws.com/test.png")!

        // When
        transferUtility.result = AWSTask(result: AWSS3TransferUtilityUploadTask())

        let dataTask = sut.upload(Data("file".utf8), fileName: "test.png", contentType: .png) as? S3UploadDataTask

        dataTask?.response = HTTPURLResponse(
            url: expectedURL,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        dataTask?.onComplete { result in
            capturedResult = result
        }

        dataTask?.completions.forEach { $0() }

        // Then
        if case let .success(url) = capturedResult {
            #expect(url == expectedURL)
        }
    }

    @Test
    func testThatUploadTaskFailsWhenCompletionReturnsError() async throws {
        // Given
        let sut = S3CloudStorage(
            bucketName: "bucketName_test",
            transferUtility: transferUtility,
            monitor: monitor
        )

        // When
        transferUtility.result = AWSTask(result: AWSS3TransferUtilityUploadTask())

        let task = sut.upload(Data("fake".utf8), fileName: "file-error", contentType: .jpeg) as? S3UploadDataTask

        try await Task.sleep(nanoseconds: 5_000_000)

        transferUtility.completionHandler?(AWSS3TransferUtilityUploadTask(), NSError(domain: "tests", code: 1))

        try await Task.sleep(nanoseconds: 5_000_000)

        // Then
        #expect(task?.error?.kind == .CloudStorageErrorReason.failedToUploadData)
        #expect(task?.state == .finished)
        #expect(monitor.didFinishUploadTaskCallCount == 1)
    }

    @Test
    func testThatUploadTaskDidCreateWhenStateIsInitializedDoesNotChangeTaskState() async throws {
        // Given
        let sut = S3CloudStorage(
            bucketName: "bucketName_test",
            transferUtility: transferUtility,
            monitor: monitor
        )

        // When
        transferUtility.result = AWSTask(result: AWSS3TransferUtilityUploadTask())

        let task = sut.upload(Data("fake".utf8), fileName: "file-init", contentType: .jpeg) as? S3UploadDataTask

        try await Task.sleep(nanoseconds: 5_000_000)

        // Then
        #expect(task?.state == .initialized)
    }

    @Test
    func testThatUploadTaskPauseShouldSucceeds() async throws {
        // Given
        let sut = S3CloudStorage(bucketName: "bucket", transferUtility: transferUtility, monitor: monitor)
        let awsTask = AWSS3TransferUtilityUploadTask()

        // When, then
        transferUtility.result = AWSTask(result: awsTask)
        let task = sut.upload(Data("data".utf8), fileName: "file", contentType: .jpeg) as? S3UploadDataTask

        #expect(task?.state == .initialized)

        try await Task.sleep(nanoseconds: 2_000_000)

        task?.pause()
        try await Task.sleep(nanoseconds: 5_000_000)

        #expect(task?.state == .suspended)
        #expect(monitor.taskDidSuspendCallCount == 1)
    }

    @Test
    func testThatUploadTaskCancelShouldSucceeds() async throws {
        // Given
        let sut = S3CloudStorage(bucketName: "bucket", transferUtility: transferUtility, monitor: monitor)
        let awsTask = AWSS3TransferUtilityUploadTask()

        // When, then
        transferUtility.result = AWSTask(result: awsTask)
        let task = sut.upload(Data("data".utf8), fileName: "file", contentType: .jpeg) as? S3UploadDataTask

        #expect(task?.state == .initialized)

        try await Task.sleep(nanoseconds: 2_000_000)

        task?.cancel()
        try await Task.sleep(nanoseconds: 5_000_000)

        #expect(task?.state == .cancelled)
        #expect(monitor.taskDidCancelCallCount == 1)
    }

    @Test
    func testThatUploadTaskPausesAndResumesShouldSucceeds() async throws {
        // Given
        let sut = S3CloudStorage(bucketName: "bucket", transferUtility: transferUtility, monitor: monitor)

        // When, Then
        transferUtility.result = AWSTask(result: AWSS3TransferUtilityUploadTask())

        let task = sut.upload(Data("data".utf8), fileName: "file", contentType: .jpeg) as? S3UploadDataTask
        #expect(task?.state == .initialized)

        try await Task.sleep(nanoseconds: 2_000_000)

        task?.pause()
        try await Task.sleep(nanoseconds: 5_000_000)
        #expect(task?.state == .suspended)

        task?.resume()
        try await Task.sleep(nanoseconds: 5_000_000)
        #expect(task?.state == .resumed)

        #expect(monitor.taskDidSuspendCallCount == 1)
        #expect(monitor.taskDidResumeCallCount == 1)
    }

    @Test
    func testThatUploadFailsWhenAWSTaskHasNoResultShouldSucceeds() async throws {
        // Given
        let sut = S3CloudStorage(
            bucketName: "bucketName_test",
            transferUtility: transferUtility,
            monitor: monitor
        )

        // When
        transferUtility.result = AWSTask(error: NSError(domain: "test", code: 1))

        let task = sut.upload(Data("fake".utf8), fileName: "file", contentType: .jpeg) as? S3UploadDataTask

        try await Task.sleep(nanoseconds: 5_000_000)

        // Then
        #expect(task?.state == .finished)
        #expect(task?.error?.kind == .CloudStorageErrorReason.uploadTaskCreationFailed)
        #expect(sut.activeUploadTasks.count == 0)
        #expect(monitor.didFailToCreateUploadTaskCallCount == 1)
        #expect(monitor.taskDidFinishCallCount == 1)
    }

    // MARK: - UploadTaskState Tests

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
}
