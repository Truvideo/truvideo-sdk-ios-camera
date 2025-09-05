//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
import Storage

/// Provides a `DependencyKey` for injecting a `ContextProvider` dependency.
///
/// `ContextProviderKey` is used by the dependency system to resolve the default
/// implementation of `ContextProvider`, which is `RuntimeContextProvider`.
struct ContextProviderKey: DependencyKey {
    /// The default context provider used if none is explicitly set.
    static let defaultValue: any ContextProvider = RuntimeContextProvider()
}

/// A dependency key used to inject a concrete implementation of the `FileWriter` protocol.
///
/// This key enables access to a shared `FileWriter` instance via Swift's dependency injection system.
/// If no custom implementation is provided, the default is `SystemFileWriter`, which writes directly to the file system.
struct FileWriterDependencyKey: DependencyKey {
    /// The default file writer used if none is explicitly injected.
    static let defaultValue: any FileWriter = SystemFileWriter()
}

/// Provides a `DependencyKey` for injecting a `Storage` dependency.
///
/// `StorageDependencyKey` allows consumers to override the default storage
/// mechanism used in the system. By default, this uses `FileSystemStorage`.
struct StorageDependencyKey: DependencyKey {
    /// The default file-based storage used if none is explicitly provided.
    static let defaultValue: any Storage = FileSystemStorage()
}

/// Provides a `DependencyKey` for injecting a `TelemetryInstallation` dependency.
///
/// `TelemetryInstallationDependencyKey` resolves the implementation responsible for
/// providing a unique identifier tied to the device installation. Defaults to `InstallationProvider`.
struct TelemetryInstallationDependencyKey: DependencyKey {
    /// The default installation provider used if none is explicitly injected.
    static let defaultValue: any TelemetryInstallation = InstallationProvider()
}

extension DependencyValues {
    /// Accessor for resolving or overriding the current `ContextProvider`.
    var contextProvider: any ContextProvider {
        get { self[ContextProviderKey.self] }
        set { self[ContextProviderKey.self] = newValue }
    }

    /// Accessor for resolving or overriding the current `FileWriter`.
    var fileWriter: any FileWriter {
        get { self[FileWriterDependencyKey.self] }
        set { self[FileWriterDependencyKey.self] = newValue }
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
