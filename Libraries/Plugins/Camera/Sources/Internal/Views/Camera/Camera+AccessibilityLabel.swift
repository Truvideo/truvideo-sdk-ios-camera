//
// Copyright © 2025 TruVideo. All rights reserved.
//

/// Accessibility identifiers used throughout the `Camera` component.
///
/// These identifiers are intended for:
/// - UI Testing: stable identifiers unaffected by localization.
/// - Accessibility: ensuring screen readers consistently recognize elements.
extension Camera {
    struct AccessibilityLabel {
        /// Close button that dismisses the camera view.
         static let closeButton = "Close Button"
        
        /// Button that allows the user to continue after capturing media.
        static let continueButton = "Continue Button"

        /// Confirmation dialog for exiting the camera view while media exist or recording is active.
        static let exitConfirmationView = "Exit Confirmation View"
        
        /// Button that toggles flash mode (on/off/auto).
        static let flashButton = "Flash Button"
        
        /// Button that shows the number of captured media items and opens the gallery.
        static let mediaCounterView = "Media Counter View"

         /// Permissions view shown when camera/microphone permissions are not granted.
         static let permissionsView = "Permissions View"
        
        /// Button that toggles between play and pause states while recording.
        static let playAndPauseButton = "Play and Pause Button"
        
        /// Button that displays and opens the resolution (preset) selector.
        static let presetButton = "Resolution Button"
        
        /// Dynamic identifier for a given camera preset option (e.g. SD, HD, FHD).
        ///
        /// Example:
        /// ```swift
        /// Camera.AccessibilityLabel.presetOption("SD") // "PresetOption_SD"
        /// ```
        static func presetOption(_ label: String) -> String { "PresetOption_\(label)" }
        
        /// Button that starts and stops video recording.
        static let recordVideo = "Record Video"
        
        /// Button that switches between front and rear cameras.
        static let switchCameraButton = "Switch Camera Button"

         /// Button to take a photo (shutter button).
         static let takePhotoButton = "Take Photo Button"
        
        /// View showing the recording timer.
        static let timerView = "Timer View"

         /// Bottom toolbar containing capture and recording controls.
         static let toolBar = "Tool Bar"
        
        /// Top bar container that holds resolution, flash, close, and counter buttons.
        static let topBar = "Top Bar"

        /// Picker control for adjusting zoom factor.
        static let zoomPicker = "Zoom Picker"
     }
}
