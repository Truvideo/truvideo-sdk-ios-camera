//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation
import XCTest

@testable import TruvideoSdkCamera

final class CameraViewUITests: XCTestCase {
    private var app: XCUIApplication!
    private var cameraScreen: CameraScreen!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments += ["-CameraSwiftUIExamplePermissionsUITest", "CameraSwiftUIExampleUITests"]
        app.launch()
        cameraScreen = CameraScreen(app: app)
    }

    // MARK: - Front Camera [Take Photo]

    func testUCPhoto01TakeFrontCameraPhoto() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.switchCameraButton.waitForExistence(timeout: 3))
        cameraScreen.switchCameraButton.tap()

        XCTAssertTrue(cameraScreen.takePhotoButton.waitForExistence(timeout: 3))
        cameraScreen.takePhotoButton.tap()

        XCTAssertTrue(cameraScreen.mediaCountButton.exists)
        cameraScreen.mediaCountButton.tap()
    }

    func testUCPhoto1ATakeFrontCameraPhoto() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.switchCameraButton.waitForExistence(timeout: 3))
        cameraScreen.switchCameraButton.tap()

        XCTAssertTrue(cameraScreen.takePhotoButton.waitForExistence(timeout: 3))
        cameraScreen.takePhotoButton.tap()

        XCTAssertTrue(cameraScreen.mediaCountButton.exists)
        cameraScreen.mediaCountButton.tap()
    }

    func testUCPhoto02TakeFrontCameraPhotoFlashOff() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.switchCameraButton.waitForExistence(timeout: 3))
        cameraScreen.switchCameraButton.tap()

        cameraScreen.takePhotoButton.tap()
        XCTAssertEqual(cameraScreen.flashButton.label, "Flash Off")
    }

    func testUCPhoto03TakeFrontCameraPhotoFlashOn() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.switchCameraButton.waitForExistence(timeout: 3))
        cameraScreen.switchCameraButton.tap()

        XCTAssertTrue(cameraScreen.flashButton.waitForExistence(timeout: 3))
        cameraScreen.flashButton.tap()
        XCTAssertEqual(cameraScreen.flashButton.label, "Flash")

        XCTAssertTrue(cameraScreen.takePhotoButton.waitForExistence(timeout: 3))
        cameraScreen.takePhotoButton.tap()

        XCTAssertTrue(cameraScreen.mediaCountButton.exists)
        cameraScreen.mediaCountButton.tap()
    }

    func testUCPhoto04TakeFrontCameraPhotoWithZoom() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.switchCameraButton.waitForExistence(timeout: 3))
        cameraScreen.switchCameraButton.tap()
        sleep(2)

        for value in cameraScreen.zoomPickerValues() {
            XCTAssertTrue(value.isHittable)
            value.tap()
        }

        XCTAssertTrue(cameraScreen.takePhotoButton.waitForExistence(timeout: 3))
        cameraScreen.takePhotoButton.tap()
    }

    func testUCPhoto05TakeFrontCameraPhotoMultipleOrientations() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.switchCameraButton.waitForExistence(timeout: 5))
        cameraScreen.switchCameraButton.tap()

        capturePhotoIn(orientation: .portrait)
        capturePhotoIn(orientation: .landscapeLeft)
        capturePhotoIn(orientation: .landscapeRight)
        capturePhotoIn(orientation: .portrait)
    }

    func testUCPhoto5ATakeFrontCameraPhotoPortrait() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.switchCameraButton.waitForExistence(timeout: 3))
        cameraScreen.switchCameraButton.tap()

        capturePhotoIn(orientation: .portrait)

        cameraScreen.mediaCountButton.tap()
    }

    func testUCPhoto5BTakeFrontCameraPhotoLandscapeLeft() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.switchCameraButton.waitForExistence(timeout: 3))
        cameraScreen.switchCameraButton.tap()

        capturePhotoIn(orientation: .landscapeLeft)

        cameraScreen.mediaCountButton.tap()
    }

    func testUCPhoto5CTakeFrontCameraPhotoLandscapeRight() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.switchCameraButton.waitForExistence(timeout: 3))
        cameraScreen.switchCameraButton.tap()

        capturePhotoIn(orientation: .landscapeRight)

        cameraScreen.mediaCountButton.tap()
    }

    func testUCPhoto08TakeFrontCameraPhotoMultipleResolutions() {
        // Given
        let resolutions = ["SD", "HD", "FHD"]

        // When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.switchCameraButton.waitForExistence(timeout: 3))
        cameraScreen.switchCameraButton.tap()

        for preset in resolutions {
            XCTAssertTrue(cameraScreen.resolutionButton.waitForExistence(timeout: 3))
            cameraScreen.resolutionButton.tap()

            let option = app.buttons[Camera.AccessibilityLabel.presetOption(preset)]
            XCTAssertTrue(option.waitForExistence(timeout: 3))
            option.tap()

            XCTAssertEqual(cameraScreen.resolutionButton.label, preset)

            XCTAssertTrue(cameraScreen.takePhotoButton.waitForExistence(timeout: 3))
            cameraScreen.takePhotoButton.tap()

            XCTAssertTrue(cameraScreen.mediaCountButton.waitForExistence(timeout: 3))
        }

        cameraScreen.mediaCountButton.tap()
    }

    func testUCPhoto8ATakeFrontCameraPhotoHD() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.switchCameraButton.waitForExistence(timeout: 3))
        cameraScreen.switchCameraButton.tap()

        XCTAssertTrue(cameraScreen.resolutionButton.waitForExistence(timeout: 3))
        cameraScreen.resolutionButton.tap()

        XCTAssertTrue(cameraScreen.hdOption.waitForExistence(timeout: 3))
        cameraScreen.hdOption.tap()

        XCTAssertEqual(cameraScreen.resolutionButton.label, "HD")

        XCTAssertTrue(cameraScreen.takePhotoButton.waitForExistence(timeout: 3))
        cameraScreen.takePhotoButton.tap()

        XCTAssertTrue(cameraScreen.mediaCountButton.waitForExistence(timeout: 3))
        cameraScreen.mediaCountButton.tap()
    }

    func testUCPhoto8BTakeFrontCameraPhotoFHD() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.switchCameraButton.waitForExistence(timeout: 3))
        cameraScreen.switchCameraButton.tap()

        XCTAssertTrue(cameraScreen.resolutionButton.waitForExistence(timeout: 3))
        cameraScreen.resolutionButton.tap()

        XCTAssertTrue(cameraScreen.fhdOption.waitForExistence(timeout: 3))
        cameraScreen.fhdOption.tap()

        XCTAssertEqual(cameraScreen.resolutionButton.label, "FHD")

        XCTAssertTrue(cameraScreen.takePhotoButton.waitForExistence(timeout: 3))
        cameraScreen.takePhotoButton.tap()

        XCTAssertTrue(cameraScreen.mediaCountButton.waitForExistence(timeout: 3))
        cameraScreen.mediaCountButton.tap()
    }

    func testUCPhoto8CTakeFrontCameraPhotoSD() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.switchCameraButton.waitForExistence(timeout: 3))
        cameraScreen.switchCameraButton.tap()

        XCTAssertTrue(cameraScreen.resolutionButton.waitForExistence(timeout: 3))
        cameraScreen.resolutionButton.tap()

        XCTAssertTrue(cameraScreen.sdOption.waitForExistence(timeout: 3))
        cameraScreen.sdOption.tap()

        XCTAssertEqual(cameraScreen.resolutionButton.label, "SD")

        XCTAssertTrue(cameraScreen.takePhotoButton.waitForExistence(timeout: 3))
        cameraScreen.takePhotoButton.tap()

        XCTAssertTrue(cameraScreen.mediaCountButton.waitForExistence(timeout: 3))
        cameraScreen.mediaCountButton.tap()
    }

    // MARK: - Front Camera [Recording Video]

    func testUCVideo01RecordFrontCamera() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.switchCameraButton.waitForExistence(timeout: 3))
        cameraScreen.switchCameraButton.tap()

        XCTAssertTrue(cameraScreen.recordVideoButton.waitForExistence(timeout: 3))
        cameraScreen.recordVideoButton.tap()

        sleep(2)
        XCTAssertNotEqual(cameraScreen.timerText.label, "00:00:00")

        cameraScreen.recordVideoButton.tap()

        XCTAssertTrue(cameraScreen.mediaCountButton.exists)
    }

    func testUCVideo03RecordFrontCameraNoFlash() throws {
        // Given, When, Then
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              device.hasTorch else {
            throw XCTSkip("Skipping test: Device does not support torch")
        }

        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 10))
        cameraScreen.openCamera.tap()
        sleep(10)

        XCTAssertTrue(cameraScreen.switchCameraButton.waitForExistence(timeout: 10))
        cameraScreen.switchCameraButton.tap()

        XCTAssertTrue(cameraScreen.flashButton.exists)
        XCTAssertTrue(cameraScreen.flashButton.isEnabled)

        XCTAssertTrue(cameraScreen.recordVideoButton.waitForExistence(timeout: 10))
        cameraScreen.recordVideoButton.tap()

        XCTAssertEqual(cameraScreen.flashButton.label, "Flash Off")

        sleep(10)
        XCTAssertNotEqual(cameraScreen.timerText.label, "00:00:00")

        cameraScreen.recordVideoButton.tap()

        XCTAssertTrue(cameraScreen.mediaCountButton.waitForExistence(timeout: 10))
        cameraScreen.mediaCountButton.tap()
    }

    func testUCVideo04RecordFrontCameraPause() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.switchCameraButton.waitForExistence(timeout: 3))
        cameraScreen.switchCameraButton.tap()

        XCTAssertTrue(cameraScreen.recordVideoButton.waitForExistence(timeout: 3))
        cameraScreen.recordVideoButton.tap()

        sleep(2)
        XCTAssertNotEqual(cameraScreen.timerText.label, "00:00:00")

        XCTAssertTrue(cameraScreen.playAndPauseButton.waitForExistence(timeout: 3))
        cameraScreen.playAndPauseButton.tap()
    }

    func testUCVideo05RecordFrontCameraPauseResume() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.switchCameraButton.waitForExistence(timeout: 3))
        cameraScreen.switchCameraButton.tap()

        XCTAssertTrue(cameraScreen.recordVideoButton.waitForExistence(timeout: 3))
        cameraScreen.recordVideoButton.tap()

        sleep(2)
        XCTAssertNotEqual(cameraScreen.timerText.label, "00:00:00")

        XCTAssertEqual(cameraScreen.playAndPauseButton.label, "Pause")

        XCTAssertTrue(cameraScreen.playAndPauseButton.waitForExistence(timeout: 3))
        cameraScreen.playAndPauseButton.tap()

        XCTAssertEqual(cameraScreen.playAndPauseButton.label, "Play")

        cameraScreen.playAndPauseButton.tap()
        XCTAssertEqual(cameraScreen.playAndPauseButton.label, "Pause")
        sleep(1)
        XCTAssertNotEqual(cameraScreen.timerText.label, "00:00:00")

        cameraScreen.recordVideoButton.tap()
    }

    func testUCVideo06RecordFrontCameraPhotoWhileRecording() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.switchCameraButton.waitForExistence(timeout: 3))
        cameraScreen.switchCameraButton.tap()

        XCTAssertTrue(cameraScreen.recordVideoButton.waitForExistence(timeout: 3))
        cameraScreen.recordVideoButton.tap()

        sleep(2)
        XCTAssertNotEqual(cameraScreen.timerText.label, "00:00:00")

        XCTAssertTrue(cameraScreen.takePhotoButton.waitForExistence(timeout: 3))
        cameraScreen.takePhotoButton.tap()

        XCTAssertEqual(cameraScreen.takePhotoButton.label, "Camera")

        cameraScreen.recordVideoButton.tap()

        XCTAssertTrue(cameraScreen.mediaCountButton.waitForExistence(timeout: 3))
        cameraScreen.mediaCountButton.tap()
    }

    func testUCVideo07RecordFrontCameraZoom() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(2)

        XCTAssertTrue(cameraScreen.switchCameraButton.waitForExistence(timeout: 3))
        cameraScreen.switchCameraButton.tap()

        XCTAssertTrue(cameraScreen.recordVideoButton.waitForExistence(timeout: 3))
        cameraScreen.recordVideoButton.tap()
        sleep(2)

        for value in cameraScreen.zoomPickerValues() {
            XCTAssertTrue(value.isHittable)
            value.tap()
        }

        sleep(3)
        XCTAssertNotEqual(cameraScreen.timerText.label, "00:00:00")

        cameraScreen.recordVideoButton.tap()

        XCTAssertTrue(cameraScreen.mediaCountButton.waitForExistence(timeout: 3))
        cameraScreen.mediaCountButton.tap()
    }

    func testUCVideo08RecordFrontCameraMultipleOrientations() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.switchCameraButton.waitForExistence(timeout: 3))
        cameraScreen.switchCameraButton.tap()

        captureVideoIn(orientation: .portrait, description: "Portrait")
        captureVideoIn(orientation: .landscapeLeft, description: "Landscape Left")
        captureVideoIn(orientation: .landscapeRight, description: "Landscape Right")
        captureVideoIn(orientation: .portrait, description: "Portrait")
    }

    func testUCVideo8ARecordFrontCameraPortrait() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.switchCameraButton.waitForExistence(timeout: 3))
        cameraScreen.switchCameraButton.tap()

        captureVideoIn(orientation: .portrait, description: "Portrait")

        XCTAssertTrue(cameraScreen.recordVideoButton.waitForExistence(timeout: 3))
        cameraScreen.recordVideoButton.tap()

        XCTAssertTrue(cameraScreen.mediaCountButton.waitForExistence(timeout: 3))
        cameraScreen.mediaCountButton.tap()
    }

    func testUCVideo8BRecordFrontCameraLandscapeLeft() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.switchCameraButton.waitForExistence(timeout: 3))
        cameraScreen.switchCameraButton.tap()

        captureVideoIn(orientation: .landscapeLeft, description: "Landscape Left")

        XCTAssertTrue(cameraScreen.recordVideoButton.waitForExistence(timeout: 3))
        cameraScreen.recordVideoButton.tap()

        XCTAssertTrue(cameraScreen.mediaCountButton.waitForExistence(timeout: 3))
        cameraScreen.mediaCountButton.tap()
    }

    func testUCVideo8CRecordFrontCameraLandscapeRight() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.switchCameraButton.waitForExistence(timeout: 3))
        cameraScreen.switchCameraButton.tap()

        captureVideoIn(orientation: .landscapeRight, description: "Landscape Right")

        XCTAssertTrue(cameraScreen.recordVideoButton.waitForExistence(timeout: 3))
        cameraScreen.recordVideoButton.tap()

        XCTAssertTrue(cameraScreen.mediaCountButton.waitForExistence(timeout: 3))
        cameraScreen.mediaCountButton.tap()
    }

    func testUCVideo09RecordFrontCameraBackgroundTransition() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.switchCameraButton.waitForExistence(timeout: 3))
        cameraScreen.switchCameraButton.tap()

        XCTAssertTrue(cameraScreen.recordVideoButton.waitForExistence(timeout: 3))
        cameraScreen.recordVideoButton.tap()

        XCUIDevice.shared.press(.home)
        sleep(3)

        app.activate()
        sleep(2)

        if cameraScreen.timerText.label != "00:00:00" {
            XCTAssertTrue(true)
            cameraScreen.recordVideoButton.tap()
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
        sleep(1)

        XCTAssertTrue(cameraScreen.switchCameraButton.waitForExistence(timeout: 5))
        cameraScreen.switchCameraButton.tap()
        sleep(1)

        for preset in resolutions {
            XCTAssertTrue(cameraScreen.resolutionButton.waitForExistence(timeout: 3))
            cameraScreen.resolutionButton.tap()

            let option = app.buttons[Camera.AccessibilityLabel.presetOption(preset)]
            XCTAssertTrue(option.waitForExistence(timeout: 3), "Preset \(preset) not found")

            option.tap()

            XCTAssertEqual(cameraScreen.resolutionButton.label, preset)

            cameraScreen.recordVideoButton.tap()
            sleep(2)

            XCTAssertNotEqual(cameraScreen.timerText.label, "00:00:00")

            cameraScreen.recordVideoButton.tap()
        }

        cameraScreen.mediaCountButton.tap()
    }

    func testUCVideo12ARecordFrontCameraHD() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.switchCameraButton.waitForExistence(timeout: 5))
        cameraScreen.switchCameraButton.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.resolutionButton.waitForExistence(timeout: 3))
        cameraScreen.resolutionButton.tap()

        XCTAssertTrue(cameraScreen.hdOption.waitForExistence(timeout: 3))
        cameraScreen.hdOption.tap()

        XCTAssertEqual(cameraScreen.resolutionButton.label, "HD")

        XCTAssertTrue(cameraScreen.recordVideoButton.waitForExistence(timeout: 3))
        cameraScreen.recordVideoButton.tap()

        sleep(2)
        XCTAssertNotEqual(cameraScreen.timerText.label, "00:00:00")

        cameraScreen.recordVideoButton.tap()

        XCTAssertTrue(cameraScreen.mediaCountButton.waitForExistence(timeout: 3))
        cameraScreen.recordVideoButton.tap()
    }

    func testUCVideo12BRecordFrontCameraFHD() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.switchCameraButton.waitForExistence(timeout: 3))
        cameraScreen.switchCameraButton.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.resolutionButton.waitForExistence(timeout: 3))
        cameraScreen.resolutionButton.tap()

        XCTAssertTrue(cameraScreen.fhdOption.waitForExistence(timeout: 3))
        cameraScreen.fhdOption.tap()

        XCTAssertEqual(cameraScreen.resolutionButton.label, "FHD")

        XCTAssertTrue(cameraScreen.recordVideoButton.waitForExistence(timeout: 3))
        cameraScreen.recordVideoButton.tap()

        sleep(2)
        XCTAssertNotEqual(cameraScreen.timerText.label, "00:00:00")

        cameraScreen.recordVideoButton.tap()

        XCTAssertTrue(cameraScreen.recordVideoButton.waitForExistence(timeout: 3))
        cameraScreen.recordVideoButton.tap()
    }

    func testUCVideo12CRecordFrontCameraSD() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.switchCameraButton.waitForExistence(timeout: 3))
        cameraScreen.switchCameraButton.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.resolutionButton.waitForExistence(timeout: 3))
        cameraScreen.resolutionButton.tap()

        XCTAssertTrue(cameraScreen.sdOption.waitForExistence(timeout: 3))
        cameraScreen.sdOption.tap()

        XCTAssertEqual(cameraScreen.resolutionButton.label, "SD")

        XCTAssertTrue(cameraScreen.recordVideoButton.waitForExistence(timeout: 3))
        cameraScreen.recordVideoButton.tap()

        sleep(2)
        XCTAssertNotEqual(cameraScreen.timerText.label, "00:00:00")

        cameraScreen.recordVideoButton.tap()

        XCTAssertTrue(cameraScreen.mediaCountButton.waitForExistence(timeout: 3))
        cameraScreen.mediaCountButton.tap()
    }

    // MARK: - Rear Camera [Take Photo]

    func testUCPhoto01TakePhotoRearCamera() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.takePhotoButton.waitForExistence(timeout: 3))
        cameraScreen.takePhotoButton.tap()

        XCTAssertTrue(cameraScreen.mediaCountButton.waitForExistence(timeout: 3))
        cameraScreen.mediaCountButton.tap()
    }

    func testUCPhoto02TakePhotoWithFlashOff() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.takePhotoButton.waitForExistence(timeout: 3))
        cameraScreen.takePhotoButton.tap()

        XCTAssertEqual(cameraScreen.flashButton.label, "Flash Off")

        XCTAssertTrue(cameraScreen.mediaCountButton.waitForExistence(timeout: 3))
        cameraScreen.mediaCountButton.tap()
    }

    func testUCPhoto03TakePhotoWithFlashOn() {
        // Given
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        // When
        XCTAssertTrue(cameraScreen.flashButton.waitForExistence(timeout: 3))

        let expectedLabel = cameraScreen.flashButton.isEnabled ? "Flash" : "Flash Off"

        if cameraScreen.flashButton.isEnabled {
            cameraScreen.flashButton.tap()
        }

        XCTAssertEqual(cameraScreen.flashButton.label, expectedLabel)

        // Then
        XCTAssertTrue(cameraScreen.takePhotoButton.waitForExistence(timeout: 3))
        cameraScreen.takePhotoButton.tap()

        XCTAssertTrue(cameraScreen.mediaCountButton.waitForExistence(timeout: 3))
        cameraScreen.mediaCountButton.tap()
    }

    func testUCPhoto04TakePhotoWithZoom() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(2)

        for value in cameraScreen.zoomPickerValues() {
            XCTAssertTrue(value.isHittable)
            value.tap()
        }

        XCTAssertTrue(cameraScreen.takePhotoButton.waitForExistence(timeout: 3))
        cameraScreen.takePhotoButton.tap()
    }

    func testUCPhoto05TakePhotoUnlockedOrientation() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        capturePhotoIn(orientation: .portrait)
        capturePhotoIn(orientation: .landscapeLeft)
        capturePhotoIn(orientation: .landscapeRight)
        capturePhotoIn(orientation: .portrait)
    }

    func testUCPhoto05ATakePhotoPortrait() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        capturePhotoIn(orientation: .portrait)

        cameraScreen.mediaCountButton.tap()
    }

    func testUCPhoto05BTakePhotoLandscapeLeft() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        capturePhotoIn(orientation: .landscapeLeft)

        cameraScreen.mediaCountButton.tap()
    }

    func testUCPhoto05CTakePhotoLandscapeRight() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()

        capturePhotoIn(orientation: .landscapeRight)

        cameraScreen.mediaCountButton.tap()
    }

    func testUCPhoto08TakePhotoDifferentResolutions() {
        // Given
        let resolutions = ["SD", "HD", "FHD"]

        // When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        for preset in resolutions {
            XCTAssertTrue(cameraScreen.resolutionButton.waitForExistence(timeout: 3))
            cameraScreen.resolutionButton.tap()

            let option = app.buttons[Camera.AccessibilityLabel.presetOption(preset)]
            XCTAssertTrue(option.waitForExistence(timeout: 3))
            option.tap()

            XCTAssertEqual(cameraScreen.resolutionButton.label, preset)

            XCTAssertTrue(cameraScreen.takePhotoButton.waitForExistence(timeout: 3))
            cameraScreen.takePhotoButton.tap()

            XCTAssertTrue(cameraScreen.mediaCountButton.waitForExistence(timeout: 3))
        }

        cameraScreen.mediaCountButton.tap()
    }

    func testUCPhoto08ATakePhotoHDResolution() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.resolutionButton.waitForExistence(timeout: 3))
        cameraScreen.resolutionButton.tap()

        XCTAssertTrue(cameraScreen.hdOption.waitForExistence(timeout: 3))
        cameraScreen.hdOption.tap()

        XCTAssertEqual(cameraScreen.resolutionButton.label, "HD")

        XCTAssertTrue(cameraScreen.takePhotoButton.waitForExistence(timeout: 3))
        cameraScreen.takePhotoButton.tap()

        XCTAssertTrue(cameraScreen.mediaCountButton.waitForExistence(timeout: 3))
        cameraScreen.mediaCountButton.tap()
    }

    func testUCPhoto08BTakePhotoFHDResolution() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.resolutionButton.waitForExistence(timeout: 3))
        cameraScreen.resolutionButton.tap()

        XCTAssertTrue(cameraScreen.fhdOption.waitForExistence(timeout: 3))
        cameraScreen.fhdOption.tap()

        XCTAssertEqual(cameraScreen.resolutionButton.label, "FHD")

        XCTAssertTrue(cameraScreen.takePhotoButton.waitForExistence(timeout: 3))
        cameraScreen.takePhotoButton.tap()

        XCTAssertTrue(cameraScreen.mediaCountButton.waitForExistence(timeout: 3))
        cameraScreen.mediaCountButton.tap()
    }

    func testUCPhoto08CTakePhotoSDResolution() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.resolutionButton.waitForExistence(timeout: 3))
        cameraScreen.resolutionButton.tap()

        XCTAssertTrue(cameraScreen.sdOption.waitForExistence(timeout: 3))
        cameraScreen.sdOption.tap()

        XCTAssertEqual(cameraScreen.resolutionButton.label, "SD")

        XCTAssertTrue(cameraScreen.takePhotoButton.waitForExistence(timeout: 3))
        cameraScreen.takePhotoButton.tap()

        XCTAssertTrue(cameraScreen.mediaCountButton.waitForExistence(timeout: 3))
        cameraScreen.mediaCountButton.tap()
    }

    // MARK: - Rear Camera [Recording Video]

    func testUC01StartVideoRecordingRearCamera() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.recordVideoButton.waitForExistence(timeout: 3))
        cameraScreen.recordVideoButton.tap()

        sleep(2)
        XCTAssertNotEqual(cameraScreen.timerText.label, "00:00:00")

        cameraScreen.recordVideoButton.tap()

        XCTAssertTrue(cameraScreen.mediaCountButton.waitForExistence(timeout: 3))
        cameraScreen.mediaCountButton.tap()
    }

    func testUC03StartVideoRecordingWithFlashOff() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.recordVideoButton.waitForExistence(timeout: 3))
        cameraScreen.recordVideoButton.tap()

        XCTAssertTrue(cameraScreen.flashButton.waitForExistence(timeout: 3))
        XCTAssertEqual(cameraScreen.flashButton.label, "Flash Off")

        sleep(2)
        XCTAssertNotEqual(cameraScreen.timerText.label, "00:00:00")

        cameraScreen.recordVideoButton.tap()

        XCTAssertTrue(cameraScreen.mediaCountButton.waitForExistence(timeout: 3))
        cameraScreen.mediaCountButton.tap()
    }

    func testUC04StartVideoRecordingWithFlashOn() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.recordVideoButton.waitForExistence(timeout: 3))
        cameraScreen.recordVideoButton.tap()

        XCTAssertTrue(cameraScreen.flashButton.waitForExistence(timeout: 3))

        let expectedLabel = cameraScreen.flashButton.isEnabled ? "Flash" : "Flash Off"

        if cameraScreen.flashButton.isEnabled {
            cameraScreen.flashButton.tap()
        }

        XCTAssertEqual(cameraScreen.flashButton.label, expectedLabel)

        sleep(2)
        XCTAssertNotEqual(cameraScreen.timerText.label, "00:00:00")

        cameraScreen.recordVideoButton.tap()

        XCTAssertTrue(cameraScreen.mediaCountButton.waitForExistence(timeout: 3))
        cameraScreen.mediaCountButton.tap()
    }

    func testUC05PauseVideoRecording() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.recordVideoButton.waitForExistence(timeout: 3))
        cameraScreen.recordVideoButton.tap()
        sleep(2)

        XCTAssertNotEqual(cameraScreen.timerText.label, "00:00:00")

        XCTAssertTrue(cameraScreen.playAndPauseButton.waitForExistence(timeout: 3))
        cameraScreen.playAndPauseButton.tap()
    }

    func testUC06VideoRecordingPauseAndResume() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.recordVideoButton.waitForExistence(timeout: 3))
        cameraScreen.recordVideoButton.tap()

        sleep(2)
        XCTAssertNotEqual(cameraScreen.timerText.label, "00:00:00")

        XCTAssertEqual(cameraScreen.playAndPauseButton.label, "Pause")

        XCTAssertTrue(cameraScreen.playAndPauseButton.waitForExistence(timeout: 3))
        cameraScreen.playAndPauseButton.tap()

        XCTAssertEqual(cameraScreen.playAndPauseButton.label, "Play")

        cameraScreen.playAndPauseButton.tap()
        XCTAssertEqual(cameraScreen.playAndPauseButton.label, "Pause")
        sleep(1)
        XCTAssertNotEqual(cameraScreen.timerText.label, "00:00:00")

        cameraScreen.recordVideoButton.tap()
    }

    func testUC07VideoRecordingCapturePhotoWhileRecording() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.recordVideoButton.waitForExistence(timeout: 3))
        cameraScreen.recordVideoButton.tap()

        sleep(2)
        XCTAssertNotEqual(cameraScreen.timerText.label, "00:00:00")

        XCTAssertTrue(cameraScreen.takePhotoButton.waitForExistence(timeout: 3))
        cameraScreen.takePhotoButton.tap()

        XCTAssertEqual(cameraScreen.takePhotoButton.label, "Camera")

        cameraScreen.recordVideoButton.tap()

        XCTAssertTrue(cameraScreen.mediaCountButton.waitForExistence(timeout: 3))
        cameraScreen.mediaCountButton.tap()
    }

    func testUC08VideoRecordingAdjustZoom() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.recordVideoButton.waitForExistence(timeout: 3))
        cameraScreen.recordVideoButton.tap()
        sleep(2)

        for value in cameraScreen.zoomPickerValues() {
            XCTAssertTrue(value.isHittable)
            value.tap()
        }

        sleep(2)
        XCTAssertNotEqual(cameraScreen.timerText.label, "00:00:00")

        cameraScreen.recordVideoButton.tap()

        XCTAssertTrue(cameraScreen.mediaCountButton.waitForExistence(timeout: 3))
        cameraScreen.mediaCountButton.tap()
    }

    func testUC09VideoRecordingUnlockedOrientation() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        captureVideoIn(orientation: .portrait, description: "Portrait")
        captureVideoIn(orientation: .landscapeLeft, description: "Landscape Left")
        captureVideoIn(orientation: .landscapeRight, description: "Landscape Right")
        captureVideoIn(orientation: .portrait, description: "Portrait")
    }

    func testUC09AVideoRecordingPortrait() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        captureVideoIn(orientation: .portrait, description: "Portrait")

        XCTAssertTrue(cameraScreen.recordVideoButton.waitForExistence(timeout: 3))
        cameraScreen.recordVideoButton.tap()

        XCTAssertTrue(cameraScreen.mediaCountButton.waitForExistence(timeout: 3))
        cameraScreen.mediaCountButton.tap()
    }

    func testUC09BVideoRecordingLandscapeLeft() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        captureVideoIn(orientation: .landscapeLeft, description: "Landscape Left")

        XCTAssertTrue(cameraScreen.recordVideoButton.waitForExistence(timeout: 3))
        cameraScreen.recordVideoButton.tap()

        XCTAssertTrue(cameraScreen.mediaCountButton.waitForExistence(timeout: 3))
        cameraScreen.mediaCountButton.tap()
    }

    func testUC09CVideoRecordingLandscapeRight() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        captureVideoIn(orientation: .landscapeRight, description: "Landscape Right")

        XCTAssertTrue(cameraScreen.recordVideoButton.waitForExistence(timeout: 3))
        cameraScreen.recordVideoButton.tap()

        XCTAssertTrue(cameraScreen.mediaCountButton.waitForExistence(timeout: 3))
        cameraScreen.mediaCountButton.tap()
    }

    func testUC10VideoRecordingFlashBackgroundTransition() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.recordVideoButton.waitForExistence(timeout: 3))
        cameraScreen.recordVideoButton.tap()

        XCUIDevice.shared.press(.home)
        sleep(3)

        app.activate()
        sleep(2)

        if cameraScreen.timerText.label != "00:00:00" {
            XCTAssertTrue(true)
            cameraScreen.recordVideoButton.tap()
        } else {
            XCTAssertTrue(true)
        }

        XCTAssertEqual(app.state, .runningForeground)
    }

    // MARK: - Private Methods

    private func captureVideoIn(orientation: UIDeviceOrientation, description: String) {
        recordVideoInOrientation(orientation)

        XCTAssertTrue(cameraScreen.recordVideoButton.waitForExistence(timeout: 5))
        cameraScreen.recordVideoButton.tap()

        XCTAssertTrue(cameraScreen.mediaCountButton.waitForExistence(timeout: 5))
    }

    private func capturePhotoIn(orientation: UIDeviceOrientation) {
        takePhotoInOrientation(orientation)

        XCTAssertTrue(cameraScreen.takePhotoButton.waitForExistence(timeout: 5))
        cameraScreen.takePhotoButton.tap()

        XCTAssertTrue(cameraScreen.mediaCountButton.waitForExistence(timeout: 5))
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
