import Foundation
import Testing

@testable import TruVideoApi

struct EnvironmentTests {
    // MARK: - Tests
    
    @Test
    func testThatEnvironmentDevShouldUseCorrectBaseURL() {
        // Given
        let environment = Environment.dev
        
        // When, Then
        #expect(environment.baseURL == "https://sdk-mobile-api-dev.truvideo.com")
    }
    
    @Test
    func testThatEnvironmentDevShouldUseCorrectRawValue() {
        // Given
        let environment = Environment.dev
        
        // When, Then
        #expect(environment.rawValue == "DEV")
    }

    @Test
    func testThatEnvironmentBetaShouldUseCorrectBaseURL() {
        // Given
        let environment = Environment.beta
        
        // When, Then
        #expect(environment.baseURL == "https://sdk-mobile-api-beta.truvideo.com")
    }
    
    func testThatEnvironmentBetaShouldUseCorrectRawValue() {
        // Given
        let environment = Environment.beta
        
        // When, Then
        #expect(environment.rawValue == "BETA")
    }

    @Test
    func testThatEnvironmentRcShouldUseCorrectBaseURL() {
        let environment = Environment.rc
        
        // When, Then
        #expect(environment.baseURL == "https://sdk-mobile-api-rc.truvideo.com")
    }
    
    @Test
    func testThatEnvironmentRcShouldUseCorrectRawValue() {
        // Given
        let environment = Environment.rc
        
        // When, Then
        #expect(environment.rawValue == "RC")
    }

    @Test
    func testThatEnvironmentProdShouldUseCorrectBaseURL() {
        // Given
        let environment = Environment.prod
        
        // When, Then
        #expect(environment.baseURL == "https://sdk-mobile-api.truvideo.com")
    }
    
    @Test
    func testThatEnvironmentProdShouldUseCorrectRawValue() {
        // Given
        let environment = Environment.prod
        
        // When, Then
        #expect(environment.rawValue == "PROD")
    }

    @Test
    func testThatUnknownEnvironmentReturnsProductionBaseURLByDefault() {
        // Given
        let custom = Environment(rawValue: "STAGING")
        
        // When, Then
        #expect(custom.baseURL == "https://sdk-mobile-api.truvideo.com")
    }
}
