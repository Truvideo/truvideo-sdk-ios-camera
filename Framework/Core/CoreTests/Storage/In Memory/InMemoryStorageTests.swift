//
//  InMemoryStorageTests.swift
//
//  Created by TruVideo on 8/08/23.
//  Copyright © TruVideo. All rights reserved.
//

import XCTest

@testable import Core

final class InMemoryStorageTests: CoreTests {

    // MARK: Tests

    func testThatSaveInStorageShouldSucceed() throws {
        // Given
        let sut = InMemoryStorage()

        // When
        try sut.write("Test", forKey: "Test")

        // Then
        let read = try sut.readValue(String.self, forKey: "Test")
        XCTAssertEqual(read, "Test")
    }

    func testThatDeleteValueInStorageShouldSucceed() throws {
        // Given
        let sut = InMemoryStorage()

        // When
        try sut.delete(key: "Test")

        // Then
        let read = try sut.readValue(String.self, forKey: "Test")
        XCTAssertNil(read)
    }

    func testThatReadStorageValueIsNil() throws {
        // Given
        let sut = InMemoryStorage()

        // When, Then
        XCTAssertNil(try? sut.readValue(String.self, forKey: "Test2"))
    }

    func testThatReadStorageValueShouldFail() throws {
        // Given
        let sut = InMemoryStorage()
        var storageError: StorageError!

        // When
        try sut.write("Test", forKey: "Test")
        do {
            let _ = try sut.readValue(Bool.self, forKey: "Test")
        } catch {
            storageError = error as? StorageError
        }

        // Then
        XCTAssertEqual(storageError.kind, .readValueFailed)
    }

    func testThatClearValuesInStorageShouldSucceed() throws {
        // Given
        let sut = InMemoryStorage()

        // When
        try sut.write("Test", forKey: "Test")
        try sut.clear()

        // Then
        let read = try sut.readValue(String.self, forKey: "Test")
        XCTAssertNil(read)
    }
}
