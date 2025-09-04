//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A representation of networking-related errors, providing detailed error information.
///
/// `NetworkingError` is used to capture various failure cases encountered during network operations,
/// including URL validation, request adaptation, serialization, and session failures. It conforms to
/// `LocalizedError` for descriptive failure messages and `Sendable` to support concurrency.
///
/// Example usage:
/// ```swift
/// let error = NetworkingError(kind: .invalidURL)
/// print(error.localizedDescription) // "Invalid URL"
/// ```
public struct NetworkingError: LocalizedError, Sendable {
    /// The affected column line in the source code.
    public let column: Int

    /// A localized message describing the reason for the failure.
    public let failureReason: String?

    /// The underliying kind of error.
    public let kind: ErrorKind

    /// The affected line in the source code.
    public let line: Int

    /// The underliying error.
    public let underlyingError: Error?

    /// A localized message describing what error occurred.
    public var errorDescription: String? {
        failureReason ?? underlyingError?.localizedDescription
    }

    // MARK: - Types

    /// The underliying kind of error.
    public enum ErrorKind: Equatable, Sendable {
        ///  `UploadableBuilder` threw an error in `createUploadable()`.
        case createUploadableFailed

        /// `Request` was explicitly cancelled.
        case explicitlyCancelled

        /// Client failed to create a valid `URL`.
        case invalidURL

        /// `ParameterEncoding` threw an error during the encoding process.
        case parameterEncodingFailed

        /// The request creation threw an error in.
        case requestCreationFailed

        /// `RequestIntercetor` threw an error during the request retry process.
        case requestInterceptationFailed

        /// `RequestRetrier` threw an error during the request retry process.
        case requestRetryFailed

        /// Response serialization failed.
        case responseSerializationFailed

        /// Response validation failed.
        case responseValidationFailed

        /// `Session` was explicitly invalidated, possibly with the `Error` produced by the underlying `URLSession`.
        case sessionInvalidated

        /// `URLSessionTask` completed with error.
        case sessionTaskFailed

        /// `URLRequest` failed validation.
        case urlRequestValidationFailed

        /// Unknown error.
        case unknown
    }

    // MARK: - Initializer

    /// Creates a new instance of the `NetworkingError` with the given underliying error type.
    ///
    /// - Parameters:
    ///   - kind: The type of error.
    ///   - column: The affected column line in the source code.
    ///   - line: The affected line in the srouce code.
    ///   - underlyingError: The underliying error.
    public init(kind: ErrorKind, underlyingError: Error? = nil, column: Int = #column, line: Int = #line) {
        self.column = column
        self.failureReason = nil
        self.kind = kind
        self.line = line
        self.underlyingError = underlyingError
    }

    /// Creates a new instance of the `NetworkingError` with the failure reason.
    ///
    /// - Parameters:
    ///   - kind: The type of error.
    ///   - failureReason: A localized message describing the reason for the failure.
    ///   - column: The affected column line in the source code.
    ///   - line: The affected line in the source code.
    public init(kind: ErrorKind, failureReason: String, column: Int = #column, line: Int = #line) {
        self.column = column
        self.failureReason = failureReason
        self.kind = kind
        self.line = line
        self.underlyingError = nil
    }
}
