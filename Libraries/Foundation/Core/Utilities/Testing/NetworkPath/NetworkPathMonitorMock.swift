//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Network
import Utilities

/// A mock implementation of NetworkPathMonitor for testing network monitoring functionality.
///
/// This class provides a testable implementation of the NetworkPathMonitor protocol
/// that allows developers to simulate network path monitoring during testing.
/// It can be configured with different network path states and provides
/// control over when path updates are delivered to test network-dependent
/// functionality without requiring actual network hardware or connectivity.
public final class NetworkPathMonitorMock: NetworkPathMonitor {
    // MARK: - Properties

    public typealias Path = NetworkPathMock

    var path: NetworkPathMock
    public var currentPath: NetworkPathMock { path }
    public var pathUpdateHandler: (@Sendable (_ newPath: NetworkPathMock) -> Void)?

    private(set) var isStarted = false
    private(set) var isCancelled = false
    private var queue: DispatchQueue?

    // MARK: - Initializer

    public init(initialPath: NetworkPathMock = NetworkPathMock(status: .satisfied)) {
        self.path = initialPath
    }

    // MARK: - NetworkPathMonitor

    /// Start the path monitor and set a queue on which path updates
    /// will be delivered.
    ///
    /// - Parameter queue: The queue where the updates will be delivered.
    public func start(queue: DispatchQueue) {
        self.queue = queue
        isStarted = true
    }

    /// Cancel the path monitor, after which point no more path updates will
    /// be delivered.
    public func cancel() {
        isCancelled = true
    }
}
