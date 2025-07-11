//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A protocol that defines the essential information for a software library
/// integrated into the TruVideo SDK ecosystem.
///
/// Conforming types must provide a name and version, enabling runtime introspection,
/// diagnostics, and library registration through `TruVideoLibraryRegistry` (or equivalent).
///
/// Typical use cases include tracking SDK dependencies, exposing integrated
/// module metadata, and contributing to telemetry payloads.
///
/// ## Example
/// ```swift
/// struct MediaLibrary: Library {
///     let name = "TruVideoMedia"
///     let version = "1.0.0"
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
}

/// A central registry for tracking integrated libraries and their versions within the TruVideo ecosystem.
///
/// `TruVideoApp` provides a static interface for registering third-party or internal modules
/// that are part of the SDK or host application. This information can be used for diagnostics,
/// telemetry, analytics, or debugging purposes to understand what components are included
/// in a given runtime.
///
/// - Note: The class is marked as `@unchecked Sendable` since it maintains static mutable state.
///   Care should be taken to access or mutate state in a thread-safe manner if extended.
///
/// ## Example
/// ```swift
/// TruVideoApp.register(Library(name: "TruvideoCamera", version: "1.2.0"))
/// TruVideoApp.registeredLibraries() // => ["TruvideoCamera": "1.2.0"]
/// ```
public class LibraryRegistry: @unchecked Sendable {
    // MARK: - Private Properties
    
    /// A static dictionary holding the names and versions of registered libraries.
    private static var libraries: [String: String] = [:]
    
    // MARK: - Public Static Methods
    
    /// Registers a library and its version to the application registry.
    ///
    /// The library name must contain only alphanumeric characters and optionally `-`, `_`, or `.`.
    /// Invalid names are ignored silently (may log a warning internally in future enhancements).
    ///
    /// - Parameter library: A `Library` instance containing the module's name and version.
    public static func register(_ library: Library) {
        var allowedSet = CharacterSet.alphanumerics
        allowedSet.insert(charactersIn: "-_.")
        
        guard library.name.rangeOfCharacter(from: allowedSet) != nil,
              library.name.rangeOfCharacter(from: allowedSet.inverted) == nil else {
            // TODO: Log warning or raise internal alert
            return
        }
        
        libraries[library.name] = library.version
    }
    
    /// Returns a dictionary of all registered libraries and their versions.
    ///
    /// - Returns: A mapping of library names to version strings.
    public static func registeredLibraries() -> [String: String] {
        libraries
    }
}
