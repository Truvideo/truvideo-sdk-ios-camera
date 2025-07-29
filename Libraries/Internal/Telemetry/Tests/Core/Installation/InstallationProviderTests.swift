//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
import Testing
import Foundation

@testable import Telemetry

struct InstallationProviderTests {
    // MARK: - Private Properties

    private let storageURL: URL

    // MARK: - Initializer

    init () {
        storageURL = FileManager.default.telemetryDirectory.appendingPathComponent("\(UUID()).json")
    }

    // MARK: - Tests

    @Test
    func testThatReturnsExistingUUIDIfPresent() async {
        // Given
        let id = UUID()
        let storage = InMemoryStorage()
        let sut = InstallationProvider(storage: storage)
        
        // When
        try? storage.write(id, forKey: InstallationIdStorageKey.self)
        let result = sut.uniqueIdentifier()
        
        // Then
        #expect(id == result, "Expect the same UUID that was written to storage to be returned")
    }

    @Test
    func testThatGeneratesAndStoresUUIDIfNotPresent() async {
        // Given
        let storage = InMemoryStorage()
        let sut = InstallationProvider(storage: storage)
        
        // When
        let result = sut.uniqueIdentifier()
        let expectedUUID = try? storage.readValue(for: InstallationIdStorageKey.self)
        
        // Then
        #expect(result == expectedUUID, "Expect that a new UUID was generated, stored, and then returned")
    }

    @Test
    func testThatReturnsNewUUIDIfStorageThrows() {
        // Given
        let id = UUID()
        let storage = StorageMock()
        let provider = InstallationProvider(storage: storage)

        // When
        try? storage.write(id, forKey: InstallationIdStorageKey.self)
        storage.error = NSError(domain: "", code: 0)
        let result = provider.uniqueIdentifier()

        // Then
        #expect(result != id, "Expect a new UUID to be returned if storage throws an error")
    }
}
