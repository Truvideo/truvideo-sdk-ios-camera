//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A typealias representing a dictionary of parameters used for network requests.
///
/// `Parameters` is defined as a dictionary where the key is a `String` and the value is any type
/// that conforms to both `Any` and `Sendable`. This allows for flexibility in the types of data
/// passed within requests, ensuring thread safety for concurrent tasks.
public typealias Parameters = [String: any Any & Sendable]

/// A protocol that defines an interface for encoding parameters into a `URLRequest`.
///
/// Types conforming to `ParameterEncoder` are responsible for encoding `Encodable` parameters
/// and embedding them into a `URLRequest`. This can involve encoding parameters into the request's
/// body, URL query, or headers, depending on the specific implementation.
///
/// - Conforms to: `Sendable` for safe usage in concurrent contexts.
///
/// ### Example Usage:
/// ```swift
/// struct JSONParameterEncoder: ParameterEncoder {
///     func encode<Parameters: Encodable & Sendable>(
///         _ parameters: Parameters?,
///         into request: URLRequest
///     ) throws -> URLRequest {
///         var request = request
///         guard let parameters = parameters else { return request }
///         request.httpBody = try JSONEncoder().encode(parameters)
///         request.addValue("application/json", forHTTPHeaderField: "Content-Type")
///         return request
///     }
/// }
///
/// let encoder = JSONParameterEncoder()
/// var request = URLRequest(url: URL(string: "https://api.example.com/data")!)
/// let parameters = ["key": "value"]
/// request = try encoder.encode(parameters, into: request)
/// ```
public protocol ParameterEncoder: Sendable {
    /// Encodes the given parameters into a `URLRequest`.
    ///
    /// Implementations of this method should handle how the parameters are encoded
    /// (e.g., as JSON in the request body, as URL query parameters, or as form data).
    ///
    /// - Parameters:
    ///   - parameters: The parameters to be encoded.
    ///   - request: The `URLRequest` instance into which the parameters will be encoded.
    /// - Throws: An error if encoding fails, typically related to serialization issues.
    /// - Returns: A modified `URLRequest` with the encoded parameters applied.
    func encode(_ parameters: Parameters?, into request: URLRequest) throws -> URLRequest
}

/// A parameter encoder that serializes parameters into JSON format.
///
/// `JSONParameterEncoder` encodes parameters conforming to `Encodable` into a JSON payload, which is then added
/// to the body of a `URLRequest`. It supports customizable formatting options such as pretty-printing and sorted keys.
/// This encoder also automatically adds a `Content-Type: application/json` header if it is not already present.
///
/// - Conforms to: `ParameterEncoder`
///
/// ### Example Usage:
/// ```swift
/// let encoder = JSONParameterEncoder()
/// var request = URLRequest(url: URL(string: "https://api.example.com/data")!)
/// let parameters = ["name": "John", "age": 30]
/// let encodedRequest = try encoder.encode(parameters, into: request)
/// ```
public struct JSONParameterEncoder: ParameterEncoder {
    // MARK: - Private Properties

    private let options: JSONSerialization.WritingOptions

    // MARK: - Static Properties

    /// Returns an encoder with `JSONSerialization.WritingOptions` set to `.prettyPrinted`.
    public static var prettyPrinted: JSONParameterEncoder {
        JSONParameterEncoder(options: [.prettyPrinted])
    }

    /// Returns an encoder with `JSONSerialization.WritingOptions` set to `.sortedKeys`.
    public static var sortedKeys: JSONParameterEncoder {
        JSONParameterEncoder(options: [.sortedKeys])
    }

    // MARK: - Initializer

    /// Initializes a new instance with the specified JSON serialization options.
    ///
    /// This initializer allows the configuration of `JSONSerialization.WritingOptions`
    /// to customize how the JSON data is written. These options determine the formatting
    /// of the resulting JSON output, such as enabling pretty-printing or sorting keys.
    ///
    /// - Parameter options: A set of options for writing JSON data. Defaults to an empty set (`[]`).
    public init(options: JSONSerialization.WritingOptions = []) {
        self.options = options
    }

