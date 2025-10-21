//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AWSS3
import Foundation

/// A mock subclass of `AWSS3TransferUtilityTask` used for unit testing.
///
/// `AWSS3TransferUtilityTask` exposes its `response` property as read-only,
/// which makes it impossible to inject a custom `HTTPURLResponse` in tests.
/// This mock provides a controlled override of that property, allowing tests
/// to simulate scenarios where the task has a specific response.
///
/// Example usage:
///
/// ```swift
/// let task = TransferUtilityTaskMock()
/// task.setMockResponse(
///     HTTPURLResponse(
///         url: URL(string: "https://example.com/file")!,
///         statusCode: 200,
///         httpVersion: nil,
///         headerFields: nil
///     )!
/// )
public final class TransferUtilityTaskMock: AWSS3TransferUtilityTask {
    private var _mockResponse: HTTPURLResponse?

    /// Overrides the `response` property of `AWSS3TransferUtilityTask`
    /// to return a mock value supplied via `setMockResponse`.
    override public var response: HTTPURLResponse? { _mockResponse }

    /// Allows injection of a custom `HTTPURLResponse` for testing.
    ///
    /// - Parameter response: The `HTTPURLResponse` instance to return when
    ///   accessing the `response` property.
    public func setMockResponse(_ response: HTTPURLResponse) {
        _mockResponse = response
    }
}
