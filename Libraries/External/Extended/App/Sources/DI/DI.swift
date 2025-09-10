//
// Copyright © 2025 TruVideo. All rights reserved.
//

internal import DI
internal import TruVideoApi

/// Provides a `DependencyKey` for injecting a `AuthenticatableClient` dependency.
///
/// `AuthenticatableClientDependencyKey` is used by the dependency system to resolve the default
/// implementation of `AuthenticatableClient`.
struct AuthenticatableClientDependencyKey: DependencyKey {
    /// The default authenticatable client used if none is explicitly set.
    static let defaultValue: any AuthenticatableClient = AuthenticationClient()
}

/// Provides a `DependencyKey` for injecting a `DeviceSettingsResource` dependency.
///
/// `DeviceSettingResourceDependencyKey` is used by the dependency system to resolve the default
/// implementation of `DeviceSettingsResource`.
struct DeviceSettingResourceDependencyKey: DependencyKey {
    /// The default authenticatable client used if none is explicitly set.
    static let defaultValue: any DeviceSettingsResource = DeviceSettingsResourceImpl()
}

extension DependencyValues {
    /// Accessor for resolving or overriding the current `AuthenticatableClient`.
    var authenticatableClient: any AuthenticatableClient {
        get { self[AuthenticatableClientDependencyKey.self] }
        set { self[AuthenticatableClientDependencyKey.self] = newValue }
    }

    /// Accessor for resolving or overriding the current `DeviceSettingsResource`.
    var deviceSettingResource: any DeviceSettingsResource {
        get { self[DeviceSettingResourceDependencyKey.self] }
        set { self[DeviceSettingResourceDependencyKey.self] = newValue }
    }
}
