//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
import Foundation
import Testing
import Utilities

@testable import Telemetry

struct EventDiskBufferTests {
    // MARK: - Tests

    @Test
    func testThatAddStoresAndRetrievesEvent() {
        // Given
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let buffer = EventDiskBuffer(storageURL: tempDir)
        let event = TelemetryReport.Event(
            name: "test_event",
            severity: .info,
            source: "test_source"
        )

        // When
        buffer.add(event)
        let events = buffer.snapshot()

        // Then
        #expect(events.count == 1, "Expected one event in buffer")
        #expect(events.first?.name == "test_event", "Expected event name to match")
        #expect(!buffer.isFull, "Expected buffer must not be full")
    }

    @Test
    func testThatFlushRemovesAllEvents() {
        // Given
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let buffer = EventDiskBuffer(storageURL: tempDir)
        let event = TelemetryReport.Event(
            name: "test_event",
            severity: .info,
            source: "test_source"
        )
        buffer.add(event)

        // When
        buffer.flush()
        let events = buffer.snapshot()

        // Then
        #expect(events.isEmpty, "Expected buffer to be empty after flush")
        #expect(!buffer.isFull, "Expected buffer must not be full")
    }

    @Test
    func testThatRehydrateRestoresPersistedEvents() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let fileWriter = SystemFileWriter()
            let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            let event = TelemetryReport.Event(
                name: "rehydrate_event",
                severity: .warning,
                source: "rehydrate_source"
            )

            // When
            try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
            dependencies.fileWriter = fileWriter

            let buffer = EventDiskBuffer(storageURL: tempDir)
            buffer.add(event)

            let restoredBuffer = EventDiskBuffer(storageURL: tempDir)
            let events = restoredBuffer.snapshot()

            // Then
            #expect(events.count == 1, "Expected one event after rehydration")
            #expect(events.first?.name == event.name, "Expected event name to match after rehydration")
            #expect(events.first?.severity == event.severity, "Expected severity to match")
            #expect(events.first?.source == event.source, "Expected source to match")
        }
    }
}
