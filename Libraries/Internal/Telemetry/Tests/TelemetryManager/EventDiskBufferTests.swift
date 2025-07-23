//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
import Foundation
import Testing

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
    }
}

