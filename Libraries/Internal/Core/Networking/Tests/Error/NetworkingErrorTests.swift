//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Testing

@testable import Networking

struct NetworkingErrorTests {
    // MARK: - Tests

    @Test
    func testThatInitialization() {
        // Given
        let sut = NetworkingError(kind: .explicitlyCancelled)

        // When, Then
        #expect(sut.errorDescription == nil)
    }

    @Test
    func testThatNetworkingErrorInitializationWithFailureReason() {
        // Given
        let sut = NetworkingError(kind: .explicitlyCancelled, failureReason: "failed")

        // When, Then
        #expect(sut.failureReason == "failed")
        #expect(sut.errorDescription == "failed")
    }

    @Test
    func testThatInitializationWithUnderlyingError() {
        // Given
        let sut = NetworkingError(kind: .explicitlyCancelled, underlyingError: NSError(domain: "", code: 0))

        // When, Then
        #expect(sut.errorDescription == "The operation couldn’t be completed. ( error 0.)")
    }
}
