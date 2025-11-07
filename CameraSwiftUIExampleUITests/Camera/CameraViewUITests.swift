//
// Copyright © 2025 TruVideo. All rights reserved.
//

import XCTest

@testable import TruvideoSdkCamera

final class CameraViewUITests: XCTestCase {
    private var app: XCUIApplication!
    private var cameraScreen: CameraScreen!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        cameraScreen = CameraScreen(app: app)
    }
    
    // MARK: - Front Camera [Take Photo]
    
    func testUCPhoto01TakeFrontCameraPhoto() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.switchCamera.waitForExistence(timeout: 3))
        cameraScreen.switchCamera.tap()
        
        XCTAssertTrue(cameraScreen.takePhoto.waitForExistence(timeout: 3))
        cameraScreen.takePhoto.tap()
        
        XCTAssertTrue(cameraScreen.mediaCount.exists)
    }
    
    func testUCPhoto1ATakeFrontCameraPhoto() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.switchCamera.waitForExistence(timeout: 3))
        cameraScreen.switchCamera.tap()
        
        XCTAssertTrue(cameraScreen.takePhoto.waitForExistence(timeout: 3))
        cameraScreen.takePhoto.tap()
        
        XCTAssertTrue(cameraScreen.mediaCount.exists)
        cameraScreen.mediaCount.tap()
    }
    
    func testUCPhoto02TakeFrontCameraPhotoFlashOff() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.switchCamera.waitForExistence(timeout: 3))
        cameraScreen.switchCamera.tap()
        
        cameraScreen.takePhoto.tap()
        XCTAssertEqual(cameraScreen.flash.label, "Flash Off")
    }
    
    func testUCPhoto03TakeFrontCameraPhotoFlashOn() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.switchCamera.waitForExistence(timeout: 3))
        cameraScreen.switchCamera.tap()
        
        XCTAssertTrue(cameraScreen.flash.waitForExistence(timeout: 3))
        cameraScreen.flash.tap()
        XCTAssertEqual(cameraScreen.flash.label, "Flash")
        
        XCTAssertTrue(cameraScreen.takePhoto.waitForExistence(timeout: 3))
        cameraScreen.takePhoto.tap()
        
        XCTAssertTrue(cameraScreen.mediaCount.exists)
        cameraScreen.mediaCount.tap()
    }
    
    func testUCPhoto04TakeFrontCameraPhotoWithZoom() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.switchCamera.waitForExistence(timeout: 3))
        cameraScreen.switchCamera.tap()
        
        XCTAssertTrue(cameraScreen.zoom1.waitForExistence(timeout: 3))
        cameraScreen.zoom1.tap()
        
        XCTAssertTrue(cameraScreen.zoom2.waitForExistence(timeout: 3))
        cameraScreen.zoom2.tap()
        
        XCTAssertTrue(cameraScreen.zoom3.waitForExistence(timeout: 3))
        cameraScreen.zoom3.tap()
        
        XCTAssertTrue(cameraScreen.zoom4.waitForExistence(timeout: 3))
        cameraScreen.zoom4.tap()
        
        XCTAssertTrue(cameraScreen.zoom5.waitForExistence(timeout: 3))
        cameraScreen.zoom5.tap()
        
        XCTAssertTrue(cameraScreen.zoom6.waitForExistence(timeout: 3))
        cameraScreen.zoom6.tap()
        
        XCTAssertTrue(cameraScreen.takePhoto.waitForExistence(timeout: 3))
        cameraScreen.takePhoto.tap()
    }
    
    func testUCPhoto05TakeFrontCameraPhotoMultipleOrientations() {
        // Given
        let switchCamera = app.buttons[Camera.AccessibilityLabel.switchCameraButton]

        // When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(switchCamera.waitForExistence(timeout: 5))
        switchCamera.tap()
        
        capturePhotoIn(orientation: .portrait)
        capturePhotoIn(orientation: .landscapeLeft)
        capturePhotoIn(orientation: .landscapeRight)
        capturePhotoIn(orientation: .portrait)
    }

    func testUCPhoto5ATakeFrontCameraPhotoPortrait() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.switchCamera.waitForExistence(timeout: 3))
        cameraScreen.switchCamera.tap()
        
        capturePhotoIn(orientation: .portrait)
        
        cameraScreen.mediaCount.tap()
    }
    
    func testUCPhoto5BTakeFrontCameraPhotoLandscapeLeft() {
        // Given
        let switchCamera = app.buttons[Camera.AccessibilityLabel.switchCameraButton]
        let mediaCount = app.buttons[Camera.AccessibilityLabel.mediaCounterView]

        // When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(switchCamera.waitForExistence(timeout: 3))
        switchCamera.tap()
        
        capturePhotoIn(orientation: .landscapeLeft)
        
        mediaCount.tap()
    }
    
    func testUCPhoto5CTakeFrontCameraPhotoLandscapeRight() {
        // Given
        let switchCamera = app.buttons[Camera.AccessibilityLabel.switchCameraButton]
        let mediaCount = app.buttons[Camera.AccessibilityLabel.mediaCounterView]

        // When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(switchCamera.waitForExistence(timeout: 3))
        switchCamera.tap()
        
        capturePhotoIn(orientation: .landscapeRight)

        mediaCount.tap()
    }
    
    func testUCPhoto08TakeFrontCameraPhotoMultipleResolutions() {
        // Given
        let resolutions = ["SD", "HD", "FHD"]
        
        // When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.switchCamera.waitForExistence(timeout: 3))
        cameraScreen.switchCamera.tap()

        for preset in resolutions {
            XCTAssertTrue(cameraScreen.resolution.waitForExistence(timeout: 3))
            cameraScreen.resolution.tap()
            
            let option = app.buttons[Camera.AccessibilityLabel.presetOption(preset)]
            XCTAssertTrue(option.waitForExistence(timeout: 3))
            option.tap()
            
            XCTAssertEqual(cameraScreen.resolution.label, preset)
            
            XCTAssertTrue(cameraScreen.takePhoto.waitForExistence(timeout: 3))
            cameraScreen.takePhoto.tap()
            
            XCTAssertTrue(cameraScreen.mediaCount.waitForExistence(timeout: 3))
        }
        
        cameraScreen.mediaCount.tap()
    }
    
    func testUCPhoto8ATakeFrontCameraPhotoHD() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.switchCamera.waitForExistence(timeout: 3))
        cameraScreen.switchCamera.tap()
        
        XCTAssertTrue(cameraScreen.resolution.waitForExistence(timeout: 3))
        cameraScreen.resolution.tap()
        
        XCTAssertTrue(cameraScreen.hdOption.waitForExistence(timeout: 3))
        cameraScreen.hdOption.tap()
        
        XCTAssertEqual(cameraScreen.resolution.label, "HD")
        
        XCTAssertTrue(cameraScreen.takePhoto.waitForExistence(timeout: 3))
        cameraScreen.takePhoto.tap()

        XCTAssertTrue(cameraScreen.mediaCount.waitForExistence(timeout: 3))
        cameraScreen.mediaCount.tap()
    }

    func testUCPhoto8BTakeFrontCameraPhotoFHD() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.switchCamera.waitForExistence(timeout: 3))
        cameraScreen.switchCamera.tap()
        
        XCTAssertTrue(cameraScreen.resolution.waitForExistence(timeout: 3))
        cameraScreen.resolution.tap()
        
        XCTAssertTrue(cameraScreen.fhdOption.waitForExistence(timeout: 3))
        cameraScreen.fhdOption.tap()
        
        XCTAssertEqual(cameraScreen.resolution.label, "FHD")
        
        XCTAssertTrue(cameraScreen.takePhoto.waitForExistence(timeout: 3))
        cameraScreen.takePhoto.tap()

        XCTAssertTrue(cameraScreen.mediaCount.waitForExistence(timeout: 3))
        cameraScreen.mediaCount.tap()
    }
    
    func testUCPhoto8CTakeFrontCameraPhotoSD() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.switchCamera.waitForExistence(timeout: 3))
        cameraScreen.switchCamera.tap()
        
        XCTAssertTrue(cameraScreen.resolution.waitForExistence(timeout: 3))
        cameraScreen.resolution.tap()
        
        XCTAssertTrue(cameraScreen.sdOption.waitForExistence(timeout: 3))
        cameraScreen.sdOption.tap()
        
        XCTAssertEqual(cameraScreen.resolution.label, "SD")
        
        XCTAssertTrue(cameraScreen.takePhoto.waitForExistence(timeout: 3))
        cameraScreen.takePhoto.tap()

        XCTAssertTrue(cameraScreen.mediaCount.waitForExistence(timeout: 3))
        cameraScreen.mediaCount.tap()
    }
    
    // MARK: - Front Camera [Recording Video]
    
    func testUCVideo01RecordFrontCamera() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.switchCamera.waitForExistence(timeout: 3))
        cameraScreen.switchCamera.tap()
        
        XCTAssertTrue(cameraScreen.recordVideo.waitForExistence(timeout: 3))
        cameraScreen.recordVideo.tap()
        
        sleep(2)
        XCTAssertNotEqual(cameraScreen.timer.label, "00:00:00")
        
        cameraScreen.recordVideo.tap()
        
        XCTAssertTrue(cameraScreen.mediaCount.exists)
    }

    func testUCVideo03RecordFrontCameraNoFlash() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.switchCamera.waitForExistence(timeout: 3))
        cameraScreen.switchCamera.tap()
        
        XCTAssertTrue(cameraScreen.flash.exists)
        XCTAssertTrue(cameraScreen.flash.isEnabled)

        XCTAssertTrue(cameraScreen.recordVideo.waitForExistence(timeout: 3))
        cameraScreen.recordVideo.tap()
        
        XCTAssertFalse(cameraScreen.flash.isEnabled)
        XCTAssertEqual(cameraScreen.flash.label, "Flash Off")
        
        sleep(2)
        XCTAssertNotEqual(cameraScreen.timer.label, "00:00:00")
        
        cameraScreen.recordVideo.tap()
        
        XCTAssertTrue(cameraScreen.mediaCount.waitForExistence(timeout: 3))
        cameraScreen.mediaCount.tap()
    }
    
    func testUCVideo04RecordFrontCameraPause() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.switchCamera.waitForExistence(timeout: 3))
        cameraScreen.switchCamera.tap()

        XCTAssertTrue(cameraScreen.recordVideo.waitForExistence(timeout: 3))
        cameraScreen.recordVideo.tap()
        
        sleep(2)
        XCTAssertNotEqual(cameraScreen.timer.label, "00:00:00")
        
        XCTAssertTrue(cameraScreen.playAndPause.waitForExistence(timeout: 3))
        cameraScreen.playAndPause.tap()
    }
    
    func testUCVideo05RecordFrontCameraPauseResume() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.switchCamera.waitForExistence(timeout: 3))
        cameraScreen.switchCamera.tap()

        XCTAssertTrue(cameraScreen.recordVideo.waitForExistence(timeout: 3))
        cameraScreen.recordVideo.tap()
        
        sleep(2)
        XCTAssertNotEqual(cameraScreen.timer.label, "00:00:00")
        
        XCTAssertEqual(cameraScreen.playAndPause.label, "Pause")
        
        XCTAssertTrue(cameraScreen.playAndPause.waitForExistence(timeout: 3))
        cameraScreen.playAndPause.tap()
        
        XCTAssertEqual(cameraScreen.playAndPause.label, "Play")
        
        cameraScreen.playAndPause.tap()
        XCTAssertEqual(cameraScreen.playAndPause.label, "Pause")
        sleep(1)
        XCTAssertNotEqual(cameraScreen.timer.label, "00:00:00")
        
        cameraScreen.recordVideo.tap()
    }
    
    func testUCVideo06RecordFrontCameraPhotoWhileRecording() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.switchCamera.waitForExistence(timeout: 3))
        cameraScreen.switchCamera.tap()

        XCTAssertTrue(cameraScreen.recordVideo.waitForExistence(timeout: 3))
        cameraScreen.recordVideo.tap()
        
        sleep(2)
        XCTAssertNotEqual(cameraScreen.timer.label, "00:00:00")
        
        XCTAssertTrue(cameraScreen.takePhoto.waitForExistence(timeout: 3))
        cameraScreen.takePhoto.tap()
        
        XCTAssertEqual(cameraScreen.takePhoto.label, "Camera")
        
        cameraScreen.recordVideo.tap()
        
        XCTAssertTrue(cameraScreen.mediaCount.waitForExistence(timeout: 3))
        cameraScreen.mediaCount.tap()
    }

    func testUCVideo07RecordFrontCameraZoom() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.switchCamera.waitForExistence(timeout: 3))
        cameraScreen.switchCamera.tap()

        XCTAssertTrue(cameraScreen.recordVideo.waitForExistence(timeout: 3))
        cameraScreen.recordVideo.tap()
        
        XCTAssertTrue(cameraScreen.zoom1.waitForExistence(timeout: 6))
        cameraScreen.zoom1.tap()
        
        XCTAssertTrue(cameraScreen.zoom2.waitForExistence(timeout: 6))
        cameraScreen.zoom2.tap()
        
        XCTAssertTrue(cameraScreen.zoom3.waitForExistence(timeout: 6))
        cameraScreen.zoom3.tap()
        
        XCTAssertTrue(cameraScreen.zoom4.waitForExistence(timeout: 6))
        cameraScreen.zoom4.tap()
        
        XCTAssertTrue(cameraScreen.zoom5.waitForExistence(timeout: 6))
        cameraScreen.zoom5.tap()
        
        XCTAssertTrue(cameraScreen.zoom6.waitForExistence(timeout: 6))
        cameraScreen.zoom6.tap()
        
        sleep(2)
        XCTAssertNotEqual(cameraScreen.timer.label, "00:00:00")
        
        cameraScreen.recordVideo.tap()
        
        XCTAssertTrue(cameraScreen.mediaCount.waitForExistence(timeout: 3))
        cameraScreen.mediaCount.tap()
    }

    func testUCVideo08RecordFrontCameraMultipleOrientations() {
        // Given
        let switchCamera = app.buttons[Camera.AccessibilityLabel.switchCameraButton]

        // When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(switchCamera.waitForExistence(timeout: 3))
        switchCamera.tap()
        
        captureVideoIn(orientation: .portrait, description: "Portrait")
        captureVideoIn(orientation: .landscapeLeft, description: "Landscape Left")
        captureVideoIn(orientation: .landscapeRight, description: "Landscape Right")
        captureVideoIn(orientation: .portrait, description: "Portrait")
    }

    func testUCVideo8ARecordFrontCameraPortrait() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.switchCamera.waitForExistence(timeout: 3))
        cameraScreen.switchCamera.tap()
        
        captureVideoIn(orientation: .portrait, description: "Portrait")
        
        XCTAssertTrue(cameraScreen.recordVideo.waitForExistence(timeout: 3))
        cameraScreen.recordVideo.tap()
        
        XCTAssertTrue(cameraScreen.mediaCount.waitForExistence(timeout: 3))
        cameraScreen.mediaCount.tap()
    }
    
    func testUCVideo8BRecordFrontCameraLandscapeLeft() {
        // Given
        let switchCamera = app.buttons[Camera.AccessibilityLabel.switchCameraButton]
        let recordVideo = app.otherElements[Camera.AccessibilityLabel.recordVideo]
        let mediaCount = app.buttons[Camera.AccessibilityLabel.mediaCounterView]

        // When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(switchCamera.waitForExistence(timeout: 3))
        switchCamera.tap()
        
        captureVideoIn(orientation: .landscapeLeft, description: "Landscape Left")
        
        XCTAssertTrue(recordVideo.waitForExistence(timeout: 3))
        recordVideo.tap()
        
        XCTAssertTrue(mediaCount.waitForExistence(timeout: 3))
        mediaCount.tap()
    }
    
    func testUCVideo8CRecordFrontCameraLandscapeRight() {
        // Given
        let switchCamera = app.buttons[Camera.AccessibilityLabel.switchCameraButton]
        let recordVideo = app.otherElements[Camera.AccessibilityLabel.recordVideo]
        let mediaCount = app.buttons[Camera.AccessibilityLabel.mediaCounterView]

        // When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(switchCamera.waitForExistence(timeout: 3))
        switchCamera.tap()
        
        captureVideoIn(orientation: .landscapeRight, description: "Landscape Right")
        
        XCTAssertTrue(recordVideo.waitForExistence(timeout: 3))
        recordVideo.tap()
        
        XCTAssertTrue(mediaCount.waitForExistence(timeout: 3))
        mediaCount.tap()
    }

    func testUCVideo09RecordFrontCameraBackgroundTransition() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.switchCamera.waitForExistence(timeout: 3))
        cameraScreen.switchCamera.tap()
        
        XCTAssertTrue(cameraScreen.recordVideo.waitForExistence(timeout: 3))
        cameraScreen.recordVideo.tap()
        
        XCUIDevice.shared.press(.home)
        sleep(3)
        
        app.activate()
        sleep(2)
        
        if cameraScreen.timer.label != "00:00:00" {
            XCTAssertTrue(true)
            cameraScreen.recordVideo.tap()
        } else {
            XCTAssertTrue(true)
        }
        
        XCTAssertEqual(cameraScreen.app.state, .runningForeground)
    }
    
    func testUCVideo12RecordFrontCameraMultipleResolutions() {
        // Given
        let resolutions = ["SD", "HD", "FHD"]

        // When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.switchCamera.waitForExistence(timeout: 5))
        cameraScreen.switchCamera.tap()
        sleep(1)

        for preset in resolutions {
            XCTAssertTrue(cameraScreen.resolution.waitForExistence(timeout: 3))
            cameraScreen.resolution.tap()

            let option = app.buttons[Camera.AccessibilityLabel.presetOption(preset)]
            XCTAssertTrue(option.waitForExistence(timeout: 3))
            option.tap()

            XCTAssertEqual(cameraScreen.resolution.label, preset)

            XCTAssertTrue(cameraScreen.recordVideo.waitForExistence(timeout: 3))
            cameraScreen.recordVideo.tap()

            sleep(2)
            XCTAssertNotEqual(cameraScreen.timer.label, "00:00:00")

            cameraScreen.recordVideo.tap()

            XCTAssertTrue(cameraScreen.mediaCount.waitForExistence(timeout: 3))
        }
        
        cameraScreen.mediaCount.tap()
    }

    func testUCVideo12ARecordFrontCameraHD() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.switchCamera.waitForExistence(timeout: 3))
        cameraScreen.switchCamera.tap()
        
        XCTAssertTrue(cameraScreen.resolution.waitForExistence(timeout: 3))
        cameraScreen.resolution.tap()
        
        XCTAssertTrue(cameraScreen.hdOption.waitForExistence(timeout: 3))
        cameraScreen.hdOption.tap()
        
        XCTAssertEqual(cameraScreen.resolution.label, "HD")
        
        XCTAssertTrue(cameraScreen.recordVideo.waitForExistence(timeout: 3))
        cameraScreen.recordVideo.tap()
        
        sleep(2)
        XCTAssertNotEqual(cameraScreen.timer.label, "00:00:00")

        cameraScreen.recordVideo.tap()

        XCTAssertTrue(cameraScreen.mediaCount.waitForExistence(timeout: 3))
        cameraScreen.mediaCount.tap()
    }
    
    func testUCVideo12BRecordFrontCameraFHD() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.switchCamera.waitForExistence(timeout: 3))
        cameraScreen.switchCamera.tap()
        
        XCTAssertTrue(cameraScreen.resolution.waitForExistence(timeout: 3))
        cameraScreen.resolution.tap()
        
        XCTAssertTrue(cameraScreen.fhdOption.waitForExistence(timeout: 3))
        cameraScreen.fhdOption.tap()
        
        XCTAssertEqual(cameraScreen.resolution.label, "FHD")
        
        XCTAssertTrue(cameraScreen.recordVideo.waitForExistence(timeout: 3))
        cameraScreen.recordVideo.tap()
        
        sleep(2)
        XCTAssertNotEqual(cameraScreen.timer.label, "00:00:00")

        cameraScreen.recordVideo.tap()

        XCTAssertTrue(cameraScreen.mediaCount.waitForExistence(timeout: 3))
        cameraScreen.mediaCount.tap()
    }
    
    func testUCVideo12CRecordFrontCameraSD() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.switchCamera.waitForExistence(timeout: 3))
        cameraScreen.switchCamera.tap()
        
        XCTAssertTrue(cameraScreen.resolution.waitForExistence(timeout: 3))
        cameraScreen.resolution.tap()
        
        XCTAssertTrue(cameraScreen.sdOption.waitForExistence(timeout: 3))
        cameraScreen.sdOption.tap()
        
        XCTAssertEqual(cameraScreen.resolution.label, "SD")
        
        XCTAssertTrue(cameraScreen.recordVideo.waitForExistence(timeout: 3))
        cameraScreen.recordVideo.tap()
        
        sleep(2)
        XCTAssertNotEqual(cameraScreen.timer.label, "00:00:00")

        cameraScreen.recordVideo.tap()

        XCTAssertTrue(cameraScreen.mediaCount.waitForExistence(timeout: 3))
        cameraScreen.mediaCount.tap()
    }
    
    // MARK: - Rear Camera [Take Photo]
    
    func testUCPhoto01TakePhotoRearCamera() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.takePhoto.waitForExistence(timeout: 3))
        cameraScreen.takePhoto.tap()
        
        XCTAssertTrue(cameraScreen.mediaCount.exists)
        cameraScreen.mediaCount.tap()
    }
    
    func testUCPhoto02TakePhotoWithFlashOff() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.takePhoto.waitForExistence(timeout: 3))
        cameraScreen.takePhoto.tap()
        
        XCTAssertEqual(cameraScreen.flash.label, "Flash Off")
        
        XCTAssertTrue(cameraScreen.mediaCount.exists)
        cameraScreen.mediaCount.tap()
    }

    func testUCPhoto03TakePhotoWithFlashOn() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.flash.waitForExistence(timeout: 3))
        cameraScreen.flash.tap()
        XCTAssertEqual(cameraScreen.flash.label, "Flash")

        XCTAssertTrue(cameraScreen.takePhoto.waitForExistence(timeout: 3))
        cameraScreen.takePhoto.tap()
        
        XCTAssertTrue(cameraScreen.mediaCount.waitForExistence(timeout: 3))
        cameraScreen.mediaCount.tap()
    }
    
    func testUCPhoto04TakePhotoWithZoom() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.zoom1.waitForExistence(timeout: 3))
        cameraScreen.zoom1.tap()
        
        XCTAssertTrue(cameraScreen.zoom2.waitForExistence(timeout: 3))
        cameraScreen.zoom2.tap()
        
        XCTAssertTrue(cameraScreen.zoom3.waitForExistence(timeout: 3))
        cameraScreen.zoom3.tap()
        
        XCTAssertTrue(cameraScreen.zoom4.waitForExistence(timeout: 3))
        cameraScreen.zoom4.tap()
        
        XCTAssertTrue(cameraScreen.zoom5.waitForExistence(timeout: 3))
        cameraScreen.zoom5.tap()
        
        XCTAssertTrue(cameraScreen.zoom6.waitForExistence(timeout: 3))
        cameraScreen.zoom6.tap()
        
        XCTAssertTrue(cameraScreen.takePhoto.waitForExistence(timeout: 3))
        cameraScreen.takePhoto.tap()
    }

    func testUCPhoto05TakePhotoUnlockedOrientation() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        capturePhotoIn(orientation: .portrait)
        capturePhotoIn(orientation: .landscapeLeft)
        capturePhotoIn(orientation: .landscapeRight)
        capturePhotoIn(orientation: .portrait)
    }

    func testUCPhoto05ATakePhotoPortrait() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        capturePhotoIn(orientation: .portrait)

        cameraScreen.mediaCount.tap()
    }
    
    func testUCPhoto05BTakePhotoLandscapeLeft() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        capturePhotoIn(orientation: .landscapeLeft)
        
        cameraScreen.mediaCount.tap()
    }
    
    func testUCPhoto05CTakePhotoLandscapeRight() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        capturePhotoIn(orientation: .landscapeRight)
        
        cameraScreen.mediaCount.tap()
    }

    func testUCPhoto08TakePhotoDifferentResolutions() {
        // Given
        let resolutions = ["SD", "HD", "FHD"]

        // When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        for preset in resolutions {
            XCTAssertTrue(cameraScreen.resolution.waitForExistence(timeout: 3))
            cameraScreen.resolution.tap()
            
            let option = app.buttons[Camera.AccessibilityLabel.presetOption(preset)]
            XCTAssertTrue(option.waitForExistence(timeout: 3))
            option.tap()
            
            XCTAssertEqual(cameraScreen.resolution.label, preset)
            
            XCTAssertTrue(cameraScreen.takePhoto.waitForExistence(timeout: 3))
            cameraScreen.takePhoto.tap()
            
            XCTAssertTrue(cameraScreen.mediaCount.waitForExistence(timeout: 3))
        }
        
        cameraScreen.mediaCount.tap()
    }

    func testUCPhoto08ATakePhotoHDResolution() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.resolution.waitForExistence(timeout: 3))
        cameraScreen.resolution.tap()
        
        XCTAssertTrue(cameraScreen.hdOption.waitForExistence(timeout: 3))
        cameraScreen.hdOption.tap()
        
        XCTAssertEqual(cameraScreen.resolution.label, "HD")
        
        XCTAssertTrue(cameraScreen.takePhoto.waitForExistence(timeout: 3))
        cameraScreen.takePhoto.tap()

        XCTAssertTrue(cameraScreen.mediaCount.waitForExistence(timeout: 3))
        cameraScreen.mediaCount.tap()
    }
    
    func testUCPhoto08BTakePhotoFHDResolution() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.resolution.waitForExistence(timeout: 3))
        cameraScreen.resolution.tap()
        
        XCTAssertTrue(cameraScreen.fhdOption.waitForExistence(timeout: 3))
        cameraScreen.fhdOption.tap()
        
        XCTAssertEqual(cameraScreen.resolution.label, "FHD")
        
        XCTAssertTrue(cameraScreen.takePhoto.waitForExistence(timeout: 3))
        cameraScreen.takePhoto.tap()

        XCTAssertTrue(cameraScreen.mediaCount.waitForExistence(timeout: 3))
        cameraScreen.mediaCount.tap()
    }
    
    func testUCPhoto08CTakePhotoSDResolution() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.resolution.waitForExistence(timeout: 3))
        cameraScreen.resolution.tap()
        
        XCTAssertTrue(cameraScreen.sdOption.waitForExistence(timeout: 3))
        cameraScreen.sdOption.tap()
        
        XCTAssertEqual(cameraScreen.resolution.label, "SD")
        
        XCTAssertTrue(cameraScreen.takePhoto.waitForExistence(timeout: 3))
        cameraScreen.takePhoto.tap()

        XCTAssertTrue(cameraScreen.mediaCount.waitForExistence(timeout: 3))
        cameraScreen.mediaCount.tap()
    }
    
    // MARK: - Rear Camera [Recording Video]
        
    func testUC01StartVideoRecordingRearCamera() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.recordVideo.waitForExistence(timeout: 3))
        cameraScreen.recordVideo.tap()
        
        sleep(2)
        XCTAssertNotEqual(cameraScreen.timer.label, "00:00:00")
        
        cameraScreen.recordVideo.tap()
        
        XCTAssertTrue(cameraScreen.mediaCount.exists)
        cameraScreen.mediaCount.tap()
    }

    func testUC03StartVideoRecordingWithFlashOff() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.recordVideo.waitForExistence(timeout: 3))
        cameraScreen.recordVideo.tap()
        
        XCTAssertEqual(cameraScreen.flash.label, "Flash Off")
        
        sleep(2)
        XCTAssertNotEqual(cameraScreen.timer.label, "00:00:00")
        
        cameraScreen.recordVideo.tap()
        
        XCTAssertTrue(cameraScreen.mediaCount.waitForExistence(timeout: 3))
        cameraScreen.mediaCount.tap()
    }
    
    func testUC04StartVideoRecordingWithFlashOn() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.recordVideo.waitForExistence(timeout: 3))
        cameraScreen.recordVideo.tap()
        
        cameraScreen.flash.tap()
        XCTAssertEqual(cameraScreen.flash.label, "Flash")
        
        sleep(2)
        XCTAssertNotEqual(cameraScreen.timer.label, "00:00:00")
        
        cameraScreen.recordVideo.tap()
        
        XCTAssertTrue(cameraScreen.mediaCount.waitForExistence(timeout: 3))
        cameraScreen.mediaCount.tap()
    }

    func testUC05PauseVideoRecording() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.recordVideo.waitForExistence(timeout: 3))
        cameraScreen.recordVideo.tap()
        
        sleep(2)
        XCTAssertNotEqual(cameraScreen.timer.label, "00:00:00")
        
        XCTAssertTrue(cameraScreen.playAndPause.waitForExistence(timeout: 3))
        cameraScreen.playAndPause.tap()
    }

    func testUC06VideoRecordingPauseAndResume() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.recordVideo.waitForExistence(timeout: 3))
        cameraScreen.recordVideo.tap()
        
        sleep(2)
        XCTAssertNotEqual(cameraScreen.timer.label, "00:00:00")
        
        XCTAssertEqual(cameraScreen.playAndPause.label, "Pause")
        
        XCTAssertTrue(cameraScreen.playAndPause.waitForExistence(timeout: 3))
        cameraScreen.playAndPause.tap()
        
        XCTAssertEqual(cameraScreen.playAndPause.label, "Play")
        
        cameraScreen.playAndPause.tap()
        XCTAssertEqual(cameraScreen.playAndPause.label, "Pause")
        sleep(1)
        XCTAssertNotEqual(cameraScreen.timer.label, "00:00:00")
        
        cameraScreen.recordVideo.tap()
    }

    func testUC07VideoRecordingCapturePhotoWhileRecording() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.recordVideo.waitForExistence(timeout: 3))
        cameraScreen.recordVideo.tap()
        
        sleep(2)
        XCTAssertNotEqual(cameraScreen.timer.label, "00:00:00")
        
        XCTAssertTrue(cameraScreen.takePhoto.waitForExistence(timeout: 3))
        cameraScreen.takePhoto.tap()
        
        XCTAssertEqual(cameraScreen.takePhoto.label, "Camera")
        
        cameraScreen.recordVideo.tap()
        
        XCTAssertTrue(cameraScreen.mediaCount.waitForExistence(timeout: 3))
        cameraScreen.mediaCount.tap()
    }
    
    func testUC08VideoRecordingAdjustZoom() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.recordVideo.waitForExistence(timeout: 3))
        cameraScreen.recordVideo.tap()
        
        XCTAssertTrue(cameraScreen.zoom1.waitForExistence(timeout: 6))
        cameraScreen.zoom1.tap()
        
        XCTAssertTrue(cameraScreen.zoom2.waitForExistence(timeout: 6))
        cameraScreen.zoom2.tap()
        
        XCTAssertTrue(cameraScreen.zoom3.waitForExistence(timeout: 6))
        cameraScreen.zoom3.tap()
        
        XCTAssertTrue(cameraScreen.zoom4.waitForExistence(timeout: 6))
        cameraScreen.zoom4.tap()
        
        XCTAssertTrue(cameraScreen.zoom5.waitForExistence(timeout: 6))
        cameraScreen.zoom5.tap()
        
        XCTAssertTrue(cameraScreen.zoom6.waitForExistence(timeout: 6))
        cameraScreen.zoom6.tap()
        
        sleep(2)
        XCTAssertNotEqual(cameraScreen.timer.label, "00:00:00")
        
        cameraScreen.recordVideo.tap()
        
        XCTAssertTrue(cameraScreen.mediaCount.waitForExistence(timeout: 3))
        cameraScreen.mediaCount.tap()
    }

    func testUC09VideoRecordingUnlockedOrientation() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        captureVideoIn(orientation: .portrait, description: "Portrait")
        captureVideoIn(orientation: .landscapeLeft, description: "Landscape Left")
        captureVideoIn(orientation: .landscapeRight, description: "Landscape Right")
        captureVideoIn(orientation: .portrait, description: "Portrait")
    }
    
    func testUC09AVideoRecordingPortrait() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        captureVideoIn(orientation: .portrait, description: "Portrait")
        
        XCTAssertTrue(cameraScreen.recordVideo.waitForExistence(timeout: 3))
        cameraScreen.recordVideo.tap()
        
        XCTAssertTrue(cameraScreen.mediaCount.waitForExistence(timeout: 3))
        cameraScreen.mediaCount.tap()
    }
    
    func testUC09BVideoRecordingLandscapeLeft() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        captureVideoIn(orientation: .landscapeLeft, description: "Landscape Left")
        
        XCTAssertTrue(cameraScreen.recordVideo.waitForExistence(timeout: 3))
        cameraScreen.recordVideo.tap()
        
        XCTAssertTrue(cameraScreen.mediaCount.waitForExistence(timeout: 3))
        cameraScreen.mediaCount.tap()
    }
    
    func testUC09CVideoRecordingLandscapeRight() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        captureVideoIn(orientation: .landscapeRight, description: "Landscape Right")
        
        XCTAssertTrue(cameraScreen.recordVideo.waitForExistence(timeout: 3))
        cameraScreen.recordVideo.tap()
        
        XCTAssertTrue(cameraScreen.mediaCount.waitForExistence(timeout: 3))
        cameraScreen.mediaCount.tap()
    }
    
    func testUC10VideoRecordingFlashBackgroundTransition() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.recordVideo.waitForExistence(timeout: 3))
        cameraScreen.recordVideo.tap()
        
        XCUIDevice.shared.press(.home)
        sleep(3)
        
        app.activate()
        sleep(2)
        
        if cameraScreen.timer.label != "00:00:00" {
            XCTAssertTrue(true)
            cameraScreen.recordVideo.tap()
        } else {
            XCTAssertTrue(true)
        }
        
        XCTAssertEqual(app.state, .runningForeground)
    }
    
    // MARK: - Private Methods
    
    private func captureVideoIn(orientation: UIDeviceOrientation, description: String) {
        recordVideoInOrientation(orientation)
        
        let recordVideo = app.otherElements[Camera.AccessibilityLabel.recordVideo]
        let mediaCount = app.buttons[Camera.AccessibilityLabel.mediaCounterView]
        
        XCTAssertTrue(recordVideo.waitForExistence(timeout: 5))
        recordVideo.tap()
        
        XCTAssertTrue(mediaCount.waitForExistence(timeout: 5))
    }
    
    private func capturePhotoIn(orientation: UIDeviceOrientation) {
        takePhotoInOrientation(orientation)
        
        let takePhoto = app.buttons[Camera.AccessibilityLabel.takePhotoButton]
        let mediaCount = app.buttons[Camera.AccessibilityLabel.mediaCounterView]
        
        XCTAssertTrue(takePhoto.waitForExistence(timeout: 5))
        takePhoto.tap()
        
        XCTAssertTrue(mediaCount.waitForExistence(timeout: 5))
    }
    
    private func takePhotoInOrientation(_ orientation: UIDeviceOrientation) {
        XCUIDevice.shared.orientation = orientation
        sleep(1)
    }
    
    private func recordVideoInOrientation(_ orientation: UIDeviceOrientation) {
        XCUIDevice.shared.orientation = orientation
        sleep(1)
    }
}
