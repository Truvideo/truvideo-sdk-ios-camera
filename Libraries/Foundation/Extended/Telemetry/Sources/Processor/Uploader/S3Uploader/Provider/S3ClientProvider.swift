//
// Copyright © 2025 TruVideo. All rights reserved.
//

internal import AWSS3
internal import AWSSDKIdentity
import Foundation
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

/// A concrete implementation of the `S3ClientProvider` protocol responsible for creating and managing S3 clients.
final class S3ClientImpl: S3ClientProvider {
    // MARK: - Private Properties

    private var client: S3ClientProtocol?
    private let credential: AWSCredentialIdentity
    private let region: String

    // MARK: - Initializers

    /// Creates a new instance of the `Uploader`.
    ///
    /// Use this initializer when you already have a configured instance of `S3Client`,
    /// and do not need to provide raw AWS credentials or region information.
    ///
    /// - Parameter client: An optional instance of `S3Client` used to perform S3 operations.
    ///   If `nil`, S3 interactions will require initialization elsewhere.
    init(client: S3ClientProtocol) {
        self.client = client
        self.credential = AWSCredentialIdentity(accessKey: "", secret: "")
        self.region = ""
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
        self.credential = AWSCredentialIdentity(accessKey: accessKey, secret: secretKey)
        self.region = region
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

        let identityResolver = StaticAWSCredentialIdentityResolver(credential)
        let configuration = try await S3Client.S3ClientConfiguration(
            awsCredentialIdentityResolver: identityResolver,
            region: region
        )

        let client = S3Client(config: configuration)
        self.client = client

        return client
    }
}
