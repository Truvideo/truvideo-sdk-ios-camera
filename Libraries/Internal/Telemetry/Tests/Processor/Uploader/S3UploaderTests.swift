//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Testing
import Utilities

@testable import Telemetry

struct S3UploaderTests {
    
    // MARK: - Tests
    
    @Test
    func testThatUploadFileShouldSucceed() async throws {
        // Given
        let client = MockS3Client()
        let clientProvider = S3ClientImpl(client: client)
        let sut = S3Uploader(bucketName: "bucket", clientProvider: clientProvider)

        // When
        _ = try await sut.upload(Data(), fileName: "file.json", contentType: .json)

        // Then
        #expect(client.uploadedObject != nil, "Expected uploaded object to be non-nil")
    }
    
    @Test
    func testThatUploadThrowsUploaderErrorWhenClientFails() async throws {
        // Given
        let client = MockS3Client()
        let clientProvider = S3ClientImpl(client: client)
        let sut = S3Uploader(bucketName: "bucket", clientProvider: clientProvider)
        var capturedError: UtilityError?

        // When
        client.error = NSError(domain: "com.test", code: 42)

        do {
            _ = try await sut.upload(Data(), fileName: "file.json", contentType: .json)
        } catch {
            capturedError = error as? UtilityError
        }

        // Then
        #expect(capturedError?.underlyingError != nil, "Expected underlyingError to be non-nil")
        #expect(
            capturedError?.kind == ErrorReason.UploaderErrorReason.uploadFileFailed,
            "Expected error kind to be `.uploadFileFailed`"
        )
    }
}
