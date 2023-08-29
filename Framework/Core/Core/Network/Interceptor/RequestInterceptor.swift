//
//  RequestInterceptor.swift
//
//  Created by TruVideo on 8/08/23.
//  Copyright © TruVideo. All rights reserved.
//

import Alamofire
import Foundation

/// Outcome of determination whether retry is necessary.
public enum RetryPolicy {
    /// Retry should be attempted immediately.
    case retry

    /// Do not retry.
    case doNotRetry
}

/// A type that determines whether a request should be intercepted.
public protocol RequestInterceptor {
    /// Inspects and adapts the specified `URLRequest` in some
    /// manner and returns the Result.
    ///
    /// - Parameters:
    ///   - request: The `URLRequest` tha has been intercepted.
    ///   - client: The `HTTPApiClient` that will execute the `URLRequest`.
    /// - Throws: An error if something went wrong.
    func intercept(_ request: URLRequest, client: HTTPApiClient) async throws -> URLRequest
}

/// A type that determines whether a request should be retried after being executed.
public protocol RequestRetrier {
    /// Determines whether the `Request` should be retried by calling the `completion` closure.
    ///
    /// - Parameters:
    ///   - request: `Request` that failed due to the provided `Error`.
    ///   - client: `HTTPApiClient` that produced the `Request`.
    ///   - error: `Error` encountered while executing the `Request`.
    func retry(_ request: Request, for client: HTTPApiClient, dueTo error: Error) async -> RetryPolicy
}

public struct Interceptor: RequestInterceptor, RequestRetrier {
    /// All `RequestInterceptor`s associated with the instance.
    public let interceptors: [RequestInterceptor]
    
    /// All `RequestRetrier`s associated with the instance.
    public let retriers: [RequestRetrier]

    // MARK: Initializers

    /// Creates a new `Interceptor` instance from a list of interceptors.
    ///
    /// - Parameters:
    ///    - interceptors: The list of child interceptors.
    ///    - retriers: All `RequestRetrier`s associated with the instance.
    public init(interceptors: [RequestInterceptor], retriers: [RequestRetrier]) {
        self.interceptors = interceptors
        self.retriers = retriers
    }

    // MARK: RequestInterceptor

    /// Inspects and adapts the specified `URLRequest` in some
    /// manner and returns the Result.
    ///
    /// - Parameters:
    ///   - request: The `URLRequest` tha has been intercepted.
    ///   - client: The `HTTPApiClient` that will execute the `URLRequest`.
    /// - Throws: An error if something went wrong.
    public func intercept(_ request: URLRequest, client: HTTPApiClient) async throws -> URLRequest {
        try await intercept(request, interceptors: interceptors, client: client)
    }

    // MARK: RequestRetrier

    /// Determines whether the `Request` should be retried by calling the `completion` closure.
    ///
    /// - Parameters:
    ///   - request: `Request` that failed due to the provided `Error`.
    ///   - client: `HTTPApiClient` that produced the `Request`.
    ///   - error: `Error` encountered while executing the `Request`.
    public func retry(_ request: Request, for client: HTTPApiClient, dueTo error: Error) async -> RetryPolicy {
        await retry(request, retriers: retriers, for: client, dueTo: error)
    }

    // MARK: Private methods

    private func intercept(
        _ request: URLRequest,
        interceptors: [RequestInterceptor],
        client: HTTPApiClient
    ) async throws -> URLRequest {

        var interceptors = interceptors

        guard !interceptors.isEmpty else {
            return request
        }

        let interceptor = interceptors.removeFirst()
        let request = try await interceptor.intercept(request, client: client)

        return try await intercept(request, interceptors: interceptors, client: client)
    }

    private func retry(
        _ request: Request,
        retriers: [RequestRetrier],
        for client: HTTPApiClient,
        dueTo error: Error
    ) async -> RetryPolicy {
        
        var retriers = retriers

        guard !retriers.isEmpty else {
            return .doNotRetry
        }

        let retrier = retriers.removeFirst()
        let policy = await retrier.retry(request, for: client, dueTo: error)

        switch policy {
        case .doNotRetry:
            return await retry(request, retriers: retriers, for: client, dueTo: error)

        case .retry:
            return .retry
        }
    }
}

struct AFRequestInterceptor: Alamofire.RequestInterceptor {
    private let client: HTTPApiClient
    private let interceptor: Interceptor?

    // MARK: Initializers

    init(client: HTTPApiClient, interceptor: Interceptor?) {
        self.client = client
        self.interceptor = interceptor
    }

    // MARK: RequestInterceptor

    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {

        Task {
            guard let interceptor = interceptor else {
                completion(.success(urlRequest))
                return
            }

            do {
                let modifiedRequest = try await interceptor.intercept(urlRequest, client: client)
                completion(.success(modifiedRequest))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func retry(
        _ request: Alamofire.Request,
        for session: Alamofire.Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {

        Task {
            guard
                /// The underlying `TruVideoCore` interceptor.
                let interceptor = interceptor,

                /// The `Request` to intercept.
                let request = await client.getRequest(with: request.id) else {

                completion(.doNotRetry)
                return
            }

            let retryPolicy = await interceptor.retry(request, for: client, dueTo: error)

            switch retryPolicy {
            case .doNotRetry: completion(.doNotRetry)
            case .retry: completion(.retry)
            }
        }
    }
}
