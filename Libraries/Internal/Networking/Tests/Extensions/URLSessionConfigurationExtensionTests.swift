//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Testing

@testable import Networking

struct URLSessionConfigurationExtensionTests {
    
    // MARK: - Tests
    
    @Test func testThatSetHeadersShouldStoreTheHeader() {
        // Given
        let sut = URLSessionConfiguration.ephemeral
        
        // When
        sut.headers = ["header": "value"]
        
        // Then
        #expect(sut.headers["header"] == "value", "Expected header to be equals to value")
    }
    
    @Test func testThatHeadersShouldBeEmptyIfNotSet() {
        // Given
        let sut = URLSessionConfiguration.ephemeral
        
        // When, Then
        #expect(sut.headers == HTTPHeaders(), "Expected header to be empty")
    }
    
    @Test func testThatCreateDefaultSessionConfiguration() {
        // Given
        let sut = URLSessionConfiguration.createDefault()
        
        // When, Then
        #expect(sut.headers == .default, "Expected headers to be equals to HTTPHeaders.default")
        #expect(sut.httpCookieStorage == .shared, "Expected httpCookieStorage to be equals to HTTPCookieStorage.shared")
        #expect(sut.urlCache == nil, "Expected urlCache to be nil")
        #expect(sut.urlCredentialStorage == nil, "Expected urlCredentialStorage to be nil")
        #if os(iOS)
        #expect(sut.multipathServiceType == .handover, "Expected multipathServiceType to be .handover")
        #endif
    }
}
