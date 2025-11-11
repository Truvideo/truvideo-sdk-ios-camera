//
// Copyright © 2025 TruVideo. All rights reserved.
//

import XCTest

@testable import CameraSwiftUIExample
@testable import TruvideoSdkCamera

/// A UI abstraction layer for interacting with the camera view in UITests.
///
/// The `CameraScreen` struct encapsulates all UI elements and accessibility
/// identifiers used in the camera interface, providing a clean and readable
/// API for test cases. This approach follows the *Page Object Pattern*,
/// improving test maintainability and reducing code duplication.
///
/// Example usage:
///
/// ```swift
/// let screen = CameraScreen(app: app)
/// XCTAssertTrue(screen.takePhoto.waitForExistence(timeout: 3))
/// screen.takePhoto.tap()
/// XCTAssertTrue(screen.mediaCount.exists)
/// ```
struct CameraScreen {
    // MARK: - Properties

    /// The XCUIApplication instance under test.
    let app: XCUIApplication

    // MARK: - Camera Configuration

    /// The navigation bar button to return to the Camera SDK main screen.
    var cameraSDK: XCUIElement { app.navigationBars.buttons[CameraConfigurationView.AccessibilityLabel.cameraSDK] }

    /// The button representing the **Capture Mode** configuration section.
    var captureMode: XCUIElement { app.buttons[CameraConfigurationView.AccessibilityLabel.captureMode] }

    /// The button that opens the camera configuration options.
    var configureCamera: XCUIElement { app.buttons[CameraConfigurationView.AccessibilityLabel.configureCamera] }

    /// The video duration text field element within the camera configuration view.
    var durationVideo: XCUIElement { app.textFields[CameraConfigurationView.AccessibilityLabel.videoDuration] }

    /// The button representing the **Flash On** option.
    var flashModeOn: XCUIElement { app.buttons[CameraConfigurationView.AccessibilityLabel.flashModeOn] }

    /// The button representing the **Flash Off** option.
    var flashModeOff: XCUIElement { app.buttons[CameraConfigurationView.AccessibilityLabel.flashModeOff] }

    /// The button to switch to the **rear-facing** camera.
    var lensFacingBack: XCUIElement { app.buttons[CameraConfigurationView.AccessibilityLabel.lensFacingBack] }

    /// The button to switch to the **front-facing** camera.
    var lensFacingFront: XCUIElement { app.buttons[CameraConfigurationView.AccessibilityLabel.lensFacingFront] }

    /// The button to open or adjust the **Limit** configuration options.
    var limit: XCUIElement { app.buttons[CameraConfigurationView.AccessibilityLabel.limit] }

    /// The button to select a **limited** capture mode option.
    var limited: XCUIElement { app.buttons[CameraConfigurationView.AccessibilityLabel.limited] }

    /// The button that opens the camera view from the configuration screen.
    var openCamera: XCUIElement { app.buttons[CameraConfigurationView.AccessibilityLabel.openCamera] }

    /// The button to enable **Photo Only** mode.
    var photoOnly: XCUIElement { app.buttons[CameraConfigurationView.AccessibilityLabel.photoOnly] }

    /// The button to enable **Single** capture mode.
    var single: XCUIElement { app.buttons[CameraConfigurationView.AccessibilityLabel.single] }

    /// The button to enable **Video Only** mode.
    var videoOnly: XCUIElement { app.buttons[CameraConfigurationView.AccessibilityLabel.videoOnly] }

    // MARK: - Camera Elements (iPhone)

    /// The main container wrapping the camera preview and overlays.
    var camera: XCUIElement { app.otherElements[CameraView.AccessibilityLabel.camera] }

    /// The error message view displayed when an operation fails.
    var errorMessage: XCUIElement { app.otherElements[CameraView.AccessibilityLabel.errorMessage] }

    /// The flash toggle button, displaying the current flash mode.
    var flash: XCUIElement { topBar.buttons[Camera.AccessibilityLabel.flashButton] }

    /// The bottom toolbar containing main capture controls.
    var toolBar: XCUIElement { camera.otherElements[Camera.AccessibilityLabel.toolBar] }

    /// The top toolbar containing secondary information and actions.
    var topBar: XCUIElement { camera.otherElements[Camera.AccessibilityLabel.topBar] }

    // MARK: - Capture Controls

    /// The counter displaying the current number of captured media items.
    var mediaCount: XCUIElement { topBar.buttons[Camera.AccessibilityLabel.mediaCounterView] }

    /// The control used to start or stop video recording.
    var recordVideo: XCUIElement { toolBar.otherElements[Camera.AccessibilityLabel.recordVideo] }

    /// The remaining time label element for the standard (iPhone) camera interface.
    var remainingTime: XCUIElement { camera.staticTexts[Camera.AccessibilityLabel.remainingTime] }

    /// The button used to take a photo.
    var takePhoto: XCUIElement { toolBar.buttons[Camera.AccessibilityLabel.takePhotoButton] }

    /// The timer text element shown during video recording.
    var timer: XCUIElement { camera.staticTexts[Camera.AccessibilityLabel.timerView] }

    // MARK: - Camera Options

    /// The “FHD” (Full HD) resolution option within the preset selection menu.
    var fhdOption: XCUIElement { app.buttons[Camera.AccessibilityLabel.presetOption("FHD")] }

    /// The “HD” resolution option within the preset selection menu.
    var hdOption: XCUIElement { app.buttons[Camera.AccessibilityLabel.presetOption("HD")] }

    /// The play/pause button for video playback or preview modes.
    var playAndPause: XCUIElement { toolBar.buttons[Camera.AccessibilityLabel.playAndPauseButton] }

    /// The button used to change video resolution presets.
    var resolution: XCUIElement { topBar.buttons[Camera.AccessibilityLabel.presetButton] }

