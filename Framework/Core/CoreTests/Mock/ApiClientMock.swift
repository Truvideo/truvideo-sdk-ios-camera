//
//  ApiClientMock.swift
//
//  Created by TruVideo on 8/08/23.
//  Copyright © TruVideo. All rights reserved.
//

/*import Foundation

@testable import Core

final class ApiClientMock: ApiClient {
    var encodableParameters: [Any] = []
    var encoding: ParameterEncoding = .json
    var path = ""
    var parameters: [String: Any] = [:]
    var requestHeaders: [String: String] = [:]

    // MARK: Overriden methods

    /// Makes a get request to the given `path` and returns the
    /// resulting `Value`.
    ///
    /// - Parameters:
    ///   - path: The path of the resource.
    ///   - encoding: A type used to define how a set of parameters are applied to a `URLRequest`.
    ///   - parameters: The parameters to send in the request.
    ///   - headers: The headers value to be added to the `URLRequest`. `nil` by default.
    ///   - responseOf: The decodable object type.
    ///   - decoder: The `JSONDecoder` to use when decoding the response.
    /// - Returns: The serialized `Value`.
    /// - Throws: An `ApiError` if something fails.
    override func get<Value: Decodable>(
        _  path: String,
        encoding: ParameterEncoding = .url,
        parameters: [String: Any] = [:],
        headers: [String: String] = [:],
        responseOf: Value.Type,
        decoder: JSONDecoder? = nil
    ) async throws -> Value {

        self.path = path
        self.parameters = parameters
        self.requestHeaders = headers

        return try await super.get(
            path,
            parameters: parameters,
            headers: headers,
            responseOf: responseOf,
            decoder: decoder
        )
    }

    /// Makes a `PATCH` request to the given `path` and returns the
    /// resulting `Value`.
    ///
    /// - Parameters:
    ///   - path: The path of the resource.
    ///   - encoding: A type used to define how a set of parameters are applied to a `URLRequest`.
    ///   - parameters: The parameters to send in the request.
    ///   - headers: The headers value to be added to the `URLRequest`. `nil` by default.
    ///   - responseOf: The decodable object type.
    ///   - decoder: The `JSONDecoder` to use when decoding the response.
    /// - Returns: The serialized `Value`.
    /// - Throws: An `ApiError` if something fails.
    override func patch<Value>(
        _ path: String,
        encoding: ParameterEncoding = .json,
        parameters: [String : Any],
        headers: [String : String] = [:],
        responseOf: Value.Type,
        decoder: JSONDecoder? = nil
    ) async throws -> Value where Value : Decodable {

        self.path = path
        self.parameters = parameters
        self.requestHeaders = headers

        return try await super.patch(path, parameters: parameters, headers: headers, responseOf: responseOf)
    }

    /// Makes a `PATCH` request to the given `path` and returns the
    /// resulting `Value`.
    ///
    /// - Parameters:
    ///   - path: The path for the base url.
    ///   - parameters: The parameters  to be encoded into the `URLRequest`.
    ///   - headers: The headers value to be added to the `URLRequest`. `nil` by default.
    ///   - responseOf: The decodable object type.
    ///   - decoder: The `JSONDecoder` to use when decoding the response.
    /// - Returns: The serialized `Value`.
    /// - Throws: An `ApiError` if something fails.
    override func patch<Parameters: Encodable, Value: Decodable>(
        _ path: String,
        parameters: Parameters,
        headers: [String : String] = [:],
        responseOf: Value.Type,
        decoder: JSONDecoder? = nil
    ) async throws -> Value where Parameters : Encodable, Value : Decodable {

        self.path = path
        self.encodableParameters = [parameters]
        self.requestHeaders = headers

        return try await super.patch(
            path,
            parameters: parameters,
            headers: headers,
            responseOf: responseOf,
            decoder: decoder
        )
    }
    
    /// Makes a `PATCH` request to the given `path` .
    ///
    /// - Parameters:
    ///   - path: The path of the resource.
    ///   - encoding: A type used to define how a set of parameters are applied to a `URLRequest`.
    ///   - parameters: The parameters to send in the request.
    ///   - headers: The headers value to be added to the `URLRequest`. `nil` by default.
    /// - Throws: An `ApiError` if something fails.
    override func patch(
        _  path: String,
        encoding: ParameterEncoding = .json,
        parameters: [String: Any],
        headers: [String: String] = [:]
    ) async throws {
        self.path = path
        self.encodableParameters = [parameters]
        self.requestHeaders = headers
        
        return try await super.patch(
            path,
            parameters: parameters,
            headers: headers
        )
    }

    /// Makes a `PUT` request to the given `path`.
    ///
    /// - Parameters:
    ///   - path: The path for the base url.
    ///   - parameters: The parameters  to be encoded into the `URLRequest`.
    ///   - headers: The headers value to be added to the `URLRequest`. `nil` by default.
    ///   - decoder: The `JSONDecoder` to use when decoding the response.
    /// - Returns: The serialized `Value`.
    /// - Throws: An `ApiError` if something fails.
    override func put<Parameters: Encodable>(
        _ path: String,
        parameters: Parameters,
        headers: [String : String] = [:]
    ) async throws where Parameters: Encodable {

        self.path = path
        self.encodableParameters = [parameters]
        self.requestHeaders = headers

        return try await super.put(
            path,
            parameters: parameters,
            headers: headers
        )
    }
    
    /// Makes a `PUT` request to the given `path` and returns the
    /// resulting `Value`.
    ///
    /// - Parameters:
    ///   - path: The path of the resource.
    ///   - encoding: A type used to define how a set of parameters are applied to a `URLRequest`.
    ///   - parameters: The parameters to send in the request.
    ///   - headers: The headers value to be added to the `URLRequest`. `nil` by default.
    ///   - responseOf: The decodable object type.
    ///   - decoder: The `JSONDecoder` to use when decoding the response.
    /// - Returns: The serialized `Value`.
    /// - Throws: An `ApiError` if something fails.
    override func put<Value>(
        _  path: String,
        encoding: ParameterEncoding = .json,
        parameters: [String: Any],
        headers: [String: String] = [:],
        responseOf: Value.Type,
        decoder: JSONDecoder? = nil
    ) async throws -> Value where Value: Decodable {
        
        self.path = path
        self.encodableParameters = [parameters]
        self.requestHeaders = headers
        
        return try await super.put(
            path,
            parameters: parameters,
            headers: headers,
            responseOf: responseOf
        )
    }
    
    /// Makes a post request to the given `path` .
    ///
    /// - Parameters:
    ///   - path: The path of the resource.
    ///   - encoding: A type used to define how a set of parameters are applied to a `URLRequest`.
    ///   - parameters: The parameters to send in the request.
    ///   - headers: The headers value to be added to the `URLRequest`. `nil` by default.
    /// - Throws: An `ApiError` if something fails.
    override func post(
        _  path: String,
        encoding: ParameterEncoding = .json,
        parameters: [String: Any],
        headers: [String: String] = [:]
    ) async throws {
        self.path = path
        self.parameters = parameters
        self.requestHeaders = headers

        return try await super.post(
            path,
            parameters: parameters,
            headers: headers
        )
    }

    /// Makes a `POST` request to the given `path` and returns the
    /// resulting `Value`.
    ///
    /// - Parameters:
    ///   - path: The path of the resource.
    ///   - parameters: The parameters to send in the request.
    ///   - headers: The headers value to be added to the `URLRequest`. `nil` by default.
    /// - Returns: The serialized `Value`.
    /// - Throws: An `ApiError` if something fails.
    override func post<Parameters: Encodable>(
        _ path: String,
        parameters: Parameters,
        headers: [String: String] = [:]
    ) async throws {
        self.path = path
        self.encodableParameters.append(parameters)
        self.requestHeaders = headers
        
        return try await super.post(
            path,
            parameters: parameters,
            headers: headers
        )
    }
    
    /// Makes a `POST` request to the given `path` and returns the
    /// resulting `Value`.
    ///
    /// - Parameters:
    ///   - path: The path for the base url.
    ///   - parameters: The parameters  to be encoded into the `URLRequest`.
    ///   - headers: The headers value to be added to the `URLRequest`. `nil` by default.
    ///   - responseOf: The decodable object type.
    ///   - decoder: The `JSONDecoder` to use when decoding the response.
    /// - Returns: A new instance of ``AnyPublisher<Response<D>, Never>``.
    override func post<Parameters: Encodable, Value: Decodable>(
        _ path: String,
        parameters: Parameters,
        headers: [String: String] = [:],
        responseOf: Value.Type,
        decoder: JSONDecoder? = nil
    ) async throws -> Value {
        self.path = path
        self.encodableParameters.append(parameters)
        self.requestHeaders = headers
        
        return try await super.post(
            path,
            parameters: parameters,
            headers: headers,
            responseOf: responseOf
        )
    }

    /// Makes a `POST` request to the given `path` and returns the
    /// resulting `Value`.
    ///
    /// - Parameters:
    ///   - path: The path of the resource.
    ///   - encoding: A type used to define how a set of parameters are applied to a `URLRequest`.
    ///   - parameters: The parameters to send in the request.
    ///   - headers: The headers value to be added to the `URLRequest`. `nil` by default.
    ///   - responseOf: The decodable object type.
    ///   - decoder: The `JSONDecoder` to use when decoding the response.
    /// - Returns: The serialized `Value`.
    /// - Throws: An `ApiError` if something fails.
    override func post<Value>(
        _ path: String,
        encoding: ParameterEncoding = .json,
        parameters: [String : Any],
        headers: [String : String] = [:],
        responseOf: Value.Type,
        decoder: JSONDecoder? = nil
    ) async throws -> Value where Value : Decodable {
        self.path = path
        self.encoding = encoding
        self.parameters = parameters
        self.requestHeaders = headers
        
        return try await super.post(
            path,
            parameters: parameters,
            headers: headers,
            responseOf: responseOf
        )
    }

    /// Makes a `DELETE` request to the given `path`.
    ///
    /// - Parameters:
    ///   - path: The path for the base url.
    ///   - encoding: A type used to define how a set of parameters are applied to a `URLRequest`.
    ///   - parameters: The parameters  to be encoded into the `URLRequest`.
    ///   - headers: The headers value to be added to the `URLRequest`. `nil` by default.
    /// - Returns: The serialized `Value`.
    /// - Throws: An `ApiError` if something fails.
    override func delete(
        _ path: String,
        encoding: ParameterEncoding = .json,
        parameters: [String : Any] = [:],
        headers: [String : String] = [:]
    ) async throws {
        self.path = path
        self.encodableParameters = [parameters]
        self.requestHeaders = headers
        
        return try await super.delete(
            path,
            parameters: parameters,
            headers: headers
        )
    }

    /// Makes a `DELETE` request to the given `path`.
    ///
    /// - Parameters:
    ///   - path: The path for the base url.
    ///   - encoding: A type used to define how a set of parameters are applied to a `URLRequest`.
    ///   - parameters: The parameters to send in the request.
    ///   - headers: The headers value to be added to the `URLRequest`. `nil` by default.
    ///   - responseOf: The decodable object type.
    ///   - decoder: The `JSONDecoder` to use when decoding the response.
    /// - Returns: The serialized `Value`.
    /// - Throws: An `ApiError` if something fails.
    override func delete<Value: Decodable>(
        _  path: String,
        encoding: ParameterEncoding = .json,
        parameters: [String: Any] = [:],
        headers: [String: String] = [:],
        responseOf: Value.Type,
        decoder: JSONDecoder? = nil
    ) async throws -> Value {
        self.path = path
        self.encodableParameters = [parameters]
        self.requestHeaders = headers

        return try await super.delete(
            path,
            parameters: parameters,
            headers: headers,
            responseOf: responseOf
        )
    }
}
*/
