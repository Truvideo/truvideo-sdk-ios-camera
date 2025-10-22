//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
import Foundation
import StorageKit
import Testing

@testable import TruVideoApi

struct SecureSessionManagerTests {
    // MARK: - Private Properties

    private let crypto: CryptoMock

    // MARK: - Initializer

    init() {
        self.crypto = CryptoMock()
    }

    // MARK: - Tests

    @Test
    func testThatInitializationUsesUserDefaultStorageByDefault() async throws {
        // Given
        let sut = SecureSessionManager(secretKey: "")

        // When, Then
        #expect(sut.storage is UserDefaultsStorage)
    }

    @Test
    func testThatCurrentSessionReturnNilWhenNoSessionStored() async throws {
        // Given
        let sut = SecureSessionManager(crypto: crypto)

        // When
        sut.storage = InMemoryStorage()

        // Then
        #expect(crypto.decryptCallCount == 0)
        #expect(sut.currentSession == nil)
    }

    @Test
    func testThatDeleteCurrentSessionSession() async throws {
        // Given
        let sut = SecureSessionManager(crypto: crypto)
        let authSession = AuthSession.mock
        var results: [Bool] = []

        // When
        sut.storage = InMemoryStorage()

        try sut.set(authSession)

        results.append(sut.currentSession != nil)

        try sut.deleteCurrentSession()

        results.append(sut.currentSession == nil)

        // Then
        #expect(results == [true, true])
    }

    @Test
    func testThatStoreAndRetrieveSession() async throws {
        // Given
        let sut = SecureSessionManager(crypto: crypto)
        let authSession = AuthSession.mock

        // When
        sut.storage = InMemoryStorage()

        try sut.set(authSession)

        // Then
        #expect(crypto.encryptCallCount == 1)
        #expect(sut.currentSession?.apiKey == authSession.apiKey)
        #expect(sut.currentSession?.authToken.id == authSession.authToken.id)
        #expect(sut.currentSession?.authToken.accessToken == authSession.authToken.accessToken)
        #expect(sut.currentSession?.authToken.refreshToken == authSession.authToken.refreshToken)
    }

    @Test
    func testThatStoreAndRetrieveSessionShouldReturnNilIfDataIsNotValid() async throws {
        // Given
        let sut = SecureSessionManager(crypto: crypto)
        let authSession = AuthSession.mock

        // When
        sut.storage = InMemoryStorage()

        try sut.storage.write(Data(), forKey: SecureSessionManager.AuthSessionStorageKey.self)

        // Then
        #expect(sut.currentSession == nil)
    }

    @Test
    func testThatStoreShouldOverwriteExistingSession() async throws {
        let sut = SecureSessionManager(crypto: crypto)
        let authSession = AuthSession.mock
        let newAuthSession = AuthSession(
            apiKey: "second-api-key",
            authToken: AuthToken(
                id: UUID(),
                accessToken: "second-access-token",
                refreshToken: "second-refresh-token"
            )
        )

        // When
        sut.storage = InMemoryStorage()

        try sut.set(authSession)
        try sut.set(newAuthSession)

        // Then
        #expect(crypto.encryptCallCount == 2)
        #expect(sut.currentSession?.apiKey == newAuthSession.apiKey)
        #expect(sut.currentSession?.authToken.accessToken == newAuthSession.authToken.accessToken)
        #expect(sut.currentSession?.authToken.refreshToken == newAuthSession.authToken.refreshToken)
    }
}
