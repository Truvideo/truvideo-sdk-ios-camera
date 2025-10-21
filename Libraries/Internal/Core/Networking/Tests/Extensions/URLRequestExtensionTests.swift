//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Testing

@testable import Networking

struct URLRequestExtensionTests {
    // MARK: - Tests

    @Test
    func testThatHTTPMethod() throws {
        // Given
        let sut = try URLRequest(url: "https://httpbin.org/", method: .post)

        // When, Then
        #expect(sut.method == .post)
    }

    @Test
    func testThatHTTPMethodShouldReturnGetByDefault() throws {
        // Given
        var sut = URLRequest(url: URL(string: "https://httpbin.org/")!)

        // When
        sut.httpMethod = ""

        // Then
        #expect(sut.method == .get)
    }
}
