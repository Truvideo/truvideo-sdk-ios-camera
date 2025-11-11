//
// Copyright © 2025 TruVideo. All rights reserved.
//

/// A collection of accessibility identifiers used within the `CameraIpad` component.
///
/// These identifiers serve two primary purposes:
/// - **UI Testing**: Provide stable, non-localized identifiers for reliable element lookup.
/// - **Accessibility**: Ensure screen readers and assistive technologies can properly reference UI elements.
extension CameraIpad {
    enum AccessibilityLabel {
        /// Identifier for the button that closes the camera view.
        static let closeButton = "Close Button"

        /// Identifier for the flash mode toggle button.
        static let flashButton = "Flash Button"

        /// Identifier for the view displaying the number of captured media items.
        static let mediaCounterView = "Media Counter View"

        /// Identifier for the play/pause toggle button in playback mode.
        static let playAndPauseButton = "Play And Pause Button"

        /// Identifier for the button that resolution.
        static let presetButton = "Resolution Button"

        /// Identifier for the main recording button (video capture).
        static let recordButton = "Record Button"

        /// Accessibility identifier for the label that displays the remaining recording time.
        static let remainingTime = "Remaining Time"

        /// Identifier for the button that switches between front and rear cameras.
        static let switchCamera = "Switch Camera"

        /// Identifier for the shutter button used to take a photo.
        static let takePhotoButton = "Take a photo"

        /// Identifier for the countdown timer display.
        static let timerView = "Timer View"

        /// Identifier for the main toolbar containing camera actions.
        static let toolBar = "Tool Bar"

        /// Identifier for the zoom level selector displayed on iPad layouts.
        static let zoomPicker = "Zoom Picker Ipad"
    }
}
