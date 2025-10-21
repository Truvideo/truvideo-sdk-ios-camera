//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// Represents the response returned from a network request.
///
/// `Response` encapsulates the data returned by the server, the associated request, the response metadata,
/// and the result of response serialization. It provides utility properties to easily access success values
/// and error information.
///
/// Example usage:
/// ```swift
/// let response = Response<String>(
///     data: responseData,
///     request: urlRequest,
///     response: httpResponse,
///     result: .success("Success")
///  )
/// print(response.value) // Optional("Success")
/// ```
public struct Response<Success: Sendable, Failure: Error>: Sendable where Failure: Sendable {
    /// The data returned by the server.
    public let data: Data?

    /// The final metrics of the response.
    public let metrics: URLSessionTaskMetrics?

    /// The URL request sent to the server.
    public let request: URLRequest?

    /// The server's response to the URL request.
    public let response: HTTPURLResponse?

    /// The result of response serialization.
    public let result: Result<Success, Failure>

    /// The source of the response.
    public let type: ResponseType

    // MARK: - Computed Properties

    /// Returns the associated error value if the result if it is a failure, `nil` otherwise.
    public var error: Failure? {
        switch result {
        case let .failure(error):
            error

        default:
            nil
        }
    }

    /// Returns the associated value of the result if it is a success, `nil` otherwise.
    public var value: Success? {
        switch result {
        case let .success(value):
            value

        default:
            nil
        }
    }

    // MARK: - Initializer

    /// Creates a `Response` instance with the specified parameters.
    ///
    /// - Parameters:
    ///    - data: The data returned by the server.
    ///    - metrics: The final metrics of the response.
    ///    - request: The URL request sent to the server.
    ///    - response: The server's response to the URL request.
    ///    - result: The result of response serialization.
    ///    - type: The source of the response.
    public init(
        data: Data?,
        metrics: URLSessionTaskMetrics?,
        request: URLRequest?,
        response: HTTPURLResponse?,
        result: Result<Success, Failure>,
        type: ResponseType
    ) {
        self.data = data
        self.metrics = metrics
        self.request = request
        self.response = response
        self.result = result
        self.type = type
    }

    // MARK: - Public methods

    /// Returns a new result, mapping any success value using the given  transformation.
    ///
    /// - Parameter transform: A closure that takes the success value of this
    ///   instance.
    /// - Returns: A `Result` instance with the result of evaluating `transform`
    ///            as the new success value if this instance represents a success.
    public func map<NewSuccess>(_ transform: (Success) -> NewSuccess) -> Response<NewSuccess, Failure> {
        .init(
            data: data,
            metrics: metrics,
            request: request,
            response: response,
            result: result.map(transform),
            type: type
        )
    }
}

extension Response: CustomStringConvertible, CustomDebugStringConvertible {
    /// The textual representation used when written to an output stream, which includes whether the result was a
    /// success or failure.
    public var description: String {
        "\(result)"
    }

    /// The debug textual representation used when written to an output stream, which includes (if available) a summary
    /// of the `URLRequest`, the request's headers and body; the
    /// `HTTPURLResponse`'s status code and body; and the `Result` of serialization.
    public var debugDescription: String {
        guard let urlRequest = request else { return "[Request]: None\n[Result]: \(result)" }

        var bodyDescription = "[Body]: None"

        if /// The body data.
            let data = urlRequest.httpBody,

            /// String representation of the body.
            let body = String(data: data, encoding: .utf8) {
            bodyDescription = """
            [Body]: \(body.trimmingCharacters(in: .whitespacesAndNewlines))
            """
                .replacingOccurrences(of: "\n", with: "\n    ")
        }

        var responseDescription = "[Response]: None"

        if let response {
            var body = "None"

            if /// The response data.
                let data,

                /// The string representation of the response.
                let responseString = String(data: data, encoding: .utf8) {
                body =
                    responseString
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .replacingOccurrences(of: "\n", with: "\n    ")
            }

            responseDescription = """
            [Response]:
                [Status Code]: \(response.statusCode)
                [Body]: \(body)
            """
                .replacingOccurrences(of: "\n", with: "\n    ")
        }

        return """
        [Request]: \(urlRequest.httpMethod ?? "") \(urlRequest)
        \(bodyDescription)
        \(responseDescription)
        [Result]: \(result)
        [Type]: \(type)
        """
    }
}
