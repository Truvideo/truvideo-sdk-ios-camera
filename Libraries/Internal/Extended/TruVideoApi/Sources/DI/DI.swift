//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
import Networking
import Storage

/// Provides a `DependencyKey` for injecting a `EnvironmentDependencyKey` dependency.
///
/// `EnvironmentDependencyKey` is used by the dependency system to resolve the default `Environment`.
public struct EnvironmentDependencyKey: DependencyKey {
    /// The default configuration used if none is explicitly set.
    public static let defaultValue = Environment.prod
}

/// Provides a `DependencyKey` for injecting a `Storage` dependency.
///
/// `StorageDependencyKey` allows consumers to override the default storage
/// mechanism used in the system. By default, this uses `KeychainStorage`.
struct StorageDependencyKey: DependencyKey {
    /// The default file-based storage used if none is explicitly provided.
    static let defaultValue: any Storage = KeychainStorage()
}

extension DependencyValues {
    /// Accessor for resolving or overriding the current `Environment`.
    public var apiEnvironment: Environment {
        get { self[EnvironmentDependencyKey.self] }
        set { self[EnvironmentDependencyKey.self] = newValue }
    }

    /// Accessor for resolving or overriding the current `Storage` implementation.
    var storage: any Storage {
        get { self[StorageDependencyKey.self] }
        set { self[StorageDependencyKey.self] = newValue }
    }
}
