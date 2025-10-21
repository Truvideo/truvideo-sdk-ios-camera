//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Testing

@testable import StorageKit

struct UserDefaultStorageTests {
    // MARK: - Tests

    @Test
    func testThatSaveInformationShouldSucceed() async throws {
        // Given
        let sut = UserDefaultsStorage()

        // When
        try sut.write("foo", forKey: StorageKeyMock.self)
        let storedValue = try sut.readValue(for: StorageKeyMock.self)

        // Then
        #expect(storedValue == "foo")
    }

    @Test
    func testThatReadInformationShouldFailOnDataTypeIsIncorrect() throws {
        // Given
        let sut = UserDefaultsStorage()

        // When, Then
        #expect {
            try sut.write("foo", forKey: StorageKeyMock.self)
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
        let sut = UserDefaultsStorage()

        // When
        try sut.clear()
        let value = try sut.readValue(for: StorageKeyMock.self)

        // Then
        #expect(value == nil)
    }

    @Test
    func testThatDeleteInformationShouldRemoveStoredValue() throws {
        // Given
        let sut = UserDefaultsStorage()
        var results: [String] = []

        // When
        try sut.write("Test1", forKey: StorageKeyMock.self)
        try results.append(sut.readValue(for: StorageKeyMock.self) ?? "")

        try sut.deleteValue(for: StorageKeyMock.self)
        try results.append(sut.readValue(for: StorageKeyMock.self) ?? "")

        // Then
        #expect(results == ["Test1", ""])
    }

    @Test
    func testThatClearRemovesAllStoredValues() throws {
        // Given
        let sut = UserDefaultsStorage()

        // When
        try sut.write("Hello", forKey: StorageKeyMock.self)
        try sut.clear()

        // Then
        #expect(try sut.readValue(for: StorageKeyMock.self) == nil)
    }
}
