//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Networking

/// A mock implementation of the `Session` protocol for testing.
public final class SessionMock: Session, @unchecked Sendable {
    // MARK: - Public Properties

    /// A mock request to be returned.
    public var dataRequest: (any DataRequest)?

    /// The number of times the `upload`data  method has been called.
    public private(set) var uploadDataCallCount = 0

    /// The number of times the `upload`URL  method has been called.
    public private(set) var uploadFileURLCallCount = 0

    /// The last data payload passed to the `upload` method.
    public var lastUploadData: Data?

    /// The last file URL  payload passed to the `upload` method.
    public var lastUploadFileURL: URL?

    /// The number of times `cancelAllRequests()` has been called.
    public private(set) var cancelAllRequestsCallCount = 0

    /// The number of times the URL-based `request(_:method:parameters:encoder:headers:middleware:cachePolicy:)` method
    /// has been called.
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

    /// An optional mock `UploadRequest` instance to be returned by the `upload` method.
    public var uploadRequestMock: (any UploadRequest)?

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
    public func request(
        _ url: URLConvertible,
        method: HTTPMethod,
        parameters: Parameters?,
        encoder: ParameterEncoder,
        headers: HTTPHeaders?,
        middleware: RequestMiddleware?,
        cachePolicy: URLCachePolicy
    ) -> any DataRequest {
        requestURLCallCount += 1
        lastRequestURL = url
        lastRequestMethod = method
        lastRequestParameters = parameters
        lastRequestEncoder = encoder
        lastRequestHeaders = headers
        lastRequestMiddleware = middleware
        lastRequestCachePolicy = cachePolicy

        return dataRequest ?? DataRequestMock()
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
        middleware: RequestMiddleware?,
        cachePolicy: URLCachePolicy
    ) -> any DataRequest {
        requestBuilderCallCount += 1
        lastRequestBuilder = requestBuilder
        lastBuilderMiddleware = middleware
        lastBuilderCachePolicy = cachePolicy

        return dataRequest ?? DataRequestMock()
    }

    // MARK: - UploadRequest

    /// Mocks an upload request for testing purposes.
    ///
    /// - Parameters:
    ///   - data: The raw data to be uploaded.
    ///   - url: The destination URL for the upload, conforming to `Networking.URLConvertible`.
    ///   - method: The HTTP method to use for the upload (e.g., `.put`, `.post`).
    ///   - headers: Optional HTTP headers to include in the request.
    ///   - middleware: Optional request middleware to apply to the upload.
    ///
    /// - Returns: A mock `UploadRequest` instance, either the `uploadRequestMock` provided
    ///            or a new `UploadRequestMock` with the configured `delay`.
    public func upload(
        _ data: Data,
        to url: any URLConvertible,
        method: HTTPMethod,
        headers: HTTPHeaders?,
        middleware: (any RequestMiddleware)?
    ) -> any UploadRequest {
        uploadDataCallCount += 1

        lastUploadData = data
        lastRequestURL = url
        lastRequestMethod = method
        lastRequestHeaders = headers
        lastRequestMiddleware = middleware

        return uploadRequestMock ?? UploadRequestMock()
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
    ///   - middleware: An optional `RequestMiddleware` instance that can modify or handle the request before it is
    /// executed.
    /// - Returns: An `UploadRequest` instance representing the upload operation, ready for execution.
    public func upload(
        _ fileURL: URL,
        to url: any URLConvertible,
        method: HTTPMethod,
        headers: HTTPHeaders?,
        middleware: RequestMiddleware?
    ) -> any UploadRequest {
        uploadFileURLCallCount += 1

        lastUploadFileURL = fileURL
        lastRequestURL = url
        lastRequestMethod = method
        lastRequestHeaders = headers
        lastRequestMiddleware = middleware

        return uploadRequestMock ?? UploadRequestMock()
    }
}
