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

    public private(set) var cancelCallCount = 0
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
