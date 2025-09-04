//
// Copyright © 2025 TruVideo. All rights reserved.
//

@_spi(Internal) import ExternalUtilities
import Foundation
internal import TruVideoApi
internal import Utilities

extension TruVideoSdkError {
    /// The SDK has already been configured and cannot be configured again.
    ///
    /// This error occurs when attempting to call `configure(with:)` multiple times.
    /// The SDK only allows configuration to be performed once per application lifecycle.
    public static let appAlreadyConfigured = TruVideoSdkError(
        kind: TruVideoSdkError.ErrorReason(rawValue: "appAlreadyConfigured"),
        errorDescription: "TruVideo SDK has already been configured. Configuration can only be performed once.",
        failureReason: "SDK configuration has already been applied and cannot be modified."
    )

    /// Authentication failed due to invalid credentials or server error.
    ///
    /// This error occurs when the authentication request fails due to invalid
    /// API credentials, server errors, or network connectivity issues during
    /// the authentication process.
    public static let authenticationFailed = TruVideoSdkError(
        kind: .TruVideoSdkErrorReason.authenticationFailed,
        errorDescription: "Authentication failed. Please check your credentials and try again.",
        failureReason: "Invalid API key, secret key, or external ID."
    )
}

extension TruVideoSdkError.ErrorReason {
    /// Error reasons specific to the TruVideo SDK.
    ///
    /// This struct defines error reasons that are specific to TruVideo SDK operations.
    /// These error reasons can be used to create `TruVideoSdkError` instances with
    /// specific error types for programmatic error handling.
    public struct TruVideoSdkErrorReason {
        /// Error indicating that the authentication process has failed.
        ///
        /// This error reason is used when the authentication process fails due to
        /// various reasons such as invalid credentials, network issues, or server errors.
        /// It provides a general authentication failure indicator for error handling.
        public static let authenticationFailed = TruVideoSdkError.ErrorReason(rawValue: "authenticationFailed")

        /// Error indicating that the authentication process has failed due to an invalid API key.
        ///
        /// This error reason is used when the authentication process fails specifically
        /// because the provided API key is invalid, expired, or malformed. It provides
        /// a specific indicator for API key-related authentication failures.
        public static let invalidApiKey = TruVideoSdkError.ErrorReason(rawValue: "invalidApiKey")

        /// Error indicating that the authentication process has failed due to an invalid signature.
        ///
        /// This error reason is used when the authentication process fails specifically
        /// because the cryptographic signature of the device context data is invalid,
        /// malformed, or cannot be verified by the server.
        public static let invalidSignature = TruVideoSdkError.ErrorReason(rawValue: "invalidSignature")

        // MARK: - Static methods

        /// Maps a string value to the corresponding error reason or returns unknown.
        ///
        /// This method provides a safe way to convert string error codes to specific
        /// error reasons. If the string doesn't match any known error code, it returns
        /// the unknown error reason.
        ///
        /// - Parameter rawValue: The string value to map to an error reason
        /// - Returns: The corresponding error reason or unknown if not found
        static func from(_ rawValue: String) -> TruVideoSdkError.ErrorReason {
            switch rawValue {
            case "authenticationFailed":
                authenticationFailed

            case "error.invalidApiKey":
                invalidApiKey

            case "Invalid signature":
                invalidSignature

            default:
                TruVideoSdkError.ErrorReason.unknown
            }
        }
    }
}
