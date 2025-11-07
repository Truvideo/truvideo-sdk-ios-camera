//
// Copyright © 2025 TruVideo. All rights reserved.
//

import XCTest

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
    
    // MARK: - Camera Elements
    
    /// The main container wrapping the camera preview and overlays.
    var camera: XCUIElement { app.otherElements[(CameraView.AccessibilityLabel.camera)] }
    
    /// The error message view displayed when an operation fails.
    var errorMessage: XCUIElement { app.otherElements[CameraView.AccessibilityLabel.errorMessage] }

    /// The flash toggle button, displaying the current flash mode.
    var flash: XCUIElement { topBar.buttons[Camera.AccessibilityLabel.flashButton] }
    
    /// The bottom toolbar containing main capture controls.
    var toolBar: XCUIElement { camera.otherElements[Camera.AccessibilityLabel.toolBar] }
    
    /// The top toolbar containing secondary information and actions.
    var topBar: XCUIElement { camera.otherElements[Camera.AccessibilityLabel.topBar] }
    
    ///
    var openCamera: XCUIElement { app.buttons["Open Camera"] }
    
    // MARK: - Capture Controls
    
    /// The counter displaying the current number of captured media items.
    var mediaCount: XCUIElement { topBar.buttons[Camera.AccessibilityLabel.mediaCounterView] }
    
    /// The control used to start or stop video recording.
    var recordVideo: XCUIElement { toolBar.otherElements[Camera.AccessibilityLabel.recordVideo] }
    
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
    
    // MARK: - Zoom Picker
    
    /// The first zoom option (usually 1x).
    var zoom1: XCUIElement { toolBar.staticTexts.matching(identifier: "Zoom Picker").element(boundBy: 1) }
    
    /// The second zoom option (usually 2x).
    var zoom2: XCUIElement { toolBar.staticTexts.matching(identifier: "Zoom Picker").element(boundBy: 2) }
    
    /// The third zoom option (usually 3x).
    var zoom3: XCUIElement { toolBar.staticTexts.matching(identifier: "Zoom Picker").element(boundBy: 3) }
    
    /// The fourth zoom option (usually 4x).
    var zoom4: XCUIElement { toolBar.staticTexts.matching(identifier: "Zoom Picker").element(boundBy: 4) }
    
    /// The fifth zoom option (usually 5x).
    var zoom5: XCUIElement { toolBar.staticTexts.matching(identifier: "Zoom Picker").element(boundBy: 5) }
    
    /// The sixth zoom option (usually 6x).
    var zoom6: XCUIElement { toolBar.staticTexts.matching(identifier: "Zoom Picker").element(boundBy: 6) }
}
