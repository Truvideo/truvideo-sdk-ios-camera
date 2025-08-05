//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
import Storage
import StorageTesting
import Foundation
import Testing
import UIKit

@testable import Telemetry

@MainActor
final class SystemEventTrackerIntegrationTests {
    // MARK: - Private Properties

    let tempDir: URL
    let buffer: EventDiskBuffer
    let ringBuffer: RingBuffer<Breadcrumb>
    let storage: InMemoryStorage
    let sut: AutoSessionTrackerIntegration
    let manager: TelemetryManagerMock

    // MARK: - Initializer

    init() {
        self.tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        self.buffer = EventDiskBuffer(storageURL: tempDir)
        self.ringBuffer = RingBuffer()
        self.storage = InMemoryStorage()
        self.sut = AutoSessionTrackerIntegration()
        self.manager = TelemetryManagerMock(
            breadcrumbsBuffer: ringBuffer,
            eventsBuffer: buffer
        )
    }

    // - MARK: Tests

    @Test
    func testThatInitStartsMonitoringAndConnectivityNofiticationCapturesBreadcrumb() {
        // Given
        let pathMock = NetworkPathMock(
            status: .satisfied,
            type: .wifi,
            connectivityType: "Wi-Fi"
        )
        let pathMonitor = NetworkPathMonitorMock(initialPath: pathMock)
        let sut = SystemEventTrackerIntegration(pathMonitor: pathMonitor)
        
        // When
        sut.install(on: manager)
        pathMonitor.pathUpdateHandler?(pathMock)

        // Then
        let breadcrumb = manager.capturedBreadcrumbs.last
        #expect(pathMonitor.isStarted == true)
        #expect(breadcrumb?.category == "device.connectivity")
        #expect(breadcrumb?.metadata?["connectivityType"] == "Wi-Fi")
        #expect(breadcrumb?.metadata?["status"] == "satisfied")
        #expect(breadcrumb?.severity == .info)
    }

    @Test
    func testThatForegroundNotificationCapturesBreadcrumb() {
        // Given
        let sut = SystemEventTrackerIntegration()

        // When
        sut.install(on: manager)
        NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)

        // Then
        let breadcrumb = manager.capturedBreadcrumbs.last
        #expect(breadcrumb?.category == "app.lifecycle")
        #expect(breadcrumb?.metadata!["state"] == "foreground")
        #expect(breadcrumb?.severity == .info)
    }

    @Test
    func testThatBackgroundNotificationCapturesBreadcrumb() {
        // Given
        let sut = SystemEventTrackerIntegration()
        
        // When
        sut.install(on: manager)
        NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        // Then
        let breadcrumb = manager.capturedBreadcrumbs.last
        #expect(breadcrumb?.category == "app.lifecycle")
        #expect(breadcrumb?.metadata!["state"] == "background")
        #expect(breadcrumb?.severity == .info)
    }

    @Test
    func testThatTimeZoneChangeCapturesBreadcrumb() {
        // Given
        let sut = SystemEventTrackerIntegration()

        // When
        sut.install(on: manager)
        NotificationCenter.default.post(name: NSNotification.Name.NSSystemTimeZoneDidChange, object: nil)

        // Then
        let breadcrumb = manager.capturedBreadcrumbs.last
        #expect(breadcrumb?.category == "device.event")
        #expect(breadcrumb?.metadata!["newTimezone"] != nil)
        #expect(breadcrumb?.severity == .info)
    }

    @Test
    func testThatMemoryWarningCapturesBreadcrumb() {
        // Given
        let sut = SystemEventTrackerIntegration()

        // When
        sut.install(on: manager)
        NotificationCenter.default.post(name: UIApplication.didReceiveMemoryWarningNotification, object: nil)

        // Then
        let breadcrumb = manager.capturedBreadcrumbs.last
        #expect(breadcrumb?.category == "device.event")
        #expect(breadcrumb?.message == "Low memory")
        #expect(breadcrumb?.metadata!["freeMemory"] != nil)
        #expect(breadcrumb?.metadata!["totalMemory"] != nil)
        #expect(breadcrumb?.severity == .warning)
    }
    
    @Test
    func testThatBatteryLevelChangeCapturesBreadcrumb() {
        // Given
        let sut = SystemEventTrackerIntegration()
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        // When
        sut.install(on: manager)
        NotificationCenter.default.post(name: UIDevice.batteryLevelDidChangeNotification, object: UIDevice.current)

        // Then
        let breadcrumb = manager.capturedBreadcrumbs.last
        #expect(breadcrumb?.category == "device.event")
        #expect(breadcrumb?.metadata!["level"] == "Unknown")
        #expect(breadcrumb?.metadata!["isLowPowerModeEnabled"] == false)
        #expect(breadcrumb?.metadata!["isPlugged"] == false)
        #expect(breadcrumb?.severity == .info)
    }
}
