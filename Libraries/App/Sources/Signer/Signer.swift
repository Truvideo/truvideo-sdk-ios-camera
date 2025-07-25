//
// Copyright © 2025 TruVideo. All rights reserved.
//

import CommonCrypto
import DI
import Foundation
import TruVideoApi
import Utilities

/// A type alias that provides convenient access to context configuration for cryptographic signing.
///
/// This type alias enables the current layer to work with context objects that contain
/// system and device information for cryptographic signing operations without requiring
/// explicit module qualification.
public typealias Context = TruVideoApi.Context

/// A protocol that defines the interface for cryptographic signing operations.
///
/// Types conforming to `Signer` are responsible for creating cryptographic signatures
/// using various algorithms (e.g., HMAC-SHA256, RSA, ECDSA) based on a signing context
/// and a secret key. This protocol is designed to be thread-safe and supports
/// asynchronous operations for potentially time-consuming cryptographic computations.
///
/// ## Responsibilities
/// - Create cryptographic signatures from signing contexts
/// - Handle different signature algorithms and key types
/// - Provide thread-safe signing operations
/// - Support asynchronous execution for performance
///
/// ## Conformance Requirements
/// Conforming types must implement the `sign(_:key:)` method and ensure thread safety
/// through the `Sendable` protocol. The signing context should contain all necessary
/// data required to create a deterministic signature.
public protocol Signer: Sendable {
    /// Creates a cryptographic signature for the given context using the specified key.
    ///
    /// This method performs the actual cryptographic signing operation. The implementation
    /// should extract the necessary data from the signing context and apply the appropriate
    /// cryptographic algorithm using the provided key.
    ///
    /// - Parameters:
    ///     - `context`: A `Context` object containing the data to be signed. The context
    ///        should provide a canonical representation of the data in a format suitable
    ///        for the specific signing algorithm.
    ///     - `secretKey`: The secret key used for cryptographic signing. This key should be kept
    ///        secure and not exposed in client-side code or logs. The key is used as the
    ///        HMAC key for creating the cryptographic signature.
    ///
    /// - Returns: A `String` representing the cryptographic signature, typically in hexadecimal
    ///            format or base64 encoding depending on the implementation.
    func sign(_ context: Context, secretKey: String) async throws -> String
}

/// A concrete implementation of the `Signer` protocol that uses HMAC-SHA256 for cryptographic signing.
///
/// `HMACSHA256Signer` provides a secure implementation of cryptographic signing using the
/// HMAC-SHA256 algorithm. It takes a `Context` object containing system and device information,
/// encodes it as JSON, and creates a cryptographic signature using a secret key.
///
/// ## Overview
///
/// This signer is designed for authentication purposes where you need to verify the integrity
/// and authenticity of context data. It uses the HMAC-SHA256 algorithm, which provides:
/// - **Message Authentication**: Ensures the data hasn't been tampered with
/// - **Cryptographic Security**: Uses SHA-256 hash function with a secret key
/// - **Deterministic Output**: Same input always produces the same signature
///
/// ## Usage
///
/// ```swift
/// let signer = HMACSHA256Signer()
/// let context = Context() // System context
/// let signature = try await signer.sign(context)
/// ```
///
/// ## Implementation Details
///
/// The signing process involves:
/// 1. **JSON Encoding**: Converts the `Context` object to JSON data
/// 2. **String Conversion**: Converts JSON data to UTF-8 string
/// 3. **HMAC-SHA256**: Applies HMAC-SHA256 algorithm using the secret key
/// 4. **Hex Encoding**: Returns the signature as a hexadecimal string
///
/// ## Security Considerations
///
/// - **Secret Key**: The secret key is injected via dependency injection and should be kept secure
/// - **Context Data**: All context data is included in the signature, ensuring comprehensive verification
/// - **Algorithm**: HMAC-SHA256 is a well-established, cryptographically secure algorithm
///
/// ## Error Handling
///
/// The signer can throw errors in the following scenarios:
/// - **Encoding Failures**: If the context cannot be encoded as JSON
/// - **String Conversion**: If the JSON data cannot be converted to UTF-8 string
/// - **Cryptographic Errors**: If the HMAC operation fails
public struct HMACSHA256Signer: Signer {
    // MARK: - Private Properties