    /// The “SD” (Standard Definition) resolution option within the preset selection menu.
    var sdOption: XCUIElement { app.buttons[Camera.AccessibilityLabel.presetOption("SD")] }

    /// The button used to switch between front and rear camera lenses.
    var switchCamera: XCUIElement { toolBar.buttons[Camera.AccessibilityLabel.switchCameraButton] }

    // MARK: - Gallery Elements

    /// The button used to close the gallery view.
    var closeButton: XCUIElement { app.buttons[GalleryView.AccessibilityLabel.closeButton] }

    /// The button used to delete selected media from the gallery.
    var deleteButton: XCUIElement { app.buttons[GalleryView.AccessibilityLabel.deleteButton] }

    /// The first photo element in the gallery grid.
    var firstPhoto: XCUIElement { galleryGrid.images.element(boundBy: 0) }

    /// The first video cell in the gallery grid.
    var firstVideo: XCUIElement { galleryGrid.cells.element(boundBy: 0) }

    /// The grid displaying media thumbnails inside the gallery.
    var galleryGrid: XCUIElement { app.otherElements[GalleryView.AccessibilityLabel.galleryGrid] }

    /// The container view representing the media gallery.
    var galleryView: XCUIElement { app.otherElements[GalleryView.AccessibilityLabel.galleryView] }

    /// The second photo element in the gallery grid.
    var secondPhoto: XCUIElement { galleryGrid.images.element(boundBy: 1) }

    // MARK: - Zoom Picker

    /// Returns a specific zoom picker element by index, ensuring its existence before use.
    func zoomPickerValues() -> [XCUIElement] {
        app.staticTexts.matching(identifier: "Zoom Picker")
            .allElementsBoundByIndex
            .filter { $0.label.range(of: #"^\d+$"#, options: .regularExpression) != nil }
    }

    // MARK: - Camera (iPad)

    /// The main container element for the camera view on iPad.
    var cameraIpad: XCUIElement { app.otherElements[CameraView.AccessibilityLabel.cameraIpad] }

    /// The bottom toolbar that contains.
    var toolBarIpad: XCUIElement { cameraIpad.otherElements[CameraIpad.AccessibilityLabel.toolBar] }

    /// The button used to capture a photo.
    var takePhotoIpad: XCUIElement { toolBarIpad.buttons[CameraIpad.AccessibilityLabel.takePhotoButton] }

    /// The play/pause button for video playback or preview.
    var playAndPauseIpad: XCUIElement { toolBarIpad.buttons[CameraIpad.AccessibilityLabel.playAndPauseButton] }

    /// The flash mode toggle button inside the toolbar.
    var flashIpad: XCUIElement { toolBarIpad.buttons[CameraIpad.AccessibilityLabel.flashButton] }

    /// The button used to select a video resolution.
    var resolutionIpad: XCUIElement { toolBarIpad.buttons[CameraIpad.AccessibilityLabel.presetButton] }

    /// The button used to close the camera screen.
    var closeButtonIpad: XCUIElement { app.otherElements[CameraIpad.AccessibilityLabel.closeButton] }

    /// The counter showing how many media items have been captured.
    var mediaCountIpad: XCUIElement { closeButtonIpad.buttons[CameraIpad.AccessibilityLabel.mediaCounterView] }

    /// The button used to switch between the front and rear camera.
    var switchCameraIpad: XCUIElement { toolBarIpad.buttons[CameraIpad.AccessibilityLabel.switchCamera] }

    /// The control used to start or stop video recording.
    var recordVideoIpad: XCUIElement { toolBarIpad.otherElements[CameraIpad.AccessibilityLabel.recordButton] }

    /// The remaining time label element for the iPad camera interface.
    var remainingTimeIpad: XCUIElement { cameraIpad.staticTexts[CameraIpad.AccessibilityLabel.remainingTime] }

    /// The timer label that appears on screen during video recording.
    var timerIpad: XCUIElement { cameraIpad.staticTexts[CameraIpad.AccessibilityLabel.timerView] }

    // MARK: - Unified Buttons

    var cameraMainContainer: XCUIElement { UIDevice.isPad ? cameraIpad : camera }

    /// Returns the flash button depending on the current device.
    var flashButton: XCUIElement { UIDevice.isPad ? flashIpad : flash }

    /// The counter displaying the number of captured media items.
    var mediaCountButton: XCUIElement { UIDevice.isPad ? mediaCountIpad : mediaCount }

    /// The play/pause button used during video playback or preview.
    var playAndPauseButton: XCUIElement { UIDevice.isPad ? playAndPauseIpad : playAndPause }

    /// The button used to start or stop video recording.
    var recordVideoButton: XCUIElement { UIDevice.isPad ? recordVideoIpad : recordVideo }

    /// The button used to open the video resolution selector.
    var resolutionButton: XCUIElement { UIDevice.isPad ? resolutionIpad : resolution }

    /// The button used to switch between front and rear cameras.
    var switchCameraButton: XCUIElement { UIDevice.isPad ? switchCameraIpad : switchCamera }

    /// The button used to capture a photo.
    var takePhotoButton: XCUIElement { UIDevice.isPad ? takePhotoIpad : takePhoto }

    /// The timer label displayed during video recording.
    var timerText: XCUIElement { UIDevice.isPad ? timerIpad : timer }

    /// The UI element displaying the remaining recording time on the camera screen.
    var remainingTimeText: XCUIElement { UIDevice.isPad ? remainingTimeIpad : remainingTime }

    /// A shared reference to the top toolbar depending on the device.
    var topBarButton: XCUIElement { UIDevice.isPad ? toolBarIpad : topBar }
}

extension UIDevice {
    static var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
}
