//
//  NetworkError.swift
//
//  Created by TruVideo on 8/08/23.
//  Copyright © TruVideo. All rights reserved.
//

import Alamofire
import Foundation

/// A type representing all the errors that can be thrown.
public struct NetworkError: LocalizedError {
    /// The affected column line in the source code.
    public let column: Int

    /// The affected line in the source code.
    public let line: Int

    /// The underliying kind of error.
    public let kind: ErrorKind

    /// The underliying error.
    public let underlyingError: Error?

    /// A default instance of the unknown error.
    static let unknown = NetworkError(kind: .unknown)

    /// A localized message describing what error occurred.
    public var errorDescription: String? {
        guard let afError = underlyingError?.asAFError else {
            return underlyingError?.localizedDescription
        }

        return afError.underlyingError?.localizedDescription ?? afError.localizedDescription
    }

    /// The underliying kind of error.
    public enum ErrorKind {
        /// `Request` was explicitly cancelled.
        case explicitlyCancelled

        /// Client failed to create a valid `URL`.
        case invalidURL(url: String)

        /// `ParameterEncoding` threw an error during the encoding process.
        case parameterEncodingFailed

        /// `RequestAdapter` threw an error during adaptation.
        case requestAdaptationFailed

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

    // MARK: Initializers

    /// Creates a new instance of the network error with the given
    /// underliying error type.
    ///
    /// - Parameters:
    ///   - kind: The type of error.
    ///   - column: The affected column line in the source code.
    ///   - line: The affected line in the srouce code.
    ///   - underlyingError: The underliying error.
    init(kind: ErrorKind, underlyingError: Error? = nil, column: Int = #column, line: Int = #line) {
        self.column = column
        self.kind = kind
        self.line = line
        self.underlyingError = underlyingError
    }
}
