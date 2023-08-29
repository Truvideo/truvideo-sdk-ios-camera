//
//  HTTPApiClient.swift
//
//  Created by TruVideo on 8/08/23.
//  Copyright © TruVideo. All rights reserved.
//

import Alamofire
import Combine
import Foundation
import Network

infix operator +
private func + (lhs: HTTPHeaders, rhs: [String: String]) -> HTTPHeaders {
    var httpHeaders = lhs
    rhs.map(HTTPHeader.init).forEach { header in
        httpHeaders.append(header)
    }

    return httpHeaders
}

/// Parameters definition.
public typealias Parameters = Alamofire.Parameters

private extension String {
    /// Returns the ``URL`` representation of the resource using the path component.
    ///
    /// - Returns: A new instance of the url, otherwise a ``NetworkError``.
    func asURL() throws -> URL {
        guard let url = URL(string: self) else {
            throw NetworkError(kind: .invalidURL(url: self))
        }

        return url
    }
}

/// A type used to define how a set of parameters are applied to a `URLRequest`.
public enum ParameterEncoder {
    /// A `ParameterEncoder` that encodes types as JSON body data.
    case json

    /// Creates a url-encoded query string to be set as or appended to any existing URL query string or set as the HTTP
    case url

    /// The underliying encoder used by `Alamofire`.
    fileprivate var afEncoder: Alamofire.ParameterEncoder {
        switch self {
        case .json: return JSONParameterEncoder.sortedKeys
        case .url: return URLEncodedFormParameterEncoder.default
        }
    }

    // MARK: Static methods

    /// Returns the default encoder for the given `HTTMethod`.
    ///
    /// - Parameter method: The `HTTPMethod` being used for the `Request`.
    /// - Returns: The appropriate `ParameterEncoder` for the given method.
    static func encoder(for method: HTTPMethod) -> Alamofire.ParameterEncoder {
        switch method {
        case .get, .delete: return URLEncodedFormParameterEncoder.default
        default: return JSONParameterEncoder.sortedKeys
        }
    }
}

/// A type used to define how a set of parameters are applied to a `URLRequest`.
public enum ParameterEncoding {
    /// Uses `JSONSerialization` to create a JSON representation of the parameters object, which is set as the body of the
    /// request.
    case json
    
    /// Creates a url-encoded query string to be set as or appended to any existing URL query string or set as the HTTP
    case url
    
    /// Create a url-encoded http body
    case body
    
    /// Returns a `URLEncoding` instance with a `.queryString` destination.
    case queryString

    /// The underliying encoding used by `Alamofire`.
    fileprivate var afEncoding: Alamofire.ParameterEncoding {
        switch self {
        case .body: return URLEncoding.httpBody
        case .json: return JSONEncoding.default
        case .queryString: return URLEncoding(destination: .queryString)
        case .url: return URLEncoding.default
        }
    }

    // MARK: Static methods

    /// Returns the default parameter encoding for the given `HTTMethod`.
    ///
    /// - Parameter method: The `HTTPMethod` being used for the `Request`.
    /// - Returns: The appropriate `ParameterEncoding` for the given method.
    static func encoding(for method: HTTPMethod) -> Alamofire.ParameterEncoding {
        switch method {
        case .get, .delete: return URLEncoding.default
        default: return JSONEncoding.default
        }
    }
}

/// Type representing HTTP methods. Raw `String` value is stored and compared case-sensitively.
///
/// See https://tools.ietf.org/html/rfc7231#section-4.3
public struct HTTPMethod: Equatable, Hashable, RawRepresentable {
    /// `DELETE` method.
    public static let delete = HTTPMethod(rawValue: "DELETE")

    /// `GET` method.
    public static let get = HTTPMethod(rawValue: "GET")

    /// `PATCH` method.
    public static let patch = HTTPMethod(rawValue: "PATCH")

    /// `POST` method.
    public static let post = HTTPMethod(rawValue: "POST")

