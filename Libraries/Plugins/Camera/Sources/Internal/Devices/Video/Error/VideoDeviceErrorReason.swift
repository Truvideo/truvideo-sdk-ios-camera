//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
internal import Utilities

extension ErrorReason {
    /// A collection of error reasons related to the video device operations.
    ///
    /// The `VideoDeviceErrorReason` struct provides a set of static constants representing various errors that can occur
    /// during interactions with the external devices.
    struct VideoDeviceErrorReason: Sendable {
        /// The capture input could not be added to the session.
        ///
        /// Typical causes:
        /// - The session preset/active device format is incompatible with the input
        /// - `canAddInput(_:)` returned `false` (e.g., too many inputs or unsupported multi‑camera)
        /// - Authorization not granted
        /// - Configuration performed outside `beginConfiguration()/commitConfiguration()`
        static let cannotAddInput = ErrorReason(rawValue: "CANNOT_ADD_VIDEO_INPUT")

        /// The capture output could not be added to the session.
        ///
        /// Typical causes:
        /// - `canAddOutput(_:)` returned `false` due to preset/format incompatibility
        /// - Conflicting outputs (e.g., multi‑camera constraints)
        /// - Output settings (pixel format, stabilization) incompatible with the active format
        static let cannotAddOutput = ErrorReason(rawValue: "CANNOT_ADD_VIDEO_OUTPUT")

        /// No matching video capture device was found.
        ///
        /// Typical causes:
        /// - Requested position/type isn’t available (e.g., telephoto on older devices)
        /// - Running in Simulator (no camera hardware)
        /// - Multi‑camera requested on an unsupported device
        static let captureDeviceNotFound = ErrorReason(rawValue: "CAPTURE_VIDEO_DEVICE_NOT_FOUND")

        /// Error reason indicating that photo capture operation failed.
        ///
        /// This error reason is used when a photo capture operation cannot be completed
        /// successfully. It may be thrown due to various issues such as device
        /// configuration problems, hardware unavailability, or capture settings
        /// incompatibility.
        static let failedToCapturePhoto = ErrorReason(rawValue: "VIDEO_DEVICE_FAILED_TO_CAPTURE_PHOTO")

        /// Error reason indicating that the device requires configuration before use.
        ///
        /// This error reason is used when a device cannot be used because it hasn't been properly
        /// configured or initialized.
        static let needsConfiguration = ErrorReason(rawValue: "DEVICE_NEEDS_CONFIGURATION")

        /// The app is not authorized to use the video device.
        static let notAuthorized = ErrorReason(rawValue: "VIDEO_DEVICE_NOT_AUTHORIZED")

        /// Represents a failure that occurred while attempting to set the camera focus point.
        ///
        /// This error reason indicates that the camera device failed to configure its focus
        /// and exposure settings to the requested point. This can happen due to various
        /// device configuration issues, hardware limitations, or system-level constraints.
        static let setFocusPointFailed = ErrorReason(rawValue: "SET_FOCUS_POINT_FAILED")

        /// Indicates that setting the video device format failed.
        ///
        /// This error reason is thrown when attempting to set a new `AVCaptureDevice.Format`
        /// on the video capture device fails.
        static let setFormatFailed = ErrorReason(rawValue: "SET_FORMAT_FAILED")

        /// Indicates that setting the video device zoom factor failed.
        ///
        /// This error reason is thrown when attempting to set a new zoom factor on the
        /// video capture device fails.
        static let setZoomFactorFailed = ErrorReason(rawValue: "SET_ZOOM_FACTOR_FAILED")

        /// Setting the torch mode failed.
        ///
        /// Typical causes:
        /// - Device does not have a torch or it’s currently unavailable
        /// - Device not locked with `lockForConfiguration()`
        /// - Requested mode not supported under current format/frame rate
        static let torchModeFailed = ErrorReason(rawValue: "TORCH_MODE_FAILED")

        /// The active device does not support a torch.
        ///
        /// Context:
        /// - Most front cameras lack a torch
        /// - Some formats/presets may disable torch availability
        static let torchNotSupported = ErrorReason(rawValue: "TORCH_NOT_SUPPORTED")

        /// The device could not be locked for configuration.
        ///
        /// Typical causes:
        /// - Another client holds the configuration lock
        /// - The device is busy (e.g., starting/stopping session)
        /// - System interruptions (backgrounding, media services reset)
        static let unableToLockDevice = ErrorReason(rawValue: "UNABLE_TO_LOCK_DEVICE_FOR_CONFIGURATION")
    }
}
