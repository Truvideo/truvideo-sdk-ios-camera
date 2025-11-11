//
// Copyright © 2025 TruVideo. All rights reserved.
//

/// Accessibility identifiers used throughout the `CameraView`.
///
/// These constants are primarily intended for:
/// - UI Testing: stable identifiers that do not change with localization.
/// - Accessibility: ensuring screen readers can consistently recognize and describe elements.
extension CameraView {
    enum AccessibilityLabel {
        /// Main container wrapping the camera preview and overlays.
        static let camera = "Camera Container"

        /// Identifier for the iPad-specific camera layout.
        static let cameraIpad = "Camera Ipad View"

        /// A view displaying error messages related to camera operations.
        static let errorMessage = "Error Message View"
    }
}