    /// `PUT` method.
    public static let put = HTTPMethod(rawValue: "PUT")

    /// The corresponding value of the raw type.
    public let rawValue: String

    // MARK: Initializers

    /// Creates a new instance with the specified raw value.
    ///
    /// If there is no value of the type that corresponds with the specified raw
    /// value, this initializer returns `nil`.
    ///
    /// - Parameter rawValue: The raw value to use for the new instance.s
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

/// A configuration object that defines behavior and policies for a ``HTTPApiClient``.
///
/// ## Discussion
///
/// An HTTPApiClientConfiguration object defines the behavior and policies to use when sending
/// data using an ``HTTPApiClient`` object. When sending data, creating a configuration object is always
/// the first step you must take. You use this object to configure the timeout values, caching policies, connection requirements,
/// and other types of information.
public class HTTPApiClientConfiguration {
    /// A Boolean value that determines whether connections should be made over a cellular network.
    ///
    /// The default value is true.
    public var allowsCellularAccess = true

    /// A dictionary of additional headers to send with requests.
    public var httpAdditionalHeaders: HTTPHeaders = [:]

    /// An optional array of Class objects which subclass NSURLProtocol.
    public var protocolClasses: [AnyClass] = []

    /// A predefined constant that determines when to return a response from the cache.
    ///
    /// It sets the policy `reloadIgnoringLocalCacheData` as default value``NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData``.
    /// it means that The URL load should be loaded only from the originating source.
    public var requestCachePolicy: NSURLRequest.CachePolicy = .reloadIgnoringLocalCacheData

    /// The maximun number of retries that a request can make.
    ///
    /// The default value is 3.
    public var requestRetryCount = 3

    /// The timeout interval to use when waiting for additional data.
    ///
    /// The default value is 60 seconds.
    public var timeoutIntervalForRequest: TimeInterval = 60

    /// The maximum amount of time that a resource request should be allowed to take.
    ///
    /// The default value is 7 days.
    public var timeoutIntervalForResource: TimeInterval = 604800

    // MARK: Initializers

    public init() {}

    // MARK: Instance methods

    /// Returns the default implementation of the session configuration
    /// used accross the networking calls.
    ///
    /// - Returns: A default `URLSessionConfiguration` object.
    func createDefaultSessionConfiguration() -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = requestCachePolicy
        configuration.httpCookieStorage = HTTPCookieStorage.shared
        configuration.timeoutIntervalForRequest = timeoutIntervalForRequest
        configuration.timeoutIntervalForResource = timeoutIntervalForResource
        configuration.urlCache = nil
        configuration.urlCredentialStorage = nil
        configuration.protocolClasses = protocolClasses + (configuration.protocolClasses ?? [])
        #if os(iOS)
            configuration.multipathServiceType = .handover
        #endif
        return configuration
    }
}

/// It prevents data races by creating synchronized access to its isolated data `requests`.
actor RequestManager {
    /// It holds all the requests `Request` created by the `HTTPApiClient`.
    private var requests: [UUID: Request] = [:]

    /// Adds a new request associated to the given id.
    ///
    /// - Parameter id: The unique identifier of the request
    func prepareDataRequest(_ request: DataRequest) {
        requests[request.dataRequest.id] = request
    }

    /// Removes the request associated to the given id.
    ///
    /// - Parameter id: The unique identifier of the request
    func removeRequest(with id: UUID) {
        requests.removeValue(forKey: id)
    }

    /// Gets the request associated to the given id.
    ///
    /// - Parameter id: The unique identifier of the request
    /// - Returns: An optional `Request`
    func getRequest(with id: UUID) -> Request? {
        requests[id]
    }
}

/// An object that coordinates a group of related, network data transfer tasks.
///
/// The `HTTPApiClient` class and related classes provide an API for preparing data and uploading
/// to endpoints indicated by the path definition.
open class HTTPApiClient {
    private var headers: HTTPHeaders = .default

