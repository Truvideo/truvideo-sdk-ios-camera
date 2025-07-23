//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Testing
import Utilities

@testable import Telemetry

struct S3ClientProviderTests {

    // MARK: - Tests

    @Test
    func testThatCreateNewS3ClientWithCredentials() async throws {
        // Given
        let sut = S3ClientImpl(accessKey: "access", secretKey: "secret", region: "region")

        // When, Then
        _ = try await sut.makeClient()
    }

    @Test
    func testThatReturnCachedS3Client() async throws {
        // Given
        let client = MockS3Client()
        let sut = S3ClientImpl(client: client)

        // When
        _ = try await sut.makeClient()

        // Then
        #expect(client.putObjectCallCount == 0)
    }
}
