//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A type-safe representation of telemetry breadcrumb categories for camera events.
///
/// `TelemetryCategory` provides predefined categories for organizing and filtering
/// telemetry breadcrumbs in the camera module. Each category groups related events
/// to enable better observability, debugging, and analytics.
///
/// ## Usage
///
/// Use the predefined static properties to specify breadcrumb categories:
///
/// ```swift
/// telemetryManager.addBreadcrumb(
///     category: .photoCapture,
///     message: "Photo captured successfully",
///     level: .info,
///     data: ["device": "back_camera", "resolution": "1080p"]
/// )
/// ```
struct TelemetryCategory: RawRepresentable {
    // MARK: - Properties

    /// The corresponding value of the raw type.
    let rawValue: String

    // MARK: - Static Properties

    /// Category for authorization and permission events.
    ///
    /// Used for tracking camera and microphone permissions including:
    /// - Authorization requested
    /// - Authorization granted
    /// - Camera/microphone permission denied
    static let authorization = TelemetryCategory(rawValue: "authorization")

    /// Category for camera lifecycle events.
    ///
    /// Used for tracking camera operation lifecycle including:
    /// - Camera operation completed
    /// - Camera dismissed with unsaved media
    static let cameraLifecycle = TelemetryCategory(rawValue: "camera_lifecycle")

    /// Category for camera system notification events.
    ///
    /// Used for tracking system-level camera events including:
    /// - Camera services were reset
    /// - Camera recovering from reset
    /// - Audio route changes
    /// - Camera runtime errors
    /// - Camera session interruptions
    static let cameraSystem = TelemetryCategory(rawValue: "camera_system")

    /// Category for camera UI interaction events.
    ///
    /// Used for tracking user interactions with camera controls including:
    /// - Camera switched (front/back)
    /// - Torch toggled
    /// - Zoom changed
    /// - Focus changed
    static let cameraUI = TelemetryCategory(rawValue: "camera_ui")

    /// Category for photo capture events.
    ///
    /// Used for tracking photo capture lifecycle including:
    /// - Photo capture started
    /// - Photo captured successfully
    /// - Photo capture failed
    static let photoCapture = TelemetryCategory(rawValue: "photo_capture")

    /// Category for video recording events.
    ///
    /// Used for tracking video recording lifecycle including:
    /// - Video recording started/paused/resumed/stopped
    /// - Video recording failed
    /// - Maximum recording duration reached
    static let videoRecording = TelemetryCategory(rawValue: "video_recording")
}
