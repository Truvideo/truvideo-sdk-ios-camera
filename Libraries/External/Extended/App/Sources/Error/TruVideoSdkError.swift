//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
internal import TruVideoApi
internal import Utilities

/// Errors that can occur when using the TruVideo SDK.
///
/// This struct defines all SDK-specific errors that can be thrown during SDK operations.
/// Each error provides user-friendly information without exposing internal
/// implementation details or sensitive information.
public struct TruVideoSdkError: LocalizedError {
    /// The specific error reason for programmatic handling.
    ///
    /// This property contains the error type that can be used in switch statements
    /// for conditional error handling and recovery strategies.
    public let kind: ErrorReason

    /// A localized message describing what error occurred.
    ///
    /// This message is designed to be displayed to end users and should be
    /// user-friendly, actionable, and free of technical jargon.
    public let errorDescription: String?

    /// A localized message describing the reason for the failure.
    ///
    /// This message contains technical details useful for debugging and should
    /// not be displayed to end users. Use this for logging and development purposes.
    public let failureReason: String?

    // MARK: - Static Properties

    /// Authentication failed due to invalid credentials or server error.
    ///
    /// This error occurs when the authentication request fails due to invalid
    /// API credentials, server errors, or network connectivity issues during
    /// the authentication process.
    public static let authenticationFailed = TruVideoSdkError(
        kind: .authenticationFailed,
        errorDescription: "Authentication failed. Please check your credentials and try again.",
        failureReason: "Invalid API key, secret key, or external ID."
    )

    /// The SDK requires configuration before use.
    ///
    /// This error occurs when attempting to use SDK functionality before
    /// calling `configure(with:)` with valid `TruVideoOptions`.
    public static let configurationRequired = TruVideoSdkError(
        kind: .configurationRequired,
        errorDescription: "TruVideo SDK requires configuration. Please configure the SDK before use.",
        failureReason: "SDK configuration is required before authentication."
    )

    /// Sign-out operation failed.
    ///
    /// This error occurs when the SDK is unable to successfully complete the sign-out process.
    /// Possible causes include network failures, internal state issues, or server errors.
    public static let signOutFailed = TruVideoSdkError(
        kind: TruVideoSdkError.ErrorReason(rawValue: "signOutFailed"),
        errorDescription: "Sign-out failed.",
        failureReason: "An error occurred during the sign-out process. Please try again."
    )

    /// An unknown error that occurred during SDK operation.
    ///
    /// This error is used when an unexpected or unclassified error occurs
    /// that doesn't match any specific error case. It provides a fallback
    /// for error handling when the specific error type cannot be determined.
    public static let unknown = TruVideoSdkError(
        kind: .unknown,
        errorDescription: "An unexpected error occurred. Please try again later.",
        failureReason: "Unknown error type that could not be classified"
    )

    // MARK: - Types

    /// Protocol for establishing reasons with the domain of Errors.
    public struct ErrorReason: Equatable, RawRepresentable {
        // MARK: - Public Properties

        /// The corresponding value of the raw type.
        public let rawValue: String

        // MARK: - Static Properties

        /// Error indicating that the authentication process has failed.
        ///
        /// This error reason is used when the authentication process fails due to
        /// various reasons such as invalid credentials, network issues, or server errors.
        /// It provides a general authentication failure indicator for error handling.
        public static let authenticationFailed = ErrorReason(rawValue: "authenticationFailed")

        /// Error reason indicating that the SDK requires configuration before it can be used.
        ///
        /// This error is thrown when attempting to use SDK functionality that requires
        /// proper initialization and configuration. The SDK must be configured with
        /// necessary parameters such as API keys, environment settings, or other
        /// configuration options before certain operations can be performed.
        public static let configurationRequired = TruVideoSdkError.ErrorReason(rawValue: "configurationRequired")

        /// Error indicating that the authentication process has failed due to an invalid API key.
        ///
        /// This error reason is used when the authentication process fails specifically
        /// because the provided API key is invalid, expired, or malformed. It provides
        /// a specific indicator for API key-related authentication failures.
        public static let invalidApiKey = ErrorReason(rawValue: "invalidApiKey")

        /// Error indicating that the authentication process has failed due to an invalid signature.
        ///
        /// This error reason is used when the authentication process fails specifically
        /// because the cryptographic signature of the device context data is invalid,
        /// malformed, or cannot be verified by the server.
        public static let invalidSignature = ErrorReason(rawValue: "invalidSignature")

        /// Unknown error.
        public static let unknown = ErrorReason(rawValue: "unknown")

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

        // MARK: - Initializer

        /// Creates a new instance with the specified raw value.
        ///
        /// If there is no value of the type that corresponds with the specified raw
        /// value, this initializer returns `nil`.
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}
