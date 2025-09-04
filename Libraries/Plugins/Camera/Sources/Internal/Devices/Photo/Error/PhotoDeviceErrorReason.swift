//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
internal import Utilities

extension ErrorReason {
    /// A collection of error reasons related to the photo device operations.
    ///
    /// The `PhotoDeviceErrorReason` struct provides a set of static constants representing various errors that can occur
    /// during interactions with the external devices.
    struct PhotoDeviceErrorReason: Sendable {
        /// The capture output could not be added to the session.
        ///
        /// Typical causes:
        /// - `canAddOutput(_:)` returned `false` for the current preset/format
        /// - Conflicting outputs or unsupported configuration
        /// - Output settings incompatible with the active device/format
        static let cannotAddOutput = ErrorReason(rawValue: "CANNOT_ADD_PHOTO_OUTPUT")

        /// Error reason indicating that photo capture operation failed.
        ///
        /// This error reason is used when a photo capture operation cannot be completed
        /// successfully. It may be thrown due to various issues such as device
        /// configuration problems, hardware unavailability, or capture settings
        /// incompatibility.
        static let failedToCapturePhoto = ErrorReason(rawValue: "FAILED_TO_CAPTURE_PHOTO")

        /// Error reason indicating that the device requires configuration before use.
        ///
        /// This error reason is used when a device cannot be used because it hasn't been properly
        /// configured or initialized.
        static let needsConfiguration = ErrorReason(rawValue: "PHOTO_DEVICE_NEEDS_CONFIGURATION")

        /// The app is not authorized to use the camera.
        ///
        /// Meaning:
        /// - Authorization status is `.denied` or `.restricted`
        static let notAuthorized = ErrorReason(rawValue: "PHOTO_DEVICE_NOT_AUTHORIZED")
    }
}
