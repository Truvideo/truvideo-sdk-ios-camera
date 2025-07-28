//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
import Foundation
import Storage
import Testing

@testable import TruVideoApi

struct SessionManagerTests {
    // MARK: - Tests
    
    @Test
    func testThatInitializationUsesKeychainStorageByDefault() async throws {
        // Given
        let sut = SessionManagerImpl()
        
        // When, Then
        #expect(sut.storage is KeychainStorage)
    }
    
    @Test
    func testThatCurrentSessionReturnNilWhenNoSessionStored() async throws {
        // Given
        let sut = SessionManagerImpl()
        
        // When
        sut.storage = InMemoryStorage()
        
        // Then
        #expect(sut.currentSession == nil)
    }
    
    @Test
    func testThatStoreAndRetrieveSession() async throws {
        // Given
        let sut = SessionManagerImpl()
        let authSession = AuthSession(
            apiKey: "test-api-key",
            authToken: AuthToken(
                id: UUID(),
                accessToken: "test-access-token",
                refreshToken: "test-refresh-token"
            )
        )
        
        // When
        sut.storage = InMemoryStorage()
        
        try sut.set(authSession)
        
        // Then
        #expect(sut.currentSession?.apiKey == authSession.apiKey)
        #expect(sut.currentSession?.authToken.id == authSession.authToken.id)
        #expect(sut.currentSession?.authToken.accessToken == authSession.authToken.accessToken)
        #expect(sut.currentSession?.authToken.refreshToken == authSession.authToken.refreshToken)
    }
    
    @Test
    func testThatStoreShouldOverwriteExistingSession() async throws {
        let sut = SessionManagerImpl()
        let authSession = AuthSession(
            apiKey: "test-api-key",
            authToken: AuthToken(
                id: UUID(),
                accessToken: "test-access-token",
                refreshToken: "test-refresh-token"
            )
        )
        
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
        #expect(sut.currentSession?.apiKey == newAuthSession.apiKey)
        #expect(sut.currentSession?.authToken.accessToken == newAuthSession.authToken.accessToken)
        #expect(sut.currentSession?.authToken.refreshToken == newAuthSession.authToken.refreshToken)
    }
}
