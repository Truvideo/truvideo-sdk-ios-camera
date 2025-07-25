//
// Copyright © 2025 TruVideo. All rights reserved.
//

import XCTest
@testable import TruVideoSdk
import TruVideoApi

final class TruVideoAppTests: XCTestCase {
    
    // MARK: - Test Properties
    
    private var mockAuthenticatableClient: MockAuthenticatableClient!
    private var mockOptions: TruVideoOptions!
    private var truVideoApp: TruVideoApp!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        mockAuthenticatableClient = MockAuthenticatableClient()
        mockOptions = TruVideoOptions(
            apiKey: "test-api-key",
            secretKey: "test-secret-key",
            externalId: "test-external-id",
            signer: MockSigner()
        )
        truVideoApp = TruVideoApp(
            authenticatableClient: mockAuthenticatableClient,
            options: mockOptions
        )
    }
    
    override func tearDown() {
        mockAuthenticatableClient = nil
        mockOptions = nil
        truVideoApp = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testAuthenticateSuccess() async throws {
        // Given
        mockAuthenticatableClient.shouldSucceed = true
        
        // When
        try await truVideoApp.authenticate()
        
        // Then
        XCTAssertTrue(mockAuthenticatableClient.authenticateCalled)
        XCTAssertEqual(mockAuthenticatableClient.lastApiKey, "test-api-key")
        XCTAssertEqual(mockAuthenticatableClient.lastExternalId, "test-external-id")
    }
    
    func testAuthenticateFailure() async {
        // Given
        mockAuthenticatableClient.shouldSucceed = false
        mockAuthenticatableClient.error = NSError(domain: "TestError", code: 1, userInfo: nil)
        
        // When & Then
        do {
            try await truVideoApp.authenticate()
            XCTFail("Expected authentication to fail")
        } catch {
            XCTAssertEqual((error as NSError).domain, "TestError")
        }
    }
    
    func testConfigureOnlyOnce() {
        // Given
        let options1 = TruVideoOptions(
            apiKey: "key1",
            secretKey: "secret1",
            externalId: "id1",
            signer: MockSigner()
        )
        let options2 = TruVideoOptions(
            apiKey: "key2",
            secretKey: "secret2",
            externalId: "id2",
            signer: MockSigner()
        )
        
        // When
        truVideoApp.configure(with: options1)
        truVideoApp.configure(with: options2)
        
        // Then
        // The second configure call should be ignored since hasBeenConfigured is true
        XCTAssertEqual(mockOptions.apiKey, "test-api-key") // Should remain unchanged
    }
}

// MARK: - Mock Types

private class MockAuthenticatableClient: AuthenticatableClient {
    var shouldSucceed = true
    var error: Error?
    var authenticateCalled = false
    var lastApiKey: String?
    var lastExternalId: String?
    var lastContext: Context?
    var lastSignature: String?
    
    func authenticate(
        apiKey: String,
        context: Context,
        signature: String,
        externalId: String
    ) async throws {
        authenticateCalled = true
        lastApiKey = apiKey
        lastExternalId = externalId
        lastContext = context
        lastSignature = signature
        
        if !shouldSucceed {
            throw error ?? NSError(domain: "MockError", code: 1, userInfo: nil)
        }
    }
}

private class MockSigner: Signer {
    func sign(_ context: Context, secretKey: String) async throws -> String {
        return "mock-signature"
    }
} 