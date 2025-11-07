//
// Copyright © 2025 TruVideo. All rights reserved.
//

/// Accessibility identifiers used throughout the `CameraView`.
///
/// These constants are primarily intended for:
/// - UI Testing: stable identifiers that do not change with localization.
/// - Accessibility: ensuring screen readers can consistently recognize and describe elements.
extension CameraView {
    struct AccessibilityLabel {
        /// Main container wrapping the camera preview and overlays.
        static let camera = "Camera Container"
        
        /// Error
        static let errorMessage = "Error Message View"
     }
}
