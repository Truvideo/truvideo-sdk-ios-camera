//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Networking

/// A mock implementation of the `RequestInterceptor` protocol for testing network requests.
///
/// `RequestInterceptorMock` is primarily designed for unit testing to verify that requests are being intercepted and
/// adapted correctly.
/// It allows for capturing intercepted `URLRequest` instances and simulating errors during interception. This makes it
/// useful for testing both successful and failure scenarios.
///
/// ### Example Usage:
/// ```swift
/// let interceptorMock = RequestInterceptorMock()
/// let session = Session()
/// let urlRequest = URLRequest(url: URL(string: "https://example.com")!)
///
/// Task {
///     do {
///         let interceptedRequest = try await interceptorMock.intercept(urlRequest, for: session)
///         XCTAssertEqual(interceptorMock.request, urlRequest)
///     } catch {
///         XCTFail("Unexpected interception failure: \(error)")
///     }
/// }
/// ```
///
/// ### Example Usage with Error Simulation:
/// ```swift
/// let interceptorMock = RequestInterceptorMock()
/// interceptorMock.error = NSError(domain: "TestError", code: 1, userInfo: nil)
///
/// Task {
///     do {
///         _ = try await interceptorMock.intercept(urlRequest, for: session)
///         XCTFail("Expected interception error but succeeded")
///     } catch {
///         XCTAssertEqual((error as NSError).domain, "TestError")
///     }
/// }
/// ```
public final class RequestInterceptorMock: RequestInterceptor {
    // MARK: - Public Properties

    /// An error to simulate during interception.
    public var error: Error?

    /// The intercepted `URLRequest` instance.
    public private(set) var request: URLRequest?

    /// The `HTTPURLSession` that initiated the intercepted request.
    public private(set) var session: Session?

    // MARK: - Initializer

    /// Creates a new instance of `RequestInterceptorMock`.
    ///
    /// Initializes the interceptor mock without any predefined errors or captured requests.
    public init() {}

    // MARK: - RequestInterceptor

    /// Inspects and captures the provided `URLRequest` and optionally throws a predefined error.
    ///
    /// - Parameters:
    ///   - request: The `URLRequest` that has been intercepted.
    ///   - session: The `Session` that initiated the request.
    ///
    /// - Throws: A predefined error if the `error` property is set, simulating interception failure.
    ///
    /// - Returns: The original `URLRequest` instance, allowing for potential modification if needed.
    ///
    /// ### Example Usage:
    /// ```swift
    /// let interceptedRequest = try await interceptorMock.intercept(request, for: session)
    /// ```
    public func intercept(_ request: URLRequest, for session: Session) async throws -> URLRequest {
        self.request = request
        self.session = session

        if let error {
            throw error
        }

        return request
    }
}
