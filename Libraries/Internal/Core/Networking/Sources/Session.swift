//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A protocol that defines an interface for converting instances into a `URL`.
///
/// Types that conform to `URLConvertible` provide a standardized way to convert various representations
/// of a URL (such as `String`, `URLComponents`, or custom URL types) into a valid `URL` instance.
///
/// - Important: Conforming types must implement the `asURL()` method, which should either return a valid `URL`
///   or throw an error if conversion fails.
public protocol URLConvertible {
    /// Converts the conforming instance into a `URL`.
    ///
    /// - Throws: An error if the conversion fails. The specific error thrown depends on the implementation.
    /// - Returns: A valid `URL` instance representing the conforming type.
    func asURL() throws -> URL
}

/// A protocol that defines the requirements for building a `URLRequest`.
///
/// Types conforming to `RequestBuilder` are responsible for constructing and returning a valid `URLRequest`.
/// This allows for a flexible and reusable pattern when creating network requests, supporting customization of headers,
/// HTTP methods, URL paths, query parameters, and body content.
///
/// Conforming types should implement the `build()` method, which can throw errors if the request configuration is
/// invalid
/// or if serialization fails.
public protocol RequestBuilder {
    /// Builds and returns a configured `URLRequest` instance.
    ///
    /// This method should be implemented by conforming types to provide the necessary logic for constructing
    /// a valid HTTP request. The request should include all necessary details such as the URL, HTTP method,
    /// headers, query parameters, and body content.
    ///
    /// - Throws: An error if the request cannot be constructed. This may occur due to invalid URL components,
    /// serialization issues, or missing required fields.
    /// - Returns: A fully configured `URLRequest` instance ready for execution.
    func build() throws -> URLRequest
}

/// A type that can produce an `UploadRequest.Uploadable` value.
public protocol UploadableBuilder {
    /// Produces an `UploadRequest.Uploadable` value from the instance.
    ///
    /// - Returns: The `UploadRequest.Uploadable`.
    /// - Throws:  Any `Error` produced during creation.
    func createUploadable() throws -> HTTPURLUploadRequest.Uploadable
}

extension HTTPURLUploadRequest.Uploadable: UploadableBuilder {
    /// Produces an `UploadRequest.Uploadable` value from the instance.
    ///
    /// - Returns: The `UploadRequest.Uploadable`.
    /// - Throws:  Any `Error` produced during creation.
    public func createUploadable() throws -> HTTPURLUploadRequest.Uploadable {
        switch self {
        case let .data(data):
            guard !data.isEmpty else {
                throw NetworkingError(
                    kind: .createUploadableFailed,
                    failureReason: "Empty Data is not allowed for upload."
                )
            }

            return self

        case let .file(url, _):
            guard url.isFileURL else {
                throw NetworkingError(
                    kind: .createUploadableFailed,
                    failureReason: "URL must be a file URL (file://)"
                )
            }

            return self

        default:
            return self
        }
    }
}

/// A type that can be converted to an upload, whether from an `UploadRequest.Uploadable` or `RequestBuilder`.
public protocol UploadRequestBuilder: UploadableBuilder & RequestBuilder {}

/// A protocol that defines a network session capable of creating and managing HTTP requests.
///
/// Types conforming to `Session` provide functionality for initiating, managing,
/// and cancelling HTTP-based network requests. This abstraction enables dependency injection,
/// mocking, and alternative session implementations beyond standard URLSession.
///
/// Conforming types should support flexible request creation using either raw URL parameters
/// or prebuilt request builders, as well as support for request-level middleware and caching policies.
public protocol Session: Sendable {
    /// Cancels all active network requests.
    ///
    /// This method asynchronously iterates through all currently active requests and cancels them.
    func cancelAllRequests()

    // MARK: - DataRequest

    /// Creates and initiates a `DataRequest` using the provided URL, HTTP method, parameters, and additional
    /// configuration.
    ///
    /// - Parameters:
    ///   - url: A `URLConvertible` instance representing the endpoint for the request.
    ///   - method: The HTTP method for the request (default is `.get`).
    ///   - parameters: A dictionary of parameters to be included in the request (default is `nil`).
    ///   - encoder: The `ParameterEncoder` used for encoding request parameters (default is `.url`).
    ///   - headers: Additional HTTP headers to be included in the request (default is `nil`).
    ///   - middleware: An optional `RequestMiddleware` to handle pre-processing or modifications before the request is
    /// executed (default is `nil`).
    ///   - cachePolicy: The caching policy that defines how network requests should interact with local cache data.
    /// - Returns: A `DataRequest` instance representing the network request, ready for execution.
    func request(
        _ url: URLConvertible,
        method: HTTPMethod,
        parameters: Parameters?,
        encoder: ParameterEncoder,
        headers: HTTPHeaders?,
        middleware: RequestMiddleware?,
        cachePolicy: URLCachePolicy
    ) -> any DataRequest

