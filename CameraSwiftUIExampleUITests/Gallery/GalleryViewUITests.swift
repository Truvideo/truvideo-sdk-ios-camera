//
// Copyright © 2025 TruVideo. All rights reserved.
//

import XCTest

@testable import TruvideoSdkCamera

final class GalleryViewUITests: XCTestCase {
    private var app: XCUIApplication!
    private var cameraScreen: CameraScreen!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        cameraScreen = CameraScreen(app: app)
    }
    
    // MARK: - Gallery
    
    func testUCGalleryCameraOrientationUnlocked() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.takePhoto.waitForExistence(timeout: 5))
        cameraScreen.takePhoto.tap()
        
        XCTAssertTrue(cameraScreen.mediaCount.waitForExistence(timeout: 3))
        cameraScreen.mediaCount.tap()
        
        XCTAssertTrue(cameraScreen.galleryView.waitForExistence(timeout: 3))
        XCTAssertTrue(cameraScreen.galleryGrid.waitForExistence(timeout: 3))
        XCTAssertTrue(cameraScreen.firstPhoto.waitForExistence(timeout: 3))
        cameraScreen.firstPhoto.tap()
        
        XCUIDevice.shared.orientation = .portrait
        sleep(1)
        
        XCUIDevice.shared.orientation = .landscapeLeft
        sleep(1)
        
        XCUIDevice.shared.orientation = .landscapeRight
        sleep(1)
        
        XCUIDevice.shared.orientation = .portrait
        sleep(1)
    }

    func testUCGalleryDeleteFirstFile() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.takePhoto.waitForExistence(timeout: 5))
        cameraScreen.takePhoto.tap()
        sleep(1)
        cameraScreen.takePhoto.tap()
        
        XCTAssertTrue(cameraScreen.mediaCount.waitForExistence(timeout: 3))
        cameraScreen.mediaCount.tap()
        
        XCTAssertTrue(cameraScreen.galleryView.waitForExistence(timeout: 3))
        XCTAssertTrue(cameraScreen.galleryGrid.waitForExistence(timeout: 3))
        XCTAssertTrue(cameraScreen.firstPhoto.waitForExistence(timeout: 3))
        cameraScreen.firstPhoto.tap()
        
        XCTAssertTrue(cameraScreen.closeButton.waitForExistence(timeout: 5))
        XCTAssertTrue(cameraScreen.deleteButton.waitForExistence(timeout: 5))
        
        cameraScreen.deleteButton.tap()
        sleep(1)
        
        cameraScreen.closeButton.tap()
        
        cameraScreen.firstPhoto.tap()
        cameraScreen.deleteButton.tap()
        sleep(1)
    }
    
    func testUCGalleryDeleteLastFile() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.takePhoto.waitForExistence(timeout: 5))
        cameraScreen.takePhoto.tap()
        sleep(1)
        cameraScreen.takePhoto.tap()
        
        XCTAssertTrue(cameraScreen.mediaCount.waitForExistence(timeout: 3))
        cameraScreen.mediaCount.tap()
        
        XCTAssertTrue(cameraScreen.galleryView.waitForExistence(timeout: 3))
        XCTAssertTrue(cameraScreen.galleryGrid.waitForExistence(timeout: 3))
        XCTAssertTrue(cameraScreen.secondPhoto.waitForExistence(timeout: 3))
        cameraScreen.secondPhoto.tap()
        
        XCTAssertTrue(cameraScreen.closeButton.waitForExistence(timeout: 5))
        XCTAssertTrue(cameraScreen.deleteButton.waitForExistence(timeout: 5))
        
        cameraScreen.deleteButton.tap()
        sleep(1)
        
        cameraScreen.closeButton.tap()
        
        cameraScreen.firstPhoto.tap()
        cameraScreen.deleteButton.tap()
        sleep(1)
    }
    
    func testUCGalleryDeleteMediaViewer() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.takePhoto.waitForExistence(timeout: 5))
        cameraScreen.takePhoto.tap()
        sleep(1)
        cameraScreen.takePhoto.tap()
        
        XCTAssertTrue(cameraScreen.mediaCount.waitForExistence(timeout: 3))
        cameraScreen.mediaCount.tap()
        
        cameraScreen.secondPhoto.tap()
        
        XCUIDevice.shared.orientation = .landscapeLeft
        sleep(1)
        
        XCTAssertTrue(cameraScreen.closeButton.waitForExistence(timeout: 5))
        XCTAssertTrue(cameraScreen.deleteButton.waitForExistence(timeout: 5))
        
        cameraScreen.deleteButton.tap()
        sleep(1)
        
        cameraScreen.closeButton.tap()
        sleep(1)
        
        XCUIDevice.shared.orientation = .portrait
        sleep(1)
        
        cameraScreen.firstPhoto.tap()
        
        XCUIDevice.shared.orientation = .landscapeRight
        sleep(1)
        
        cameraScreen.deleteButton.tap()
        sleep(1)
    }

    func testUCGalleryAccessAfterCapture() {
        // Given, When, Then
        XCTAssertTrue(cameraScreen.openCamera.waitForExistence(timeout: 3))
        cameraScreen.openCamera.tap()
        
        XCTAssertTrue(cameraScreen.takePhoto.waitForExistence(timeout: 5))
        cameraScreen.takePhoto.tap()
        XCTAssertTrue(cameraScreen.mediaCount.waitForExistence(timeout: 3))
        XCTAssertEqual(cameraScreen.mediaCount.label, "1")
        
        XCTAssertTrue(cameraScreen.recordVideo.waitForExistence(timeout: 5))
        cameraScreen.recordVideo.tap()
        sleep(2)
        cameraScreen.recordVideo.tap()
        
        XCTAssertTrue(cameraScreen.mediaCount.waitForExistence(timeout: 3))
        XCTAssertEqual(cameraScreen.mediaCount.label, "1, 1")
        
        cameraScreen.takePhoto.tap()
        sleep(1)
        
        cameraScreen.recordVideo.tap()
        sleep(1)
        cameraScreen.recordVideo.tap()
        
        XCTAssertEqual(cameraScreen.mediaCount.label, "2, 2")
        cameraScreen.mediaCount.tap()
        
        XCTAssertTrue(cameraScreen.galleryView.waitForExistence(timeout: 5))
        XCTAssertTrue(cameraScreen.galleryGrid.waitForExistence(timeout: 5))
        XCTAssertGreaterThan(cameraScreen.galleryGrid.images.count, 0)
        
        cameraScreen.firstPhoto.tap()
        sleep(1)
        
        cameraScreen.closeButton.tap()
        
        cameraScreen.firstVideo.tap()
        XCUIDevice.shared.orientation = .landscapeLeft
    }
}