    /// It prevents data races by creating synchronized access to its isolated data `requests`.
    private let requestManager = RequestManager()

    /// An observer to use to monitor and react to network changes.
    private let pathMonitor = NWPathMonitor()

    /// The underliying `AlamoFire` session.
    private var session: Session!

    /// A copy of the configuration object for this `HTTPApiClient`.
    public let configuration: HTTPApiClientConfiguration

    /// `RequestInterceptor` used for all `Request`´s created by the instance.
    public let interceptor: RequestInterceptor?

    /// `CompositeRequestMonitor` used to compose `defaultEventMonitors` and any passed `EventMonitor`s.
    public let monitor: CompositeRequestMonitor

    /// The current connection status of the client.
    ///
    /// ## Discussion
    ///
    /// An observer that you use to monitor and react to network changes.
    public let status = CurrentValueSubject<NWPath.Status, Never>(.unsatisfied)

    /// The base url used for all the requests.
    public let url: String

    // MARK: Initializers

    /// Creates a new instance of the http client.
    ///
    /// - Parameters:
    ///   - url: The base url to use when creeating the requests.
    ///   - configuration: The configuration object that defines behavior and policies for the requests.
    ///   - interceptor: A interceptor  used for all `Request`´s created by the instance.
    ///   - monitors: The list of monitors used to compose the default monitors.
    public init(
        url: String,
        configuration: HTTPApiClientConfiguration? = nil,
        interceptor: RequestInterceptor? = nil,
        monitors: [RequestMonitor] = []
    ) {

        let configuration = configuration ?? HTTPApiClientConfiguration()

        self.configuration = configuration
        self.interceptor = interceptor
        self.monitor = CompositeRequestMonitor(monitors: monitors)
        self.url = url
        self.session = Session(
            configuration: configuration.createDefaultSessionConfiguration(),
            eventMonitors: [AFRequestMonitor(client: self, monitor: monitor)]
        )

        prepareSubscriptions()
    }

    // MARK: Instance methods

    /// Remove the request associated to the given id.
    ///
    /// - Parameter id: The unique identifier of the request
    func removeRequest(with id: UUID) {
        Task {
            await requestManager.removeRequest(with: id)
        }
    }

    /// Gets the request associated to the given id.
    ///
    /// - Parameter id: The unique identifier of the request
    /// - Returns: An optional `Request`
    func getRequest(with id: UUID) async -> Request? {
        await requestManager.getRequest(with: id)
    }

    // MARK: Public methods

    /// Case-insensitively removes an `HTTPHeader`, if it exists, from the instance.
    ///
    /// - Parameter key: The header name.
    open func removeHeader(forKey key: String) {
        headers.removeHeader(forKey: key)
    }

    /// Sets the new header into the session.
    ///
    /// - Parameter header: The ``HTTPHeader``  to add into the `Connection`.
    open func setHeader(_ header: HTTPHeader) {
        headers.append(header)
    }

