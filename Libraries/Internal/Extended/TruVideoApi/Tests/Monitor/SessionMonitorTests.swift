//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
import Foundation
import Networking
import NetworkingTesting
import Testing
import Utilities

@testable import TruVideoApi

struct SessionMonitorTests {
    // MARK: - Tests

    @Test
    func testThatMonitorShouldCallLoggerMethodsOnSuccess() async throws {
        await withDependencyValues { _ in
            // Given
            let sut = AuthenticationClient()

            // When, Then
            #expect(sut.session is HTTPURLSession, "Expected the default session to be HTTPURLSession")
        }
    }
}
