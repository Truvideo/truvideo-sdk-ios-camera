//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// Protocol for establishing reasons with the domain of Errors.
public struct ErrorReason: Equatable, RawRepresentable {
    // MARK: - Public Properties

    /// The corresponding value of the raw type.
    public let rawValue: String
    
    // MARK: - Static Properties
    
    /// Unknown error.
    public static let unknown = ErrorReason(rawValue: "com.truvideo.commonUtility.unknownError")

    // MARK: - Initializer

    /// Creates a new instance with the specified raw value.
    ///
    /// If there is no value of the type that corresponds with the specified raw
    /// value, this initializer returns `nil`.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension ErrorReason: ExpressibleByStringLiteral {
    /// Creates an instance initialized to the given string value.
    ///
    /// - Parameter value: The value of the new instance.
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

/// A wrapper that contains an error reason as well as an underlying error.
public struct UtilityError: LocalizedError {
    /// The affected column line in the source code.
    public let column: Int

    /// A localized message describing the reason for the failure.
    public let failureReason: String?

    /// The affected line in the source code.
    public let line: Int

    /// The reason the error was triggered.
    public let kind: ErrorReason

    /// The underliying error.
    public let underlyingError: Error?

    /// A localized message describing what error occurred.
    public var errorDescription: String? {
        failureReason ?? underlyingError?.localizedDescription
    }

    // MARK: - Initializer

    /// Creates a new instance of the `FoundationError` with the given
    /// underliying error type.
    ///
    /// - Parameters:
    ///   - kind: The type of error.
    ///   - column: The affected column line in the source code.
    ///   - failureReason: A localized message describing the reason for the failure.
    ///   - line: The affected line in the source code.
    ///   - underlyingError: The underliying error.
    public init(
        kind: ErrorReason,
        failureReason: String? = nil,
        underlyingError: Error? = nil,
        column: Int = #column,
        line: Int = #line
    ) {

        self.column = column
        self.failureReason = failureReason
        self.kind = kind
        self.line = line
        self.underlyingError = underlyingError
    }
}
