//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Testing
import Telemetry

@testable import Utilities

struct SystemFileWriterTests {
    // MARK: - Tests
    
    @Test
    func testThatRemoveShouldSucceedsDeletesWhenExistingFile() throws {
        // Given
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("file_to_delete.json")
        try "Test".write(to: tempURL, atomically: true, encoding: .utf8)
        let sut = SystemFileWriter()

        // When
        try sut.remove(at: tempURL)

        // Then
        #expect(!FileManager.default.fileExists(atPath: tempURL.path))
    }
    
    @Test
    func testThatRemoveURLShouldFailsWhenThrowsAnyError() throws {
        // Given
        var expectedError: UtilityError?
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("protected.json")
        let sut = SystemFileWriter(fileManager: FileManagerMock())
        
        // When
        do {
            try sut.remove(at: tempURL)
        } catch let error as UtilityError? {
            expectedError = error
        }

        // Then
        #expect(expectedError?.kind == .FileWriterErrorReason.removeAtURLFailed)
    }
    
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
        var expectedError: UtilityError!
        let invalidURL = URL(fileURLWithPath: "/invalid/path/that/does/not/exist/file.json")
        let sut = SystemFileWriter()
        let testContent = TestCodable(id: 1, name: "Test", isActive: true)
        
        // When
        do {
            try sut.write(testContent, to: invalidURL)
        } catch let error as UtilityError? {
            expectedError = error
        }
        
        // Then
        #expect(
            expectedError.kind == .FileWriterErrorReason.writeToFileFailed,
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


private final class FileManagerMock: FileManager {
    override func removeItem(at URL: URL) throws {
        throw NSError(domain: NSCocoaErrorDomain, code: 513, userInfo: nil)
    }
}

private struct TestCodable: Codable, Equatable {
    let id: Int
    let name: String
    let isActive: Bool
}
