//
// Copyright © 2025 TruVideo. All rights reserved.
//

@testable import Registry

/// A mock implementation of the `Library` protocol, used for testing.
///
/// This mock allows unit tests to verify that library registration and configuration
/// logic is invoked correctly without requiring a real library implementation.
public final class LibraryRegistryMock: Library {
    /// Flag to track whether `configure()` was called.
    public private(set) var configureCalled = false

    /// The name of the library.
    public private(set) var name: String

    /// The version of the library.
    public private(set) var version: String

    // MARK: - Initializer

    /// Creates a new `LibraryRegistryMock` instance.
    ///
    /// - Parameters:
    ///   - name: Optional library name. Defaults to `"MockLibrary"`.
    ///   - version: Optional library version. Defaults to `"1.0.0"`.
    public init(name: String, version: String) {
        self.name = name
        self.version = version
    }

    // MARK: - Library

    /// Simulates configuring the library.
    ///
    /// Sets `configureCalled` to `true` to indicate that this method was invoked.
    /// No real configuration logic is executed, making it safe for unit tests.
    public func configure() {
        configureCalled = true
    }
}
