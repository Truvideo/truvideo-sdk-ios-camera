//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// Represents a structured telemetry report used to capture diagnostic, performance,
/// and contextual data during the application's runtime.
///
/// `TelemetryReport` is the central payload structure sent by the telemetry system. It encapsulates:
/// - the core event being reported (e.g., an error, warning, or custom event),
/// - contextual device and OS information at the time of the event,
/// - an optional list of breadcrumbs leading up to the event,
/// - and an optional exception payload describing any thrown error.
///
/// This struct is typically constructed internally by the telemetry manager and used
/// to persist, send, or inspect application telemetry data.
public struct TelemetryReport: Codable, Identifiable, Sendable {
    /// A unique identifier for the report.
    public let id: UUID

    /// A chronological list of breadcrumbs that describe notable events leading up to the telemetry event.
    public let breadcrumbs: [Breadcrumb]?

    /// The full contextual snapshot of the device and operating system at the time of the event.
    public let context: Context

    /// The primary telemetry event being reported.
    public let event: Event

    /// An optional exception object containing the message and stack frame when the event involves an error or failure.
    public let exception: Exception?

    // MARK: - Initializer

    /// Creates a new telemetry report instance.
    ///
    /// - Parameters:
    ///   - event: The event to report.
    ///   - context: The context of the device and OS at the time of the event.
    ///   - breadcrumbs: An optional breadcrumb trail leading up to the event.
    ///   - exception: An optional exception if the event involves an error.
    init(event: Event, context: Context, breadcrumbs: [Breadcrumb]? = nil, exception: Exception? = nil) {
        self.id = UUID()
        self.breadcrumbs = breadcrumbs
        self.context = context
        self.event = event
        self.exception = exception
    }

    // MARK: - Types

    /// Represents the core telemetry event, including its name, severity, source, metadata, and timestamp.
    public struct Event: Codable, Sendable {
        /// A descriptive name identifying the type of event (e.g., "camera.session.failed").
        public let name: String
        
        /// Additional metadata relevant to the event, such as device config or capture context.
        public let metadata: Metadata
        
        /// The severity level of the event (e.g., info, warning, error).
        public let severity: Severity
        
        /// The source module or component where the event originated.
        public let source: String
        
        /// The time the event occurred.
        public let timestamp: Date

        // MARK: - Initializer

        /// Creates a new event.
        ///
        /// - Parameters:
        ///   - name: A descriptive name for the event.
        ///   - severity: The severity level of the event.
        ///   - source: The originating component or module.
        ///   - timestamp: The time the event occurred. Defaults to the current time.
        ///   - metadata: Optional metadata associated with the event.
        init(name: String, severity: Severity, source: String, timestamp: Date = Date(), metadata: Metadata = [:]) {
            self.name = name
            self.severity = severity
            self.source = source
            self.timestamp = timestamp
            self.metadata = metadata
        }
    }

    /// Represents an exception that occurred during the execution of the app,
    /// including an error message and a captured stack frame.
    public struct Exception: Codable, Hashable, Sendable {
        /// A human-readable error message describing the failure.
        public let message: String

        /// The stack frame where the exception occurred.
        public let stackFrame: StackFrame

        // MARK: - Initializer

        /// Creates a new exception instance.
        ///
        /// - Parameters:
        ///   - message: A description of the exception.
        ///   - stackFrame: The location in the code where the exception was thrown.
        init(message: String, stackFrame: StackFrame) {
            self.message = message
            self.stackFrame = stackFrame
        }
    }
}
