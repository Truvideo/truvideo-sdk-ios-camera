//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A validator for HTTP responses that handles error parsing and validation.
///
/// `RequestValidator` provides a standardized way to validate HTTP responses and parse
/// error information from server responses. It automatically detects error responses
/// and converts them into appropriate `UtilityError` instances with detailed error
/// information.
///
/// ## Purpose
///
/// This validator is used to:
/// - **Parse error responses**: Extract error details from JSON responses
/// - **Standardize error handling**: Convert server errors to consistent error types
/// - **Provide detailed error information**: Include both error message and detail
/// - **Validate response data**: Ensure proper error response structure
///
/// ## Error Response Format
///
/// The validator expects error responses in the following JSON format:
///
/// ```json
/// {
///   "type": "about:blank",
///   "title": "Unsupported Media Type",
///   "status": 415,
///   "detail": "Content-Type 'application/x-www-form-urlencoded;charset=UTF-8' is not supported.",
///   "instance": "/api/device"
/// }
/// ```
enum RequestValidator {
    // MARK: - Types

    /// Internal structure for parsing error responses from the server.
    ///
    /// This private struct defines the expected JSON structure for error responses,
    /// containing error details and optional additional fields for enhanced error information.
    struct ResponseError: Decodable, Error {
        /// A detailed description of the error that occurred.
        ///
        /// This provides human-readable information about what went wrong,
        /// useful for debugging and user-facing error messages.
        let detail: String?

        /// A machine-readable error code that identifies the type of error.
        ///
        /// This code should correspond to a value in the `ErrorReason` enum
        /// to enable proper error handling and categorization.
        let message: String?
    }

    // MARK: - Static methods

    /// Validates an HTTP response and parses any error information.
    ///
    /// This method examines the response data and attempts to parse it as an error
    /// response. If successful, it throws a `UtilityError` with the parsed error
    /// information. If parsing fails or no error is detected, the method returns
    /// normally.
    ///
    /// - Parameters:
    ///    - request: The original URL request (unused in current implementation)
    ///    - response: The HTTP response to validate
    ///    - data: The response data to parse for error information
    /// - Throws: an `UtilityError` If the response contains valid error information
    @Sendable
    static func validate(request: URLRequest?, response: HTTPURLResponse, data: Data?) throws {
        guard
            /// Response should be a error valid status code.
            response.statusCode >= 400,

            /// The response data received by the server.
            let data,

            /// The decoded error if any,
            let error = try? JSONDecoder().decode(ResponseError.self, from: data)
        else { return }

        throw error
    }
}
