//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
internal import AWSS3

@testable import Telemetry

/// A mock implementation of the `S3ClientProtocol` protocol for use in unit tests.
final class MockS3Client: S3ClientProtocol {
    // MARK: - Properties

    var error: Error?
    fileprivate(set) var putObjectCallCount = 0
    fileprivate(set) var uploadedObject: PutObjectInput?

    // MARK: - S3ClientProtocol

    /// Uploads an object to an S3 bucket.
    ///
    /// - Parameter input: The configuration for the object to upload, including bucket name, key, and body.
    /// - Returns: A `PutObjectOutput` containing metadata about the uploaded object.
    /// - Throws: An error if the upload fails (e.g., due to network issues or authentication failure).
    func putObject(input: PutObjectInput) async throws -> PutObjectOutput {
        self.putObjectCallCount += 1

        if let error {
            throw error
        }

        uploadedObject = input
        return PutObjectOutput()
    }
}
