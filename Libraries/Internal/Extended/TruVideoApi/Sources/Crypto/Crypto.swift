//
// Copyright © 2025 TruVideo. All rights reserved.
//

import CryptoKit
import Foundation
internal import InternalUtilities
import Utilities

extension ErrorReason {
    /// A collection of error reasons related to the crypto protocol.
    ///
    /// The `CryptoErrorReason` struct provides a set of static constants representing various errors that can occur
    /// during encryption and decryption processes.
    struct CryptoErrorReason: Sendable {
        /// Error indicating that the encryption process has failed.
        ///
        /// This error occurs when attempting to encrypt data using the SDK's
        /// cryptographic layer (e.g., AES-GCM) but the operation cannot be
        /// completed successfully.
        static let encryptionFailed = ErrorReason(rawValue: "encryptionFailed")

        /// Error indicating that the decryption process has failed.
        ///
        /// This error occurs when attempting to decrypt data using the SDK's
        /// cryptographic layer (e.g., AES-GCM) but the operation cannot be
        /// completed successfully. Common causes include invalid encrypted data,
        /// corrupted authentication tags, or mismatched encryption keys.
        static let decryptionFailed = ErrorReason(rawValue: "decryptionFailed")
    }
}

/// A protocol that defines encryption and decryption behavior for `Codable` types.
///
/// Conforming types can use a `SecureCoder` to safely serialize and protect data.
/// This is typically used when storing sensitive information locally or sending
/// data over insecure channels.
protocol Crypto {
    /// Decrypts data previously encrypted with `encrypt(_:)` and decodes it to the specified type.
    ///
    /// This method takes encrypted binary data, decrypts it using the conforming type's
    /// decryption mechanism, and then decodes the decrypted data into the specified `Decodable` type.
    ///
    /// - Parameters:
    ///   - value: The type to decode the decrypted data into.
    ///   - data: The encrypted data to decrypt and decode.
    /// - Returns: The decrypted and decoded object of type `T`.
    /// - Throws: An error if decryption or decoding fails. Common causes include invalid
    ///           encrypted data, corrupted authentication tags, mismatched encryption keys,
    ///           or invalid JSON structure.
    func decrypt<T: Decodable>(_ value: T.Type, from data: Data) throws -> T

    /// Encrypts a `Codable` object using AES-GCM.
    ///
    /// - Parameter value: The object to encrypt.
    /// - Returns: Encrypted binary data that includes the nonce and authentication tag.
    /// - Throws: An error if encoding or encryption fails.
    func encrypt(_ value: some Codable) throws -> Data
}

/// A utility class that provides AES-GCM encryption and decryption for `Codable` types.
///
/// This class uses a symmetric key derived from a user-provided string using SHA-256.
/// It’s designed for local encryption, such as protecting tokens or configuration data.
///
/// AES.GCM provides both confidentiality and integrity protection.
struct AESCrypto: Crypto {
    // MARK: - Private Properties

    private let key: SymmetricKey

    // MARK: - Types

    /// Internal errors specific to AES-GCM encryption operations.
    ///
    /// These errors represent specific failure cases that can occur during
    /// the encryption process within the `AESCrypto` implementation.
    enum AESError: Error {
        /// Error indicating that the sealed box's combined data is empty or nil.
        ///
        /// This error occurs when `AES.GCM.SealedBox.combined` returns `nil`,
        /// which should theoretically never happen when using the standard `seal()` method.
        /// This case exists as a defensive check to handle unexpected states in the
        /// CryptoKit framework.
        case emptyBox
    }

    // MARK: - Initializer

    /// Initializes a new `SecureCoder` using a string-based key.
    /// The provided string is hashed with SHA-256 to create a 256-bit key suitable for AES-GCM.
    ///
    /// - Parameter keyString: The string used to derive the encryption key.
    init(secretKey: String) {
        let data = SHA256.hash(data: Data(secretKey.utf8))

        self.key = SymmetricKey(data: data)
    }

    // MARK: - Crypto

    /// Decrypts data previously encrypted with `encrypt(_:)` and decodes it to the specified type.
    ///
    /// This method takes encrypted binary data, decrypts it using the conforming type's
    /// decryption mechanism, and then decodes the decrypted data into the specified `Decodable` type.
    ///
    /// - Parameters:
    ///   - value: The type to decode the decrypted data into.
    ///   - data: The encrypted data to decrypt and decode.
    /// - Returns: The decrypted and decoded object of type `T`.
    /// - Throws: An error if decryption or decoding fails. Common causes include invalid
    ///           encrypted data, corrupted authentication tags, mismatched encryption keys,
    ///           or invalid JSON structure.
    func decrypt<T: Decodable>(_ value: T.Type, from data: Data) throws -> T {
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            let data = try AES.GCM.open(sealedBox, using: key)

            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw UtilityError(kind: .CryptoErrorReason.decryptionFailed, underlyingError: error)
        }
    }

    /// Encrypts a `Codable` object using AES-GCM.
    ///
    /// - Parameter value: The object to encrypt.
    /// - Returns: Encrypted binary data that includes the nonce and authentication tag.
    /// - Throws: An error if encoding or encryption fails.
    func encrypt(_ value: some Codable) throws -> Data {
        do {
            let data = try JSONEncoder().encode(value)
            let sealedBox = try AES.GCM.seal(data, using: key)

            return try sealedBox.combined.unwrap(or: AESError.emptyBox)
        } catch {
            throw UtilityError(kind: .CryptoErrorReason.encryptionFailed, underlyingError: error)
        }
    }
}