    // MARK: - ParameterEncoder

    /// Encodes the given parameters into a `URLRequest`.
    ///
    /// - Parameters:
    ///   - parameters: The parameters to be encoded.
    ///   - request: The `URLRequest` instance into which the parameters will be encoded.
    /// - Throws: An error if encoding fails, typically related to serialization issues.
    /// - Returns: A modified `URLRequest` with the encoded parameters applied.
    public func encode(_ parameters: Parameters?, into request: URLRequest) throws -> URLRequest {
        guard let parameters else {
            return request
        }

        guard JSONSerialization.isValidJSONObject(parameters) else {
            throw NetworkingError(
                kind: .parameterEncodingFailed,
                failureReason: "The provided parameters \(parameters) cannot be converted to a valid JSON object."
            )
        }

        var request = request

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: options)

            if !request.allHTTPHeaders.contains(.contentType("application/json")) {
                request.allHTTPHeaders.append(.contentType("application/json"))
            }

            return request
        } catch {
            throw NetworkingError(kind: .parameterEncodingFailed, underlyingError: error)
        }
    }
}

extension ParameterEncoder where Self == JSONParameterEncoder {
    /// Provides a default instance of `JSONParameterEncoder`.
    ///
    /// This static property returns a new instance of `JSONParameterEncoder` using the default
    /// `JSONSerialization.WritingOptions`.
    /// It is a convenient way to quickly access a basic JSON encoder for encoding parameters into
    /// a request body.
    public static var json: JSONParameterEncoder {
        JSONParameterEncoder()
    }

    // MARK: - Static methods

    /// Creates a new instance of `JSONParameterEncoder` using a custom `JSONSerialization.WritingOptions`.
    ///
    /// This method allows configuring a custom `JSONEncoder` to handle specialized encoding behavior,
    /// such as custom date formatting strategies or key decoding strategies.
    ///
    /// - Parameter options:  A set of options for writing JSON data. Defaults to an empty set (`[]`).
    /// - Returns: A `JSONParameterEncoder` configured with the specified encoder.
    public static func json(options: JSONSerialization.WritingOptions = []) -> JSONParameterEncoder {
        JSONParameterEncoder(options: options)
    }
}

/// An encoder that encodes parameters into a `URLRequest` either as URL query items or as HTTP body data.
///
/// The `URLParameterEncoder` determines the encoding destination based on the HTTP method or a specified
/// `ParameterDestination`.
/// It supports encoding parameters directly into the URL for methods like `GET`, `HEAD`, and `DELETE`, or into the body
/// for methods like `POST`, `PUT`,
/// and `PATCH`.
///
/// This encoder conforms to the `ParameterEncoder` protocol and is designed to work seamlessly with network request
/// configurations.
public struct URLParameterEncoder: ParameterEncoder {
    // MARK: - Private methods

    private let destination: ParameterDestination

    // MARK: - Types

    /// Defines where the parameters should be encoded within the `URLRequest`.
    public enum ParameterDestination: Sendable {
        /// Automatically determines the destination based on the HTTP method.
        /// Parameters will be encoded in the URL for `GET`, `HEAD`, and `DELETE` methods.
        case auto

        /// Forces parameters to be encoded in the HTTP body.
        case body

        /// Forces parameters to be encoded in the URL query string.
        case query

        // MARK: - Instance Methods

        /// Determines whether parameters should be encoded in the URL based on the HTTP method.
        ///
        /// - Parameter method: The HTTP method used in the request.
        /// - Returns: `true` if the parameters should be encoded in the URL; `false` otherwise.
        func encodeParametersInURL(for method: HTTPMethod) -> Bool {
            switch self {
            case .auto:
                [HTTPMethod.get, .head, .delete].contains(method)

            case .body:
                false

            case .query:
                true
            }
        }
    }

    // MARK: - Initializer

    /// Initializes a new instance of `URLParameterEncoder` with the default destination behavior.
    ///
    /// - Parameter destination: The destination for the parameters.
    public init(destination: ParameterDestination = .auto) {
        self.destination = destination
    }

