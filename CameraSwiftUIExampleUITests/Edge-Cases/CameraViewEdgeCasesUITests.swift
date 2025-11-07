//
// Copyright © 2025 TruVideo. All rights reserved.
//

import XCTest

@testable import TruvideoSdkCamera

final class CameraViewEdgeCasesUITests: XCTestCase {
    private var app: XCUIApplication!
    private var cameraScreen: CameraScreen!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments += ["-CameraSwiftUIExamplePermissionsUITest"]
        app.launch()
        cameraScreen = CameraScreen(app: app)
    }
     
    // MARK: - Tests
    
    func testUC01FlashResetOnCameraSwitch() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)
        
        XCTAssertEqual(cameraScreen.flashButton.label, "Flash Off")
        cameraScreen.flashButton.tap()
        
        XCTAssertTrue(cameraScreen.switchCameraButton.waitForExistence(timeout: 3))
        cameraScreen.switchCameraButton.tap()
        
        XCTAssertTrue(cameraScreen.recordVideoButton.waitForExistence(timeout: 3))
        cameraScreen.recordVideoButton.tap()
        
        XCTAssertEqual(cameraScreen.flashButton.label, "Flash Off")
        
        sleep(2)        
        cameraScreen.recordVideoButton.tap()
        
        XCTAssertEqual(cameraScreen.flashButton.label, "Flash Off")
        
        cameraScreen.switchCameraButton.tap()
        
        XCTAssertTrue(cameraScreen.recordVideoButton.waitForExistence(timeout: 3))
        cameraScreen.recordVideoButton.tap()
        
        XCTAssertEqual(cameraScreen.flashButton.label, "Flash Off")
        
        sleep(2)
        XCTAssertNotEqual(cameraScreen.timerText.label, "00:00:00")
        
        cameraScreen.recordVideoButton.tap()
    }
    
    func testUC02ChangeResolutionDuringOrientationSwitch() {
        // Given, When, Then
        XCUIDevice.shared.orientation = .portrait
        sleep(1)
        
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)
        
        XCTAssertTrue(cameraScreen.resolutionButton.waitForExistence(timeout: 3))
        cameraScreen.resolutionButton.tap()
        
        XCUIDevice.shared.orientation = .landscapeLeft
        sleep(4)
        
        XCTAssertTrue(cameraScreen.hdOption.waitForExistence(timeout: 3))
        cameraScreen.hdOption.tap()
        sleep(4)
        
        XCTAssertEqual(cameraScreen.resolutionButton.label, "HD")
        
        XCTAssertTrue(cameraScreen.cameraMainContainer.waitForExistence(timeout: 3))
        
        XCUIDevice.shared.orientation = .portrait
        sleep(4)
        
        XCTAssertTrue(cameraScreen.resolutionButton.waitForExistence(timeout: 3))
        cameraScreen.resolutionButton.tap()
        
        XCTAssertTrue(cameraScreen.sdOption.waitForExistence(timeout: 3))
        cameraScreen.sdOption.tap()
        sleep(1)
        
        XCTAssertTrue(cameraScreen.sdOption.waitForExistence(timeout: 3))
        cameraScreen.sdOption.tap()
        sleep(1)
        
        XCTAssertTrue(cameraScreen.cameraMainContainer.waitForExistence(timeout: 3))
    }
    
    func testUC03PreventScreenLockDuringRecording() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)
        
        let initial = cameraScreen.timerText.label

        XCTAssertTrue(cameraScreen.recordVideoButton.waitForExistence(timeout: 3))
        cameraScreen.recordVideoButton.tap()

        XCTAssertTrue(cameraScreen.timerText.exists)

        sleep(12)

        let updated = cameraScreen.timerText.label
        XCTAssertNotEqual(initial, updated)

        cameraScreen.recordVideoButton.tap()

        XCTAssertTrue(cameraScreen.cameraMainContainer.waitForExistence(timeout: 3))
    }
}
