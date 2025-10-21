//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Testing

@testable import Networking

struct ProtectedTests {
    // MARK: - Tests

    @Test
    func testThatValuesAreAccessedSafely() {
        // Given
        let initialValue = "value"
        let protected = Protected<String>(initialValue)

        // When
        DispatchQueue.concurrentPerform(iterations: 1000) { iteration in
            _ = protected.read()
            protected.write("\(iteration)")
        }

        // Then
        #expect(protected.wrappedValue != initialValue, "Expected value should not be equals to \(initialValue)")
    }
}
