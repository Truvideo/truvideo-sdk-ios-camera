//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Testing

@testable import Networking

struct NetworkingErrorTests {
    
    // MARK: - Tests
    
    @Test func testThatInitialization() {
        // Given
        let sut = NetworkingError(kind: .explicitlyCancelled)

        // When, Then
        #expect(sut.errorDescription == nil, "Expected errorDescription to be nil")
    }

    @Test func testThatNetworkingErrorInitializationWithFailureReason() {
        // Given
        let sut = NetworkingError(kind: .explicitlyCancelled, failureReason: "failed")

        // When, Then
        #expect(sut.failureReason == "failed", "Expected failureReason to be equals to failed")
        #expect(sut.errorDescription == "failed", "Expected errorDescription to be equals to failed")
    }

    @Test func testThatInitializationWithUnderlyingError() {
        // Given
        let sut = NetworkingError(kind: .explicitlyCancelled, underlyingError: NSError(domain: "", code: 0))

        // When, Then
        #expect(
            sut.errorDescription == "The operation couldn’t be completed. ( error 0.)",
            "Expected failureReason to be equals to The operation couldn’t be completed. ( error 0.)"
        )
    }
}
