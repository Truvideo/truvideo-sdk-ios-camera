//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

@testable import TruVideoApi

/// A mock implementation of the `Crypto` protocol for testing.
final class CryptoMock: Crypto {
    // MARK: - Properties

    /// Controls whether decryption should fail and throw an error.
    var shouldFailDecryption = false

    /// The error to throw when encryption fails.
    var encryptionError: Error?

    /// The error to throw when decryption fails.
    var decryptionError: Error?

    // MARK: - Call Tracking

    /// Tracks the number of times `encrypt(_:)` was called.
    private(set) var encryptCallCount = 0

    /// Tracks the number of times `decrypt(_:from:)` was called.
    private(set) var decryptCallCount = 0

    /// Stores the last value passed to `encrypt(_:)` for verification in tests.
    private(set) var lastEncryptedValue: Any?

    /// Stores the last data passed to `decrypt(_:from:)` for verification in tests.
    private(set) var lastDecryptedData: Data?

    /// Stores the last type requested in `decrypt(_:from:)` for verification in tests.
    private(set) var lastDecryptedType: Any.Type?

    // MARK: - Crypto

    /// Decrypts data previously encrypted with `encrypt(_:)` and decodes it to the specified type.
    ///
    /// This mock implementation simply decodes the data as JSON without performing actual decryption.
    /// This is suitable for testing since real encryption/decryption is not needed in unit tests.
    ///
    /// - Parameters:
    ///   - value: The type to decode the decrypted data into.
    ///   - data: The encrypted data to decrypt and decode.
    /// - Returns: The decrypted and decoded object of type `T`.
    /// - Throws: An error if decryption or decoding fails. Common causes include invalid
    ///           encrypted data, corrupted authentication tags, mismatched encryption keys,
    ///           or invalid JSON structure.
    func decrypt<T: Decodable>(_ value: T.Type, from data: Data) throws -> T {
        decryptCallCount += 1
        lastDecryptedData = data
        lastDecryptedType = T.self

        if let decryptionError {
            throw decryptionError
        }

        return try JSONDecoder().decode(T.self, from: data)
    }

    /// Encrypts a `Codable` object using AES-GCM.
    ///
    /// This mock implementation simply encodes the value as JSON without performing actual encryption.
    /// This is suitable for testing since real encryption/decryption is not needed in unit tests.
    ///
    /// - Parameter value: The object to encrypt.
    /// - Returns: Encrypted binary data that includes the nonce and authentication tag.
    /// - Throws: An error if encoding or encryption fails.
    func encrypt(_ value: some Codable) throws -> Data {
        encryptCallCount += 1
        lastEncryptedValue = value

        if let encryptionError {
            throw encryptionError
        }

        return try JSONEncoder().encode(value)
    }
}
