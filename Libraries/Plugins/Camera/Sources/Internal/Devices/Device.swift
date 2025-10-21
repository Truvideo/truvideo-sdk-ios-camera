//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit
internal import Utilities

/// The title metadata value for TruVideo media files.
///
/// This constant defines the title that will be embedded in media file metadata
/// to identify the content as originating from the TruVideo platform.
/// It is used when creating media files to ensure proper attribution
/// and identification in media players and file systems.
let truVideoMetadataTitle = "TruVideo"

/// The artist metadata value for TruVideo media files.
///
/// This constant defines the artist/creator metadata that points to the
/// TruVideo platform URL. It serves as a reference to the source
/// platform and provides users with a way to identify the origin
/// of the media content.
let truVideoMetadataArtist = "https://truvideo.com/"

/// A global actor that serializes access to capture-device operations.
///
/// Use this actor to ensure all capture session and device mutations occur on a single,
/// well-defined executor, preventing data races and reducing configuration hazards.
/// Conforming device types may isolate their APIs to `DeviceActor` to guarantee consistency.
@globalActor
actor DeviceActor {
    /// The shared global actor instance used to isolate device operations.
    static let shared = DeviceActor()
}

/// Represents the lifecycle state of a capture/recording component.
///
/// The state machine models a simple flow from initialization to running,
/// and then to either a finished or failed condition.
enum RecordingState: Sendable {
    /// The component encountered an error.
    case failed

    /// The component completed successfully and is no longer active.
    case finished

    /// The component has been created and configured but not started.
    ///
    /// From this state you can move to `running` to begin work, or to `failed`
    /// if setup detects an unrecoverable issue.
    case initialized

    /// The component is temporarily suspended but remains configured in the session.
    ///
    /// From this state you can resume to `running` or transition to `finished`
    /// if the component is no longer needed. The device remains connected
    /// to the session during this state.
    case paused

    /// The component is actively capturing or processing.
    case running

    // MARK: - Instance methods

    /// Indicates whether a transition from the current state to a new state is permitted.
    /// Any other transition is rejected to protect lifecycle invariants.
    ///
    /// - Parameter newState: The target state to evaluate.
    /// - Returns: `true` if the transition is allowed; otherwise, `false`.
    func canTransition(to newState: RecordingState) -> Bool {
        switch (self, newState) {
        case (.initialized, .failed),
             (.initialized, .finished),
             (.initialized, .running),
             (.failed, .running),
             (.failed, .initialized),
             (.finished, .running),
             (.paused, .finished),
             (.paused, .initialized),
             (.paused, .running),
             (.running, .failed),
             (.running, .finished),
             (.running, .paused):
            true

        default:
            false
        }
    }
}

/// A sendable abstraction for a capture device that can attach to and detach from a session.
///
/// Conforming types manage their own inputs/outputs and any device-specific configuration.
/// Implementations are typically isolated to `DeviceActor` to serialize access to the
/// underlying `AVCaptureSession` and `AVCaptureDevice`.
@DeviceActor
protocol Device: AnyObject, Sendable {
    /// Configures the device for use with the specified capture session.
    ///
    /// This function sets up the device with the necessary configuration to work with the given
    /// AVCaptureSession. It handles device initialization, format selection, and session integration
    /// to ensure the device is ready for capture operations.
    ///
    /// - Parameter session: The AVCaptureSession to configure the device with.
    /// - Throws: UtilityError if the device configuration fails or cannot be completed.
    func configure(in session: AVCaptureSession) throws(UtilityError)

    /// Stops capture for this device and removes any installed inputs/outputs from the session.
    ///
    /// Implementations should safely detach inputs/outputs and perform any necessary cleanup.
    /// Prefer calling this while the session is inside a configuration block.
    ///
    /// - Parameter session: The `AVCaptureSession` from which to remove this device’s input/output.
    func endCapturing(in session: AVCaptureSession)

    /// Pauses capture for this device without removing it from the session.
    ///
    /// Implementations should temporarily stop processing or capturing data while maintaining
    /// the device's connection to the session. This allows for quick resumption of capture
    /// without the overhead of reconfiguring inputs/outputs.
    func pause()

    /// Configures and starts capture for this device on the given session.
    ///
    /// Implementations typically validate authorization, resolve an `AVCaptureDevice`,
    /// install an `AVCaptureDeviceInput` and any required outputs, and update connection
    /// settings as needed. Prefer calling this while the session is inside a configuration block.
    ///
    /// - Parameter session: The `AVCaptureSession` to which inputs/outputs will be added.
    /// - Throws: An error if authorization is missing, if no suitable device is found, or if inputs/outputs cannot be
    /// added to the session due to incompatibility.
    func startCapturing() throws(UtilityError)
}