    /// Creates and initiates a `DataRequest` using the provided request builder and optional middleware.
    ///
    /// This method constructs a `DataRequest` by utilizing the given `RequestBuilder` to configure the request.
    /// Optionally, a `RequestMiddleware` can be applied to modify the request before execution, such as adding headers,
    /// logging, or handling pre-processing logic.
    ///
    /// - Parameters:
    ///   - requestBuilder: An instance conforming to `RequestBuilder`, responsible for constructing a valid
    /// `URLRequest`.
    ///   - middleware: An optional `RequestMiddleware` instance that can modify or handle the request before it is
    /// executed.
    ///   - cachePolicy: The caching policy that defines how network requests should interact with local cache data.
    /// - Returns: A `DataRequest` instance representing the ongoing network request, which can be monitored, cancelled,
    /// or validated.
    func request(
        _ requestBuilder: RequestBuilder,
        middleware: RequestMiddleware?,
        cachePolicy: URLCachePolicy
    ) -> any DataRequest

    // MARK: - UploadRequest

    /// Creates and initiates an `UploadRequest` for uploading `Data` to the specified endpoint.
    ///
    /// This method builds a `URLRequest` using the provided URL, HTTP method, headers, and optional
    /// request modifications. The upload is then managed by the returned `UploadRequest`, which supports
    /// additional features like interceptors and custom file management.
    ///
    /// - Parameters:
    ///   - data: The `Data` to upload.
    ///   - url: A `URLConvertible` value representing the endpoint for the request.
    ///   - method: The `HTTPMethod` for the request. Defaults to `.post`.
    ///   - headers: Additional `HTTPHeaders` to include in the request. Defaults to `nil`.
    ///   - middleware: An optional `RequestMiddleware` instance that can modify or handle the request before it is
    /// executed.
    ///
    /// - Returns: An `UploadRequest` instance representing the upload operation, ready for execution.
    func upload(
        _ data: Data,
        to url: URLConvertible,
        method: HTTPMethod,
        headers: HTTPHeaders?,
        middleware: RequestMiddleware?
    ) -> any UploadRequest

    /// Creates an `UploadRequest` to send raw `Data` to a server using the provided request configuration.
    ///
    /// This method builds and initiates an `UploadRequest` by combining the provided raw `Data` payload
    /// with a `RequestBuilder`, which is responsible for constructing the base `URLRequest`.
    /// Optionally, a `RequestMiddleware` can be applied to intercept or modify the request before
    /// it is executed (e.g., to inject headers, perform logging, or apply custom pre-processing logic).
    ///
    /// - Parameters:
    ///   - data: The `Data` payload to be uploaded.
    ///   - requestBuilder: A `RequestBuilder` instance responsible for generating the `URLRequest`
    ///     configuration (e.g., URL, HTTP method, headers).
    ///   - middleware: An optional `RequestMiddleware` that can modify or inspect the request before
    ///     execution. Defaults to `nil`.
    ///
    /// - Returns: An `UploadRequest` configured with the given `Data` and request parameters.
    func upload(
        _ data: Data,
        with requestBuilder: RequestBuilder,
        middleware: RequestMiddleware?
    ) -> any UploadRequest

    /// Creates and initiates an `UploadRequest` for uploading `file URL` to the specified endpoint.
    ///
    /// This method builds a `URLRequest` using the provided URL, HTTP method, headers, and optional
    /// request modifications. The upload is then managed by the returned `UploadRequest`, which supports
    /// additional features like interceptors and custom file management.
    ///
    /// - Parameters:
    ///   - fileURL: The `URL` of the file to upload.
    ///   - url: A `URLConvertible` value representing the endpoint for the request.
    ///   - method: The `HTTPMethod` for the request. Defaults to `.post`.
    ///   - headers: Additional `HTTPHeaders` to include in the request. Defaults to `nil`.
    ///   - fileManager: `FileManager` instance to be used by the returned `UploadRequest`. `.default` instance by
    /// default.
    ///   - middleware: An optional `RequestMiddleware` instance that can modify or handle the request before it is
    /// executed.
    /// - Returns: An `UploadRequest` instance representing the upload operation, ready for execution.
    func upload(
        _ fileURL: URL,
        to url: any URLConvertible,
        method: HTTPMethod,
        headers: HTTPHeaders?,
        fileManager: FileManager,
        middleware: RequestMiddleware?
    ) -> any UploadRequest

