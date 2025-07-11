//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

@testable import Networking

/// A mock implementation of `Session` for testing purposes.
///
/// `SessionMock` is a subclass of `Session` that allows simulating network requests and responses
/// in a controlled testing environment. It overrides key networking methods to capture request parameters
/// and provide predefined responses, making it useful for unit testing and debugging.
public class SessionMock: Session, @unchecked Sendable {
    // MARK: - Public Properties
    
    /// A list of captured request parameters from executed requests.
    public private(set) var parameters: [Parameters] = []
    
    /// The HTTP headers applied to the request.
    public private(set) var httpHeaders: HTTPHeaders?
    
    /// The most recent `DataRequest` created by this session.
    public private(set) var request: DataRequest?

    // MARK: - Overriden Methods

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
    public override func request(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoder: ParameterEncoder = .url,
        headers: HTTPHeaders? = nil,
        middleware: RequestMiddleware? = nil,
        cachePolicy: URLCachePolicy? = nil
    ) -> DataRequest {
        
        let requestBuilder = URLRequestBuilder(
            url: url,
            method: method,
            parameters: parameters,
            encoder: encoder,
            headers: headers
        )
        
        let dataRequest = super.request(requestBuilder, middleware: middleware)
        
        if let parameters = parameters {
            self.parameters.append(parameters)
        }
        
        httpHeaders = headers
        
        return request(requestBuilder, middleware: middleware)
    }
}
