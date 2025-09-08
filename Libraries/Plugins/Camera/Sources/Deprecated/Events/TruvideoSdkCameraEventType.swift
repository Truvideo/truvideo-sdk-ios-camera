//
// Created by TruVideo on 14/8/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

/// Defines the different types of events emitted by `TruvideoSdkCamera`.
///
/// `TruvideoSdkCameraEventType` represents specific camera-related actions, such as:
/// - **Flash mode changes**
/// - **Camera flips**
/// - **Media capture events**
/// - **Video recording state changes**
/// - **Zoom and resolution updates**
///
/// ## Example Usage
/// ```swift
/// let event = TruvideoSdkCameraEventType.truvideoSdkCameraEventPictureTaken(media: capturedImage)
/// print("Event: \(event)")
/// ```
public enum TruvideoSdkCameraEventType {
    /// Triggered when the camera flash mode changes.
    ///
    /// This event is fired whenever the **flash setting** is updated.
    ///
    /// - Parameter flashMode: The new flash mode (`.on`, `.off`).
    case truvideoSdkCameraEventFlashModeChanged(flashMode: TruvideoSdkCameraFlashMode)

    /// Triggered when the camera is flipped between **front-facing** and **rear-facing**.
    ///
    /// - Parameter lensFacing: The new lens direction (`.front`, `.back`).
    case truvideoSdkCameraEventCameraFlipped(lensFacing: TruvideoSdkCameraLensFacing)

    /// Triggered when media capture is successfully completed.
    ///
    /// This event fires when the camera session **continues** and media is recorded.
    ///
    /// - Parameter media: The list of captured media.
    case truvideoSdkCameraEventMediaContinue(media: [TruvideoSdkCameraMedia])

    /// Triggered when a media file is **deleted**.
    ///
    /// - Parameter media: The deleted media object.
    case truvideoSdkCameraEventMediaDeleted(media: TruvideoSdkCameraMedia)

    /// Triggered when media is **discarded** after closing the camera.
    ///
    /// - Parameter media: The list of discarded media.
    case truvideoSdkCameraEventMediaDiscard(media: [TruvideoSdkCameraMedia])

    /// Triggered when a **photo is captured**.
    ///
    /// - Parameter media: The captured image.
    case truvideoSdkCameraEventPictureTaken(media: TruvideoSdkCameraMedia)

    /// Triggered when **video recording is completed**.
    ///
    /// - Parameter media: The recorded video.
    case truvideoSdkCameraEventRecordingFinished(media: TruvideoSdkCameraMedia)

    /// Triggered when **video recording is paused**.
    ///
    /// - Parameters:
    ///   - resolution: The current recording resolution.
    ///   - orientation: The current camera orientation.
    ///   - lensFacing: The current lens direction.
    case truvideoSdkCameraEventRecordingPaused(
        resolution: TruvideoSdkCameraResolution,
        orientation: TruvideoSdkCameraOrientation,
        lensFacing: TruvideoSdkCameraLensFacing
    )

    /// Triggered when **video recording is resumed** after being paused.
    ///
    /// - Parameters:
    ///   - resolution: The current recording resolution.
    ///   - orientation: The current camera orientation.
    ///   - lensFacing: The current lens direction.
    case truvideoSdkCameraEventRecordingResumed(
        resolution: TruvideoSdkCameraResolution,
        orientation: TruvideoSdkCameraOrientation,
        lensFacing: TruvideoSdkCameraLensFacing
    )

    /// Triggered when **video recording starts**.
    ///
    /// - Parameters:
    ///   - resolution: The resolution at the start of recording.
    ///   - orientation: The camera orientation.
    ///   - lensFacing: The active camera lens.
    case truvideoSdkCameraEventRecordingStarted(
        resolution: TruvideoSdkCameraResolution,
        orientation: TruvideoSdkCameraOrientation,
        lensFacing: TruvideoSdkCameraLensFacing
    )

    /// Triggered when the **camera resolution is changed**.
    ///
    /// - Parameter resolution: The new resolution applied to the camera.
    case truvideoSdkCameraEventResolutionChanged(resolution: TruvideoSdkCameraResolution)

    /// Triggered when the **camera zoom level changes**.
    ///
    /// - Parameter zoom: The new zoom level.
    case truvideoSdkCameraEventZoomChanged(zoom: Float)
}
