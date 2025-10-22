//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A type-safe representation of telemetry error event names for camera failures.
///
/// `TelemetryEventName` provides predefined event names for tracking errors and
/// exceptional conditions in the camera module. Each event name represents a specific
/// type of failure or error that requires debugging, monitoring, and alerting.
///
/// ## Usage
///
/// Use the predefined static properties to specify error event names:
///
/// ```swift
/// do {
///     let photo = try await videoDevice.capturePhoto()
/// } catch {
///     telemetryManager.captureError(
///         error,
///         name: .photoCaptureFailed,
///         metadata: ["device": .int(videoDevice.position.rawValue)]
///     )
/// }
/// ```
struct TelemetryEventName: RawRepresentable {
    // MARK: - Properties

    /// The corresponding value of the raw type.
    let rawValue: String

    // MARK: - Static Properties

    /// Event name for audio route change failures.
    ///
    /// Captured when the camera module fails to reconfigure audio after a route change.
    /// Includes error details, route information, and recording state.
    static let audioRouteChangeFailed = TelemetryEventName(rawValue: "audio_route_change_failed")

    /// Event name for camera recovery failures.
    ///
    /// Captured when the camera fails to recover after a system reset.
    /// Includes status code, error details, and recording state.
    static let cameraFailedToRecoverFromReset = TelemetryEventName(rawValue: "camera_failed_to_recover_from_reset")

    /// Event name for camera initialization failures.
    ///
    /// Captured when the camera fails to initialize during startup.
    /// Includes authorization status and error details.
    static let cameraInitializationFailed = TelemetryEventName(rawValue: "camera_initialization_failed")

    /// Event name for camera permission denial.
    ///
    /// Captured when camera permission is denied by the user.
    /// Includes device information and authorization status.
    static let cameraPermissionDenied = TelemetryEventName(rawValue: "camera_permission_denied")

    /// Event name for camera runtime errors.
    ///
    /// Captured when the camera capture session receives a runtime error.
    /// Includes status code, error details, device information, and recording state.
    static let cameraRuntimeError = TelemetryEventName(rawValue: "camera_runtime_error")
    
    /// Event name for torch-related errors occurring during video recording.
    ///
    /// Captured when the camera fails to configure or update the torch (flash) state
    /// while a video recording session is active. This event provides diagnostic context
    /// such as device capabilities, torch availability, and current zoom factor.
    static let cameraTorchErrorDuringRecording = TelemetryEventName(rawValue: "camera_torch_error_during_recording")

    /// Event name for camera switch failures.
    ///
    /// Captured when switching between front and back cameras fails.
    /// Includes previous and new device positions.
    static let cameraSwitchFailed = TelemetryEventName(rawValue: "camera_switch_failed")

    /// Event name for focus change failures.
    ///
    /// Captured when setting camera focus point fails.
    /// Includes device position and attempted focus point.
    static let focusChangeFailed = TelemetryEventName(rawValue: "focus_change_failed")

    /// Event name for microphone permission denial.
    ///
    /// Captured when microphone permission is denied by the user.
    /// Includes device information and authorization status.
    static let microphonePermissionDenied = TelemetryEventName(rawValue: "microphone_permission_denied")

    /// Event name for photo capture failures.
    ///
    /// Captured when photo capture fails for any reason.
    /// Includes device information and error details.
    static let photoCaptureFailed = TelemetryEventName(rawValue: "photo_capture_failed")

    /// Event name for torch not available errors.
    ///
    /// Captured when user attempts to toggle torch but the device doesn't support it.
    /// Includes device information.
    static let torchNotAvailable = TelemetryEventName(rawValue: "torch_not_available")

    /// Event name for video recording failures.
    ///
    /// Captured when video recording fails for any reason.
    /// Includes device information and error details.
    static let videoRecordingFailed = TelemetryEventName(rawValue: "video_recording_failed")
}
