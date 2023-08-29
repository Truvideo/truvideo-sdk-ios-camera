//
//  Response.swift
//
//  Created by TruVideo on 8/08/23.
//  Copyright © TruVideo. All rights reserved.
//

import Foundation

/// Type used to store all values associated with a serialized response of a `HTTPURLResponse`.
public struct Response<Success> {
    /// The data returned by the server.
    public let data: Data?

    /// Returns the associated error value if the result if it is a failure, `nil` otherwise.
    public var error: NetworkError? {
        switch result {
        case let .failure(error): return error
        default: return nil
        }
    }

    /// The URL request sent to the server.
    public let request: URLRequest?

    /// The server's response to the URL request.
    public let response: HTTPURLResponse?

    /// The result of response serialization.
    public let result: Result<Success, NetworkError>

    /// Returns the associated value of the result if it is a success, `nil` otherwise.
    public var value: Success? {
        switch result {
        case let .success(value): return value
        default: return nil
        }
    }

    // MARK: Initializers

    /// Creates a `Response` instance with the specified parameters.
    ///
    /// - Parameters:
    ///    - data: The data returned by the server.
    ///    - request: The URL request sent to the server.
    ///    - response: The server's response to the URL request.
    ///    - result: The result of response serialization.
    init(
        data: Data? = nil,
        request: URLRequest? = nil,
        response: HTTPURLResponse? = nil,
        result: Result<Success, NetworkError>
    ) {

        self.data = data
        self.request = request
        self.response = response
        self.result = result
    }

    // MARK: Public methods

    /// Returns a new result, mapping any success value using the given  transformation.
    ///
    /// - Parameter transform: A closure that takes the success value of this
    ///   instance.
    /// - Returns: A `Result` instance with the result of evaluating `transform`
    ///            as the new success value if this instance represents a success.
    public func map<NewSuccess>(_ transform: (Success) -> NewSuccess) -> Response<NewSuccess> {
        .init(data: data, request: request, response: response, result: result.map(transform))
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

        if let data = urlRequest.httpBody {
            bodyDescription = """
            [Body]: \(String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines))
            """
                .replacingOccurrences(of: "\n", with: "\n    ")
        }

        let responseDescription = response.map { response in
            let body = data.map { data in
                String(decoding: data, as: UTF8.self)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .replacingOccurrences(of: "\n", with: "\n    ")
            } ?? "None"
            return """
            [Response]:
                [Status Code]: \(response.statusCode)
                [Body]: \(body)
            """
                .replacingOccurrences(of: "\n", with: "\n    ")
        } ?? "[Response]: None"

        return """
        [Request]: \(urlRequest.httpMethod ?? "") \(urlRequest)
        \(bodyDescription)
        \(responseDescription)
        [Result]: \(result)
        """
    }
}
