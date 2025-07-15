//
// Copyright © 2025 TruVideo. All rights reserved.
//

internal import AWSS3
import Foundation

@testable import Telemetry

final class MockS3Client: S3ClientProtocol {
    // MARK: - Properties

    var callCount = 0
    var uploadedObject: PutObjectInput?
    var error: Error?

    // MARK: - S3ClientProtocol

    /// Uploads an object to an S3 bucket.
    ///
    /// - Parameter input: The configuration for the object to upload, including bucket name, key, and body.
    /// - Returns: A `PutObjectOutput` containing metadata about the uploaded object.
    /// - Throws: An error if the upload fails (e.g., due to network issues or authentication failure).
    func putObject(input: PutObjectInput) async throws -> PutObjectOutput {
        self.callCount += 1

        if let error {
            throw error
        }

        uploadedObject = input
        return PutObjectOutput()
    }
}
