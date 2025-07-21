//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// Represents a lightweight, timestamped log entry used to capture relevant contextual events
/// leading up to a telemetry report.
///
/// `Breadcrumb` instances are designed to help trace user and system behavior over time.
/// They can be attached to `TelemetryReport` objects to provide insight into the events
/// and state transitions that occurred before an error, warning, or significant event.
///
/// This model is inspired by common breadcrumb systems in error tracking platforms like Sentry and Datadog.
///
/// Example usage:
/// ```swift
/// let breadcrumb = Breadcrumb(
///     severity: .info,
///     source: "camera",
///     category: "camera.session",
///     message: "Camera preview started",
///     metadata: ["lens": "front"]
/// )
/// telemetryManager.captureBreadcrumb(breadcrumb)
/// ```
public struct Breadcrumb: Codable, Sendable {
    /// The logical grouping of the breadcrumb, typically used for filtering or categorizing related events.
    public let category: String

    /// An optional message describing the event or context.
    public let message: String?

    /// Additional structured metadata that provides details about the event.
    public let metadata: Metadata?

    /// The severity level of the breadcrumb.
    public let severity: Severity

    /// The source of the breadcrumb, typically the file or component name.
    public let source: String

    /// The timestamp indicating when the breadcrumb was recorded.
    public let timestamp: Date

    // MARK: - Initializer

    /// Creates a new `Breadcrumb` instance with the specified attributes.
    ///
    /// - Parameters:
    ///   - severity: The severity level of the breadcrumb.
    ///   - source: The origin of the event (e.g., file, system component).
    ///   - category: The category used to group similar breadcrumbs (default is `"default"`).
    ///   - message: A brief human-readable message describing the event (default is an empty string).
    ///   - timestamp: The timestamp for when the breadcrumb occurred (default is the current date and time).
    ///   - metadata: Additional key-value data related to the event (default is an empty dictionary).
    public init(
        severity: Severity,
        source: String,
        category: String = "default",
        message: String? = nil,
        timestamp: Date = Date(),
        metadata: Metadata? = nil
    ) {

        self.category = category
        self.message = message
        self.metadata = metadata
        self.severity = severity
        self.source = source
        self.timestamp = timestamp
    }
}
