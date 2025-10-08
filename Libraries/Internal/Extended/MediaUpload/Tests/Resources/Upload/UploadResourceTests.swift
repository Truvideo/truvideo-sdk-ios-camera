//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
import Foundation
import Networking
import NetworkingTesting
import Testing
import Utilities

@testable import MediaUpload

struct UploadResourceTests {
    // MARK: - Private Properties
    
    private let dataRequest = DataRequestMock()
    private let session = SessionMock()
    private let uploadId = "upload-session-foo"
    
    // MARK: - Tests
    
    
    
    // MARK: - Complete
    
    @Test
    func testThatCompleteShouldThrowUploadCompletionFailedOnRequestError() async throws {
        await withDependencyValues { dependencies in
            // Given
            let sut = UploadResourceImpl()
            
            // When
            session.dataRequest = dataRequest
            dependencies.session = session
            dependencies.apiEnvironment = .dev
            dataRequest.mockResponse = Response<Empty, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: nil,
                result: .failure(NetworkingError(kind: .invalidURL, failureReason: "")),
                type: .networkLoad
            )
            
            // Then
            await #expect {
                try await sut.complete(for: uploadId)
            } throws: { error in
                return (error as? UtilityError)?.kind == .MediaUploadErrorReason.completeUploadFailed
            }
        }
    }
    
    @Test
    func testThatCompleteShouldUseCorrectURL() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let sut = UploadResourceImpl()
            
            // When
            session.dataRequest = dataRequest
            dependencies.session = session
            dependencies.apiEnvironment = .dev
            dataRequest.mockResponse = Response<Empty, NetworkingError>(
                data: nil,
                metrics: nil,
                request: nil,
                response: HTTPURLResponse(
                    url: URL(string: "/upload/\(uploadId)/complete/stream")!,
                    statusCode: 200,
                    httpVersion: "HTTP/1.1",
                    headerFields: [
                            "Content-Type": "application/json",
                            "Date": "Thu, 25 Sep 2025 15:42:00 GMT",
                            "Server": "TruVideoMockServer/1.0",
                            "X-Request-ID": UUID().uuidString
                        ]
                ),
                result: .success(Empty.value),
                type: .networkLoad
            )
            
            _ = try await sut.complete(for: uploadId)
            let url = try session.lastRequestURL?.asURL()
            
            // Then
            #expect(url!.absoluteString.contains("/upload/\(uploadId)/complete/stream"))
        }
    }
    
    @Test
    func testThatCompleteShouldUseGetMethod() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let sut = UploadResourceImpl()
            
            // When
            session.dataRequest = dataRequest
            dependencies.session = session
            dependencies.apiEnvironment = .dev
            dataRequest.mockResponse = Response<Empty, NetworkingError>(
                data: nil,
                metrics: nil,
                request: nil,
                response: HTTPURLResponse(
                    url: URL(string: "/api/upload/\(uploadId)/complete")!,
                    statusCode: 200,
                    httpVersion: "HTTP/1.1",
                    headerFields: [
                            "Content-Type": "application/json",
                            "Date": "Thu, 25 Sep 2025 15:42:00 GMT",
                            "Server": "TruVideoMockServer/1.0",
                            "X-Request-ID": UUID().uuidString
                        ]
                ),
                result: .success(Empty.value),
                type: .networkLoad
            )
            
            _ = try await sut.complete(for: uploadId)
            
            // Then
            #expect(session.lastRequestMethod == .post)
        }
    }
    
    // MARK: - Register
    
    @Test
    func testThatRegisterShouldThrowUploadPartRegistrationFailedOnRequestError() async throws {
        await withDependencyValues { dependencies in
            // Given
            let sut = UploadResourceImpl()
            
            // When
            session.dataRequest = dataRequest
            dependencies.apiEnvironment = .dev
            dependencies.session = session
            dataRequest.mockResponse = Response<Empty, NetworkingError>(
                data: nil,
                metrics: nil,
                request: nil,
                response: nil,
                result: .failure(NetworkingError(kind: .invalidURL, failureReason: "")),
                type: .networkLoad
            )
            
            // Then
            await #expect {
                try await sut.register(for: uploadId, partNumber: 1, withETag: "etag-part-0001")
            } throws: { error in
                return (error as? UtilityError)?.kind == .MediaUploadErrorReason.partRegistrationFailed
            }
        }
    }
    
    @Test
    func testThatRegisterShouldUseCorrectParameters() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let sut = UploadResourceImpl()
            
            // When
            session.dataRequest = dataRequest
            dependencies.apiEnvironment = .dev
            dependencies.session = session
            dataRequest.mockResponse = Response<Empty, NetworkingError>(
                data: nil,
                metrics: nil,
                request: nil,
                response: HTTPURLResponse(
                    url: URL(string: "api/upload/\(uploadId)/part")!,
                    statusCode: 200,
                    httpVersion: "HTTP/1.1",
                    headerFields: [
                            "Content-Type": "application/json",
                            "Date": "Thu, 25 Sep 2025 15:42:00 GMT",
                            "Server": "TruVideoMockServer/1.0",
                            "X-Request-ID": UUID().uuidString
                        ]
                ),
                result: .success(Empty.value),
                type: .networkLoad
            )
            
            try await sut.register(for: uploadId, partNumber: 1, withETag: "etag-part-0001")
            
            let parameters = session.lastRequestParameters
            
            // Then
            #expect(parameters?["partNumber"] as? Int == 1)
            #expect(parameters?["etag"] as? String == "etag-part-0001")
        }
    }
    
    @Test
    func testThatRegisterShouldUseCorrectURL() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let sut = UploadResourceImpl()
            
            // When
            session.dataRequest = dataRequest
            dependencies.apiEnvironment = .dev
            dependencies.session = session
            dataRequest.mockResponse = Response<Empty, NetworkingError>(
                data: nil,
                metrics: nil,
                request: nil,
                response: HTTPURLResponse(
                    url: URL(string: "api/upload/\(uploadId)/part")!,
                    statusCode: 200,
                    httpVersion: "HTTP/1.1",
                    headerFields: [
                            "Content-Type": "application/json",
                            "Date": "Thu, 25 Sep 2025 15:42:00 GMT",
                            "Server": "TruVideoMockServer/1.0",
                            "X-Request-ID": UUID().uuidString
                        ]
                ),
                result: .success(Empty.value),
                type: .networkLoad
            )
            
            try await sut.register(for: uploadId, partNumber: 1, withETag: "etag-part-0001")
            
            let url = try session.lastRequestURL?.asURL()
            
            // Then
            #expect(url!.absoluteString.contains("api/upload/\(uploadId)/part"))
        }
    }
    
    @Test
    func testThatRegisterShouldUseGetMethod() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let sut = UploadResourceImpl()
            
            // When
            session.dataRequest = dataRequest
            dependencies.apiEnvironment = .dev
            dependencies.session = session
            dataRequest.mockResponse = Response<Empty, NetworkingError>(
                data: nil,
                metrics: nil,
                request: nil,
                response: HTTPURLResponse(
                    url: URL(string: "/api/upload/\(uploadId)/complete")!,
                    statusCode: 200,
                    httpVersion: "HTTP/1.1",
                    headerFields: [
                            "Content-Type": "application/json",
                            "Date": "Thu, 25 Sep 2025 15:42:00 GMT",
                            "Server": "TruVideoMockServer/1.0",
                            "X-Request-ID": UUID().uuidString
                        ]
                ),
                result: .success(Empty.value),
                type: .networkLoad
            )
            
            try await sut.register(for: uploadId, partNumber: 1, withETag: "etag-part-0001")
            
            // Then
            #expect(session.lastRequestMethod == .post)
        }
    }
    
    // MARK: - Retrieve
    
    @Test
    func testThatRetrieveShouldSucceed() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let sut = UploadResourceImpl()
            
            // When
            session.dataRequest = dataRequest
            dependencies.apiEnvironment = .dev
            dependencies.session = session
            dataRequest.mockResponse = Response<UploadPartResponse, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: nil,
                result: .success(UploadPartResponse.mock),
                type: .networkLoad
            )
            
            let result = try await sut.retrieve(for: uploadId, count: 2)
            
            let firstUploadPart = result.first
            let secondUploadPart = result.last
            
            // Then
            #expect(firstUploadPart?.partNumber == 1)
            #expect(firstUploadPart?.presignedUrl == "https://example-bucket.s3.amazonaws.com/upload-session-foo/part1?signature=abc123")
            
            #expect(secondUploadPart?.partNumber == 2)
            #expect(secondUploadPart?.presignedUrl == "https://example-bucket.s3.amazonaws.com/upload-session-foo/part2?signature=def456")
        }
    }
    
    @Test
    func testThatRetrieveShouldThrowUploadPartsRetrievalFailedOnRequestError() async throws {
        await withDependencyValues { dependencies in
            // Given
            let sut = UploadResourceImpl()
            
            // When
            session.dataRequest = dataRequest
            dependencies.apiEnvironment = .dev
            dependencies.session = session
            dataRequest.mockResponse = Response<UploadPartResponse, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: nil,
                result: .failure(NetworkingError(kind: .invalidURL, failureReason: "")),
                type: .networkLoad
            )
            
            // Then
            await #expect {
                try await sut.retrieve(for: uploadId, count: 2)
            } throws: { error in
                return (error as? UtilityError)?.kind == .MediaUploadErrorReason.retrieveUploadPartsFailed
            }
        }
        
    }
        
    @Test
    func testThatRetrieveShouldUseCorrectURL() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let sut = UploadResourceImpl()
            
            // When
            session.dataRequest = dataRequest
            dependencies.apiEnvironment = .dev
            dependencies.session = session
            dataRequest.mockResponse = Response<UploadPartResponse, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: nil,
                result: .success(UploadPartResponse.mock),
                type: .networkLoad
            )
            
            let _ = try await sut.retrieve(for: uploadId, count: 2)
            
            let url = try session.lastRequestURL?.asURL()
            
            // Then
            #expect(url!.absoluteString.contains("api/upload/parts/\(uploadId)/2"))
        }
    }
    
    @Test
    func testThatRetrieveShouldUseGetMethod() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let sut = UploadResourceImpl()
            
            // When
            session.dataRequest = dataRequest
            dependencies.apiEnvironment = .dev
            dependencies.session = session
            dataRequest.mockResponse = Response<UploadPartResponse, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: nil,
                result: .success(UploadPartResponse.mock),
                type: .networkLoad
            )
            
            let _ = try await sut.retrieve(for: uploadId, count: 2)
            
            // Then
            #expect(session.lastRequestMethod == .get)
        }
    }
    
    // MARK: - Start
    
    @Test
    func testThatStartShouldSucceed() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let sut = UploadResourceImpl()
            
            // When
            session.dataRequest = dataRequest
            dependencies.apiEnvironment = .dev
            dependencies.session = session
            
            dataRequest.mockResponse = Response<UploadSession, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: nil,
                result: .success(UploadSession.mock),
                type: .networkLoad
            )
            
            let result = try await sut.start(for: FileType.mp4)
            
            // Then
            #expect(result.uploadId == "upload-session-foo")
            #expect(result.mediaId == "media-image-001")
        }
    }
    
    @Test
    func testThatStartShouldThrowUploadInitializationFailedOnRequestError() async throws {
        await withDependencyValues { dependencies in
            // Given
            let sut = UploadResourceImpl()
            
            // When
            session.dataRequest = dataRequest
            dependencies.apiEnvironment = .dev
            dependencies.session = session
            
            dataRequest.mockResponse = Response<UploadSession, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: nil,
                result: .failure(NetworkingError(kind: .invalidURL, failureReason: "")),
                type: .networkLoad
            )
            
            // Then
           await #expect {
               try await sut.start(for: FileType.mp4)
            } throws: { error in
                return (error as? UtilityError)?.kind == .MediaUploadErrorReason.uploadInitializationFailed
            }
        }
    }
    
    @Test
    func testThatStartShouldUseCorrectParameters() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let dataRequest = DataRequestMock()
            let sut = UploadResourceImpl()
            let fileType = FileType.mp4
            
            // When
            session.dataRequest = dataRequest
            dependencies.apiEnvironment = .dev
            dependencies.session = session
            
            dataRequest.mockResponse = Response<UploadSession, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: nil,
                result: .success(UploadSession.mock),
                type: .networkLoad
            )
            
            _ = try await sut.start(for: FileType.mp4)
            
            // Then
            #expect(session.lastRequestParameters?["fileType"] as? String == fileType.rawValue)
        }
    }
    
    @Test
    func testThatStartShouldUseCorrectURL() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let sut = UploadResourceImpl()
            
            // When
            session.dataRequest = dataRequest
            dependencies.apiEnvironment = .dev
            dependencies.session = session
            
            dataRequest.mockResponse = Response<UploadSession, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: nil,
                result: .success(UploadSession.mock),
                type: .networkLoad
            )
            
            _ = try await sut.start(for: FileType.mp4)
            let url = try session.lastRequestURL?.asURL()
            
            // Then
            #expect(url!.absoluteString.contains("/api/upload/start"))
        }
    }
    
    @Test
    func testThatStartShouldUseGetMethod() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let sut = UploadResourceImpl()
            
            // When
            session.dataRequest = dataRequest
            dependencies.apiEnvironment = .dev
            dependencies.session = session
            
            dataRequest.mockResponse = Response<UploadSession, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: nil,
                result: .success(UploadSession.mock),
                type: .networkLoad
            )
            
            _ = try await sut.start(for: FileType.mp4)
            
            // Then
            #expect(session.lastRequestMethod == .post)
        }
    }
}

private extension UploadPartResponse {
    /// A mock instance of the upload part response.
    static var mock: UploadPartResponse {
        UploadPartResponse(
            parts: [
                Part(
                    presignedUrl: "https://example-bucket.s3.amazonaws.com/upload-session-foo/part1?signature=abc123",
                    partNumber: 1
                ),
                Part(
                    presignedUrl: "https://example-bucket.s3.amazonaws.com/upload-session-foo/part2?signature=def456",
                    partNumber: 2
                )
            ]
        )
    }
}

private extension UploadSession {
    /// A mock instance of the  upload session.
    static var mock: UploadSession {
        UploadSession(
            uploadId: "upload-session-foo",
            mediaId: "media-image-001"
        )
    }
}
