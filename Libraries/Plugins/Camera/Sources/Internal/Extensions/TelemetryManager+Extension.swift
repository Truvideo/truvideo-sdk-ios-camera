//
// Copyright © 2025 TruVideo. All rights reserved.
//

internal import Telemetry
internal import Utilities

extension TelemetryManager {
    /// Captures a telemetry breadcrumb for camera module events.
    ///
    /// This method creates and captures a breadcrumb with camera-specific context,
    /// automatically setting the source to "TruvideoCameraSdk" and the base category
    /// to "Camera". Breadcrumbs are used for tracking user actions, state changes,
    /// and system events to enable better debugging and analytics.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Capture a photo event
    /// telemetryManager.captureBreadcrumb(
    ///     severity: .info,
    ///     category: .photoCapture,
    ///     message: "Photo captured successfully",
    ///     metadata: ["device": "back_camera", "resolution": "1080p"]
    /// )
    ///
    /// // Capture an error
    /// telemetryManager.captureBreadcrumb(
    ///     severity: .error,
    ///     category: .videoRecording,
    ///     message: "Video recording failed",
    ///     metadata: ["error": "Disk full"]
    /// )
    ///
    /// // Capture without message
    /// telemetryManager.captureBreadcrumb(
    ///     severity: .info,
    ///     category: .cameraUI,
    ///     metadata: ["action": "torch_toggled", "enabled": true]
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - severity: The severity level of the breadcrumb (info, warning, or error)
    ///   - category: The category for grouping related breadcrumbs (e.g., `.photoCapture`)
    ///   - message: An optional human-readable message describing the event
    ///   - metadata: Optional additional context data as key-value pairs
    ///
    /// - SeeAlso: `TelemetryCategory` for available category constants
    func captureBreadcrumb(
        severity: Severity,
        category: TelemetryCategory,
        message: String? = nil,
        metadata: Metadata? = nil
    ) {
        let breadcrumb = Breadcrumb(
            severity: severity,
            source: "TruvideoCameraSdk",
            category: category.rawValue,
            message: message,
            metadata: metadata
        )

        capture(breadcrumb)
    }

    /// Captures a telemetry breadcrumb with a required message.
    ///
    /// This is a convenience method that captures a breadcrumb with the message
    /// parameter as the first argument. It provides an alternative syntax for cases
    /// where the message is the most important context, delegating to the main
    /// `captureBreadcrumb` method.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// telemetryManager.captureBreadcrumb(
    ///     "Photo capture started",
    ///     severity: .info,
    ///     category: .photoCapture,
    ///     metadata: ["device": "back_camera"]
    /// )
    ///
    /// telemetryManager.captureBreadcrumb(
    ///     "Camera switched",
    ///     severity: .info,
    ///     category: .cameraUI,
    ///     metadata: ["previousDevice": "front", "newDevice": "back"]
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - message: A human-readable message describing the event
    ///   - severity: The severity level of the breadcrumb (info, warning, or error)
    ///   - category: The category for grouping related breadcrumbs
    ///   - metadata: Optional additional context data as key-value pairs
    func captureBreadcrumb(_ message: String, severity: Severity, category: TelemetryCategory, metadata: Metadata?) {
        captureBreadcrumb(severity: severity, category: category, message: message, metadata: metadata)
    }

    /// Captures a telemetry error event for camera module failures.
    ///
    /// This method creates and captures an error event with camera-specific context,
    /// automatically setting the source to "TruvideoCameraSdk". Error events are used
    /// for tracking exceptional conditions, failures, and system errors that require
    /// debugging and monitoring.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// do {
    ///     let photo = try await videoDevice.capturePhoto()
    /// } catch {
    ///     telemetryManager.captureError(
    ///         error,
    ///         name: .photoCaptureFailed,
    ///         metadata: [
    ///             "device": .int(videoDevice.position.rawValue)
    ///         ]
    ///     )
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - error: The error that occurred
    ///   - name: The event name for categorizing the error (e.g., `.photoCaptureFailed`)
    ///   - metadata: Optional additional context data as key-value pairs
    ///   - stackFrame: The stack frame where the error was captured (automatically provided)
    ///
    /// - SeeAlso: `TelemetryEventName` for available event name constants
    func captureError(
        _ error: Error,
        name: TelemetryEventName,
        metadata: Metadata? = nil,
        stackFrame: StackFrame = StackFrame()
    ) {
        capture(error, name: name.rawValue, source: "TruvideoCameraSdk", metadata: metadata, stackFrame: stackFrame)
    }
}
