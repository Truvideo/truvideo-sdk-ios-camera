//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

@testable import Telemetry

/// A minimal mock implementation of the `TelemetryInstallation` protocol for use in unit tests.
struct TelemetryInstallationMock: TelemetryInstallation {
    // MARK: - Properties

    /// The mock installation identifier.
    let id = UUID()

    // MARK: - TelemetryInstallation

    /// Returns the mock installation's unique identifier.
    ///
    /// - Returns: A predefined `UUID` representing the installation.
    func uniqueIdentifier() -> UUID {
        id
    }
}
