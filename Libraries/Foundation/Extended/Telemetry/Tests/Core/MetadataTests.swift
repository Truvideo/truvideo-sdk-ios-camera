//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Testing

@testable import Telemetry

struct MetadataTests {
    
    // MARK: - Tests

    @Test
    func testThatPrettifyEmpty() {
        // Given
        let metadata: Metadata = [:]

        // When, Then
        #expect(metadata.prettify() == nil)
    }

    @Test
    func testThatPrettifyValidMetadata() {
        // Given
        let expectedKeys = ["username", "age", "active", "info"]
        let metadata: Metadata = [
            "username": "test",
            "age": 30,
            "active": true,
            "info": [
                "email": "test@example.com",
                "score": 95.5
            ]
        ]

        // When
        let result = metadata.prettify()
        
        // Then
        #expect(result != nil)
        for key in expectedKeys {
            #expect(result?.contains("\"\(key)\"") == true)
        }
    }

    @Test
    func testThatDescription() {
        // Given, When, Then
        #expect(MetadataValue.string("Hello").description == "Hello")
        #expect(MetadataValue.int(42).description == "42")
        #expect(MetadataValue.double(3.14).description == "3.14")
        #expect(MetadataValue.bool(true).description == "true")
        #expect(MetadataValue.array([.int(1), .string("a")]).description.contains("1"))
        #expect(MetadataValue.dictionary(["key": .bool(false)]).description.contains("false"))
    }

    @Test
    func testThatDecoding() throws {
        // Given
        let decoder = JSONDecoder()
        let json = """
        {
            "name": "Test",
            "count": 10,
            "isEnabled": true,
            "rating": 4.5,
            "tags": ["swift", "ios"],
            "details": {
                "nested": false
            }
        }
        """
        let data = Data(json.utf8)
        
        // When
        let result = try decoder.decode(Metadata.self, from: data)
        
        // Then
        #expect(result["name"] == .string("Test"))
        #expect(result["count"] == .int(10))
        #expect(result["isEnabled"] == .bool(true))
        #expect(result["rating"] == .double(4.5))
        #expect(result["tags"] == .array(["swift", "ios"]))
        #expect(result["details"] == .dictionary(["nested": false]))
    }

    @Test
    func testThatEncoding() throws {
        // Given
        let metadata: Metadata = [
            "language": "Swift",
            "version": 5,
            "typed": true,
            "supportedPlatforms": ["iOS", "macOS", "tvOS"],
            "authors": ["Apple": "https://developer.apple.com/"],
            "license": 2.0
        ]
        
        // When
        let data = try JSONEncoder().encode(metadata)
        let string = String(data: data, encoding: .utf8)
        
        // Then
        #expect(string?.contains("language") == true)
        #expect(string?.contains("Swift") == true)
        #expect(string?.contains("version") == true)
        #expect(string?.contains("5") == true)
        #expect(string?.contains("typed") == true)
        #expect(string?.contains("true") == true)
        #expect(string?.contains("supportedPlatforms") == true)
        #expect(string?.contains("license") == true)
    }
}
