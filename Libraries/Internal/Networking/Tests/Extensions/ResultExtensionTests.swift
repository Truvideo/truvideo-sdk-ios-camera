//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Testing

@testable import Networking

struct ResultExtensionTests {
    
    // MARK: - Tests
    
    @Test func testThatFailureResultShouldReturnTheFailure() {
        // Given
        let sut = Result<Void, NetworkingError>.failure(NetworkingError(kind: .explicitlyCancelled))
        
        // When, Then
        #expect(sut.failure?.kind == .explicitlyCancelled, "Expected error to be equals to explicitlyCancelled")
    }
    
    @Test func testThatSuccessResultShouldReturnNil() {
        // Given
        let sut = Result<String, NetworkingError>.success("")
        
        // When, Then
        #expect(sut.failure == nil, "Expected error to be nil")
    }
}
