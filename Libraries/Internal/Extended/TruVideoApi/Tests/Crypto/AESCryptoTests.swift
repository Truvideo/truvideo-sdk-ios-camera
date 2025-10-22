//
// Copyright © 2025 TruVideo. All rights reserved.
//

import CryptoKit
import Foundation
import Testing

@testable import TruVideoApi

struct AESCryptoTests {
    // MARK: - Tests

    @Test
    func testThatEncryptData() async throws {
        // Given
        let crypto = AESCrypto(secretKey: "KEY")
        let authSession = AuthSession.mock

        // When, Then
        let data = try crypto.encrypt(authSession)

        // Then
        #expect(data != nil)
    }

    @Test
    func testThatDecryptData() async throws {
        // Given
        let authSession = AuthSession.mock
        let crypto = AESCrypto(secretKey: "KEY")

        // When
        let data = try crypto.encrypt(authSession)
        let session = try crypto.decrypt(AuthSession.self, from: data)

        // Then
        #expect(authSession.apiKey == session.apiKey)
        #expect(authSession.authToken.id == session.authToken.id)
        #expect(authSession.authToken.accessToken == session.authToken.accessToken)
        #expect(authSession.authToken.refreshToken == session.authToken.refreshToken)
    }
}
