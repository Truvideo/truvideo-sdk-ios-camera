//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Testing

@testable import Networking

struct URLSessionConfigurationExtensionTests {
    // MARK: - Tests

    @Test
    func testThatSetHeadersShouldStoreTheHeader() {
        // Given
        let sut = URLSessionConfiguration.ephemeral

        // When
        sut.headers = ["header": "value"]

        // Then
        #expect(sut.headers["header"] == "value")
    }

    @Test
    func testThatHeadersShouldBeEmptyIfNotSet() {
        // Given
        let sut = URLSessionConfiguration.ephemeral

        // When, Then
        #expect(sut.headers == HTTPHeaders())
    }

    @Test
    func testThatCreateDefaultSessionConfiguration() {
        // Given
        let sut = URLSessionConfiguration.createDefault()

        // When, Then
        #expect(sut.headers == .default)
        #expect(sut.httpCookieStorage == .shared)
        #expect(sut.urlCache == nil)
        #expect(sut.urlCredentialStorage == nil)
        #if os(iOS)
            #expect(sut.multipathServiceType == .handover)
        #endif
    }
}
