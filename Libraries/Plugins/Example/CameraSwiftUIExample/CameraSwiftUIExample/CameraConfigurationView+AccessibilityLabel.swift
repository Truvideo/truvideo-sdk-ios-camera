//
// Copyright © 2025 TruVideo. All rights reserved.
//

/// Extends `CameraConfigurationView` with additional functionality and supporting types.
///
/// This extension organizes and encapsulates code related to camera configuration behavior,
/// UI identifiers, and helper structures. By grouping related elements in an extension,
/// the core view definition remains focused on layout and logic, while auxiliary details
/// such as accessibility labels, constants, or test identifiers are neatly separated.
extension CameraConfigurationView {
    enum AccessibilityLabel {
        /// Accessibility label for the **Camera SDK** navigation button.
        static let cameraSDK = "Camera SDK"

        /// Accessibility label for the **Configure Camera** button.
        static let configureCamera = "Configure Camera"

        /// Accessibility label for the **capture mode** section.
        static let captureMode = "Capture Mode"

        /// Accessibility label for the **flash off** option.
        static let flashModeOff = "Flash Mode Off"

        /// Accessibility label for the **flash on** option.
        static let flashModeOn = "Flash Mode On"

        /// Accessibility label for selecting the **JPEG** image format.
        static let jpeg = "JPEG"

        /// Accessibility label for the option to select the **rear-facing camera**.
        static let lensFacingBack = "Lens Facing Back"

        /// Accessibility label for the option to select the **front-facing camera**.
        static let lensFacingFront = "Lens Facing Front"

        /// Accessibility label for the **limit** configuration option.
        static let limit = "Limit"

        /// Accessibility label indicating that a capture mode is **limited**.
        static let limited = "Limited"

        /// Accessibility label for the **Open Camera** button.
        static let openCamera = "Open Camera"

        /// Accessibility label for selecting **photo-only** capture mode.
        static let photoOnly = "Photo Only"

        /// Accessibility label for selecting the **PNG** image format.
        static let png = "PNG"

        /// Accessibility label for the **single capture** mode option.
        static let single = "Single"

        /// Accessibility label for selecting **combined photo and video** capture mode.
        static let videoAndPicture = "Video And Picture"

        /// Accessibility label for selecting **video duration** to capture video.
        static let videoDuration = "Video Duration"

        /// Accessibility label for selecting **video-only** capture mode.
        static let videoOnly = "Video Only"
    }
}