    /// Creates a  new request from the parameters values.
    ///
    /// ## Discussion
    ///
    /// This is a more flexible method that allows to have a fine grained control over the
    /// parameters to be used for the request. There are scenarios where the ``Endpoint``
    /// doesn't fit the requirements i.e. Using an array of  ``Parameters`` as a
    /// parameters instead of the ``Parameters`` definition itself.
    ///
    /// - Parameters:
    ///   - path: The path for the base url.
    ///   - method: The ``HTTPMethod`` for the `URLRequest`.
    ///   - parameters: The parameters  to be encoded into the `URLRequest`.
    ///   - encoding: `ParameterEncoding` to be used to encode the `parameters` value into the `URLRequest`.
    ///   - headers: The ``HTTPHeaders`` value to be added to the `URLRequest`. `nil` by default.
    ///   - interceptor: `RequestInterceptor` value to be used by the returned `Request`.
    /// - Returns: A ``DataRequest`` produced by the request and its response handler.
    open func request(
        _ path: String,
        method: HTTPMethod,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding? = nil,
        headers: HTTPHeaders = [:],
        interceptor: RequestInterceptor? = nil
    ) throws -> DataRequest {

        let url = try url.asURL()
        let interceptor = self.interceptor(with: interceptor)
        let request = session.request(
            url.appendingPathComponent(path),
            method: .init(rawValue: method.rawValue),
            parameters: parameters,
            encoding: encoding?.afEncoding ?? ParameterEncoding.encoding(for: method),
            headers: Alamofire.HTTPHeaders((headers + configuration.httpAdditionalHeaders).dictionary),
            interceptor: AFRequestInterceptor(client: self, interceptor: interceptor)
        )
        let dataRequest = DataRequest(dataRequest: request, interceptor: interceptor, monitor: monitor)
        prepareDataRequest(dataRequest)
        return dataRequest
    }

    /// Creates a  new request from the  parameter values.
    ///
    /// ## Discussion
    ///
    /// This is a more flexible method that allows to have a fine grained control over the
    /// parameters to be used for the request. This method is similar to
    /// ``request(_, method:parameters:headers)`
    /// but this takes a ``Encodable`` value a parameter.
    ///
    /// - Parameters:
    ///   - path: The path for the base url.
    ///   - method: The ``HTTPMethod`` for the `URLRequest`.
    ///   - parameters: The parameters  to be encoded into the `URLRequest`.
    ///   - encoder: `ParameterEncoder` to be used to encode the `parameters` value into the `URLRequest`.
    ///   - headers: The ``HTTPHeaders`` value to be added to the `URLRequest`. `nil` by default.
    ///   - interceptor: `RequestInterceptor` value to be used by the returned `Request`.
    /// - Returns: A ``DataRequest`` produced by the request and its response handler.
    open func request<E: Encodable>(
        _ path: String,
        method: HTTPMethod,
        parameters: E? = nil,
        encoder: ParameterEncoder? = nil,
        headers: HTTPHeaders = [:],
        interceptor: RequestInterceptor? = nil
    ) throws -> DataRequest {

        let url = try url.asURL()
        let interceptor = self.interceptor(with: interceptor)
        let request = session.request(
            url.appendingPathComponent(path),
            method: .init(rawValue: method.rawValue),
            parameters: parameters,
            encoder: encoder?.afEncoder ?? ParameterEncoder.encoder(for: method),
            headers: Alamofire.HTTPHeaders((headers + configuration.httpAdditionalHeaders).dictionary),
            interceptor: AFRequestInterceptor(client: self, interceptor: interceptor)
        )

        let dataRequest = DataRequest(dataRequest: request, interceptor: interceptor, monitor: monitor)
        prepareDataRequest(dataRequest)
        return dataRequest
    }

    // MARK: Private methods

    private func prepareDataRequest(_ request: DataRequest) {
        Task {
            await requestManager.prepareDataRequest(request)
        }
    }

    private func interceptor(with requestInterceptor: RequestInterceptor?) -> Interceptor? {
        var interceptors: [RequestInterceptor] = []
        var retriers: [RequestRetrier] = []

        if let interceptor = requestInterceptor {
            retriers.append(contentsOf: (interceptor as? Interceptor)?.retriers ?? [])
            interceptors.append(interceptor)
        }

        if let interceptor = interceptor {
            retriers.append(contentsOf: (interceptor as? Interceptor)?.retriers ?? [])
            interceptors.append(interceptor)
        }

        return interceptors.isEmpty ? nil : Interceptor(interceptors: interceptors, retriers: retriers)
    }

    private func prepareSubscriptions() {
        pathMonitor.pathUpdateHandler = { [self] path in
            status.send(path.status)
        }

        pathMonitor.start(queue: .main)
    }
}
