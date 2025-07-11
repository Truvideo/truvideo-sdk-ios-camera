//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A central manager for collecting, buffering, and dispatching telemetry data throughout the application.
///
/// The `TelemetryManager` coordinates the capture of telemetry events, contextual information, and breadcrumbs.
/// It allows subscribers to receive structured `TelemetryReport` instances, making it suitable for error
/// reporting, logging, analytics, and observability.
///
/// This class also supports pluggable `TelemetryIntegration`s to hook into system-level events like app
/// lifecycle changes, connectivity status, memory warnings, and more.
///
/// ## Responsibilities
/// - Captures structured events and exceptions
/// - Manages a breadcrumb buffer to include historical context for critical events
/// - Provides contextual system and device data via a `ContextProvider`
/// - Dispatches telemetry reports to registered `TelemetryManagerSubscriber`s
/// - Installs telemetry integrations for passive event collection
///
/// ## Example
/// ```swift
/// TelemetryManager.shared.capture("User signed in", name: "auth.success", source: "auth.screen")
/// ```
open class TelemetryManager: @unchecked Sendable {
    // MARK: - Private Properties
    
    private var buffer: BreadcrumbBuffer
    private let contextProvider: ContextProvider
    private let lock = NSLock()
    private var subscribers: [ObjectIdentifier: any TelemetryManagerSubscriber] = [:]
    
    // MARK: - Properties
    
    /// A list of telemetry integrations that automatically install when the manager is initialized.
    let integrations: [any TelemetryIntegration]
    
    // MARK: - Static Properties
    
    /// The shared singleton instance of `TelemetryManager` used across the app or SDK.
    public static let shared = TelemetryManager()
    
    // MARK: - Initializer
    
    /// Initializes a new instance with a custom buffer, context provider, and optional integrations.
    init(
        buffer: BreadcrumbBuffer,
        contextProvider: ContextProvider = RuntimeContextProvider(),
        integrations: [any TelemetryIntegration] = [SystemEventTrackerIntegration()]
    ) {

        self.buffer = buffer
        self.contextProvider = contextProvider
        self.integrations = integrations
        
        integrations.forEach { $0.install(on: self) }
    }

    /// Initializes a default instance using the standard breadcrumb buffer and runtime context provider.
    public convenience init() {
        self.init(buffer: BreadcrumbBuffer())
    }
    
    // MARK: - Public methods
    
    /// Registers a telemetry subscriber to receive `TelemetryReport` events.
    ///
    /// - Parameter subscriber: An object conforming to `TelemetryManagerSubscriber`.
    public func add(_ subscriber: any TelemetryManagerSubscriber) {
        subscribers[ObjectIdentifier(subscriber)] = subscriber
    }
    
    /// Captures a breadcrumb and appends it to the internal buffer asynchronously.
    ///
    /// - Parameter breadcrumb: A `Breadcrumb` representing a contextual event.
    public func capture(_ breadcrumb: Breadcrumb) {
        buffer.add(breadcrumb)
    }
    
    /// Captures a basic informational event without an exception.
    ///
    /// - Parameters:
    ///   - message: An optional descriptive message.
    ///   - name: A unique event identifier.
    ///   - source: The logical source of the event (e.g., module or component name).
    ///   - metadata: Optional structured metadata.
    public func capture(_ message: String, name: String, source: String, metadata: Metadata = [:]) {
        let event = TelemetryReport.Event(
            name: name,
            severity: .info,
            source: source,
            metadata: metadata
        )
        
        sendEvent(event)
    }
    
    /// Captures an error event with an associated exception and optional stack trace.
    ///
    /// - Parameters:
    ///   - error: The error object to capture.
    ///   - name: A unique event identifier.
    ///   - source: The logical source of the error.
    ///   - metadata: Optional structured metadata.
    ///   - stackFrame: Optional stack frame information.
    public func capture(
        _ error: Error,
        name: String,
        source: String,
        metadata: Metadata = [:],
        stackFrame: StackFrame = StackFrame()
    ) {

        let exception = TelemetryReport.Exception(message: error.localizedDescription, stackFrame: stackFrame)
        let event = TelemetryReport.Event(
            name: name,
            severity: .error,
            source: source,
            metadata: metadata
        )
        
        sendEvent(event, exception: exception)
    }
    
    /// Removes a previously registered subscriber.
    ///
    /// - Parameter subscriber: The subscriber instance to remove.
    public func remove(_ subscriber: any TelemetryManagerSubscriber) {
        let identifier = ObjectIdentifier(subscriber)
        subscribers.removeValue(forKey: identifier)
    }

    // MARK: - Private methods
    
    private func notify(_ report: TelemetryReport) {
        lock.lock()
        defer { lock.unlock() }
        
        for subscriber in subscribers.values {
            subscriber.didReceive(report)
        }
    }
    
    private func sendEvent(_ event: TelemetryReport.Event, exception: TelemetryReport.Exception? = nil) {
        let report = TelemetryReport(
            event: event,
            context: contextProvider.makeContext(),
            breadcrumbs: [.critical, .error].contains(event.severity) ? buffer.snapshot() : nil,
            exception: exception
        )
        
        notify(report)
    }
}

