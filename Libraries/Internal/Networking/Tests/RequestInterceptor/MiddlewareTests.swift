//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import NetworkingTesting
import Testing

@testable import Networking

struct MiddlewareTests {
    // MARK: - Properties
    
    let error = NetworkingError(kind: .explicitlyCancelled)
    let request = Request(delegate: nil, middleware: nil, monitor: nil, queue: .main)
    let session = Session()

    // MARK: - Tests

    @Test func testThatInitialization() {
        // Given
        let interceptor = RequestInterceptorMock()
        let retrier = RequestRetrierMock()
        let sut = Middleware(interceptors: [interceptor], retriers: [retrier])

        // When, Then
        #expect(sut.interceptors.count == 1, "Expect interceptors to be set correctly")
        #expect(sut.retriers.count == 1, "Expect retriers to be set correctly")
    }

    @Test func testThatIntercept() async throws {
        // Given
        let interceptor = RequestInterceptorMock()
        let retrier = RequestRetrierMock()
        let request = URLRequest(url: URL(string: "https://httpbin.org")!)
        let sut = Middleware(interceptors: [interceptor], retriers: [retrier])

        // When
        _ = try await sut.intercept(request, for: session)
        
        // Then
        #expect(interceptor.request == request, "Expect request to be equals to \(request)")
        #expect(interceptor.session != nil, "Expect session to not be nil")
    }

    @Test func testThatRetryShouldRetryRequestWithCorrectParameters() async {
        // Given
        let interceptor = RequestInterceptorMock()
        let retrier = RequestRetrierMock()
        let sut = Middleware(interceptors: [interceptor], retriers: [retrier])

        // When
        let retryPolicy = await sut.retry(request, for: session, failedWith: error)
        
        // Then
        #expect(retryPolicy.isRetry, "Expect retry policy to be equals to retry")
        #expect(
            (retrier.error as? NetworkingError)?.kind == .explicitlyCancelled,
            "Expect error to be a explicitlyCancelled"
        )
        #expect(retrier.request == request, "Expect underlying request to be equals to \(request)")
        #expect(retrier.session != nil, "Expect session to not be nil")
    }
    
    @Test func testThatDoNotRetryShouldNotRetryTheRequest() async {
        // Given
        let interceptor = RequestInterceptorMock()
        let retrier = RequestRetrierMock()
        let sut = Middleware(interceptors: [interceptor], retriers: [retrier])

        // When
        retrier.retry = .doNotRetry
        
        let retryPolicy = await sut.retry(request, for: session, failedWith: error)
        
        // Then
        #expect(retryPolicy.isDoNotRetry, "Expect retry policy to be equals to doNotRetry")
        #expect(
            (retrier.error as? NetworkingError)?.kind == .explicitlyCancelled,
            "Expect error to be a explicitlyCancelled"
        )
        #expect(retrier.request == request, "Expect underlying request to be equals to \(request)")
        #expect(retrier.session != nil, "Expect session to not be nil")
    }

    @Test func testThatDoNotRetryWithErrorShouldNotRetryTheRequest() async {
        // Given
        let interceptor = RequestInterceptorMock()
        let retrier = RequestRetrierMock()
        let sut = Middleware(interceptors: [interceptor], retriers: [retrier])

        // When
        retrier.retry = .doNotRetryWithError(NetworkingError(kind: .sessionTaskFailed))
        
        let retryPolicy = await sut.retry(request, for: session, failedWith: error)
        
        // Then
        #expect(retryPolicy.isDoNotRetryWithError, "Expect retry policy to be equals to doNotRetryWithError")
        #expect(
            (retrier.error as? NetworkingError)?.kind == .explicitlyCancelled,
            "Expect error to be a explicitlyCancelled"
        )
        #expect(retrier.request == request, "Expect underlying request to be equals to \(request)")
        #expect(retrier.session != nil, "Expect session to not be nil")
    }
    
    @Test func testThatRetryShouldDoNotRetryWhenRetriersAreEmpty() async {
        // Given
        let sut = Middleware(interceptors: [], retriers: [])

        // When
        let retryPolicy = await sut.retry(request, for: session, failedWith: error)
        
        // Then
        #expect(retryPolicy.isDoNotRetry, "Expect retry policy to be equals to doNotRetry")
    }
    
    @Test func testThatDefaultRetryPolicy() async {
        // Given
        let retrier = CustomRetrier()
        let sut = Middleware(interceptors: [], retriers: [retrier])

        // When
        let retryPolicy = await sut.retry(request, for: session, failedWith: error)
        
        // Then
        #expect(retryPolicy.isDoNotRetry, "Expect retry policy to be equals to doNotRetry")
    }
}

private struct CustomRetrier: RequestRetrier {}

private extension RetryPolicy {
    /// Returns true if the policy is a do not retry.
    var isDoNotRetry: Bool {
        guard case .doNotRetry = self else { return false }
        
        return true
    }
    
    /// Returns true if the policy is a do not retry with error.
    var isDoNotRetryWithError: Bool {
        guard case .doNotRetryWithError(_) = self else { return false }
        
        return true
    }
    
    /// Returns true if the policy is a retry.
    var isRetry: Bool {
        guard case .retry(_) = self else { return false }
        
        return true
    }
}
