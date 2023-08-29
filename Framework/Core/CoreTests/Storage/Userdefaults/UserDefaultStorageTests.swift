//
//  UserDefaultStorageTests.swift
//
//  Created by TruVideo on 8/08/23.
//  Copyright © TruVideo. All rights reserved.
//

import XCTest

@testable import Core

final class UserDefaultStorageTests: CoreTests {
    let sut = UserDefaultsStorage()

    // MARK: Overriden methods

    override func setUpWithError() throws {
        try sut.clear()
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    // MARK: Tests

    func testThatSaveInStorageShouldSucceed() throws {
        // Given
        let sut = UserDefaultsStorage()

        // When
        try sut.write("Test", forKey: "Test")

        // Then
        let read = try sut.readValue(String.self, forKey: "Test")
        XCTAssertEqual(read, "Test")
    }

    func testThatDeleteValueInStorageShouldSucceed() throws {
        // Given
        let sut = UserDefaultsStorage()

        // When
        try sut.delete(key: "Test")

        // Then
        let read = try sut.readValue(String.self, forKey: "Test")
        XCTAssertNil(read)
    }

    func testThatReadStorageValueIsNil() throws {
        // Given
        let sut = UserDefaultsStorage()

        // When, Then
        XCTAssertNil(try? sut.readValue(String.self, forKey: "Test2"))
    }

    func testThatReadStorageValueShouldFail() throws {
        // Given
        let sut = UserDefaultsStorage()
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
}
