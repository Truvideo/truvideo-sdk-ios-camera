//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
import Networking
import StorageKit

/// Provides a `DependencyKey` for injecting a `EnvironmentDependencyKey` dependency.
///
/// `EnvironmentDependencyKey` is used by the dependency system to resolve the default `Environment`.
public struct EnvironmentDependencyKey: DependencyKey {
    /// The default configuration used if none is explicitly set.
    public static let defaultValue = Environment.prod
}

/// Provides a `DependencyKey` for injecting a `Session` dependency.
///
/// `SessionDependencyKey` allows consumers to override the default storage
/// mechanism used in the system. By default, this uses `HTTPURLSession`.
struct SessionDependencyKey: DependencyKey {
    /// The default file-based storage used if none is explicitly provided.
    static let defaultValue: any Session = HTTPURLSession(
        cache: InMemoryURLCache(),
        middleware: Middleware(interceptors: [AuthTokenInterceptor()], retriers: [SessionRequestRetrier()]),
        monitors: [SessionMonitor()]
    )
}

/// Provides a `DependencyKey` for injecting a `Storage` dependency.
///
/// `StorageDependencyKey` allows consumers to override the default storage
/// mechanism used in the system. By default, this uses `KeychainStorage`.
public struct SessionManagerDependencyKey: DependencyKey {
    /// The default file-based storage used if none is explicitly provided.
    public static let defaultValue: any SessionManager = SessionManagerImpl()
}

extension DependencyValues {
    /// Accessor for resolving or overriding the current `Environment`.
    public var apiEnvironment: Environment {
        get { self[EnvironmentDependencyKey.self] }
        set { self[EnvironmentDependencyKey.self] = newValue }
    }

    /// Accessor for resolving or overriding the current `Session` implementation.
    var session: any Session {
        get { self[SessionDependencyKey.self] }
        set { self[SessionDependencyKey.self] = newValue }
    }
    /// Accessor for resolving or overriding the current `SessionManager` implementation.
    public var sessionManager: any SessionManager {
        get { self[SessionManagerDependencyKey.self] }
        set { self[SessionManagerDependencyKey.self] = newValue }
    }
}