    // MARK: - ParameterEncoder

    /// Encodes the given parameters into a `URLRequest`.
    ///
    /// - Parameters:
    ///   - parameters: The parameters to be encoded.
    ///   - request: The `URLRequest` instance into which the parameters will be encoded.
    /// - Throws: An error if encoding fails, typically related to serialization issues.
    /// - Returns: A modified `URLRequest` with the encoded parameters applied.
    public func encode(_ parameters: Parameters?, into request: URLRequest) throws -> URLRequest {
        guard let parameters else {
            return request
        }

        var request = request

        if /// The raw string http method.
            let method = request.httpMethod, destination.encodeParametersInURL(for: .init(rawValue: method)) {
            if /// The url of the request.
                let url = request.url,

                /// The components of the url.
                var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                urlComponents.queryItems = parameters.queryItems
                request.url = urlComponents.url
            }
        } else {
            if !request.allHTTPHeaders.contains(.contentType("application/x-www-form-urlencoded")) {
                request.allHTTPHeaders.append(.contentType("application/x-www-form-urlencoded"))
            }

            request.httpBody = Data(parameters.queryString.utf8)
        }

        return request
    }
}

extension ParameterEncoder where Self == URLParameterEncoder {
    /// A static instance of `URLParameterEncoder` for convenience.
    public static var url: URLParameterEncoder {
        URLParameterEncoder()
    }
}

extension NSNumber {
    /// A Boolean property that indicates whether the `NSNumber` instance represents a boolean value.
    ///
    /// This property checks the Objective-C type encoding of the `NSNumber` instance. In Objective-C, the type code
    /// `"c"`
    /// corresponds to a `Bool` (or `char` type). By comparing the `objCType` of the `NSNumber` instance to `"c"`,
    /// this property determines if the instance represents a boolean value.
    ///
    /// - Returns: `true` if the `NSNumber` represents a boolean value; otherwise, `false`.
    fileprivate var isBool: Bool {
        String(cString: objCType) == "c"
    }
}

extension Parameters {
    /// Converts the dictionary into an array of `URLQueryItem`.
    ///
    /// - Returns: An array of `URLQueryItem` representing the key-value pairs.
    /// - Throws: `ParametersEncodingError` if an unsupported type is encountered.
    var queryItems: [URLQueryItem] {
        var components: [URLQueryItem] = []

        for key in keys.sorted(by: <) {
            if let value = self[key] {
                components.append(contentsOf: queryItems(for: key, value: value))
            }
        }

        return components
    }

    /// Generates a URL query string from the dictionary's key-value pairs using `URLQueryItem`.
    ///
    /// This method converts all key-value pairs from the dictionary into a valid URL query string.
    /// The keys are sorted alphabetically for consistent output, which is useful for caching or hashing.
    /// Each key-value pair is encoded and formatted properly.
    ///
    /// - Returns: A `String` representing the URL query parameters, properly formatted and encoded.
    var queryString: String {
        queryItems.map { "\($0.name)=\($0.value ?? "")" }.joined(separator: "&")
    }

    // MARK: - Private methods

    private func queryItems(for key: String, value: Any) -> [URLQueryItem] {
        var items: [URLQueryItem] = []

        switch value {
        case let array as [Any]:
            for (index, element) in array.enumerated() {
                let arrayKey = "\(key)[\(index)]"

                items.append(contentsOf: queryItems(for: arrayKey, value: element))
            }

        case let bool as Bool:
            items.append(URLQueryItem(name: key, value: bool ? "true" : "false"))

        case let dictionary as [String: Any]:
            for (nestedKey, nestedValue) in dictionary {
                let fullKey = "\(key)[\(nestedKey)]"

                items.append(contentsOf: queryItems(for: fullKey, value: nestedValue))
            }

        case let number as NSNumber:
            let valueString = number.isBool ? (number.boolValue ? "true" : "false") : "\(number)"

            items.append(URLQueryItem(name: key, value: valueString))

        case let string as String:
            items.append(URLQueryItem(name: key, value: string))

        default:
            break
        }

        return items
    }
}
