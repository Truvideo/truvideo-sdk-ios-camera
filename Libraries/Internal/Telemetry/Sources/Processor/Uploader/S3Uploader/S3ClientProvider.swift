//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

internal import AWSS3
internal import AWSSDKIdentity
internal import Smithy

/// A protocol that defines a provider responsible for creating instances of `S3ClientProtocol`.
///
/// Implementations of this protocol are expected to manage the creation or configuration
/// of S3 clients, which can be used to interact with AWS S3 services.
///
/// This is especially useful for dependency injection, testing, or abstracting the client creation logic.
protocol S3ClientProvider {
    /// Asynchronously creates and returns an instance conforming to `S3ClientProtocol`.
    ///
    /// - Returns: A fully configured `S3ClientProtocol` instance.
    /// - Throws: An error if the client could not be created (e.g. invalid configuration or network issues).
    func makeClient() async throws -> S3ClientProtocol
}

final class S3ClientImpl: S3ClientProvider {
    // MARK: - Private Properties

    private let accessKey: String
    private var client: S3ClientProtocol?
    private let region: String
    private let secretKey: String

    // MARK: - Initializer

    /// Creates a new instance of the `Uploader`.
    ///
    /// Use this initializer when you already have a configured instance of `S3Client`,
    /// and do not need to provide raw AWS credentials or region information.
    ///
    /// - Parameter client: An optional instance of `S3Client` used to perform S3 operations.
    ///   If `nil`, S3 interactions will require initialization elsewhere.
    init(client: S3ClientProtocol?) {
        self.client = client
        self.accessKey = ""
        self.region = ""
        self.secretKey = ""
    }

    /// Creates a new instance of the `Uploader`.
    ///
    /// This initializer sets up a static AWS credentials provider and configures the default service
    /// configuration used by AWS clients (e.g., `AWSS3TransferUtility`). Once set, this configuration
    /// will be used globally by default for all AWS service calls that rely on `default()` clients.
    ///
    /// - Parameters:
    ///   - accessKey: Your AWS access key ID. Used for authentication.
    ///   - secretKey: Your AWS secret access key. Used for authentication.
    ///   - region: The AWS region where the bucket is located (e.g., `.USEast1`, `.EUWest1`).
    init(accessKey: String, secretKey: String, region: String) {
        self.accessKey = accessKey
        self.region = region
        self.secretKey = secretKey
    }

    // MARK: - S3ClientProvider

    /// Asynchronously creates and returns an instance conforming to `S3ClientProtocol`.
    ///
    /// - Returns: A fully configured `S3ClientProtocol` instance.
    /// - Throws: An error if the client could not be created (e.g. invalid configuration or network issues).
    func makeClient() async throws -> S3ClientProtocol {
        if let client {
            return client
        }

        let credentials = AWSCredentialIdentity(accessKey: accessKey, secret: secretKey)
        let identityResolver = StaticAWSCredentialIdentityResolver(credentials)
        let configuration = try await S3Client.S3ClientConfiguration(
            awsCredentialIdentityResolver: identityResolver,
            region: region
        )

        let client = S3Client(config: configuration)
        self.client = client

        return client
    }
}

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
