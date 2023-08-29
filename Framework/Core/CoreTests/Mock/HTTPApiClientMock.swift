//
//  HTTPApiClientMock.swift
//  
//  Created by TruVideo on 8/08/23.
//  Copyright © TruVideo. All rights reserved.
//

import XCTest

@testable import Core

class HTTPApiClientMock: HTTPApiClient {
    var error: Error?
    var parameters: Parameters = [:]
    var request: DataRequest?

    // MARK: Overriden methods

    override func request(
        _ path: String,
        method: HTTPMethod,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding? = nil,
        headers: HTTPHeaders = [:],
        interceptor: RequestInterceptor? = nil
    ) throws -> DataRequest {
        if let error = error {
            throw error
        }

        let dataRequest = try super.request(
            path,
            method: method,
            parameters: parameters,
            headers: headers,
            interceptor: interceptor
        )

        if let parameters = parameters {
            self.parameters = parameters
        }

        request = dataRequest
        return dataRequest
    }

    override func request<E: Encodable>(
        _ path: String,
        method: HTTPMethod,
        parameters: E? = nil,
        encoder: ParameterEncoder? = nil,
        headers: HTTPHeaders = [:],
        interceptor: RequestInterceptor? = nil
    ) throws -> DataRequest {

        if let error = error {
            throw error
        }

        let dataRequest = try super.request(
            path,
            method: method,
            parameters: parameters,
            encoder: encoder,
            headers: headers,
            interceptor: interceptor
        )

        if let parameters = parameters as? Parameters {
            self.parameters = parameters
        }

        request = dataRequest
        return dataRequest
    }
}
