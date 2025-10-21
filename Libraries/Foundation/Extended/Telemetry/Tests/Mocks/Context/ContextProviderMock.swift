//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

@testable import Telemetry

/// A mock implementation of the `ContextProvider` protocol for use in unit tests.
final class ContextProviderMock: ContextProvider, @unchecked Sendable {
    // MARK: - Properties

    /// The number of times the make context function was invoked.
    private(set) var makeContextCallCount = 0

    // MARK: - ContextProvider

    /// Returns a static `Context` object with predefined values representing
    /// a test environment.
    ///
    /// - Returns: A `Context` containing simulated device, OS, and SDK information.
    func makeContext() -> Context {
        makeContextCallCount += 1

        return Context(
            device: .init(
                battery: .init(isLowPowerMode: false, level: 100, state: "full"),
                cpuArchitecture: "arm64",
                disk: .init(free: 100_000_000, total: 200_000_000),
                manufacturer: "Apple",
                memory: .init(free: 50_000_000, total: 100_000_000),
                model: "TestModel",
                processorCount: 4,
                thermalState: "nominal",
                uptimeSeconds: 1000
            ),
            osInfo: .init(name: "iOS", version: "17.0"),
            sdks: [:]
        )
    }
}
