//
// Copyright © 2025 TruVideo. All rights reserved.
//

@testable import TruvideoSdk

/// A mock implementation of a `Migrator`, used for testing.
public final class MigratorMock: Migrator {
    /// Flag to track whether `migrate()` was called.
    public private(set) var migrateCallCount = 0

    // MARK: - Initializer

    public init() {}

    // MARK: - Migrator

    /// Simulates a migration operation.
    ///
    /// Increments the `migrateCallCount` by 1 each time this method is called.
    public func migrate() throws {
        migrateCallCount += 1
    }
}
