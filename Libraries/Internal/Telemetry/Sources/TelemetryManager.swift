//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
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
    
    private var breadcrumbsBuffer: RingBuffer<Breadcrumb>
    private let defaultEventsFlushDuration: TimeInterval = 180
    private var eventsBuffer: EventDiskBuffer
    private let lock = NSLock()
    private var previousFlushDate: Date?
    private var session: Session?
    private let sessionStorage = SessionStorage()
    private var subscribers: [ObjectIdentifier: any TelemetryManagerSubscriber] = [:]
    
    // MARK: - Dependencies
    
    @Dependency(\.contextProvider)
    private var contextProvider: ContextProvider
    
    @Dependency(\.installation)
    private var installation: TelemetryInstallation
    
    // MARK: - Properties
    
    /// A list of telemetry integrations that automatically install when the manager is initialized.
    let integrations: [any TelemetryIntegration]
    
    // MARK: - Static Properties
    
    /// The shared singleton instance of `TelemetryManager` used across the app or SDK.
    public static let shared = TelemetryManager()
    
    // MARK: - Initializer
    
    /// Initializes a new instance of `TelemetryManager` with custom dependencies.
    ///
    /// This initializer allows you to configure the telemetry manager with a custom
    /// breadcrumb buffer, runtime context provider, installation identifier provider,
    /// and any number of telemetry integrations. These components work together to collect,
    /// enrich, and forward telemetry data such as errors, events, and system changes.
    ///
    /// - Parameters:
    ///   - breadcrumbsBuffer: An instance of `RingBuffer` used to collect recent event breadcrumbs that provide context for errors or telemetry events.
    ///   - eventsBuffer: An instane of `EventDiskBuffer` used to collect recent events.
    ///   - integrations: A list of telemetry integrations conforming to `TelemetryIntegration`, responsible for hooking into various system events.
    init(
        breadcrumbsBuffer: RingBuffer<Breadcrumb>,
        eventsBuffer: EventDiskBuffer,
        integrations: [any TelemetryIntegration] = [AutoSessionTrackerIntegration(), SystemEventTrackerIntegration()]
    ) {

        self.breadcrumbsBuffer = breadcrumbsBuffer
        self.eventsBuffer = eventsBuffer
        self.integrations = integrations
        
        integrations.forEach { $0.install(on: self) }
    }

    /// Initializes a default instance using the standard breadcrumb buffer and runtime context provider.
    public convenience init() {
        self.init(breadcrumbsBuffer: RingBuffer(), eventsBuffer: EventDiskBuffer())
    }
    
    // MARK: - Instance methods
    
    /// Finalizes and reports any previously stored session that differs from the currently active session.
    ///
    /// This method checks whether a previously stored session exists in `sessionStorage` and ensures it is
    /// not the same as the currently active `session`. If such a session exists, it marks the session as ended
    /// at the given date, emits a `TelemetryReport.Event` indicating that the session ended, and sends
    /// the completed session report to the telemetry manager.
    ///
    /// This is typically useful for recovery scenarios where the app may have been terminated or suspended
    /// before a session could be properly closed.
    ///
    /// - Parameter date: The date to mark as the session's end time.
    func flushPreviousSession(endedAt date: Date) {
        if var storedSession = sessionStorage.retrieve(), storedSession != session {
            let event = TelemetryReport.Event(
                name: "session_ended",
                severity: .info,
                source: "Telemetry",
                message: "Discarded stale session from previous app run."
            )
            
            storedSession.endSession(at: date)
            eventsBuffer.add(event)
            
            sessionStorage.delete()
            flushSession(storedSession, force: true)
        }
    }
    
    /// Ends the current telemetry session at the specified date.
    ///
    /// This method locks the session state to ensure thread safety. It attempts to retrieve the current session
    /// from storage and update its `endedAt` timestamp. If an in-memory session exists, it also ends and clears it.
    /// Additionally, it sends a `"session_ended"` telemetry event to subscribers and deletes the session from storage.
    ///
    /// - Parameter date: The timestamp at which the session is considered ended.
    func endSession(at date: Date) {
        lock.lock()
        defer { lock.unlock() }
        
        guard var currentSession = session else { return }
        
        currentSession.endSession(at: date)
        
        let event = TelemetryReport.Event(
            name: "session_ended",
            severity: .info,
            source: "Telemetry"
        )
        
        breadcrumbsBuffer.removeAll()
        eventsBuffer.add(event)
        flushSession(currentSession, force: true)

        session = nil
        sessionStorage.delete()
    }
    
    /// Starts a new telemetry session.
    ///
    /// This method initializes a new `Session` with a unique installation identifier
    /// and stores it both in memory and persistent storage. It ensures thread safety and
    /// avoids overwriting an existing active session.
    func startSession() {
        lock.lock()
        defer { lock.unlock() }
        
        if var storedSession = sessionStorage.retrieve(), storedSession != session {
            storedSession.endSession(status: .exited)
            
            flushSession(storedSession, force: true)
            sessionStorage.delete()
        }
        
        guard session == nil else { return }
        
        let newSession = Session(installationId: installation.uniqueIdentifier())
        let event = TelemetryReport.Event(name: "session_started", severity: .info, source: "Telemetry")
        
        sendEvent(event)
        sessionStorage.store(newSession)
        session = newSession
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
    open func capture(_ breadcrumb: Breadcrumb) {
        breadcrumbsBuffer.add(breadcrumb)
    }
    
    /// Captures a basic informational event without an exception.
    ///
    /// - Parameters:
    ///   - name: The name of the event.
    ///   - source: The logical source of the event (e.g., module or component name).
    ///   - metadata: Optional structured metadata.
    open func captureEvent(name: String, source: String, metadata: Metadata = [:]) {
        let event = TelemetryReport.Event(
            name: name,
            severity: .info,
            source: source,
            metadata: metadata
        )
        
        sendEvent(event)
    }
    
    /// Captures a basic informational event without an exception.
    ///
    /// - Parameters:
    ///   - message: An optional descriptive message.
    ///   - name: The name of the event.
    ///   - source: The logical source of the event (e.g., module or component name).
    ///   - metadata: Optional structured metadata.
    open func capture(_ message: String, name: String, source: String, metadata: Metadata = [:]) {
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
    open func capture(
        _ error: Error,
        name: String,
        source: String,
        metadata: Metadata = [:],
        stackFrame: StackFrame = StackFrame()
    ) {
        guard var session else {
            // Logging could be added here to capture the info reason.
            return
        }
                
        let event = TelemetryReport.Event(
            name: name,
            severity: .error,
            source: source,
            breadcrumbs: breadcrumbsBuffer.snapshot(),
            exception: TelemetryReport.Event.Exception(message: error.localizedDescription, stackFrame: stackFrame),
            metadata: metadata
        )
        
        session.incrementErrors()
        sendEvent(event)
    }
    
    /// Removes a previously registered subscriber.
    ///
    /// - Parameter subscriber: The subscriber instance to remove.
    public func remove(_ subscriber: any TelemetryManagerSubscriber) {
        let identifier = ObjectIdentifier(subscriber)
        subscribers.removeValue(forKey: identifier)
    }

    // MARK: - Private methods
    
    private func flushSession(_ session: Session, force: Bool = false) {
        let lastFlushDate = previousFlushDate ?? Date()
        let needsFlush = Date().timeIntervalSince(lastFlushDate) > defaultEventsFlushDuration
        
        if eventsBuffer.isFull || force || needsFlush {
            let report = TelemetryReport(
                events: eventsBuffer.snapshot(),
                context: contextProvider.makeContext(),
                session: session
            )
            
            lock.lock()
            subscribers.values.forEach { $0.didReceive(report) }
            lock.unlock()
            
            eventsBuffer.flush()
            previousFlushDate = Date()
        }
    }
    
    private func sendEvent(_ event: TelemetryReport.Event) {
        eventsBuffer.add(event)
        
        guard let session else { return }
        
        flushSession(session)
    }
}

/// A disk-backed buffer for storing telemetry events using a ring buffer structure.
///
/// The `EventDiskBuffer` maintains a fixed-size in-memory ring buffer to hold recent telemetry events,
/// and persists each event to disk in newline-delimited JSON format. This allows recovery of events
/// after app restarts or crashes.
///
/// Events are written to a file (`events.json`) located in the telemetry directory. Upon initialization,
/// any existing events in that file are loaded back into memory.
///
/// This buffer is useful for scenarios where event loss is undesirable and recovery of telemetry data is needed
/// between sessions or application restarts.
final class EventDiskBuffer {
    // MARK: - Private Properties
        
    private var buffer = RingBuffer<TelemetryReport.Event>(maxCapacity: 100)
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let storageURL: URL
    
    // MARK: - Computed Properties
    
    /// A boolean indicating if the ring is full.
    var isFull: Bool {
        buffer.isFull
    }

    // MARK: - Initializer
    
    /// Creates a new disk-backed telemetry buffer.
    ///
    /// - Parameter storageURL: The root directory for storing events. Defaults to the app's telemetry directory.
    init(storageURL: URL = FileManager.default.telemetryDirectory) {
        self.storageURL = storageURL.appendingPathComponent("events.json")
        
        rehydrate()
    }

    // MARK: - Instance methods

    /// Adds a telemetry event to the in-memory buffer and persists it to disk.
    ///
    /// - Parameter event: The telemetry event to store.
    func add(_ event: TelemetryReport.Event) {
        buffer.add(event)
        
        do {
            let fileHandle = try FileHandle(forWritingTo: storageURL)
            let data = try encoder.encode(event)

            try fileHandle.seekToEnd()
            try fileHandle.write(contentsOf: data)
            
            if let breakLine = "\n".data(using: .utf8) {
                try fileHandle.write(contentsOf: breakLine)
            }
            
            try fileHandle.close()
        } catch {
            // Logging could be added here to capture the failure reason.
        }
    }
    
    /// Clears all telemetry events from memory and removes the backing file from disk.
    func flush() {
        buffer.removeAll()
        
        do {
            try FileManager.default.removeItem(at: storageURL)
        } catch {
            // Logging could be added here to capture the failure reason.
        }
    }
    
    /// Returns a snapshot of the current buffered events, excluding nil entries.
    ///
    /// - Returns: An array containing all stored telemetry events.
    func snapshot() -> [TelemetryReport.Event] {
        buffer.snapshot()
    }
    
    // MARK: - Private methods
    
    private func rehydrate() {
        guard FileManager.default.fileExists(atPath: storageURL.path) else { return }
            
        do {
            let data = try Data(contentsOf: storageURL)
            let lines = data.split(separator: UInt8(ascii: "\n"))
            
            for line in lines {
                do {
                    let event = try decoder.decode(TelemetryReport.Event.self, from: Data(line))

                    buffer.add(event)
                } catch {
                    // Logging could be added here to capture the failure reason.
                }
            }
        } catch {
            // Logging could be added here to capture the failure reason.
        }
    }
}

/// A storage utility responsible for persisting and retrieving telemetry session data.
///
/// `SessionStorage` abstracts the underlying persistence mechanism to manage a `Session` lifecycle.
/// It uses the injected `Storage` dependency to store, retrieve, and delete session data tied to a
/// specific key (`SessionStorageKey`). This helps in restoring session context after app restarts
/// or handling session-related telemetry tracking.
struct SessionStorage {
    // MARK: - Dependencies
    
    @Dependency(\.storage)
    var storage: Storage

    // MARK: - Instance Methods

    /// Deletes the current session from persistent storage.
    ///
    /// This is typically called when a session ends or needs to be reset.
    func delete() {
        do {
            try storage.deleteValue(for: SessionStorageKey.self)
        } catch {
            // Consider logging or surfacing the error for observability.
        }
    }

    /// Retrieves the currently stored telemetry session.
    ///
    /// - Returns: A `Session` instance if found; otherwise, `nil`. This can be used to restore a session between app launches.
    func retrieve() -> Session? {
        do {
            return try storage.readValue(for: SessionStorageKey.self)
        } catch {
            // Consider logging or surfacing the error for observability.
            return nil
        }
    }

    /// Persists the provided session to storage.
    ///
    /// - Parameter session: The telemetry `Session` to persist. This method will override any previously stored session.
    func store(_ session: Session) {
        do {
            try storage.write(session, forKey: SessionStorageKey.self)
        } catch {
            // Consider logging or surfacing the error for observability.
        }
    }
}
