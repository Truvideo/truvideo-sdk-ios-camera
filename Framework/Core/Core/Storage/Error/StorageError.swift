//
//  StorageError.swift
//
//  Created by TruVideo on 8/08/23.
//  Copyright © TruVideo. All rights reserved.
//

import Foundation

/// A type representing all the errors that can be thrown.
public struct StorageError: Error {
    /// The affected column line in the source code.
    public let column: Int

    /// The affected line in the source code.
    public let line: Int

    /// The underliying kind of error.
    public let kind: ErrorKind

    /// The underliying error.
    public let underlyingError: Error?

    /// A default instance of the unknown error.
    static let unknown = StorageError(kind: .unknown)

    /// The underliying kind of error.
    public enum ErrorKind {
        /// `clear` failed.
        case clearFailed

        /// `delete` failed.
        case deleteFailed

        /// `readValue` failed.
        case readValueFailed

        /// `write` failed.
        case writeFailed

        /// Unknown error.
        case unknown
    }

    // MARK: Initializers

    /// Creates a new instance of the CMS error with the given
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
