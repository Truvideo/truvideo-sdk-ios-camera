//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
internal import Utilities

extension ErrorReason {
    /// A collection of error reasons related to the audio device operations.
    ///
    /// The `AudioDeviceErrorReason` struct provides a set of static constants representing various errors that can occur
    /// during interactions with the external devices.
    struct AudioDeviceErrorReason: Sendable {
        /// The capture input could not be added to the session.
        ///
        /// Typical causes:
        /// - The session preset/active format is incompatible with the input
        /// - `canAddInput(_:)` returned `false` (e.g., too many inputs)
        /// - Microphone permission not granted
        /// - Changes applied outside `beginConfiguration()/commitConfiguration()`
        static let cannotAddInput = ErrorReason(rawValue: "CANNOT_ADD_AUDIO_INPUT")

        /// The capture output could not be added to the session.
        ///
        /// Typical causes:
        /// - `canAddOutput(_:)` returned `false` for the current preset/format
        /// - Conflicting outputs or unsupported configuration
        /// - Output settings incompatible with the active device/format
        static let cannotAddOutput = ErrorReason(rawValue: "CANNOT_ADD_AUDIO_OUTPUT")

        /// No matching audio capture device was found.
        ///
        /// Typical causes:
        /// - No available microphone (hardware or permission constraints)
        /// - Running in an environment without audio input
        /// - Device temporarily unavailable or in use by another session
        static let captureDeviceNotFound = ErrorReason(rawValue: "CAPTURE_AUDIO_DEVICE_NOT_FOUND")

        /// Error reason indicating that the device requires configuration before use.
        ///
        /// This error reason is used when a device cannot be used because it hasn't been properly
        /// configured or initialized.
        static let needsConfiguration = ErrorReason(rawValue: "DEVICE_NEEDS_CONFIGURATION")

        /// The app is not authorized to use the microphone.
        ///
        /// Meaning:
        /// - Authorization status is `.denied` or `.restricted`
        static let notAuthorized = ErrorReason(rawValue: "AUDIO_DEVICE_NOT_AUTHORIZED")
    }
}
