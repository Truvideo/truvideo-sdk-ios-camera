//
// Created by TruVideo on 18/06/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import Foundation
import TruvideoSdkFoundation

/// A mock implementation of the `HTTPClient` protocol for testing purposes.
public final class HTTPClientMock: HTTPClient {
    // MARK: - Public Properties
    
    /// The body of the response returned by the mock.
    public let body: String
    
    /// An optional error that can be set to simulate error scenarios.
    public var error: Error?
    
    /// The status code for the response.
    public let statusCode: Int
    
    /// The base URL used for the requests.
    public let url = URL(string: "https://any-url.com/")!
    
    /// The number of times the `authenticated` method has been called.
    public private(set) var authenticatedCallCount = 0
    
    /// A list of parameters passed in the body of the POST request.
    public private(set) var bodyParameters: [Any] = []
   
    /// The number of times the `get` method has been called.
    public private(set) var getCallCount = 0
    
    /// The number of times the `post` method has been called.
    public private(set) var postCallCount = 0
    
    /// The path of the URL used in the request.
    public private(set) var path: String = ""
    
    /// A dictionary of query parameters passed in the GET request.
    public private(set) var queryParameters: [String: String] = [:]
    
    // MARK: Initializer
    
    /// Creates a new instance of `HTTPClientMock` with the specified body.
    ///
    /// - Parameters:
    ///    - statusCode: The status code of the response.
    ///    - body: The body of the response returned by the mock.
    public init(statusCode: Int = 200, body: String = "") {
        self.statusCode = statusCode
        self.body = body
    }
    
    // MARK: HTTPClient
    
    /// Fetch and applies the authorization header from the `TokenProvider`.
    ///
    /// - Returns: A new copy of the `HTTPClient` with the authorization header.
    /// - Throws: An error if the token retrival fails.
    public func authenticated() async throws -> Self {
        authenticatedCallCount += 1
        
        return self
    }
    
    /// Makes a get request to the given `path`.
    ///
    /// - Parameters:
    ///   - path: The path of the resource.
    ///   - parameters: The query parameters to send in the request.
    ///   - headers: The headers value to be added to the request.
    /// - Returns: The serialized `Value`.
    /// - Throws: An `Error` if something fails.
    public func get(_ path: String, parameters: [String: String], headers: [String: String]) async throws -> Request {
        self.path = path
        self.queryParameters = parameters
        
        getCallCount += 1
        
        if let error {
            throw error
        }
        
        return .init(url: url.appendingPathComponent(path), requestInterceptor: nil) { [self] in
            if let error {
                throw error
            }
            
            return URLResponse(url: url.appendingPathExtension(path), statusCode: statusCode, data: Data())
        }
    }
    
    /// Makes a post request to the given `path`.
    ///
    /// - Parameters:
    ///   - path: The path of the resource.
    ///   - parameters: The parameters to send in the request.
    ///   - encoder: The encoder to be used to encode the `parameters` value into the `Request`.
    ///   - headers: The headers value to be added to the request.
    /// - Returns: The serialized `Value`.
    /// - Throws: An `Error` if something fails.
    public func post<Parameters: Encodable>(
        _ path: String,
        parameters: Parameters,
        encoder: any ParameterEncoder,
        headers: [String: String]
    ) async throws -> Request {
        self.path = path
        self.bodyParameters = [parameters]
        
        postCallCount += 1
        
        return .init(url: url.appendingPathComponent(path), requestInterceptor: nil) { [self] in
            if let error {
                throw error
            }
            
            return URLResponse(
                url: url.appendingPathExtension(path),
                statusCode: statusCode, data: body.data(using: .utf8)
            ) 
        }
    }
}
