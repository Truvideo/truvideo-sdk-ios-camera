//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

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

    /// The SDK requires configuration before use.
    ///
    /// This error occurs when attempting to use SDK functionality before
    /// calling `configure(with:)` with valid `TruVideoOptions`.
    public static let configurationRequired = TruVideoSdkError(
        kind: .configurationRequired,
        errorDescription: "TruVideo SDK requires configuration. Please configure the SDK before use.",
        failureReason: "SDK configuration is required before authentication."
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

        /// Unknown error.
        public static let unknown = ErrorReason(rawValue: "unknown")

        // MARK: - Initializer

        /// Creates a new instance with the specified raw value.
        ///
        /// If there is no value of the type that corresponds with the specified raw
        /// value, this initializer returns `nil`.
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }

    // MARK: - Initializer

    /// Creates a new SDK error with the specified error details.
    ///
    /// This initializer is marked as internal SPI to allow SDK components to create
    /// custom error instances while maintaining control over error creation.
    ///
    /// - Parameters:
    ///    - kind: The specific error reason for programmatic handling
    ///    - errorDescription: User-friendly error message for display
    ///    - failureReason: Technical reason for debugging purposes
    @_spi(Internal)
    public init(kind: ErrorReason, errorDescription: String?, failureReason: String?) {
        self.errorDescription = errorDescription
        self.failureReason = failureReason
        self.kind = kind
    }
}

extension TruVideoSdkError.ErrorReason {
    // MARK: - Static Properties

    /// Configuration Required.
    public static let configurationRequired = TruVideoSdkError.ErrorReason(rawValue: "configurationRequired")
}
