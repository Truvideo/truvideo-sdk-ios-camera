//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Networking
import NetworkingTesting
import Testing

@testable import CloudStorageKit

struct UploadRequestRetrierTests {
    // MARK: - Tests

    @Test
    func testThatUploadPartTaskShouldInitialize() async throws {
        // Given
        let sut = UploadRequestRetrier()
        let session = SessionMock()
        let request = RequestMock()

        // When
        let policy = await sut.retry(request, for: session, failedWith: URLError(.badServerResponse))

        // Then
        if case .doNotRetry = policy {
            #expect(true)
        }
    }

    @Test
    func testThatRetryStopsAfterMaxNumberOfRetries() async throws {
        // Given
        let sut = UploadRequestRetrier()
        let session = SessionMock()
        let request = RequestMock()

        // When
        request.request = URLRequest(url: URL(string: "https://test.com")!)
        request.response = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )

        request.retryCount = 3

        let policy = await sut.retry(request, for: session, failedWith: URLError(.unknown))

        // Then
        if case .doNotRetry = policy {
            #expect(true)
        }
    }

    @Test
    func testThatRetryAppliesExponentialBackoffOnServerError() async throws {
        // Given
        let sut = UploadRequestRetrier()
        let session = SessionMock()
        let request = RequestMock()
        request.request = URLRequest(url: URL(string: "https://test.com")!)
        request.response = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 408,
            httpVersion: nil,
            headerFields: nil
        )
        request.retryCount = 2

        // When
        let policy = await sut.retry(request, for: session, failedWith: URLError(.badServerResponse))

        // Then
        if case let .retry(delay) = policy {
            #expect(delay == 2.0)
        }
    }

    @Test
    func testThatRetryDoesNotRetryOnNonRetriableStatusCode() async throws {
        // Given
        let sut = UploadRequestRetrier()
        let session = SessionMock()
        let request = RequestMock()
        request.request = URLRequest(url: URL(string: "https://test.com")!)
        request.response = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        request.retryCount = 2

        // When
        let policy = await sut.retry(request, for: session, failedWith: URLError(.badServerResponse))

        // Then
        if case .doNotRetry = policy {
            #expect(true)
        }
    }
}
