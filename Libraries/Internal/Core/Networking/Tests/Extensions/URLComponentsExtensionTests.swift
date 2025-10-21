//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Testing

@testable import Networking

struct URLComponentsExtensionTests {
    // MARK: - Tests

    @Test
    func testThatAsURLReturnsAValidURL() throws {
        // Given
        let url = URL(string: "https://httpbin.org/")!
        let sut = URLComponents(url: url, resolvingAgainstBaseURL: false)

        // When, Then
        #expect(try sut?.asURL() == url)
    }

    @Test
    func testThatAsURLThrowsAnErrorOnInvalidURL() throws {
        // Given
        let sut = URLComponents()

        // When, Then
        #expect {
            try sut.asURL()
        } throws: { error in
            guard let error = error as? NetworkingError else {
                return false
            }

            return error.kind == .invalidURL
        }
    }
}
