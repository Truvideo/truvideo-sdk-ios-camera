//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
import Networking
import StorageKit

/// Provides a `DependencyKey` for injecting a `Session` dependency.
///
/// `SessionDependencyKey` allows consumers to override the default storage
/// mechanism used in the system. By default, this uses `HTTPURLSession`.
public struct SessionDependencyKey: DependencyKey {
    /// The default file-based storage used if none is explicitly provided.
    public static let defaultValue: any Session = HTTPURLSession(
        cache: InMemoryURLCache(),
        middleware: Middleware(interceptors: [], retriers: []),
        monitors: []
    )
}

extension DependencyValues {
    /// Accessor for resolving or overriding the current `Session` implementation.
    public var truVideoSession: any Session {
        get { self[SessionDependencyKey.self] }
        set { self[SessionDependencyKey.self] = newValue }
    }
}
