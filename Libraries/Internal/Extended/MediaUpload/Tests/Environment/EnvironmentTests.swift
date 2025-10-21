// Copyright © 2025 TruVideo. All rights reserved.

import Foundation
import InternalUtilities
import Testing

@testable import MediaUpload

struct UploadEnvironmentTests {
    // MARK: - Tests

    @Test
    func testThatEnvironmentDevShouldUseCorrectBaseURL() {
        // Given
        let environment = Environment.dev

        // When, Then
        #expect(environment.baseURL == "https://upload-api-dev.truvideo.com")
    }

    @Test
    func testThatEnvironmentBetaShouldUseCorrectBaseURL() {
        // Given
        let environment = Environment.beta

        // When, Then
        #expect(environment.baseURL == "https://upload-api-beta.truvideo.com")
    }

    @Test
    func testThatEnvironmentRcShouldUseCorrectBaseURL() {
        // Given
        let environment = Environment.rc

        // When, Then
        #expect(environment.baseURL == "https://upload-api-rc.truvideo.com")
    }

    @Test
    func testThatEnvironmentProdShouldUseCorrectBaseURL() {
        // Given
        let environment = Environment.prod

        // When, Then
        #expect(environment.baseURL == "https://upload-api.truvideo.com")
    }

    @Test
    func testThatUnknownEnvironmentReturnsProductionBaseURLByDefault() {
        // Given
        let custom = Environment(rawValue: "STAGING")

        // When, Then
        #expect(custom.baseURL == "https://upload-api.truvideo.com")
    }
}
