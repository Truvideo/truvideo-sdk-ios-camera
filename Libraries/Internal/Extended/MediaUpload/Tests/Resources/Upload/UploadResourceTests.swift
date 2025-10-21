//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
import Foundation
import InternalUtilities
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
    func testThatCompleteShouldThrowCompleteUploadFailedOnRequestError() async throws {
        await withDependencyValues { dependencies in
            // Given
            let parts = [UploadPart.firstPart, UploadPart.secondPart]
            let sut = UploadResourceImpl()

            // When
            session.dataRequest = dataRequest
            dependencies.truVideoSession = session
            dependencies.environment = .dev
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
                try await sut.complete(for: uploadId, withParts: parts)
            } throws: { error in
                (error as? UtilityError)?.kind == .MediaUploadErrorReason.completeUploadFailed
            }
        }
    }

    @Test
    func testThatCompleteShouldUseCorrectParameters() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let parts = [UploadPart.firstPart, UploadPart.secondPart]
            let sut = UploadResourceImpl()

            // When
            session.dataRequest = dataRequest
            dependencies.environment = .dev
            dependencies.truVideoSession = session
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

            try await sut.complete(for: uploadId, withParts: parts)

            let uploadedParts = session.lastRequestParameters?["parts"] as? [[String: Any]]
            let firstUploadedPart = uploadedParts?.first
            let secondUploadedPart = uploadedParts?.last
            let numOfUploadedParts = uploadedParts?.count

            // Then
            #expect(numOfUploadedParts == 2)

            #expect(firstUploadedPart?["etag"] as? String == parts.first?.eTag)
            #expect(firstUploadedPart?["partNumber"] as? Int == parts.first?.partNumber)

            #expect(secondUploadedPart?["etag"] as? String == parts.last?.eTag)
            #expect(secondUploadedPart?["partNumber"] as? Int == parts.last?.partNumber)
        }
    }

    @Test
    func testThatCompleteShouldUseCorrectURL() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let parts = [UploadPart.firstPart, UploadPart.secondPart]
            let sut = UploadResourceImpl()

            // When
            session.dataRequest = dataRequest
            dependencies.truVideoSession = session
            dependencies.environment = .dev
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

            _ = try await sut.complete(for: uploadId, withParts: parts)
            let url = try session.lastRequestURL?.asURL()

            // Then
            #expect(url!.absoluteString.contains("/upload/\(uploadId)/complete/stream"))
        }
    }

    @Test
    func testThatCompleteShouldUseGetMethod() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let parts = [UploadPart.firstPart, UploadPart.secondPart]
            let sut = UploadResourceImpl()

            // When
            session.dataRequest = dataRequest
            dependencies.truVideoSession = session
            dependencies.environment = .dev
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

            _ = try await sut.complete(for: uploadId, withParts: parts)

            // Then
            #expect(session.lastRequestMethod == .post)
        }
    }

    // MARK: - Register

    @Test
    func testThatRegisterShouldSucceed() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let sut = UploadResourceImpl()

            // When
            session.dataRequest = dataRequest
            dependencies.environment = .dev
            dependencies.truVideoSession = session
            dataRequest.mockResponse = Response<UploadPartStatus, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: HTTPURLResponse(
                    url: URL(string: "/upload/\(uploadId)/part")!,
                    statusCode: 200,
                    httpVersion: "HTTP/1.1",
                    headerFields: [
                        "Content-Type": "application/json",
                        "Date": "Thu, 25 Sep 2025 15:42:00 GMT",
                        "Server": "TruVideoMockServer/1.0",
                        "X-Request-ID": UUID().uuidString
                    ]
                ),
                result: .success(UploadPartStatus.mock),
                type: .networkLoad
            )

            let result = try await sut.register(for: uploadId, withPart: UploadPart.firstPart)

            // Then
            #expect(result.uploadId == uploadId)
            #expect(result.partNumber == 1)
            #expect(result.status == "PARTIAL")
        }
    }

    @Test
    func testThatRegisterShouldThrowPartRegistrationFailedOnRequestError() async throws {
        await withDependencyValues { dependencies in
            // Given
            let sut = UploadResourceImpl()

            // When
            session.dataRequest = dataRequest
            dependencies.environment = .dev
            dependencies.truVideoSession = session
            dataRequest.mockResponse = Response<UploadPartStatus, NetworkingError>(
                data: nil,
                metrics: nil,
                request: nil,
                response: nil,
                result: .failure(NetworkingError(kind: .invalidURL, failureReason: "")),
                type: .networkLoad
            )

            // Then
            await #expect {
                _ = try await sut.register(for: uploadId, withPart: UploadPart.firstPart)
            } throws: { error in
                (error as? UtilityError)?.kind == .MediaUploadErrorReason.partRegistrationFailed
            }
        }
    }

    @Test
    func testThatRegisterShouldUseCorrectParameters() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let part = UploadPart.firstPart
            let sut = UploadResourceImpl()

            // When
            session.dataRequest = dataRequest
            dependencies.environment = .dev
            dependencies.truVideoSession = session
            dataRequest.mockResponse = Response<UploadPartStatus, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: HTTPURLResponse(
                    url: URL(string: "/upload/\(uploadId)/part")!,
                    statusCode: 200,
                    httpVersion: "HTTP/1.1",
                    headerFields: [
                        "Content-Type": "application/json",
                        "Date": "Thu, 25 Sep 2025 15:42:00 GMT",
                        "Server": "TruVideoMockServer/1.0",
                        "X-Request-ID": UUID().uuidString
                    ]
                ),
                result: .success(UploadPartStatus.mock),
                type: .networkLoad
            )

            _ = try await sut.register(for: uploadId, withPart: part)

            let parameters = session.lastRequestParameters

            // Then
            #expect(parameters?["partNumber"] as? Int == part.partNumber)
            #expect(parameters?["etag"] as? String == part.eTag)
        }
    }

    @Test
    func testThatRegisterShouldUseCorrectURL() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let sut = UploadResourceImpl()

            // When
            session.dataRequest = dataRequest
            dependencies.environment = .dev
            dependencies.truVideoSession = session
            dataRequest.mockResponse = Response<UploadPartStatus, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: HTTPURLResponse(
                    url: URL(string: "/upload/\(uploadId)/part")!,
                    statusCode: 200,
                    httpVersion: "HTTP/1.1",
                    headerFields: [
                        "Content-Type": "application/json",
                        "Date": "Thu, 25 Sep 2025 15:42:00 GMT",
                        "Server": "TruVideoMockServer/1.0",
                        "X-Request-ID": UUID().uuidString
                    ]
                ),
                result: .success(UploadPartStatus.mock),
                type: .networkLoad
            )

            _ = try await sut.register(for: uploadId, withPart: UploadPart.firstPart)

            let url = try session.lastRequestURL?.asURL()

            // Then
            #expect(url!.absoluteString.contains("/upload/\(uploadId)/part"))
        }
    }

    @Test
    func testThatRegisterShouldUseGetMethod() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let sut = UploadResourceImpl()

            // When
            session.dataRequest = dataRequest
            dependencies.environment = .dev
            dependencies.truVideoSession = session
            dataRequest.mockResponse = Response<UploadPartStatus, NetworkingError>(
                data: Data(),
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
                result: .success(UploadPartStatus.mock),
                type: .networkLoad
            )

            _ = try await sut.register(for: uploadId, withPart: UploadPart.firstPart)

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
            dependencies.environment = .dev
            dependencies.truVideoSession = session
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
            #expect(firstUploadPart?.expiresAt == "2025-10-08T16:30:00Z")
            #expect(firstUploadPart?
                .presignedUrl == "https://example-bucket.s3.amazonaws.com/upload-session-foo/part1?signature=abc123")

            #expect(secondUploadPart?.expiresAt == "2025-10-08T16:45:00Z")
            #expect(secondUploadPart?
                .presignedUrl == "https://example-bucket.s3.amazonaws.com/upload-session-foo/part2?signature=def456")
        }
    }

    @Test
    func testThatRetrieveShouldThrowRetrieveUploadPartsFailedOnRequestError() async throws {
        await withDependencyValues { dependencies in
            // Given
            let sut = UploadResourceImpl()

            // When
            session.dataRequest = dataRequest
            dependencies.environment = .dev
            dependencies.truVideoSession = session
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
                (error as? UtilityError)?.kind == .MediaUploadErrorReason.retrieveUploadPartsFailed
            }
        }
    }

    @Test
    func testThatRetrieveShouldUseCorrectQueryParameters() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let count = 2
            let sut = UploadResourceImpl()

            // When
            session.dataRequest = dataRequest
            dependencies.environment = .dev
            dependencies.truVideoSession = session
            dataRequest.mockResponse = Response<UploadPartResponse, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: nil,
                result: .success(UploadPartResponse.mock),
                type: .networkLoad
            )

            _ = try await sut.retrieve(for: uploadId, count: count)

            // Then
            #expect(session.lastRequestEncoder is URLParameterEncoder)
            #expect(session.lastRequestParameters?["count"] as? Int == count)
        }
    }

    @Test
    func testThatRetrieveShouldUseCorrectURL() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let sut = UploadResourceImpl()

            // When
            session.dataRequest = dataRequest
            dependencies.environment = .dev
            dependencies.truVideoSession = session
            dataRequest.mockResponse = Response<UploadPartResponse, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: nil,
                result: .success(UploadPartResponse.mock),
                type: .networkLoad
            )

            _ = try await sut.retrieve(for: uploadId, count: 2)

            let url = try session.lastRequestURL?.asURL()

            // Then
            #expect(url!.absoluteString.contains("/upload/\(uploadId)/parts"))
        }
    }

    @Test
    func testThatRetrieveShouldUseGetMethod() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let sut = UploadResourceImpl()

            // When
            session.dataRequest = dataRequest
            dependencies.environment = .dev
            dependencies.truVideoSession = session
            dataRequest.mockResponse = Response<UploadPartResponse, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: nil,
                result: .success(UploadPartResponse.mock),
                type: .networkLoad
            )

            _ = try await sut.retrieve(for: uploadId, count: 2)

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
            dependencies.environment = .dev
            dependencies.truVideoSession = session

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
            dependencies.environment = .dev
            dependencies.truVideoSession = session

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
                (error as? UtilityError)?.kind == .MediaUploadErrorReason.uploadInitializationFailed
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
            dependencies.environment = .dev
            dependencies.truVideoSession = session
            dataRequest.mockResponse = Response<UploadSession, NetworkingError>(
                data: Data(),
                metrics: nil,
                request: nil,
                response: nil,
                result: .success(UploadSession.mock),
                type: .networkLoad
            )

            _ = try await sut.start(for: FileType.mp4)

            let expected: Parameters = [
                "media": [
                    "fileType": fileType.rawValue
                ]
            ]

            // Then
            #expect(NSDictionary(dictionary: session.lastRequestParameters!)
                .isEqual(to: expected))
        }
    }

    @Test
    func testThatStartShouldUseCorrectURL() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let sut = UploadResourceImpl()

            // When
            session.dataRequest = dataRequest
            dependencies.environment = .dev
            dependencies.truVideoSession = session

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
            #expect(url!.absoluteString.contains("/upload/start/stream"))
        }
    }

    @Test
    func testThatStartShouldUseGetMethod() async throws {
        try await withDependencyValues { dependencies in
            // Given
            let sut = UploadResourceImpl()

            // When
            session.dataRequest = dataRequest
            dependencies.environment = .dev
            dependencies.truVideoSession = session

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

private extension UploadPart {
    /// A mock instance of the upload part.
    static var firstPart: UploadPart {
        UploadPart(
            eTag: "etag-part-0001",
            partNumber: 1
        )
    }

    /// A mock instance of the upload part.
    static var secondPart: UploadPart {
        UploadPart(
            eTag: "etag-part-0002",
            partNumber: 2
        )
    }
}

private extension UploadPartStatus {
    /// A mock instance of the upload part status.
    static var mock: UploadPartStatus {
        UploadPartStatus(
            uploadId: "upload-session-foo",
            partNumber: 1,
            status: "PARTIAL"
        )
    }
}

private extension UploadPartResponse {
    /// A mock instance of the upload part response.
    static var mock: UploadPartResponse {
        UploadPartResponse(
            uploadId: "upload-session-foo",
            parts: [
                Part(
                    expiresAt: "2025-10-08T16:30:00Z",
                    presignedUrl: "https://example-bucket.s3.amazonaws.com/upload-session-foo/part1?signature=abc123"
                ),
                Part(
                    expiresAt: "2025-10-08T16:45:00Z",
                    presignedUrl: "https://example-bucket.s3.amazonaws.com/upload-session-foo/part2?signature=def456"
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
