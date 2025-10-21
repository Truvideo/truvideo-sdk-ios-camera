//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

@testable import TruvideoSdk

/// Mock implementation of `Signer` for use in unit tests.
public final class SignerMock: Signer, @unchecked Sendable {
    // MARK: - Properties

    /// Records whether `sign(_:, secretKey:)` was called.
    public private(set) var signCalled = false

    /// Captures the parameters passed to `sign(_:, secretKey:)`.
    public private(set) var lastSignParams: (context: Context, secretKey: String)?

    /// Value to return from `sign(_:, secretKey:)` if set.
    public var signResult: String?

    /// Error to throw from `sign(_:, secretKey:)` if set.
    public var error: Error?

    // MARK: - Initializer

    /// Creates a new instance of the `SignerMock`.
    public init() {}

    // MARK: - Signer

    /// Simulates the signing operation.
    ///
    /// - Parameters:
    ///   - context: The `Context` containing the data to sign.
    ///   - secretKey: The secret key used for signing.
    /// - Returns: A mock signature string. Defaults to `"mock-signature"`.
    /// - Throws: The configured `error` if set.
    public func sign(_ context: Context, secretKey: String) async throws -> String {
        signCalled = true
        lastSignParams = (context, secretKey)

        if let error {
            throw error
        }

        return signResult ?? "mock-signature"
    }
}
