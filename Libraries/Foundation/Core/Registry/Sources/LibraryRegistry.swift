//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A protocol that defines the essential information and configuration logic for a software library
/// integrated into the TruVideo SDK ecosystem.
///
/// Conforming types must provide a name and version, and implement configuration logic
/// that will be called during SDK initialization.
///
/// ## Example
/// ```swift
/// struct MediaLibrary: Library {
///     let name = "TruVideoMedia"
///     let version = "1.0.0"
///
///     func configure(with configuration: SDKConfiguration) {
///         // Configure media-specific dependencies and services
///         DependencyValues.current[MediaServiceKey.self] = MediaService()
///     }
/// }
/// ```
public protocol Library {
    /// The unique name of the library.
    ///
    /// This should be a concise, URL-safe string using only alphanumeric characters,
    /// hyphens (`-`), underscores (`_`), or dots (`.`). It is used to register and
    /// reference the library in runtime systems.
    var name: String { get }

    /// The current semantic version of the library.
    ///
    /// Follows standard versioning schemes such as `"1.0.0"` or `"75.2.1-RC.3"`.
    /// Used for compatibility checks, debugging, and diagnostics.
    var version: String { get }

    /// Configures the library with the provided SDK configuration.
    ///
    /// This method is called during SDK initialization to set up library-specific
    /// dependencies, services, or configurations.
    func configure()
}

/// A central registry for tracking integrated libraries within the TruVideo ecosystem.
///
/// `LibraryRegistry` provides a static interface for registering third-party or internal modules
/// that are part of the SDK or host application. This information can be used for diagnostics,
/// telemetry, analytics, or debugging purposes to understand what components are included
/// in a given runtime.
///
/// The registry manages library registration and configuration, allowing for dynamic
/// discovery and setup of modules during SDK initialization.
///
/// - Note: The class is marked as `@unchecked Sendable` since it maintains static mutable state.
///   Care should be taken to access or mutate state in a thread-safe manner if extended.
///
/// ## Example
/// ```swift
/// // Register a library
/// LibraryRegistry.register(MediaLibrary())
///
/// // Configure all registered libraries
/// LibraryRegistry.configureAll(with: configuration)
/// ```
public class LibraryRegistry: @unchecked Sendable {
    // MARK: - Private Properties

    /// A static array holding registered libraries.
    private static var libraries: [Library] = []

    // MARK: - Public static methods

    /// Configures all registered libraries with the provided configuration.
    ///
    /// This method orchestrates the configuration of all libraries that have been
    /// registered with the registry. It iterates through each registered library
    /// and calls its `configure(with:)` method, allowing each library to set up
    /// its dependencies, services, and environment-specific configurations.
    ///
    /// ## Thread Safety
    ///
    /// This method is not thread-safe. It should be called from a single thread
    /// during SDK initialization, typically from the main thread.
    public static func configureAll() {
        for library in libraries {
            library.configure()
        }
    }

    /// Registers a library to the application registry.
    ///
    /// The library name must contain only alphanumeric characters and optionally `-`, `_`, or `.`.
    /// Invalid names are ignored silently (may log a warning internally in future enhancements).
    ///
    /// - Parameter library: A `Library` instance containing the module's metadata and configuration logic.
    public static func register(_ library: Library) {
        var allowedSet = CharacterSet.alphanumerics
        allowedSet.insert(charactersIn: "-_.")

        guard library.name.rangeOfCharacter(from: allowedSet) != nil,
            library.name.rangeOfCharacter(from: allowedSet.inverted) == nil
        else {
            return
        }

        libraries.append(library)
    }

    /// Returns all registered libraries.
    ///
    /// - Returns: An array of registered `Library` instances.
    public static func registeredLibraries() -> [Library] {
        libraries
    }
}
