//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Testing

@testable import Networking

struct StringExtensionTests {
    // MARK: - Tests

    @Test
    func testThatAsURLReturnsAValidURL() throws {
        // Given, When, Then
        #expect(try "https://httpbin.org/".asURL() == URL(string: "https://httpbin.org/")!)
    }

    @Test
    func testThatSuccessResultShouldReturnNil() {
        // Given, When, Then
        #expect(throws: NetworkingError.self) {
            try "".asURL()
        }
    }
}
