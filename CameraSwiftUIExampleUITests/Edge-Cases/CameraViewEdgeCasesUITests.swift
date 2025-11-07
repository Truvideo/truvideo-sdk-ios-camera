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
        app.launch()
        cameraScreen = CameraScreen(app: app)
    }
     
    // MARK: - Tests
    
    func testUC01FlashResetOnCameraSwitch() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertEqual(cameraScreen.flash.label, "Flash Off")
        cameraScreen.flash.tap()
        
        XCTAssertTrue(cameraScreen.switchCamera.waitForExistence(timeout: 3))
        cameraScreen.switchCamera.tap()
        
        XCTAssertEqual(cameraScreen.flash.label, "Flash")
        
        XCTAssertTrue(cameraScreen.recordVideo.waitForExistence(timeout: 3))
        cameraScreen.recordVideo.tap()
        
        XCTAssertEqual(cameraScreen.flash.label, "Flash Off")
        
        sleep(2)
        XCTAssertNotEqual(cameraScreen.timer.label, "00:00:00")
        
        cameraScreen.recordVideo.tap()
        
        XCTAssertEqual(cameraScreen.flash.label, "Flash Off")
        
        cameraScreen.switchCamera.tap()
        
        XCTAssertTrue(cameraScreen.recordVideo.waitForExistence(timeout: 3))
        cameraScreen.recordVideo.tap()
        
        XCTAssertEqual(cameraScreen.flash.label, "Flash Off")
        
        sleep(2)
        XCTAssertNotEqual(cameraScreen.timer.label, "00:00:00")
        
        cameraScreen.recordVideo.tap()
    }
    
    func testUC02ChangeResolutionDuringOrientationSwitch() {
        // Given, When, Then
        XCUIDevice.shared.orientation = .portrait
        sleep(1)
        
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.resolution.waitForExistence(timeout: 3))
        cameraScreen.resolution.tap()
        
        XCUIDevice.shared.orientation = .landscapeLeft
        sleep(1)
        
        XCTAssertTrue(cameraScreen.fhdOption.waitForExistence(timeout: 3))
        cameraScreen.fhdOption.tap()
        sleep(1)
        
        XCTAssertEqual(cameraScreen.resolution.label, "FHD")
        
        XCTAssertTrue(cameraScreen.camera.waitForExistence(timeout: 3))
        
        XCUIDevice.shared.orientation = .portrait
        sleep(1)
        
        XCTAssertTrue(cameraScreen.sdOption.waitForExistence(timeout: 3))
        cameraScreen.sdOption.tap()
        sleep(1)
        
        XCTAssertEqual(cameraScreen.resolution.label, "SD")
        
        XCTAssertTrue(cameraScreen.camera.waitForExistence(timeout: 3))
    }
    
    func testUC03PreventScreenLockDuringRecording() {
        // Given
        let initial = cameraScreen.timer.label

        // When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.recordVideo.waitForExistence(timeout: 3))
        cameraScreen.recordVideo.tap()

        XCTAssertTrue(cameraScreen.timer.exists)

        sleep(12)

        let updated = cameraScreen.timer.label
        XCTAssertNotEqual(initial, updated)

        cameraScreen.recordVideo.tap()

        XCTAssertTrue(cameraScreen.camera.waitForExistence(timeout: 3))
    }
}
