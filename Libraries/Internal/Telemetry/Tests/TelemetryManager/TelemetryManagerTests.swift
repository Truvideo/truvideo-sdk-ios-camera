//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
import Foundation
import Testing

@testable import Telemetry

private final class TelemetryManagerTests {
    // MARK: - Private Properties
    
    private var contextProvider: ContextProviderMock!
    private let storageURL: URL
    private var subscriber: TelemetryManagerSubscriberMock!
    
    // MARK: - Initializer
    
    init () {
        contextProvider = ContextProviderMock()
        storageURL = FileManager.default.telemetryDirectory.appendingPathComponent("\(UUID()).json")
        subscriber = TelemetryManagerSubscriberMock()
    }

    // MARK: - Tests
    
    @Test
    func testThatFlushPreviousSessionEmitsSessionEndedEvent() async throws {
        await withDependencyValues { dependencies in
            // Given
            let endDate = Date()
            let event: TelemetryReport.Event?
            let report: TelemetryReport?
            let installation = TelemetryInstallationMock()
            let session = Session(installationId: installation.uniqueIdentifier())
            let sut = TelemetryManager(
                breadcrumbsBuffer: RingBuffer(),
                eventsBuffer: EventDiskBuffer(storageURL: storageURL),
                integrations: []
            )

            // When
            dependencies.contextProvider = contextProvider
            dependencies.installation = installation
            dependencies.storage = InMemoryStorage()
            
            try! dependencies.storage.write(session, forKey: SessionStorageKey.self)
            
            sut.add(subscriber)
            sut.flushPreviousSession(endedAt: endDate)
            
            report = subscriber.receivedReports.first
            event = report?.events.first { $0.name == "session_ended" }
            
            // Then
            #expect(subscriber.receivedReports.count == 1)
            #expect(contextProvider.makeContextCallCount == 1)
            #expect(event?.message == "Discarded stale session from previous app run.")
            #expect(event?.severity == .info, "Expected event severity to be info")
            #expect(event?.source == "Telemetry", "Expected event source to be Telemetry")
            #expect(report?.session.endedAt == endDate)
        }
    }
    
    @Test
    func testThatEndSessionEmitsSessionEndedEvent() async throws {
        await withDependencyValues { dependencies in
            // Given
            let event: TelemetryReport.Event?
            let report: TelemetryReport?
            let endDate = Date()
            let sut = TelemetryManager(
                breadcrumbsBuffer: RingBuffer(),
                eventsBuffer: EventDiskBuffer(storageURL: storageURL),
                integrations: []
            )
            
            // When
            dependencies.contextProvider = contextProvider
            dependencies.installation = TelemetryInstallationMock()
            dependencies.storage = InMemoryStorage()
            
            sut.add(subscriber)
            
            sut.startSession()
            sut.endSession(at: endDate)
            
            report = subscriber.receivedReports.last!
            event = report?.events.first { $0.name == "session_ended" }
            
            // Then
            #expect(subscriber.receivedReports.count == 1)
            #expect(contextProvider.makeContextCallCount == 1)
            #expect(event?.severity == .info)
            #expect(event?.source == "Telemetry")
            #expect(report?.session.endedAt == endDate)            
            #expect(try! dependencies.storage.readValue(for: SessionStorageKey.self) == nil)
        }
    }
    
    @Test
    func testThatEndSessionDoesNothingWhenNoActiveSession() async throws {
        await withDependencyValues { dependencies in
            // Given
            let sut = TelemetryManager(
                breadcrumbsBuffer: RingBuffer(),
                eventsBuffer: EventDiskBuffer(storageURL: storageURL),
                integrations: []
            )
            
            // When
            dependencies.contextProvider = contextProvider
            dependencies.installation = TelemetryInstallationMock()
            dependencies.storage = InMemoryStorage()
            
            sut.add(subscriber)
            sut.endSession(at: Date())
            
            // Then
            #expect(contextProvider.makeContextCallCount == 0)
            #expect(subscriber.receivedReports.isEmpty)
        }
    }
    
    @Test
    func testThatRemoveSubscriberUnregistersSubscriber() async throws {
        await withDependencyValues { dependencies in
            // Given
            let sut = TelemetryManager(
                breadcrumbsBuffer: RingBuffer(),
                eventsBuffer: EventDiskBuffer(storageURL: storageURL),
                integrations: []
            )
            
            // When
            dependencies.contextProvider = contextProvider
            dependencies.installation = TelemetryInstallationMock()
            dependencies.storage = InMemoryStorage()

            sut.add(subscriber)
            sut.startSession()
            sut.endSession(at: Date())
            
            sut.remove(subscriber)
            sut.startSession()
            sut.endSession(at: Date())

            // Then
            #expect(subscriber.receivedReports.count == 1)
        }
    }

    @Test
    func testThatCaptureEventEmitsEvent() async throws {
        await withDependencyValues { dependencies in
            // Given
            let event: TelemetryReport.Event?
            let eventsBuffer = EventDiskBuffer(storageURL: storageURL)
            let sut = TelemetryManager(breadcrumbsBuffer: RingBuffer(), eventsBuffer: eventsBuffer, integrations: [])

            // When
            dependencies.contextProvider = contextProvider
            dependencies.installation = TelemetryInstallationMock()
            dependencies.storage = InMemoryStorage()
            
            sut.add(subscriber)
            sut.startSession()
            sut.captureEvent(name: "custom_event", source: "test_source", metadata: ["foo": "bar"])
                        
            event = eventsBuffer.snapshot().first(where: { $0.name == "custom_event" })

            // Then            
            #expect(event?.metadata?["foo"] == "bar")
            #expect(event?.source == "test_source")
        }
    }

