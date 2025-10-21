//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Testing

@testable import InternalUtilities

struct EnvironmentTests {
    // MARK: - Tests

    @Test
    func testThatEnvironmentDevShouldUseCorrectRawValue() {
        // Given
        let environment = Environment.dev

        // When, Then
        #expect(environment.rawValue == "DEV")
    }

    func testThatEnvironmentBetaShouldUseCorrectRawValue() {
        // Given
        let environment = Environment.beta

        // When, Then
        #expect(environment.rawValue == "BETA")
    }

    @Test
    func testThatEnvironmentRcShouldUseCorrectRawValue() {
        // Given
        let environment = Environment.rc

        // When, Then
        #expect(environment.rawValue == "RC")
    }

    @Test
    func testThatEnvironmentProdShouldUseCorrectRawValue() {
        // Given
        let environment = Environment.prod

        // When, Then
        #expect(environment.rawValue == "PROD")
    }
}
