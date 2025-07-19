//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A protocol that defines a subscriber interface for receiving telemetry reports
/// from the `TelemetryManager`.
///
/// Conforming types will be notified whenever a new `TelemetryReport` is generated.
/// This is useful for logging systems, monitoring tools, debugging utilities, or
/// custom analytics pipelines that need to consume structured telemetry data.
///
/// ## Usage
/// Implement this protocol in any class that needs to observe and process telemetry reports:
///
/// ```swift
/// final class CrashReporter: TelemetryManagerSubscriber {
///     func didReceive(_ report: TelemetryReport) {
///         // Forward the report to a crash analytics system
///     }
/// }
/// ```
public protocol TelemetryManagerSubscriber: AnyObject {
    /// Called whenever a new telemetry report is published by the `TelemetryManager`.
    ///
    /// - Parameter report: A fully structured telemetry report containing contextual
    ///   metadata, breadcrumbs, and event details.
    func didReceive(_ report: TelemetryReport)
}
