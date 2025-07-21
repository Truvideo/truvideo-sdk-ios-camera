//
// Copyright © 2025 TruVideo. All rights reserved.
//

internal import AWSS3
internal import AWSSDKIdentity
import Foundation
internal import Smithy
import Utilities

/// A concrete implementation of the `Uploader` protocol that uploads `Encodable` objects to Amazon S3.
///
/// This class handles the encoding of objects to JSON and uploads them using `AWSS3TransferUtility`,
/// part of the AWS SDK for iOS. It relies on a static credentials provider and a preconfigured
/// AWS service configuration set during initialization.
///
/// The class uses the default AWS service manager configuration,
/// allowing other AWS services to use the same settings.
final class S3Uploader: Uploader {
    // MARK: - Private Properties

    private let bucketName: String
    private let clientProvider: S3ClientProvider

    // MARK: - Initializer

    /// Creates a new instance of the `Uploader`.
    ///
    /// This initializer sets up a static AWS credentials provider and configures the default service
    /// configuration used by AWS clients (e.g., `AWSS3TransferUtility`). Once set, this configuration
    /// will be used globally by default for all AWS service calls that rely on `default()` clients.
    ///
    /// - Parameters:
    ///   - bucketName: The name of the S3 bucket where files will be uploaded.
    ///   - clientProvider:
    init(bucketName: String, clientProvider: S3ClientProvider) {
        self.bucketName = bucketName
        self.clientProvider = clientProvider
    }

    // MARK: - Uploader

    /// Uploads raw `Data` to an S3 bucket using the specified file name and content type.
    ///
    /// This method performs an asynchronous upload operation using AWS S3.
    /// It throws an error if the upload fails or is interrupted.
    ///
    /// - Parameters:
    ///   - data: The binary data to be uploaded to S3.
    ///   - fileName: The key (path/name) under which the file will be stored in the S3 bucket.
    ///   - contentType: The MIME type of the data (e.g., "image/jpeg", "application/json").
    /// - Throws: An error of type `CommonUtilityError` if the upload fails.
    func upload(_ data: Data, fileName: String, contentType: ContentType) async throws {
        let dataStream = ByteStream.data(data)
        let input = PutObjectInput(
            body: dataStream,
            bucket: bucketName,
            contentType: contentType.rawValue,
            key: fileName
        )

        do {
            let s3Client = try await clientProvider.makeClient()
            _ = try await s3Client.putObject(input: input)
        } catch {
            throw UtilityError(kind: .UploaderErrorReason.uploadFileFailed, underlyingError: error)
        }
    }
}
