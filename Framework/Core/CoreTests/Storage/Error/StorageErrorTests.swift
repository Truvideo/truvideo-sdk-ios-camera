//
//  StorageErrorTests.swift
//
//  Created by TruVideo on 18/08/23.
//  Copyright © TruVideo. All rights reserved.
//

import XCTest
@testable import Core

final class StorageErrorTests: CoreTests {

    // MARK: Tests

    func testThatInit() throws {
        // Given
        let error = NSError(domain: "", code: 0)
        let sut = StorageError(kind: .deleteFailed, underlyingError: error, column: 2, line: 3)
        
        // When, Then
        XCTAssertNotNil(sut)
    }
}
