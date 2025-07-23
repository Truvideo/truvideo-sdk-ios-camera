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
        try await sut.upload(Data(), fileName: "file.json", contentType: .json)

        // Then
        #expect(client.uploadedObject != nil, "Expected uploaded object to be non-nil")
    }
    
    @Test
    func testThatUploadThrowsUploaderErrorWhenClientFails() async throws {
        // Given
        let client = MockS3Client()
        let sut = S3Uploader(bucketName: "bucket", clientProvider: S3ClientImpl(client: client))

        // When
        client.error = NSError(domain: "com.test", code: 42)
        
        // Then
        await #expect {
            try await sut.upload(Data(), fileName: "file.json", contentType: .json)
        } throws: { error in
            guard let error = error as? UtilityError else { return false }
                        
            return error.kind == .UploaderErrorReason.uploadFileFailed && error.underlyingError != nil
        }
    }
}
