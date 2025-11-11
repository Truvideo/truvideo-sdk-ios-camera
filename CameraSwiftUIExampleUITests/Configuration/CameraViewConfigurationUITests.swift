//
// Copyright © 2025 TruVideo. All rights reserved.
//

import UIKit
import XCTest

@testable import TruvideoSdkCamera

final class CameraViewConfigurationUITests: XCTestCase {
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

    // MARK: - Configuration Flash Mode Tests

    func testUC01TruvideoSdkCameraConfigurationFlashOff() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.configureCamera.waitForExistence(timeout: 3))
        cameraScreen.configureCamera.tap()

        XCTAssertTrue(cameraScreen.flashModeOff.waitForExistence(timeout: 3))

        XCTAssertTrue(cameraScreen.cameraSDK.waitForExistence(timeout: 3))
        cameraScreen.cameraSDK.tap()

        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertEqual(cameraScreen.flashButton.label, "Flash Off")

        XCTAssertTrue(cameraScreen.takePhotoButton.waitForExistence(timeout: 3))
        cameraScreen.takePhotoButton.tap()

        XCTAssertTrue(cameraScreen.mediaCountButton.waitForExistence(timeout: 3))
        cameraScreen.mediaCountButton.tap()
    }

    func testUC02TruvideoSdkCameraConfigurationFlashOn() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.configureCamera.waitForExistence(timeout: 3))
        cameraScreen.configureCamera.tap()

        XCTAssertTrue(cameraScreen.flashModeOn.waitForExistence(timeout: 3))
        cameraScreen.flashModeOn.tap()

        XCTAssertTrue(cameraScreen.cameraSDK.waitForExistence(timeout: 3))
        cameraScreen.cameraSDK.tap()

        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertEqual(cameraScreen.flashButton.label, "Flash")

        XCTAssertTrue(cameraScreen.takePhotoButton.waitForExistence(timeout: 3))
        cameraScreen.takePhotoButton.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.mediaCountButton.waitForExistence(timeout: 3))
        cameraScreen.mediaCountButton.tap()
    }

    // MARK: - Configuration Lens Facing Tests

    func testUC01TruvideoSdkCameraConfigurationLensFacingBack() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.configureCamera.waitForExistence(timeout: 3))
        cameraScreen.configureCamera.tap()

        XCTAssertTrue(cameraScreen.lensFacingBack.waitForExistence(timeout: 3))

        XCTAssertTrue(cameraScreen.cameraSDK.waitForExistence(timeout: 3))
        cameraScreen.cameraSDK.tap()

        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.takePhotoButton.waitForExistence(timeout: 3))
        cameraScreen.takePhotoButton.tap()

        XCTAssertTrue(cameraScreen.mediaCountButton.waitForExistence(timeout: 3))
        cameraScreen.mediaCountButton.tap()
    }

    func testUC02TruvideoSdkCameraConfigurationLensFacingFront() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.configureCamera.waitForExistence(timeout: 3))
        cameraScreen.configureCamera.tap()

        XCTAssertTrue(cameraScreen.lensFacingFront.waitForExistence(timeout: 3))
        cameraScreen.lensFacingFront.tap()

        XCTAssertTrue(cameraScreen.cameraSDK.waitForExistence(timeout: 3))
        cameraScreen.cameraSDK.tap()

        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.takePhotoButton.waitForExistence(timeout: 3))
        cameraScreen.takePhotoButton.tap()

        XCTAssertTrue(cameraScreen.mediaCountButton.waitForExistence(timeout: 3))
        cameraScreen.mediaCountButton.tap()
    }

    // MARK: - Configuration Mode Tests

    func testUC01TruvideoSdkCameraConfigurationModeVideoandPictureSeparateLimits() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.configureCamera.waitForExistence(timeout: 3))
        cameraScreen.configureCamera.tap()

        app.scrollToElement(cameraScreen.limit)

        XCTAssertTrue(cameraScreen.captureMode.waitForExistence(timeout: 3))
        XCTAssertEqual(cameraScreen.captureMode.label, "Mode, Photo & Video")

        XCTAssertTrue(cameraScreen.limit.waitForExistence(timeout: 3))
        cameraScreen.limit.tap()

        XCTAssertEqual(cameraScreen.limit.label, "Limit, Unlimited")

        cameraScreen.limited.tap()

        XCTAssertEqual(cameraScreen.limit.label, "Limit, Limited")

        XCTAssertTrue(cameraScreen.cameraSDK.waitForExistence(timeout: 3))
        cameraScreen.cameraSDK.tap()

        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.mediaCountButton.waitForExistence(timeout: 3))
        XCTAssertEqual(cameraScreen.mediaCountButton.label, "0/1, 0/1")

        XCTAssertTrue(cameraScreen.takePhotoButton.waitForExistence(timeout: 3))
        cameraScreen.takePhotoButton.tap()

        XCTAssertTrue(cameraScreen.mediaCountButton.waitForExistence(timeout: 2))
        XCTAssertEqual(cameraScreen.mediaCountButton.label, "0/1, 1/1")

        XCTAssertTrue(cameraScreen.recordVideoButton.waitForExistence(timeout: 3))
        cameraScreen.recordVideoButton.tap()
        sleep(4)

        XCTAssertNotEqual(cameraScreen.timerText.label, "00:00:00")
        cameraScreen.recordVideoButton.tap()

        XCTAssertEqual(cameraScreen.mediaCountButton.label, "1/1, 1/1")

        cameraScreen.recordVideoButton.tap()
        XCTAssertEqual(cameraScreen.timerText.label, "00:00:00")

        XCTAssertTrue(cameraScreen.errorMessage.waitForExistence(timeout: 3))
        XCTAssertEqual(cameraScreen.errorMessage.label, "Error Message View")
    }

    func testUC01ATruvideoSdkCameraConfigurationModeVideoandPicture() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.configureCamera.waitForExistence(timeout: 3))
        cameraScreen.configureCamera.tap()

        app.scrollToElement(cameraScreen.limit)

        XCTAssertTrue(cameraScreen.captureMode.waitForExistence(timeout: 3))
        XCTAssertEqual(cameraScreen.captureMode.label, "Mode, Photo & Video")

        XCTAssertTrue(cameraScreen.limit.waitForExistence(timeout: 3))
        XCTAssertEqual(cameraScreen.limit.label, "Limit, Unlimited")

        XCTAssertTrue(cameraScreen.cameraSDK.waitForExistence(timeout: 3))
        cameraScreen.cameraSDK.tap()

        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.takePhotoButton.waitForExistence(timeout: 3))
        cameraScreen.takePhotoButton.tap()

        XCTAssertTrue(cameraScreen.recordVideoButton.waitForExistence(timeout: 3))
        cameraScreen.recordVideoButton.tap()

        sleep(4)
        XCTAssertNotEqual(cameraScreen.timerText.label, "00:00:00")
        cameraScreen.recordVideoButton.tap()

        cameraScreen.recordVideoButton.tap()
    }

    func testUC01BTruvideoSdkCameraConfigurationModeVideoandPictureFixedDuration() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.configureCamera.waitForExistence(timeout: 3))
        cameraScreen.configureCamera.tap()

        app.scrollToElement(cameraScreen.limit)

        XCTAssertTrue(cameraScreen.captureMode.waitForExistence(timeout: 3))
        XCTAssertEqual(cameraScreen.captureMode.label, "Mode, Photo & Video")

        XCTAssertTrue(cameraScreen.limit.waitForExistence(timeout: 3))
        XCTAssertEqual(cameraScreen.limit.label, "Limit, Unlimited")

        XCTAssertTrue(cameraScreen.durationVideo.waitForExistence(timeout: 3))
        clearText(in: cameraScreen.durationVideo, app: app)
        typeNumber("8", app: app)

        XCTAssertTrue(cameraScreen.cameraSDK.waitForExistence(timeout: 3))
        cameraScreen.cameraSDK.tap()

        cameraScreen.openCamera.tap()
        sleep(2)

        let initial = cameraScreen.timerText.label

        XCTAssertTrue(cameraScreen.recordVideoButton.waitForExistence(timeout: 3))
        XCTAssertEqual(initial, "00:00:00")
        cameraScreen.recordVideoButton.tap()

        sleep(8)

        let updated = cameraScreen.remainingTimeText.label
        XCTAssertEqual(updated, "00:00:08")

        XCTAssertTrue(cameraScreen.mediaCountButton.exists)
        cameraScreen.mediaCountButton.tap()
    }

    func testUC02TruvideoSdkCameraConfigurationModePicture() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.configureCamera.waitForExistence(timeout: 3))
        cameraScreen.configureCamera.tap()

        app.scrollToElement(cameraScreen.limit)

        XCTAssertTrue(cameraScreen.captureMode.waitForExistence(timeout: 3))
        cameraScreen.captureMode.tap()

        XCTAssertEqual(cameraScreen.captureMode.label, "Mode, Photo & Video")

        cameraScreen.photoOnly.tap()
        XCTAssertEqual(cameraScreen.captureMode.label, "Mode, Photo Only")

        XCTAssertEqual(cameraScreen.limit.label, "Limit, Unlimited")

        XCTAssertTrue(cameraScreen.cameraSDK.waitForExistence(timeout: 3))
        cameraScreen.cameraSDK.tap()

        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.takePhotoButton.waitForExistence(timeout: 3))
        cameraScreen.takePhotoButton.tap()

        XCTAssertTrue(cameraScreen.recordVideoButton.waitForExistence(timeout: 3))
        cameraScreen.recordVideoButton.tap()

        sleep(2)
        XCTAssertEqual(cameraScreen.timerText.label, "00:00:00")

        XCTAssertTrue(cameraScreen.errorMessage.waitForExistence(timeout: 3))
        XCTAssertEqual(cameraScreen.errorMessage.label, "Error Message View")
    }

    func testUC03TruvideoSdkCameraConfigurationModeSinglePicture() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.configureCamera.waitForExistence(timeout: 3))
        cameraScreen.configureCamera.tap()

        app.scrollToElement(cameraScreen.limit)

        XCTAssertTrue(cameraScreen.captureMode.waitForExistence(timeout: 3))
        cameraScreen.captureMode.tap()
        XCTAssertEqual(cameraScreen.captureMode.label, "Mode, Photo & Video")

        cameraScreen.photoOnly.tap()
        XCTAssertEqual(cameraScreen.captureMode.label, "Mode, Photo Only")

        XCTAssertTrue(cameraScreen.limit.waitForExistence(timeout: 3))
        cameraScreen.limit.tap()

        cameraScreen.single.tap()

        XCTAssertTrue(cameraScreen.cameraSDK.waitForExistence(timeout: 3))
        cameraScreen.cameraSDK.tap()

        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.mediaCountButton.waitForExistence(timeout: 3))
        XCTAssertEqual(cameraScreen.mediaCountButton.label, "0/1")

        XCTAssertTrue(cameraScreen.takePhotoButton.waitForExistence(timeout: 3))
        cameraScreen.takePhotoButton.tap()

        XCTAssertTrue(cameraScreen.mediaCountButton.waitForExistence(timeout: 3))
        XCTAssertEqual(cameraScreen.mediaCountButton.label, "1/1")

        cameraScreen.takePhotoButton.tap()

        XCTAssertTrue(cameraScreen.errorMessage.waitForExistence(timeout: 3))
        XCTAssertEqual(cameraScreen.errorMessage.label, "Error Message View")
    }

    func testUC04TruvideoSdkCameraConfigurationModeSingleVideo() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.configureCamera.waitForExistence(timeout: 3))
        cameraScreen.configureCamera.tap()

        app.scrollToElement(cameraScreen.limit)

        XCTAssertTrue(cameraScreen.captureMode.waitForExistence(timeout: 3))
        cameraScreen.captureMode.tap()
        XCTAssertEqual(cameraScreen.captureMode.label, "Mode, Photo & Video")

        cameraScreen.videoOnly.tap()
        XCTAssertEqual(cameraScreen.captureMode.label, "Mode, Video Only")

        XCTAssertTrue(cameraScreen.limit.waitForExistence(timeout: 3))
        cameraScreen.limit.tap()

        cameraScreen.single.tap()

        XCTAssertTrue(cameraScreen.cameraSDK.waitForExistence(timeout: 3))
        cameraScreen.cameraSDK.tap()

        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.mediaCountButton.waitForExistence(timeout: 3))
        XCTAssertEqual(cameraScreen.mediaCountButton.label, "0/1")

        XCTAssertTrue(cameraScreen.recordVideoButton.waitForExistence(timeout: 3))
        cameraScreen.recordVideoButton.tap()

        sleep(2)
        XCTAssertNotEqual(cameraScreen.timerText.label, "00:00:00")

        cameraScreen.recordVideoButton.tap()

        XCTAssertTrue(cameraScreen.mediaCountButton.waitForExistence(timeout: 3))
        XCTAssertEqual(cameraScreen.mediaCountButton.label, "1/1")

        cameraScreen.recordVideoButton.tap()
        XCTAssertEqual(cameraScreen.timerText.label, "00:00:00")

        XCTAssertTrue(cameraScreen.errorMessage.waitForExistence(timeout: 3))
        XCTAssertEqual(cameraScreen.errorMessage.label, "Error Message View")
    }

    func testUC04ATruvideoSdkCameraConfigurationModeSingleVideoFixedDuration() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.configureCamera.waitForExistence(timeout: 3))
        cameraScreen.configureCamera.tap()

        app.scrollToElement(cameraScreen.limit)

        XCTAssertTrue(cameraScreen.captureMode.waitForExistence(timeout: 3))
        cameraScreen.captureMode.tap()
        XCTAssertEqual(cameraScreen.captureMode.label, "Mode, Photo & Video")

        cameraScreen.videoOnly.tap()
        XCTAssertEqual(cameraScreen.captureMode.label, "Mode, Video Only")

        XCTAssertTrue(cameraScreen.limit.waitForExistence(timeout: 3))
        cameraScreen.limit.tap()

        cameraScreen.single.tap()

        XCTAssertTrue(cameraScreen.durationVideo.waitForExistence(timeout: 3))
        clearText(in: cameraScreen.durationVideo, app: app)
        typeNumber("8", app: app)

        XCTAssertTrue(cameraScreen.cameraSDK.waitForExistence(timeout: 3))
        cameraScreen.cameraSDK.tap()

        cameraScreen.openCamera.tap()
        sleep(2)

        XCTAssertTrue(cameraScreen.mediaCountButton.waitForExistence(timeout: 3))
        XCTAssertEqual(cameraScreen.mediaCountButton.label, "0/1")

        let initial = cameraScreen.timerText.label

        XCTAssertTrue(cameraScreen.recordVideoButton.waitForExistence(timeout: 3))
        XCTAssertEqual(initial, "00:00:00")
        cameraScreen.recordVideoButton.tap()

        sleep(8)

        let updated = cameraScreen.remainingTimeText.label
        XCTAssertEqual(updated, "00:00:08")

        XCTAssertTrue(cameraScreen.mediaCountButton.waitForExistence(timeout: 3))
        XCTAssertEqual(cameraScreen.mediaCountButton.label, "1/1")

        XCTAssertTrue(cameraScreen.mediaCountButton.exists)
        cameraScreen.mediaCountButton.tap()
    }

    func testUC05TruvideoSdkCameraConfigurationModeSingleVideoOrPicture() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.configureCamera.waitForExistence(timeout: 3))
        cameraScreen.configureCamera.tap()

        app.scrollToElement(cameraScreen.limit)

        XCTAssertTrue(cameraScreen.captureMode.waitForExistence(timeout: 3))
        XCTAssertEqual(cameraScreen.captureMode.label, "Mode, Photo & Video")

        XCTAssertTrue(cameraScreen.limit.waitForExistence(timeout: 3))
        cameraScreen.limit.tap()

        cameraScreen.single.tap()

        XCTAssertTrue(cameraScreen.cameraSDK.waitForExistence(timeout: 3))
        cameraScreen.cameraSDK.tap()

        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.mediaCountButton.waitForExistence(timeout: 3))
        XCTAssertEqual(cameraScreen.mediaCountButton.label, "0/1")

        XCTAssertTrue(cameraScreen.takePhotoButton.waitForExistence(timeout: 3))
        cameraScreen.takePhotoButton.tap()

        XCTAssertEqual(cameraScreen.mediaCountButton.label, "1/1")

        XCTAssertTrue(cameraScreen.recordVideoButton.waitForExistence(timeout: 3))
        cameraScreen.recordVideoButton.tap()

        XCTAssertEqual(cameraScreen.timerText.label, "00:00:00")

        XCTAssertTrue(cameraScreen.errorMessage.waitForExistence(timeout: 3))
        XCTAssertEqual(cameraScreen.errorMessage.label, "Error Message View")
    }

    func testUC06TruvideoSdkCameraConfigurationModeVideo() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.configureCamera.waitForExistence(timeout: 3))
        cameraScreen.configureCamera.tap()

        app.scrollToElement(cameraScreen.limit)

        XCTAssertTrue(cameraScreen.captureMode.waitForExistence(timeout: 3))
        cameraScreen.captureMode.tap()
        XCTAssertEqual(cameraScreen.captureMode.label, "Mode, Photo & Video")

        cameraScreen.videoOnly.tap()
        XCTAssertEqual(cameraScreen.captureMode.label, "Mode, Video Only")

        XCTAssertTrue(cameraScreen.cameraSDK.waitForExistence(timeout: 3))
        cameraScreen.cameraSDK.tap()

        cameraScreen.openCamera.tap()
        sleep(1)

        XCTAssertTrue(cameraScreen.recordVideoButton.waitForExistence(timeout: 3))
        cameraScreen.recordVideoButton.tap()

        sleep(4)
        XCTAssertNotEqual(cameraScreen.timerText.label, "00:00:00")

        cameraScreen.recordVideoButton.tap()

        XCTAssertTrue(cameraScreen.takePhotoButton.waitForExistence(timeout: 3))
        cameraScreen.takePhotoButton.tap()

        XCTAssertTrue(cameraScreen.errorMessage.waitForExistence(timeout: 3))
        XCTAssertEqual(cameraScreen.errorMessage.label, "Error Message View")
    }

    func testUC06ATruvideoSdkCameraConfigurationModeVideoFixedDuration() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.configureCamera.waitForExistence(timeout: 3))
        cameraScreen.configureCamera.tap()

        app.scrollToElement(cameraScreen.limit)

        XCTAssertTrue(cameraScreen.captureMode.waitForExistence(timeout: 3))
        cameraScreen.captureMode.tap()
        XCTAssertEqual(cameraScreen.captureMode.label, "Mode, Photo & Video")

        cameraScreen.videoOnly.tap()
        XCTAssertEqual(cameraScreen.captureMode.label, "Mode, Video Only")

        XCTAssertTrue(cameraScreen.durationVideo.waitForExistence(timeout: 3))
        clearText(in: cameraScreen.durationVideo, app: app)
        typeNumber("8", app: app)

        XCTAssertTrue(cameraScreen.cameraSDK.waitForExistence(timeout: 3))
        cameraScreen.cameraSDK.tap()

        cameraScreen.openCamera.tap()
        sleep(2)

        let initial = cameraScreen.timerText.label

        XCTAssertTrue(cameraScreen.recordVideoButton.waitForExistence(timeout: 3))
        XCTAssertEqual(initial, "00:00:00")
        cameraScreen.recordVideoButton.tap()

        sleep(8)

        let updated = cameraScreen.remainingTimeText.label
        XCTAssertEqual(updated, "00:00:08")

        XCTAssertTrue(cameraScreen.mediaCountButton.exists)
        cameraScreen.mediaCountButton.tap()
    }
}

extension XCUIApplication {
    func scrollToElement(_ element: XCUIElement, maxScrolls: Int = 5) {
        var attempts = 0
        while !element.exists, attempts < maxScrolls {
            swipeUp()
            attempts += 1
        }
    }
}

extension XCTestCase {
    func clearText(in element: XCUIElement, app: XCUIApplication) {
        guard element.exists else { return }
        element.tap()

        let selectAll = app.menuItems["Select All"]
        if selectAll.waitForExistence(timeout: 0.5) {
            selectAll.tap()
            app.keys["delete"].tap()
            return
        }

        if let currentValue = element.value as? String, !currentValue.isEmpty {
            let deleteKey = app.keys["delete"]
            if deleteKey.exists {
                for _ in 0 ..< currentValue.count {
                    deleteKey.tap()
                }
            } else {
                element.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentValue.count))
            }
        }

        UIPasteboard.general.string = ""
        element.doubleTap()
    }

    func typeNumber(_ number: String, app: XCUIApplication) {
        for digit in number {
            let key = app.keys[String(digit)]
            if key.waitForExistence(timeout: 0.2) {
                key.tap()
            } else {
                app.typeText(String(digit))
            }
        }
    }
}
