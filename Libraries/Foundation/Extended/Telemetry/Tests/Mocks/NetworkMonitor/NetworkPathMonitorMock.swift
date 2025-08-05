//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Network

@testable import Telemetry

final class NetworkPathMonitorMock: NetworkPathMonitor {
    // MARK: - Properties

    typealias Path = NetworkPathMock
    
    var path: NetworkPathMock
    var currentPath: NetworkPathMock { path }
    var pathUpdateHandler: (@Sendable (_ newPath: NetworkPathMock) -> Void)?

    private(set) var isStarted = false
    private(set) var isCancelled = false
    private var queue: DispatchQueue?

    // MARK: - Initializer

    init(initialPath: NetworkPathMock = NetworkPathMock()) {
        self.path = initialPath
    }

    // MARK: - NetworkPathMonitor

    /// Start the path monitor and set a queue on which path updates
    /// will be delivered.
    ///
    /// - Parameter queue: The queue where the updates will be delivered.
    func start(queue: DispatchQueue) {
        self.queue = queue
        isStarted = true
    }

    /// Cancel the path monitor, after which point no more path updates will
    /// be delivered.
    func cancel() {
        isCancelled = true
    }
}
