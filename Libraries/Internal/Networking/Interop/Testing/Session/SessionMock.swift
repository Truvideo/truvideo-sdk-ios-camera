//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import NetworkingInterop

/// A mock implementation of the `Session` protocol for testing.
public final class SessionMock: Session {
    // MARK: - Public Properties

    /// The number of times `cancelAllRequests()` has been called.
    public private(set) var cancelAllRequestsCallCount = 0

    /// The number of times the URL-based `request(_:method:parameters:encoder:headers:middleware:cachePolicy:)` method has been called.
    public private(set) var requestURLCallCount = 0

    /// The number of times the builder-based `request(_:middleware:cachePolicy:)` method has been called.
    public private(set) var requestBuilderCallCount = 0

    /// The last URL passed to the URL-based request method.
    public private(set) var lastRequestURL: URLConvertible?

    /// The last HTTP method passed to the URL-based request method.
    public private(set) var lastRequestMethod: HTTPMethod?

    /// The last parameters passed to the URL-based request method.
    public private(set) var lastRequestParameters: Parameters?

    /// The last parameter encoder passed to the URL-based request method.
    public private(set) var lastRequestEncoder: ParameterEncoder?

    /// The last HTTP headers passed to the URL-based request method.
    public private(set) var lastRequestHeaders: HTTPHeaders?

    /// The last middleware passed to the URL-based request method.
    public private(set) var lastRequestMiddleware: RequestMiddleware?

    /// The last cache policy passed to the URL-based request method.
    public private(set) var lastRequestCachePolicy: URLCachePolicy?

    /// The last request builder passed to the builder-based request method.
    public private(set) var lastRequestBuilder: RequestBuilder?

    /// The last middleware passed to the builder-based request method.
    public private(set) var lastBuilderMiddleware: RequestMiddleware?

    /// The last cache policy passed to the builder-based request method.
    public private(set) var lastBuilderCachePolicy: URLCachePolicy?

    // MARK: - Initializer

    /// Creates a new instance of the `SessionMock`.
    public init() {}

    // MARK: - Session

    /// Cancels all active network requests.
    ///
    /// This method asynchronously iterates through all currently active requests and cancels them.
    public func cancelAllRequests() {
        cancelAllRequestsCallCount += 1
    }

    /// Creates and initiates a `DataRequest` using the provided URL, HTTP method, parameters, and additional configuration.
    ///
    /// - Parameters:
    ///   - url: A `URLConvertible` instance representing the endpoint for the request.
    ///   - method: The HTTP method for the request (default is `.get`).
    ///   - parameters: A dictionary of parameters to be included in the request (default is `nil`).
    ///   - encoder: The `ParameterEncoder` used for encoding request parameters (default is `.url`).
    ///   - headers: Additional HTTP headers to be included in the request (default is `nil`).
    ///   - middleware: An optional `RequestMiddleware` to handle pre-processing or modifications before the request is executed (default is `nil`).
    ///   - cachePolicy: The caching policy that defines how network requests should interact with local cache data.
    /// - Returns: A `DataRequest` instance representing the network request, ready for execution.
    public func request(
        _ url: URLConvertible,
        method: HTTPMethod,
        parameters: Parameters?,
        encoder: ParameterEncoder,
        headers: HTTPHeaders?,
        middleware: RequestMiddleware?,
        cachePolicy: URLCachePolicy
    ) -> DataRequestMock {
        requestURLCallCount += 1
        lastRequestURL = url
        lastRequestMethod = method
        lastRequestParameters = parameters
        lastRequestEncoder = encoder
        lastRequestHeaders = headers
        lastRequestMiddleware = middleware
        lastRequestCachePolicy = cachePolicy

        return DataRequestMock()
    }

    /// Creates and initiates a `DataRequest` using the provided request builder and optional middleware.
    ///
    /// This method constructs a `DataRequest` by utilizing the given `RequestBuilder` to configure the request.
    /// Optionally, a `RequestMiddleware` can be applied to modify the request before execution, such as adding headers,
    /// logging, or handling pre-processing logic.
    ///
    /// - Parameters:
    ///   - requestBuilder: An instance conforming to `RequestBuilder`, responsible for constructing a valid `URLRequest`.
    ///   - middleware: An optional `RequestMiddleware` instance that can modify or handle the request before it is executed.
    ///   - cachePolicy: The caching policy that defines how network requests should interact with local cache data.
    /// - Returns: A `DataRequest` instance representing the ongoing network request, which can be monitored, cancelled, or validated.
    public func request(
        _ requestBuilder: RequestBuilder,
        middleware: RequestMiddleware?,
        cachePolicy: URLCachePolicy
    ) -> DataRequestMock {
        requestBuilderCallCount += 1
        lastRequestBuilder = requestBuilder
        lastBuilderMiddleware = middleware
        lastBuilderCachePolicy = cachePolicy

        return DataRequestMock()
    }
}
