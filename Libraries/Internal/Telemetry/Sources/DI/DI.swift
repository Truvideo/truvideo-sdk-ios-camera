//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI

/// Provides a `DependencyKey` for injecting a `ContextProvider` dependency.
///
/// `ContextProviderKey` is used by the dependency system to resolve the default
/// implementation of `ContextProvider`, which is `RuntimeContextProvider`.
struct ContextProviderKey: DependencyKey {
    typealias Value = any ContextProvider

    /// The default context provider used if none is explicitly set.
    static let defaultValue: any ContextProvider = RuntimeContextProvider()
}

/// Provides a `DependencyKey` for injecting a `Storage` dependency.
///
/// `StorageDependencyKey` allows consumers to override the default storage
/// mechanism used in the system. By default, this uses `FileSystemStorage`.
struct StorageDependencyKey: DependencyKey {
    typealias Value = any Storage

    /// The default file-based storage used if none is explicitly provided.
    static let defaultValue: any Storage = FileSystemStorage()
}

/// Provides a `DependencyKey` for injecting a `TelemetryInstallation` dependency.
///
/// `TelemetryInstallationDependencyKey` resolves the implementation responsible for
/// providing a unique identifier tied to the device installation. Defaults to `InstallationProvider`.
struct TelemetryInstallationDependencyKey: DependencyKey {
    typealias Value = any TelemetryInstallation

    /// The default installation provider used if none is explicitly injected.
    static let defaultValue: any TelemetryInstallation = InstallationProvider()
}

extension DependencyValues {
    /// Accessor for resolving or overriding the current `ContextProvider`.
    var contextProvider: any ContextProvider {
        get { self[ContextProviderKey.self] }
        set { self[ContextProviderKey.self] = newValue }
    }

    /// Accessor for resolving or overriding the current `TelemetryInstallation` instance.
    var installation: any TelemetryInstallation {
        get { self[TelemetryInstallationDependencyKey.self] }
        set { self[TelemetryInstallationDependencyKey.self] = newValue }
    }

    /// Accessor for resolving or overriding the current `Storage` implementation.
    var storage: any Storage {
        get { self[StorageDependencyKey.self] }
        set { self[StorageDependencyKey.self] = newValue }
    }
}
