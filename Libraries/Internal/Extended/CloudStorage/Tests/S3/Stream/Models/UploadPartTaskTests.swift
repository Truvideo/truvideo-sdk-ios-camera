//
// Copyright © 2025 TruVideo. All rights reserved.
//

import NetworkingTesting
import Foundation
import Testing

@testable import CloudStorageKit

struct UploadPartTaskTests {
    // MARK: - Tests
    
    @Test
    func testThatUploadPartTaskShouldInitialize() {
        // Given
        let id = UUID()
        let data = Data("hello".utf8)
        let request = UploadRequestMock()
        
        // When
        let task = UploadPartTask(id: id, partBody: data, partNumber: 42, request: request)
        
        // Then
        #expect(task.id == id)
        #expect(task.partBody == data)
        #expect(task.partNumber == 42)
        #expect(task.request is UploadRequestMock)
    }
    
    @Test
    func testThatUploadTasktPartEqualityReturnsTrueForSameId() {
        // Given
        let id = UUID()
        let task1 = UploadPartTask(id: id, partBody: Data("A".utf8), partNumber: 1, request: UploadRequestMock())
        let task2 = UploadPartTask(id: id, partBody: Data("B".utf8), partNumber: 2, request: UploadRequestMock())
        
        // When, Then
        #expect(task1 == task2)
    }
    
    @Test
    func testThatUploadPartTaskEqualityReturnsFalseForDifferentId() {
        // Given
        let task1 = UploadPartTask(id: UUID(), partBody: Data(), partNumber: 1, request: UploadRequestMock())
        let task2 = UploadPartTask(id: UUID(), partBody: Data(), partNumber: 1, request: UploadRequestMock())
        
        // When, Then
        #expect(task1 != task2)
    }
}