    let encoder = JSONEncoder()

    // MARK: - Types

    /// An enumeration representing errors that can occur during cryptographic signing operations.
    ///
    /// `SignerError` provides specific error cases for different failure scenarios that may
    /// arise when creating cryptographic signatures. This allows for precise error handling
    /// and debugging of signing-related issues.
    enum SignerError: LocalizedError {
        /// Indicates that the signing context contains invalid or malformed data.
        ///
        /// This error occurs when the data provided for signing cannot be processed
        /// due to format issues, encoding problems, or structural inconsistencies.
        case invalidMessage

        /// Indicates that the cryptographic signing operation failed due to an underlying error.
        ///
        /// This error occurs when the signing process encounters an unexpected failure
        /// that is not covered by other specific error cases. The associated error provides
        /// detailed information about what went wrong during the signing operation.
        ///
        /// Common causes include:
        /// - JSON encoding failures when converting the context to data
        /// - Cryptographic algorithm errors during HMAC computation
        /// - Memory allocation failures during the signing process
        /// - System-level cryptographic service errors
        ///
        /// - Parameter `error`: The underlying error that caused the signing operation to fail.
        case unableToSignContext(Error)

        // MARK: - LocalizedError

        /// A localized message describing what error occurred.
        ///
        /// This property provides a user-friendly description of the storage error.
        /// It delegates to `failureReason` to provide consistent error messaging.
        var errorDescription: String? {
            failureReason
        }

        /// A localized message describing the reason for the failure.
        ///
        /// This property extracts the localized description from the underlying error
        /// that caused the storage operation to fail. This provides detailed information
        /// about what went wrong during the storage operation.
        var failureReason: String? {
            switch self {
            case .invalidMessage:
                "Invalid message data for signing."

            case let .unableToSignContext(error):
                "Unable to sign context: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Initializer

    /// Creates a new instance of the `HMACSHA256Signer`.
    public init() {}

    // MARK: - Signer

    /// Creates a cryptographic signature for the given context using the specified key.
    ///
    /// This method performs the actual cryptographic signing operation. The implementation
    /// should extract the necessary data from the signing context and apply the appropriate
    /// cryptographic algorithm using the provided key.
    ///
    /// - Parameters:
    ///     - `context`: A `Context` object containing the data to be signed. The context
    ///        should provide a canonical representation of the data in a format suitable
    ///        for the specific signing algorithm.
    ///     - `secretKey`: The secret key used for cryptographic signing. This key should be kept
    ///        secure and not exposed in client-side code or logs. The key is used as the
    ///        HMAC key for creating the cryptographic signature.
    ///
    /// - Returns: A `String` representing the cryptographic signature, typically in hexadecimal
    ///            format or base64 encoding depending on the implementation.
    public func sign(_ context: Context, secretKey: String) async throws -> String {
        do {
            let data = try encoder.encode(context)

            guard let message = String(data: data, encoding: .utf8) else {
                throw SignerError.invalidMessage
            }

            let hmac256 = CCHmacAlgorithm(kCCHmacAlgSHA256)
            var macData = Data(count: Int(CC_SHA256_DIGEST_LENGTH))

            secretKey.withCString { keyCString in
                message.withCString { msgCString in
                    macData.withUnsafeMutableBytes { macDataBytes in
                        guard let keyBytes = UnsafeRawPointer(keyCString)?.assumingMemoryBound(to: UInt8.self),
                            let msgBytes = UnsafeRawPointer(msgCString)?.assumingMemoryBound(to: UInt8.self)
                        else {
                            return
                        }

                        CCHmac(
                            hmac256,
                            keyBytes,
                            Int(strlen(keyCString)),
                            msgBytes,
                            Int(strlen(msgCString)),
                            macDataBytes.bindMemory(to: UInt8.self).baseAddress
                        )
                    }
                }
            }

            return
                macData
                .map { String(format: "%02x", $0) }
                .joined()
        } catch let error as SignerError {
            throw error
        } catch {
            throw SignerError.unableToSignContext(error)
        }
    }
}
