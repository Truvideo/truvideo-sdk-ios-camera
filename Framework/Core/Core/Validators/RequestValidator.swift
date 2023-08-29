//
//  RequestValidator.swift
//
//  Created by TruVideo on 8/08/23.
//  Copyright © TruVideo. All rights reserved.
//

import Foundation

/// A custom validation struct that acts as a filter to parse
/// and return meaningfuls error messages.
///
///     ## Example
///
///     {
///         "_v": "21.10",
///         "fault": {
///             "type": "InvalidAuthorizationHeaderException",
///             "message": "The request is unauthorized. In the 'Authorization' header, the 'Bearer <access token>' is expected.",
///             "arguments": {
///                 "statusCode": "008"
///             }
///          }
///      }
struct RequestValidator {
    struct ErrorEntry: Codable, LocalizedError {
        /// The error fault.
        let fault: ErrorFault

        /// A localized message describing what error occurred.
        var errorDescription: String? {
            fault.localizedDescription
        }
    }

    struct ErrorArguments: Codable, LocalizedError {
        /// The status code representing the error.
        let statusCode: String?
    }

    struct ErrorFault: Codable, LocalizedError {
        /// The arguments of the error.
        let arguments: ErrorArguments?

        /// A meaningful message of the error.
        let message: String

        /// The fault type.
        let type: String

        /// A localized message describing what error occurred.
        var errorDescription: String? {
            message
        }
    }

    // MARK: Static methods

    /// Validates the request, using the specified closure.
    ///
    /// - Parameters:
    ///    - request: The request to validate.
    ///    - response: The response returned by the server.
    ///    - data: The data returned by the server.
    /// - Returns: A result containing a success, otherwise an error.
    static func validate(request: URLRequest?, response: URLResponse, data: Data?) -> Result<Void, Error> {
        guard let data = data, !data.isEmpty else {
            return .success(())
        }

        do {
            let error = try JSONDecoder().decode(ErrorEntry.self, from: data)
            return .failure(error)
        } catch {
            guard
                // JSON Object
                let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],

                // Error message
                var error = json["error"] as? String else {

                return .success(())
            }

            // JO: Localize
            error = error == "LoginAlreadyInUseException" ? "This email is already in use. Please sign in." : error

            let errorEntry = ErrorEntry(fault: ErrorFault(arguments: nil, message: error, type: error))
            return .failure(errorEntry)
        }
    }
}
