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
    // MARK: - Public Properties

    /// The signer implementation used for cryptographic operations.
    public let signer: Signer

    // MARK: - Initializer

    /// Creates a new instance of `TruVideoOptions` with the specified configuration.
    ///
    /// - Parameter signer: The signer implementation used for cryptographic operations (defaults to
    /// `HMACSHA256Signer()`)
    public init(signer: Signer = HMACSHA256Signer()) {
        self.signer = signer
    }
}
