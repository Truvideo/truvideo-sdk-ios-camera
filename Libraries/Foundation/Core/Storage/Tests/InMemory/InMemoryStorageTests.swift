//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Testing

@testable import StorageKit

struct InMemoryStorageTests {
    // MARK: - Tests

    @Test
    func testThatSaveInformationShouldSucceed() async throws {
        // Given
        let sut = InMemoryStorage()

        // When
        try sut.write("bar", forKey: StorageKeyMock.self)
        let value = try sut.readValue(for: StorageKeyMock.self)

        // Then
        #expect(value == "bar")
    }

    @Test
    func testThatReadInformationShouldFailOnDataTypeIsIncorrect() throws {
        // Given
        let sut = InMemoryStorage()

        // When, Then
        #expect {
            try sut.write("bar", forKey: StorageKeyMock.self)
            _ = try sut.readValue(for: InvalidStorageKeyMock.self)
        } throws: { error in
            guard let storageError = error as? StorageError,
                  case .readFailed = storageError else {
                return false
            }

            return true
        }
    }

    @Test
    func testThatReadValueShouldReturnNilWhenKeyNotFound() throws {
        // Given
        let sut = InMemoryStorage()

        // When
        let value = try sut.readValue(for: StorageKeyMock.self)

        // Then
        #expect(value == nil)
    }

    @Test
    func testThatDeleteInformationShouldRemoveStoredValue() throws {
        // Given
        let sut = InMemoryStorage()
        var results: [String] = []

        // When
        try sut.write("bar", forKey: StorageKeyMock.self)
        try results.append(sut.readValue(for: StorageKeyMock.self) ?? "")

        try sut.deleteValue(for: StorageKeyMock.self)
        try results.append(sut.readValue(for: StorageKeyMock.self) ?? "")

        // Then
        #expect(results == ["bar", ""])
    }

    @Test
    func testThatClearRemovesAllStoredValues() throws {
        // Given
        let sut = InMemoryStorage()

        // When
        try sut.write("Hello", forKey: StorageKeyMock.self)
        try sut.clear()

        // Then
        #expect(try sut.readValue(for: StorageKeyMock.self) == nil)
    }
}

struct StorageKeyMock: StorageKey {
    static let name = "testKey"
    typealias Value = String
}

struct InvalidStorageKeyMock: StorageKey {
    static let name = "testKey"
    typealias Value = Int
}
