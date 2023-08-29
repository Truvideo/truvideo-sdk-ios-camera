//
//  HTTPApiClient+Extension.swift
//
//  Created by TruVideo on 8/08/23.
//  Copyright © TruVideo. All rights reserved.
//

import Foundation

private extension AsyncDataTask {
    /// Returns the success value as a throwing expression.
    ///
    /// - Returns: The success value, if the instance represents a success.
    /// - Throws: The failure value, if the instance represents a failure.
    @discardableResult
    func get() async throws -> Value {
        switch await response.result {
        case .failure(let error):
            throw CoreError(kind: .apiRequestFailed, underlyingError: error.underlyingError ?? error)

        case .success(let value):
            return value
        }
    }
}

private extension JSONDecoder {
    /// Returns an instance of the `JSONDecoder` configured with the
    /// `convertFromSnakeCase` key decoding strategy.
    static var snakeCase: JSONDecoder {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return jsonDecoder
    }
}

extension HTTPApiClient {
    /// Handy method to make an  http `Request` when the response is empty.
    ///
    /// - Parameters:
    ///   - path: The path of the resource.
    ///   - encoding: A type used to define how a set of parameters are applied to a `URLRequest`.
    ///   - method: The ``HTTPMethod`` for the request.
    ///   - parameters: The parameters to send in the request.
    ///   - headers: The headers value to be added to the `URLRequest`. `nil` by default.
    /// - Throws: An `ApiError` if something fails.
    func request(
        _  path: String,
        encoding: ParameterEncoding,
        method: HTTPMethod,
        parameters: [String: Any],
        headers: HTTPHeaders
    ) async throws {

        try await createRequest(path, encoding: encoding, method: method, parameters: parameters, headers: headers)
            .serializingData()
            .get()
    }

    /// Handy method to make an  http `Request` with generic parameters and a expected response.
    ///
    /// - Parameters:
    ///   - path: The path of the resource.
    ///   - method: The ``HTTPMethod`` for the request.
    ///   - parameters: The parameters to send in the request.
    ///   - headers: The headers value to be added to the `URLRequest`. `nil` by default.
    ///   - type: The object type to use when decoding the response.
    ///   - decoder: The `JSONDecoder` to use when decoding the response.
    /// - Returns: The serialized `Value`.
    /// - Throws: An `ApiError` if something fails.
    func request<Parameters: Encodable, Value: Decodable>(
        _  path: String,
        method: HTTPMethod,
        parameters: Parameters,
        headers: HTTPHeaders,
        of type: Value.Type,
        decoder: JSONDecoder?
    ) async throws -> Value {

        try await createRequest(path, method: method, parameters: parameters, headers: headers)
            .serializing(Value.self, decoder: .snakeCase)
            .get()
    }

    /// Handy method to make an  http `Request` with generic parameters and a empty response.
    ///
    /// - Parameters:
    ///   - path: The path of the resource.
    ///   - method: The ``HTTPMethod`` for the request.
    ///   - parameters: The parameters to send in the request.
    ///   - headers: The headers value to be added to the `URLRequest`. `nil` by default.
    /// - Throws: An `ApiError` if something fails.
    func request<Parameters: Encodable>(
        _  path: String,
        method: HTTPMethod,
        parameters: Parameters,
        headers: HTTPHeaders
    ) async throws {

        try await createRequest(path, method: method, parameters: parameters, headers: headers)
            .serializingData()
            .get()
    }

    /// Decodes a top-level value of the given type from the remote JSON response representation.
    ///
    /// - Parameters:
    ///   - path: The path of the resource.
    ///   - encoding: A type used to define how a set of parameters are applied to a `URLRequest`.
    ///   - method: The ``HTTPMethod`` for the request.
    ///   - parameters: The parameters to send in the request.
    ///   - headers: The headers value to be added to the `URLRequest`. `nil` by default.
    ///   - type: The object type to use when decoding the response.
    ///   - decoder: The `JSONDecoder` to use when decoding the response.
    /// - Returns: The serialized `Value`.
    /// - Throws: An `ApiError` if something fails.
    func request<Value: Decodable>(
        _  path: String,
        encoding: ParameterEncoding,
        method: HTTPMethod,
        parameters: [String: Any],
        headers: HTTPHeaders,
        of type: Value.Type,
        decoder: JSONDecoder?
    ) async throws -> Value {

        try await createRequest(path, encoding: encoding, method: method, parameters: parameters, headers: headers)
            .serializing(Value.self, decoder: decoder ?? .snakeCase)
            .get()
    }

    // MARK: Private methods

    private func createRequest(
        _ path: String,
        encoding: ParameterEncoding,
        method: HTTPMethod,
        parameters: [String: Any],
        headers: HTTPHeaders
    ) throws -> DataRequest {

        do {
            return try request(path, method: method, parameters: parameters, encoding: encoding, headers: headers)
                .validate(RequestValidator.validate)
                .validate()
        } catch {
            throw CoreError(kind: .apiRequestFailed, underlyingError: error)
        }
    }

    private func createRequest<Parameters: Encodable>(
        _ path: String,
        method: HTTPMethod,
        parameters: Parameters,
        headers: HTTPHeaders
    ) throws -> DataRequest {

        do {
            return try request(path, method: method, parameters: parameters, headers: headers)
                .validate(RequestValidator.validate)
                .validate()
        } catch {
            throw CoreError(kind: .apiRequestFailed, underlyingError: error)
        }
    }
}
