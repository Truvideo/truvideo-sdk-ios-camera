//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

extension TruvideoSdkCameraConfiguration {
    /// Creates a new camera configuration with all parameters specified.
    ///
    /// This factory method provides a comprehensive way to instantiate a camera
    /// configuration with all available settings. It allows fine-grained control
    /// over camera behavior including lens selection, resolution options, flash
    /// settings, image format, capture mode, and output path.
    ///
    /// The method accepts both resolution arrays (for available options) and
    /// specific resolution selections (for current settings). This provides
    /// flexibility in how the camera handles resolution selection and fallbacks.
    ///
    /// - Warning: This method is deprecated. Use the initializer `TruvideoSdkCameraConfiguration(...)` instead.
    ///
    /// - Parameters:
    ///   - lensFacing: The camera lens to use (front or back)
    ///   - backResolution: The specific resolution selected for the back camera (nil = auto-select)
    ///   - backResolutions: Available resolution options for the back camera
    ///   - flashMode: The flash mode setting for the camera
    ///   - frontResolution: The specific resolution selected for the front camera (nil = auto-select)
    ///   - frontResolutions: Available resolution options for the front camera
    ///   - imageFormat: The image format for captured photos (default: JPEG)
    ///   - mode: The media capture mode and limits
    ///   - outputPath: The directory path where captured media will be saved
    /// - Returns: A fully configured camera configuration instance
    @available(*, deprecated, message: "Use TruvideoSdkCameraConfiguration(...) initializer instead")
    public static func instantiate(
        with lensFacing: TruvideoSdkCameraLensFacing,
        imageFormat: TruvideoSdkCameraImageFormat = .jpeg,
        mode: TruvideoSdkCameraMediaMode,
        outputPath: String
    ) -> TruvideoSdkCameraConfiguration {
        TruvideoSdkCameraConfiguration(
            imageFormat: imageFormat,
            lensFacing: lensFacing,
            mode: mode,
            outputPath: outputPath
        )
    }
}
