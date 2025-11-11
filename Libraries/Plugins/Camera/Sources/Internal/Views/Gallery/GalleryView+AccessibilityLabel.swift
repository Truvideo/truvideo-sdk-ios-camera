//
// Copyright © 2025 TruVideo. All rights reserved.
//

/// Accessibility identifiers used throughout the `GalleryView`.
///
/// These constants serve two main purposes:
/// - **UI Testing:** Provide stable identifiers for automated tests that remain consistent regardless of localization.
extension GalleryView {
    enum AccessibilityLabel {
        /// Button that closes the current gallery or media viewer and returns to the previous screen.
        static let closeButton = "Close button"

        /// Button that deletes the currently selected or displayed media item.
        static let deleteButton = "Delete button"

        /// Grid or collection view displaying all photo and video thumbnails available in the gallery.
        static let galleryGrid = "Gallery grid"

        /// Main container wrapping the entire gallery interface.
        static let galleryView = "Gallery Container"
    }
}
