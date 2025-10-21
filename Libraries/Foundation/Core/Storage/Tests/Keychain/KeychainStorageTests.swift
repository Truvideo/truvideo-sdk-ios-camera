//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import StorageTesting
import Testing

@testable import StorageKit

struct KeychainStorageTests {
    // MARK: - Private Properties

    private let keychain: KeychainProtocolMock

    // MARK: - Initializer

    init() {
        self.keychain = KeychainProtocolMock()
    }

    // MARK: - Tests

    @Test
    func testThatKeychainStorageShouldInitialize() {
        // When
        let sut = KeychainStorage()

        // Then
        #expect(sut != nil)
    }

    @Test
    func testThatInitWithAccessGroupShouldCreateKeychainWithAccessGroup() {
        // Given
        let accessGroup = "com.tests.group"

        // When
        let sut = KeychainStorage(accessGroup: accessGroup)

        // Then
        #expect(sut != nil)
    }

    @Test
    func testThatInitWithHttpsUrlShouldCreateKeychainWithHttpsProtocol() {
        // Given
        let httpsURL = "https://test.com"

        // When
        let sut = KeychainStorage(url: httpsURL)

        // Then
        #expect(sut != nil)
    }

    @Test
    func testThatSaveInformationShouldSucceed() async throws {
        // Given
        let sut = KeychainStorage(keychain: keychain)

        // When
        try sut.write("foo", forKey: StorageKeyMock.self)
        let storedValue = try sut.readValue(for: StorageKeyMock.self)

        // Then
        #expect(storedValue == "foo")
    }

    @Test
    func testThatReadInformationShouldFailOnDataTypeIsIncorrect() throws {
        // Given
        let sut = KeychainStorage(keychain: keychain)

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
        let sut = KeychainStorage(keychain: keychain)

        // When
        try sut.clear()
        let value = try sut.readValue(for: StorageKeyMock.self)

        // Then
        #expect(value == nil)
    }

    @Test
    func testThatDeleteInformationShouldRemoveStoredValue() throws {
        // Given
        let sut = KeychainStorage(keychain: keychain)
        var results: [String] = []

        // When
        try sut.write("foo", forKey: StorageKeyMock.self)
        try results.append(sut.readValue(for: StorageKeyMock.self) ?? "")

        try sut.deleteValue(for: StorageKeyMock.self)
        try results.append(sut.readValue(for: StorageKeyMock.self) ?? "")

        // Then
        #expect(results == ["foo", ""])
    }

    @Test
    func testThatClearRemovesAllStoredValues() throws {
        // Given
        let sut = KeychainStorage(keychain: keychain)

        // When
        try sut.write("Hello", forKey: StorageKeyMock.self)
        try sut.clear()

        // Then
        #expect(try sut.readValue(for: StorageKeyMock.self) == nil)
    }

    @Test
    func testThatWriteFailsWhenUnderlyingKeychainThrows() throws {
        // Given
        let sut = KeychainStorage(keychain: keychain)

        // When, Then
        keychain.error = NSError(domain: "test", code: 1)

        #expect {
            try sut.write("oops", forKey: StorageKeyMock.self)
        } throws: { error in
            guard
                let storageError = error as? StorageError,
                case .writeFailed = storageError
            else {
                return false
            }

            return true
        }
    }

    @Test
    func testThatClearFailsWhenUnderlyingKeychainThrows() throws {
        // Given
        let sut = KeychainStorage(keychain: keychain)

        // When, Then
        keychain.error = NSError(domain: "test", code: -1)

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

        #expect(keychain.removeAllCallCount == 1)
    }

    @Test
    func testThatDeleteFailsWhenUnderlyingKeychainThrows() throws {
        // Given
        let sut = KeychainStorage(keychain: keychain)

        // When, Then
        keychain.error = NSError(domain: "test", code: 2)

        #expect {
            try sut.deleteValue(for: StorageKeyMock.self)
        } throws: { error in
            guard
                let storageError = error as? StorageError,
                case .deleteFailed = storageError
            else {
                return false
            }

            return true
        }

        #expect(keychain.removeCallCount == 1)
        #expect(keychain.key == StorageKeyMock.name)
    }

    // MARK: - StorageKey

    @Test
    func testThatWriteUsesStorageKeyName() throws {
        // Given
        let sut = KeychainStorage(keychain: keychain)

        // When
        try sut.write("foo", forKey: TokenKey.self)

        // Then
        #expect(keychain.key == TokenKey.name)
    }
}

private struct TokenKey: StorageKey { typealias Value = String }
