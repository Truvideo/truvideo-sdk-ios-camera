//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
import StorageKit
import StorageKitTesting
import Foundation
import Testing
import UIKit

@testable import Telemetry

private final class AutoSessionTrackerIntegrationTests {
    // MARK: - Private Properties

    let tempDir: URL
    let buffer: EventDiskBuffer
    let ringBuffer: RingBuffer<Breadcrumb>
    let storage: InMemoryStorage
    let manager: TelemetryManagerMock

    // MARK: - Initializer

    init() {
        self.tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        self.buffer = EventDiskBuffer(storageURL: tempDir)
        self.ringBuffer = RingBuffer()
        self.storage = InMemoryStorage()
        self.manager = TelemetryManagerMock(
            breadcrumbsBuffer: ringBuffer,
            eventsBuffer: buffer
        )
    }
    
    // MARK: - Tests
    
    @Test
    func testThatInstallStartsSessionWhenAppIsActive() async {
        await withDependencyValues { dependencies in
            // Given
            let sut = AutoSessionTrackerIntegration()
            
            // When
            dependencies.storage = storage
            sut.install(on: manager)

            // Then
            #expect(manager.didStartSession == true)
        }
    }
    
    @Test
    func testThatWillResignActiveStoresForegroundDate() async {
        await withDependencyValues { dependencies in
            // Given
            let sut = AutoSessionTrackerIntegration()
            let now = Date()
            
            // When
            dependencies.storage = storage
            sut.install(on: manager)

            NotificationCenter.default.post(name: UIApplication.willResignActiveNotification, object: nil)

            let storedDate = try? storage.readValue(
                for: AutoSessionTrackerIntegration.PreviousForegroundDateStorageKey.self
            )

            // Then
            #expect(storedDate != nil)
            #expect(storedDate!.timeIntervalSince(now) < 1.0)
        }
    }

    @Test
    func testThatWillTerminateEndsSessionWithStoredDate() async {
        await withDependencyValues { dependencies in
            // Given
            let pastDate = Date().addingTimeInterval(-100)
            let sut = AutoSessionTrackerIntegration()

            // When
            dependencies.storage = storage

            try? storage.write(pastDate, forKey: AutoSessionTrackerIntegration.PreviousForegroundDateStorageKey.self)

            sut.install(on: manager)
            
            NotificationCenter.default.post(name: UIApplication.willTerminateNotification, object: nil)

            let storedDate = try? storage.readValue(
                for: AutoSessionTrackerIntegration.PreviousForegroundDateStorageKey.self
            )

            // Then
            #expect(storedDate == nil)
            #expect(manager.endedSessionAt != nil)
            #expect(abs(manager.endedSessionAt!.timeIntervalSince(pastDate)) < 1.0)
        }
    }

    @Test
    func testThatBecomeActiveStartsNewSessionIfPastDateTooOld() async {
        await withDependencyValues { dependencies in
            // Given
            let pastDate = Date().addingTimeInterval(-121)
            let sut = AutoSessionTrackerIntegration()

            // When
            dependencies.storage = storage

            try? storage.write(pastDate, forKey: AutoSessionTrackerIntegration.PreviousForegroundDateStorageKey.self)

            sut.install(on: manager)
            
            NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)

            // Then
            #expect(manager.didStartSession == true)
            #expect(manager.endedSessionAt != nil)
        }
    }
    
    @Test
    func testThatStartSessionStartsNewSessionWhenStorageReadFails() async {
        await withDependencyValues { dependencies in
            // Given
            let storage = StorageMock()
            let sut = AutoSessionTrackerIntegration()
            let manager = TelemetryManagerMock(
                breadcrumbsBuffer: ringBuffer,
                eventsBuffer: buffer
            )

            // When
            dependencies.storage = storage
            storage.error = NSError(domain: "", code: 0)
            
            sut.install(on: manager)
            
            // Then
            #expect(manager.didStartSession == true)
            #expect(manager.endedSessionAt == nil)
        }
    }
}
