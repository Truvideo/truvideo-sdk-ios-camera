//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Testing
import Utilities

@testable import Telemetry

struct SystemFileWriterTests {
    // MARK: - Tests
    
    @Test
    func testThatWriteCreatesFileAndWritesContent() throws {
        // Given
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("test_write.json")
        let sut = SystemFileWriter()
        let testContent = TestCodable(id: 1, name: "Test", isActive: true)
        
        // When
        try sut.write(testContent, to: tempURL)

        let fileExists = FileManager.default.fileExists(atPath: tempURL.path)
        let fileContent = try String(contentsOf: tempURL, encoding: .utf8)
        
        // Then
        #expect(fileExists, "File should be created")
        #expect(fileContent.contains("\"id\":1"), "Should contain id property")
        #expect(fileContent.contains("\"name\":\"Test\""), "Should contain name property")
        #expect(fileContent.contains("\"isActive\":true"), "Should contain isActive property")
        #expect(fileContent.hasSuffix("\n"), "Should end with newline")
        
        try? FileManager.default.removeItem(at: tempURL)
    }
    
    @Test
    func testThatWriteAppendsToExistingFile() throws {
        // Given
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("test_append.json")
        let sut = SystemFileWriter()
        let firstContent = TestCodable(id: 1, name: "First", isActive: true)
        let secondContent = TestCodable(id: 2, name: "Second", isActive: false)
        
        // When
        try sut.write(firstContent, to: tempURL)
        try sut.write(secondContent, to: tempURL)

        let fileContent = try String(contentsOf: tempURL, encoding: .utf8)
        let lines = fileContent.components(separatedBy: .newlines).filter { !$0.isEmpty }
        
        // Then
        #expect(lines.count == 2, "Should have exactly two lines")

        #expect(fileContent.contains("\"id\":1"), "Should contain first object id")
        #expect(fileContent.contains("\"name\":\"First\""), "Should contain first object name")
        #expect(fileContent.contains("\"isActive\":true"), "Should contain first object isActive")
        
        #expect(fileContent.contains("\"id\":2"), "Should contain second object id")
        #expect(fileContent.contains("\"name\":\"Second\""), "Should contain second object name")
        #expect(fileContent.contains("\"isActive\":false"), "Should contain second object isActive")

        try? FileManager.default.removeItem(at: tempURL)
    }
    
    @Test
    func testThatWriteShouldFail() throws {
        // Given
        var writeError: UtilityError!
        let invalidURL = URL(fileURLWithPath: "/invalid/path/that/does/not/exist/file.json")
        let sut = SystemFileWriter()
        let testContent = TestCodable(id: 1, name: "Test", isActive: true)
        
        // When
        do {
            try sut.write(testContent, to: invalidURL)
        } catch let error as UtilityError {
            writeError = error
        }
        
        // Then
        #expect(
            writeError.kind == .TelemetryErrorReason.writeToFileFailed,
            "Should have writeToFileFailed error reason"
        )
    }
    
    @Test
    func testThatWriteUsesCustomEncoder() throws {
        // Given
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("test_custom_encoder.json")
        let customEncoder = JSONEncoder()
        customEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let sut = SystemFileWriter(encoder: customEncoder)
        let testContent = TestCodable(id: 1, name: "Test", isActive: true)
        let expectedJSON = """
        {
          "id" : 1,
          "isActive" : true,
          "name" : "Test"
        }
        """
        
        // When
        try sut.write(testContent, to: tempURL)
        let fileContent = try String(contentsOf: tempURL, encoding: .utf8)
        
        // Then
        #expect(fileContent == expectedJSON + "\n", "File content should use custom encoder formatting")
        
        try? FileManager.default.removeItem(at: tempURL)
    }
}

private struct TestCodable: Codable, Equatable {
    let id: Int
    let name: String
    let isActive: Bool
}
