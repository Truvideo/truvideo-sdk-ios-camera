//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import NetworkingTesting
import Testing

@testable import Networking

struct HTTPURLUploadRequestTests {
    // MARK: - Private Properties
    
    private let queue = DispatchQueue.global()
    private let request = URLRequest(url: URL(string: "https://httpbin.org/")!)
    
    // MARK: - Tests
    
    @Test
    func testThatDidCreateUploadableShouldSucceeds() async throws {
        // Given
        let monitor = MonitorMock()
        let data = "Test".data(using: .utf8)!
        let uploadBuilder = UploadBuilderMock(data: data)
        let sut = HTTPURLUploadRequest(
            uploadBuilder: uploadBuilder,
            delegate: nil,
            middleware: nil,
            monitor: monitor,
            queue: queue
        )
        
        // When
        let uploadable = try uploadBuilder.createUploadable()
        
        sut.didCreateUploadable(uploadable)
        
        // Then
        #expect(uploadable != nil)
        #expect(sut.state == .initialized)
        #expect(monitor.uploadRequestDidCreateUploadableCallCount == 1)
    }
    
    @Test
    func tesThatDidFailToCreateUploadableShouldFailWhenErrorOccurs() async throws {
        // Given
        let monitor = MonitorMock()
        let data = "Test".data(using: .utf8)!
        let uploadBuilder = UploadBuilderMock(data: data)
        let sut = HTTPURLUploadRequest(
            uploadBuilder: uploadBuilder,
            delegate: nil,
            middleware: nil,
            monitor: monitor,
            queue: queue
        )
        
        // When
        sut.didFailToCreateUploadable(with: NetworkingError.errorMock)
        
        // Then
        #expect(sut.state == .initialized)
        #expect(monitor.uploadRequestDidFailToCreateUploadableCallCount == 1)
    }
    
    @Test
    func testThatResetClearsUploadableShouldSucceeds() async throws {
        // Given
        let monitor = MonitorMock()
        let data = "Test".data(using: .utf8)!
        let uploadBuilder = UploadBuilderMock(data: data)
        let sut = HTTPURLUploadRequest(
            uploadBuilder: uploadBuilder,
            delegate: nil,
            middleware: nil,
            monitor: monitor,
            queue: queue
        )
        
        // When
        let uploadable = try uploadBuilder.createUploadable()
        sut.didCreateUploadable(uploadable)
        sut.reset()
        
        // Then
        #expect(sut.state == .initialized)
    }
    
    @Test
    func testThatTaskShouldSucceed() async throws {
        // Given
        let monitor = MonitorMock()
        let data = "Test".data(using: .utf8)!
        let uploadBuilder = UploadBuilderMock(data: data)
        let sut = HTTPURLUploadRequest(
            uploadBuilder: uploadBuilder,
            delegate: nil,
            middleware: nil,
            monitor: monitor,
            queue: queue
        )
        let url = URLSession(configuration: URLSessionConfiguration.default)
        let request = URLRequest(url: URL(string: "https://example.com")!)
        
        // When
        let uploadable = try uploadBuilder.createUploadable()
        sut.didCreateUploadable(uploadable)
        
        let task = try sut.task(for: request, using: url)
        
        task.resume()
        
        // Then
        #expect(task is URLSessionUploadTask)
        #expect(task.state == .running)
    }
    
    @Test
    func testThatTaskThrowsCreateUploadableFailedErrorWhenUploadBuilderFails() async throws {
        // Given
        let expectedError: NetworkingError!
        let monitor = MonitorMock()
        let uploadBuilder = UploadBuilderFailingMock()
        let sut = HTTPURLUploadRequest(
            uploadBuilder: uploadBuilder,
            delegate: nil,
            middleware: nil,
            monitor: monitor,
            queue: queue
        )
        let url = URLSession(configuration: URLSessionConfiguration.default)
        let request = URLRequest(url: URL(string: "https://example.com")!)
        
        // When, Then
        #expect {
            try sut.task(for: request, using: url)
        } throws: { expectedError in
            guard let error = expectedError as? NetworkingError else {
                return false
            }
            
            return error.kind == .createUploadableFailed
            
        }
    }
}

private struct UploadBuilderMock: UploadRequestBuilder {
    let data: Data
    
    func createUploadable() throws -> Networking.HTTPURLUploadRequest.Uploadable {
        .data(data)
    }
    
    func build() throws -> URLRequest {
        URLRequest(url: URL(string: "test")!)
    }
}

private struct UploadBuilderFailingMock: UploadRequestBuilder {
    func createUploadable() throws -> Networking.HTTPURLUploadRequest.Uploadable {
        throw NetworkingError(
            kind: .createUploadableFailed,
            failureReason: "Attempting to create a URLSessionUploadTask when Uploadable value doesn't exist."
        )
    }
    
    func build() throws -> URLRequest {
        URLRequest(url: URL(string: "test")!)
    }
}
