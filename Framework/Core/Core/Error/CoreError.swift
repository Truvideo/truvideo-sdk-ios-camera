//
//  CoreError.swift
//
//  Created by TruVideo on 8/08/23.
//  Copyright © TruVideo. All rights reserved.
//

import Foundation

/// A type representing all the errors that can be thrown.
public struct CoreError: LocalizedError {
    /// The affected column line in the source code.
    public let column: Int

    /// The affected line in the source code.
    public let line: Int

    /// The underliying kind of error.
    public let kind: ErrorKind

    /// The underliying error.
    public let underlyingError: Error?

    /// A localized message describing what error occurred.
    public var errorDescription: String? {
        underlyingError?.localizedDescription
    }

    /// A default instance of the unknown error.
    static let unknown = CoreError(kind: .unknown)

    /// The underliying kind of error.
    public enum ErrorKind {
        /// `apiClient` client request failed.
        case apiRequestFailed

        /// `authenticated` client failed.
        case authenticatedClientFailed
        
        /// `authenticate` failed.
        case authenticateFailed
        
        /// `authenticate` device has failed.
        case deviceAutheticationFailed

        /// `init` device has failed.
        case initializationFailed

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
    public init(kind: ErrorKind, underlyingError: Error? = nil, column: Int = #column, line: Int = #line) {
        self.column = column
        self.kind = kind
        self.line = line
        self.underlyingError = underlyingError
    }
}
