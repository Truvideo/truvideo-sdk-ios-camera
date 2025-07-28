//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Networking

/// A mock implementation of the `Request` protocol for testing.
public final class RequestMock: Request {
    // MARK: - Private Properties

    private let id = UUID()

    // MARK: - Public Properties

    /// The current `URLRequest` created on behalf of the `Request`.
    public var request: URLRequest?

    /// `HTTPURLResponse` received from the server, if any.
    public var response: HTTPURLResponse?

    /// The current retry count for this request.
    public var retryCount: Int = 0

    /// A human-readable description for debugging purposes.
    public var debugDescription: String {
        "DataRequestMock(id: \(id), retryCount: \(retryCount))"
    }

    // MARK: - Call Count Properties

    /// The number of times `cancel` has been called.
    public private(set) var cancelCallCount = 0

    /// The number of times `resume` has been called.
    public private(set) var resumeCallCount = 0

    // MARK: - Initializer

    /// Creates a new instance of the `RequestMock`.
    public init() {}

    // MARK: - Request

    /// Cancels the request, if allowed.
    ///
    /// - Returns: The current `Request` instance.
    @discardableResult
    public func cancel() -> Self {
        cancelCallCount += 1
        return self
    }

    /// Resumes the request, if allowed.
    ///
    /// - Returns: The current `Request` instance.
    public func resume() -> Self {
        resumeCallCount += 1
        return self
    }
}

extension RequestMock {

    // MARK: - Equatable

    /// Returns a Boolean value indicating whether two values are equal.
    public static func == (lhs: RequestMock, rhs: RequestMock) -> Bool {
        lhs.id == rhs.id
    }
}