    /// Creates an `UploadRequest` to send `file URL` to a server using the provided request configuration.
    ///
    /// This method builds and initiates an `UploadRequest` by combining the provided `file URL` payload
    /// with a `RequestBuilder`, which is responsible for constructing the base `URLRequest`.
    /// Optionally, a `RequestMiddleware` can be applied to intercept or modify the request before
    /// it is executed (e.g., to inject headers, perform logging, or apply custom pre-processing logic).
    ///
    /// - Parameters:
    ///   - fileURL: The `URL` of the file to upload.
    ///   - requestBuilder: A `RequestBuilder` instance responsible for generating the `URLRequest`
    ///     configuration (e.g., URL, HTTP method, headers).
    ///   - fileManager: `FileManager` instance to be used by the returned `UploadRequest`. `.default` instance by
    /// default.
    ///   - middleware: An optional `RequestMiddleware` that can modify or inspect the request before
    ///     execution. Defaults to `nil`.
    /// - Returns: An `UploadRequest` configured with the given `file URL` and request parameters.
    func upload(
        _ fileURL: URL,
        with requestBuilder: any RequestBuilder,
        fileManager: FileManager,
        middleware: RequestMiddleware?
    ) -> any UploadRequest
}

extension Session {
    /// Creates and initiates a `DataRequest` using the provided URL, HTTP method, parameters, and additional
    /// configuration.
    ///
    /// - Parameters:
    ///   - url: A `URLConvertible` instance representing the endpoint for the request.
    ///   - method: The HTTP method for the request (default is `.get`).
    ///   - parameters: A dictionary of parameters to be included in the request (default is `nil`).
    ///   - encoder: The `ParameterEncoder` used for encoding request parameters (default is `.url`).
    ///   - headers: Additional HTTP headers to be included in the request (default is `nil`).
    ///   - middleware: An optional `RequestMiddleware` to handle pre-processing or modifications before the request is
    /// executed (default is `nil`).
    ///   - cachePolicy: The caching policy that defines how network requests should interact with local cache data.
    /// - Returns: A `DataRequest` instance representing the network request, ready for execution.
    public func request(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoder: ParameterEncoder = .url,
        headers: HTTPHeaders? = nil,
        middleware: RequestMiddleware? = nil,
        cachePolicy: URLCachePolicy = .reloadIgnoringLocalCacheData
    ) -> any DataRequest {
        request(
            url,
            method: method,
            parameters: parameters,
            encoder: encoder,
            headers: headers,
            middleware: middleware,
            cachePolicy: cachePolicy
        )
    }

    /// Creates and initiates a `DataRequest` using the provided request builder and optional middleware.
    ///
    /// This method constructs a `DataRequest` by utilizing the given `RequestBuilder` to configure the request.
    /// Optionally, a `RequestMiddleware` can be applied to modify the request before execution, such as adding headers,
    /// logging, or handling pre-processing logic.
    ///
    /// - Parameters:
    ///   - requestBuilder: An instance conforming to `RequestBuilder`, responsible for constructing a valid
    /// `URLRequest`.
    ///   - middleware: An optional `RequestMiddleware` instance that can modify or handle the request before it is
    /// executed.
    ///   - cachePolicy: The caching policy that defines how network requests should interact with local cache data.
    /// - Returns: A `DataRequest` instance representing the ongoing network request, which can be monitored, cancelled,
    /// or validated.
    public func request(
        _ requestBuilder: RequestBuilder,
        middleware: RequestMiddleware? = nil,
        cachePolicy: URLCachePolicy = .reloadIgnoringLocalCacheData
    ) -> any DataRequest {
        request(requestBuilder, middleware: middleware, cachePolicy: cachePolicy)
    }

