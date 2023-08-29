//
//  OperatorsTests.swift
//
//  Created by TruVideo on 8/08/23.
//  Copyright © TruVideo. All rights reserved.
//

import XCTest

@testable import Core

final class OperatorsTests: CoreTests {

    // MARK: Overriden methods

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    // MARK: Tests

    func testDictionaryMergeOperator() {
        // Given
        let dict1: [String: Int] = ["a": 1, "b": 2]
        let dict2: [String: Int] = ["b": 3, "c": 4]
        
        // When
        let mergedDict = dict1 ++ dict2
        
        // Then
        XCTAssertEqual(mergedDict["a"], 1)
        XCTAssertEqual(mergedDict["b"], 3)
        XCTAssertEqual(mergedDict["c"], 4)
    }
}
