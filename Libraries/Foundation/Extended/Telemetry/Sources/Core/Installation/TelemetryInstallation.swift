//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
import Foundation
import StorageKit

/// A protocol that defines a contract for providing a unique, persistent identifier
/// tied to an installation of the application.
///
/// Implementations are expected to return the same identifier for the lifetime
/// of the app installation. This is typically used for telemetry, analytics,
/// or uniquely identifying devices without requiring user authentication.
public protocol TelemetryInstallation {
    /// Retrieves the unique identifier associated with the current app installation.
    ///
    /// - Returns: A stable `UUID` identifier that uniquely represents the current installation.
    func uniqueIdentifier() -> UUID
}

/// A default implementation of `TelemetryInstallation` using `UserDefaults` to persist
/// and retrieve a unique identifier for the app installation.
///
/// The identifier is stored using a predefined key (`com.truvideo.installation`)
/// and is generated via `UUID` if not already present. This approach ensures
/// consistency across app launches, unless the app data is removed or reset.
struct InstallationProvider: TelemetryInstallation {
    // MARK: - Private Properties

    @Dependency(\.storage)
    var storage: Storage

    // MARK: - Types

    /// A key used for storing the unique installation identifier.
    struct InstallationIdStorageKey: StorageKey {
        /// The associated value type that will be stored and retrieved using this key.
        typealias Value = UUID
    }

    // MARK: - TelemetryInstallation

    /// Retrieves the unique identifier associated with the current app installation.
    ///
    /// - Returns: A stable `UUID` identifier that uniquely represents the current installation.
    func uniqueIdentifier() -> UUID {
        do {
            guard let uniqueIdentifier = try storage.readValue(for: InstallationIdStorageKey.self) else {
                let uniqueIdentifier = UUID()

                try storage.write(uniqueIdentifier, forKey: InstallationIdStorageKey.self)
                return uniqueIdentifier
            }

            return uniqueIdentifier
        } catch {
            // LOG Error
            /// storage should not fail but in case it does we will fallback to a temporary id.
            return UUID()
        }
    }
}
