//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
import Foundation
import StorageKit
import StorageKitTesting
import Testing

@testable import Telemetry

struct TelemetryInstallationTests {
    // MARK: - Tests

    @Test
    func testThatUniqueIdentifierGeneratesNewUUIDWhenNotStored() async throws {
        await withDependencyValues { dependencies in
            // Given
            let storage = InMemoryStorage()
            let sut = InstallationProvider()

            // When
            dependencies.storage = storage
            let identifier = sut.uniqueIdentifier()
            let storedIdentifier = try? storage.readValue(for: InstallationProvider.InstallationIdStorageKey.self)

            // Then
            #expect(identifier != UUID(), "Should generate a valid UUID")
            #expect(storedIdentifier == identifier, "Should store the generated UUID")
        }
    }

    @Test
    func testThatUniqueIdentifierReturnsSameUUIDWhenAlreadyStored() async throws {
        await withDependencyValues { dependencies in
            // Given
            let storage = InMemoryStorage()
            let existingUUID = UUID()
            let sut = InstallationProvider()

            // When
            dependencies.storage = storage
            try? storage.write(existingUUID, forKey: InstallationProvider.InstallationIdStorageKey.self)
            let identifier = sut.uniqueIdentifier()

            // Then
            #expect(identifier == existingUUID, "Should return the same UUID that was already stored")
        }
    }

    @Test
    func testThatUniqueIdentifierReturnsSameUUIDOnMultipleCalls() async throws {
        await withDependencyValues { dependencies in
            // Given
            let storage = InMemoryStorage()
            let sut = InstallationProvider()

            // When
            dependencies.storage = storage
            let firstIdentifier = sut.uniqueIdentifier()
            let secondIdentifier = sut.uniqueIdentifier()
            let thirdIdentifier = sut.uniqueIdentifier()

            // Then
            #expect(firstIdentifier == secondIdentifier, "Should return same UUID on second call")
            #expect(secondIdentifier == thirdIdentifier, "Should return same UUID on third call")
            #expect(firstIdentifier == thirdIdentifier, "Should return same UUID across all calls")
        }
    }

    @Test
    func testThatUniqueIdentifierHandlesStorageError() async throws {
        await withDependencyValues { dependencies in
            // Given
            let id = UUID()
            let sut = InstallationProvider()
            let storage = StorageMock()

            // When
            dependencies.storage = storage

            try? storage.write(id, forKey: InstallationProvider.InstallationIdStorageKey.self)
            storage.error = NSError(domain: "", code: 0)
            let result = sut.uniqueIdentifier()

            // Then
            #expect(result != UUID(), "Should return a valid UUID even when storage fails")
            #expect(result != UUID(), "Should return a different UUID on subsequent calls when storage fails")
        }
    }

    @Test
    func testThatUniqueIdentifierPersistsUUIDInStorage() async throws {
        await withDependencyValues { dependencies in
            // Given
            let storage = InMemoryStorage()
            let sut = InstallationProvider()

            // When
            dependencies.storage = storage
            let identifier = sut.uniqueIdentifier()

            // Then
            let storedIdentifier = try? storage.readValue(for: InstallationProvider.InstallationIdStorageKey.self)
            #expect(storedIdentifier != nil, "Should store the UUID in storage")
            #expect(storedIdentifier == identifier, "Stored UUID should match the returned identifier")
        }
    }
}
