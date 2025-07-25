//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A configuration struct for the TruVideo SDK.
///
/// This struct will contain configuration settings for the SDK. The implementation
/// is currently being developed.
public struct TruVideoOptions: Sendable {
    public let apiKey: String
    public let externalId: String?
    public let secretKey: String
    public let signer: Signer

    // MARK: - Initializer

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
