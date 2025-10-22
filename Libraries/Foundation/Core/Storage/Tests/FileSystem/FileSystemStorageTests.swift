//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Testing

@testable import StorageKit

struct FileSystemStorageTests {
    // MARK: - Tests

    @Test
    func testThatSaveInformationShouldSucceed() async throws {
        // Given
        let sut = FileSystemStorage()

        // When
        try sut.write("foo", forKey: StorageKeyMock.self)
        let storedValue = try sut.readValue(for: StorageKeyMock.self)

        // Then
        #expect(storedValue == "foo")
    }

    @Test
    func testThatReadInformationShouldFailOnDataTypeIsIncorrect() throws {
        // Given
        let sut = FileSystemStorage()

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
        let sut = FileSystemStorage()

        // When
        try sut.clear()
        let value = try sut.readValue(for: StorageKeyMock.self)

        // Then
        #expect(value == nil)
    }

    @Test
    func testThatDeleteInformationShouldRemoveStoredValue() throws {
        // Given
        let sut = FileSystemStorage()
        var results: [String] = []

        // When
        try sut.write("foo-bar", forKey: StorageKeyMock.self)
        try results.append(sut.readValue(for: StorageKeyMock.self) ?? "")

        try sut.deleteValue(for: StorageKeyMock.self)
        try results.append(sut.readValue(for: StorageKeyMock.self) ?? "")

        // Then
        #expect(results == ["foo-bar", ""])
    }

    @Test
    func testThatClearRemovesAllStoredValues() throws {
        // Given
        let sut = FileSystemStorage()

        // When
        try sut.write("foo-bar", forKey: StorageKeyMock.self)
        try sut.clear()

        // Then
        #expect(try sut.readValue(for: StorageKeyMock.self) == nil)
    }

    @Test
    func testThatClearFailsWhenUnderlyingKeychainThrows() throws {
        // Given
        let sut = FileSystemStorage()

        // When, Then
        #expect {
            try sut.clear()
        } throws: { error in
            guard let storageError = error as? StorageError,
                  case .clearFailed = storageError
            else {
                return false
            }

            return true
        }
    }

    @Test
    func testThatDeleteFailsWhenUnderlyingKeychainThrows() throws {
        // Given
        let sut = FileSystemStorage()

        // When, Then
        #expect {
            try sut.deleteValue(for: StorageKeyMock.self)
        } throws: { error in
            guard let storageError = error as? StorageError,
                  case .deleteFailed = storageError
            else {
                return false
            }

            return true
        }
    }
}