    /// Creates and initiates a `DataRequest` using the provided URL, HTTP method, parameters, and additional
    /// configuration.
    ///
    /// - Parameters:
    ///   - url: A `URLConvertible` instance representing the endpoint for the request.
    ///   - method: The HTTP method for the request (default is `.get`).
    ///   - headers: Additional HTTP headers to be included in the request (default is `nil`).
    ///   - middleware: An optional `RequestMiddleware` to handle pre-processing or modifications before the request is
    /// executed (default is `nil`).
    /// - Returns: A `DataRequest` instance representing the network request, ready for execution.
    public func upload(
        _ data: Data,
        to url: URLConvertible,
        method: HTTPMethod = .post,
        headers: HTTPHeaders? = nil,
        middleware: RequestMiddleware? = nil
    ) -> any UploadRequest {
        upload(data, to: url, method: method, headers: headers, middleware: middleware)
    }

    /// Creates an `UploadRequest` to send raw `Data` to a server using the provided request configuration.
    ///
    /// This method builds and initiates an `UploadRequest` by combining the provided raw `Data` payload
    /// with a `RequestBuilder`, which is responsible for constructing the base `URLRequest`.
    /// Optionally, a `RequestMiddleware` can be applied to intercept or modify the request before
    /// it is executed (e.g., to inject headers, perform logging, or apply custom pre-processing logic).
    ///
    /// - Parameters:
    ///   - data: The `Data` payload to be uploaded.
    ///   - requestBuilder: A `RequestBuilder` instance responsible for generating the `URLRequest`
    ///     configuration (e.g., URL, HTTP method, headers).
    ///   - middleware: An optional `RequestMiddleware` that can modify or inspect the request before
    ///     execution. Defaults to `nil`.
    /// - Returns: An `UploadRequest` configured with the given `Data` and request parameters.
    public func upload(
        _ data: Data,
        with requestBuilder: RequestBuilder,
        middleware: RequestMiddleware? = nil
    ) -> any UploadRequest {
        upload(data, with: requestBuilder, middleware: middleware)
    }

    /// Creates and initiates an `UploadRequest` for uploading `file URL` to the specified endpoint.
    ///
    /// This method builds a `URLRequest` using the provided URL, HTTP method, headers, and optional
    /// request modifications. The upload is then managed by the returned `UploadRequest`, which supports
    /// additional features like interceptors and custom file management.
    ///
    /// - Parameters:
    ///   - fileURL: The `URL` of the file to upload.
    ///   - url: A `URLConvertible` value representing the endpoint for the request.
    ///   - method: The `HTTPMethod` for the request. Defaults to `.post`.
    ///   - headers: Additional `HTTPHeaders` to include in the request. Defaults to `nil`.
    ///   - fileManager: `FileManager` instance to be used by the returned `UploadRequest`. `.default` instance by
    /// default.
    ///   - middleware: An optional `RequestMiddleware` instance that can modify or handle the request before it is
    /// executed.
    /// - Returns: An `UploadRequest` instance representing the upload operation, ready for execution.
    public func upload(
        _ fileURL: URL,
        to url: any URLConvertible,
        method: HTTPMethod,
        headers: HTTPHeaders? = nil,
        fileManager: FileManager = FileManager.default,
        middleware: RequestMiddleware? = nil
    ) -> any UploadRequest {
        upload(fileURL, to: url, method: method, headers: headers, fileManager: fileManager, middleware: middleware)
    }

    /// Creates an `UploadRequest` to send `file URL` to a server using the provided request configuration.
    ///
    /// This method builds and initiates an `UploadRequest` by combining the provided `file URL` payload
    /// with a `RequestBuilder`, which is responsible for constructing the base `URLRequest`.
    /// Optionally, a `RequestMiddleware` can be applied to intercept or modify the request before
    /// it is executed (e.g., to inject headers, perform logging, or apply custom pre-processing logic).
    ///
    /// - Parameters:
    ///   - fileURL: The `URL` of the file to upload.
    ///   - requestBuilder: A `RequestBuilder` instance responsible for generating the `URLRequest`
    ///     configuration (e.g., URL, HTTP method, headers).
    ///   - fileManager: `FileManager` instance to be used by the returned `UploadRequest`. `.default` instance by
    /// default.
    ///   - middleware: An optional `RequestMiddleware` that can modify or inspect the request before
    ///     execution. Defaults to `nil`.
    /// - Returns: An `UploadRequest` configured with the given `file URL` and request parameters.
    public func upload(
        _ fileURL: URL,
        with requestBuilder: any RequestBuilder,
        fileManager: FileManager = FileManager.default,
        middleware: RequestMiddleware? = nil
    ) -> any UploadRequest {
        upload(fileURL, with: requestBuilder, fileManager: fileManager, middleware: middleware)
    }
}