    @Test
    func testThatCaptureMessageEmitsEventWithMessage() async throws {
        await withDependencyValues { dependencies in
            // Given
            let event: TelemetryReport.Event?
            let eventsBuffer = EventDiskBuffer(storageURL: storageURL)
            let sut = TelemetryManager(breadcrumbsBuffer: RingBuffer(), eventsBuffer: eventsBuffer, integrations: [])

            // When
            dependencies.contextProvider = contextProvider
            dependencies.installation = TelemetryInstallationMock()
            dependencies.storage = InMemoryStorage()

            sut.add(subscriber)
            sut.startSession()
            sut.capture(
                "A test message",
                name: "message_event",
                source: "test_source",
                metadata: ["foo": "bar"]
            )
            
            event = eventsBuffer.snapshot().first(where: { $0.name == "message_event" })

            // Then
            #expect(event?.message == "A test message")
            #expect(event?.metadata?["foo"] == "bar")
            #expect(event?.source == "test_source")
        }
    }

    @Test
    func testThatCaptureErrorEmitsErrorEvent() async throws {
        await withDependencyValues { dependencies in
            // Given
            let event: TelemetryReport.Event?
            let eventsBuffer = EventDiskBuffer(storageURL: storageURL)
            let sut = TelemetryManager(breadcrumbsBuffer: RingBuffer(), eventsBuffer: eventsBuffer, integrations: [])
            let error = NSError(
                domain: "TestDomain",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Something went wrong"]
            )
            
            // When
            dependencies.contextProvider = contextProvider
            dependencies.installation = TelemetryInstallationMock()
            dependencies.storage = InMemoryStorage()

            sut.add(subscriber)
            sut.capture(error, name: "error_event", source: "test_source", metadata: ["foo": .string("bar")])
            
            event = eventsBuffer.snapshot().first(where: { $0.name == "error_event" })

            // Then
            #expect(event?.severity == .error)
            #expect(event?.exception?.message == "Something went wrong")
            #expect(event?.metadata?["foo"] == "bar")
        }
    }
    
    @Test
    func testThatCaptureBreadcrumbAddsBreadcrumbToEvent() async throws {
        await withDependencyValues { dependencies in
            // Given
            let breadcrumb = Breadcrumb(
                severity: .info,
                source: "test_source",
                category: "test_category",
                message: "Test breadcrumb"
            )

            let sut = TelemetryManager()

            // When
            dependencies.contextProvider = contextProvider
            dependencies.installation = TelemetryInstallationMock()
            dependencies.storage = InMemoryStorage()

            sut.capture(breadcrumb)

            // Then
            #expect(sut.breadcrumbsBuffer.count == 1)
        }
    }

    @Test
    func testThatStartSessionCreatesSessionWhenNoneExists() async throws {
        await withDependencyValues { dependencies in
            // Given
            let event: TelemetryReport.Event?
            let eventsBuffer = EventDiskBuffer(storageURL: storageURL)
            let sut = TelemetryManager(breadcrumbsBuffer: RingBuffer(), eventsBuffer: eventsBuffer, integrations: [])

            // When
            dependencies.contextProvider = contextProvider
            dependencies.installation = TelemetryInstallationMock()
            dependencies.storage = InMemoryStorage()

            sut.add(subscriber)
            sut.startSession()
            
            event = eventsBuffer.snapshot().first(where: { $0.name == "session_started" })

            // Then
            #expect(try! dependencies.storage.readValue(for: SessionStorageKey.self) != nil)
            #expect(event?.severity == .info)
            #expect(event?.source == "Telemetry")
        }
    }

    @Test
    func testThatStartSessionReplacesStaleSessionInStorage() async throws {
        await withDependencyValues { dependencies in
            // Given
            let session = Session(installationId: UUID())
            let eventsBuffer = EventDiskBuffer(storageURL: storageURL)
            let sut = TelemetryManager(breadcrumbsBuffer: RingBuffer(), eventsBuffer: eventsBuffer, integrations: [])

            // When
            dependencies.storage = InMemoryStorage()
            dependencies.installation = TelemetryInstallationMock()
            dependencies.contextProvider = contextProvider

            try! dependencies.storage.write(session, forKey: SessionStorageKey.self)

            sut.add(subscriber)
            sut.startSession()

            // Then
            #expect(try! dependencies.storage.readValue(for: SessionStorageKey.self) != session)
            #expect(eventsBuffer.snapshot().count(where: { $0.name == "session_started" }) == 1)
        }
    }

    @Test
    func testThatStartSessionDoesNothingIfSessionAlreadyExists() async throws {
        await withDependencyValues { dependencies in
            // Given
            let eventsBuffer = EventDiskBuffer(storageURL: storageURL)
            let sut = TelemetryManager(breadcrumbsBuffer: RingBuffer(), eventsBuffer: eventsBuffer, integrations: [])

            // When
            dependencies.contextProvider = contextProvider
            dependencies.installation = TelemetryInstallationMock()
            dependencies.storage = InMemoryStorage()

            sut.add(subscriber)
            sut.startSession()
            
            let firstSession = try! dependencies.storage.readValue(for: SessionStorageKey.self)

            sut.startSession()
            let secondSession = try! dependencies.storage.readValue(for: SessionStorageKey.self)

            // Then
            #expect(firstSession == secondSession)
            #expect(eventsBuffer.snapshot().count(where: { $0.name == "session_started" }) == 1)
        }
    }
}
