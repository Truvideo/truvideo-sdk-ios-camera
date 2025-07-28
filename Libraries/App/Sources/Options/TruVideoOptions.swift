//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A configuration struct for the TruVideo SDK.
///
/// This struct will contain configuration settings for the SDK. The implementation
/// is currently being developed.
/// Configuration options for the TruVideo SDK.
///
/// This struct contains all the necessary configuration parameters required to
/// initialize and configure the TruVideo SDK, including authentication credentials
/// and signing configuration.
public struct TruVideoOptions: Sendable {
    /// The API key used to authenticate requests to the TruVideo API.
    public let apiKey: String

    /// An optional external identifier for the user or session.
    public let externalId: String?

    /// The secret key used for signing requests and generating authentication tokens.
    public let secretKey: String

    /// The signer implementation used for cryptographic operations.
    public let signer: Signer

    // MARK: - Initializer

    /// Creates a new instance of `TruVideoOptions` with the specified configuration.
    ///
    /// - Parameters:
    ///   - apiKey: The API key used to authenticate requests to the TruVideo API
    ///   - secretKey: The secret key used for signing requests and generating authentication tokens
    ///   - externalId: An optional external identifier for the user or session (defaults to `nil`)
    ///   - signer: The signer implementation used for cryptographic operations (defaults to `HMACSHA256Signer()`)
    public init(
        apiKey: String,
        secretKey: String,
        externalId: String? = nil,
        signer: Signer = HMACSHA256Signer()
    ) {

        self.apiKey = apiKey
        self.secretKey = secretKey
        self.externalId = externalId
        self.signer = signer
    }
}
