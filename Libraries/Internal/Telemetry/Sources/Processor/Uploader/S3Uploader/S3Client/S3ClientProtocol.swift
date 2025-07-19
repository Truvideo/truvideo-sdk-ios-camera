//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

internal import AWSS3

/// A protocol that defines the interface for uploading objects to an Amazon S3 bucket.
///
/// This abstraction enables dependency injection and unit testing by decoupling
/// your code from the concrete `S3Client` implementation.
protocol S3ClientProtocol {
    /// Uploads an object to an S3 bucket.
    ///
    /// - Parameter input: The configuration for the object to upload, including bucket name, key, and body.
    /// - Returns: A `PutObjectOutput` containing metadata about the uploaded object.
    /// - Throws: An error if the upload fails (e.g., due to network issues or authentication failure).
    func putObject(input: PutObjectInput) async throws -> PutObjectOutput
}

/// Conformance of the official AWS `S3Client` to `S3ClientProtocol`,
/// allowing it to be used wherever the protocol is expected.
extension S3Client: S3ClientProtocol {}
