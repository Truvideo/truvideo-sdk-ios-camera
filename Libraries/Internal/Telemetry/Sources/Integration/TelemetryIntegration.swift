//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A protocol that defines the interface for integrating third-party or custom telemetry systems.
///
/// Types conforming to `TelemetryIntegration` provide their own installation logic, allowing them
/// to hook into a central `TelemetryManager`. This enables modular telemetry setups where integrations
/// can be dynamically added or removed as needed.
///
/// Typical use cases include:
/// - Registering crash reporting tools (e.g., Sentry, Firebase Crashlytics)
/// - Adding performance monitoring tools (e.g., MetricKit, custom tracers)
/// - Injecting logging pipelines or event dispatchers
///
/// Example:
/// ```swift
/// struct CustomIntegration: TelemetryIntegration {
///     func install(on manager: TelemetryManager) {
///         // initialization code
///     }
/// }
/// ```
public protocol TelemetryIntegration {
    /// Installs the telemetry integration into the provided telemetry manager.
    ///
    /// - Parameter manager: The central `TelemetryManager` responsible for coordinating integrations.
    func install(on manager: TelemetryManager)
}
