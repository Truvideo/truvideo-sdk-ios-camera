//
//  Request.swift
//
//  Created by TruVideo on 8/08/23.
//  Copyright © TruVideo. All rights reserved.
//

@_implementationOnly import Alamofire
import Foundation

/// A convenience `RedirectHandler` making it easy to follow, not follow, or modify a redirect.
public typealias Redirector = (URLSessionTask, URLRequest, HTTPURLResponse) -> URLRequest?

/// `Request` is the common superclass of all `TruVideoCore` request.
///
/// ## Discussion
///
/// Is a cancelable object that refers to the lifetime of processing a given request,
/// Identified by a unique id assigned by the owning session
open class Request {
    public typealias ValidationCallback = (URLRequest?, HTTPURLResponse, Data?) -> Result<Void, Error>

    /// The underlying `AFRequest`.
    private let afRequest: Alamofire.Request

    /// `UUID` providing a unique identifier for the `Request`.
    public let id: UUID

    /// The `Request`'s interceptor.
    public let interceptor: RequestInterceptor?

    /// The last `URLSessionTaskMetrics` collected for this `Request`.
    public var metrics: URLSessionTaskMetrics? {
        afRequest.metrics
    }

    /// `RequestMonitor` used for events.
    public let monitor: RequestMonitor?

    /// Current `URLRequest` created on behalf of the `Request`.
    public var request: URLRequest? {
        afRequest.request
    }

    /// `HTTPURLResponse` received from the server, if any. If the `Request` was retried, this is the response of the
    /// last `URLSessionTask`.
    public var response: HTTPURLResponse? {
        afRequest.response
    }

    /// Number of times the `Request` has been retried.
    public var retryCount: Int {
        afRequest.retryCount
    }

    /// `State` of the `Request`.
    public var state: State {
        switch afRequest.state {
        case .cancelled: return .cancelled
        case .finished: return .finished
        case .initialized: return .initialized
        case .resumed: return .resumed
        case .suspended: return .suspended
        }
    }

    /// Current `URLSessionTask` created on behalf of the `Request`.
    public var task: URLSessionTask? {
        afRequest.task
    }

    /// All `URLSessionTask` created on behalf of the `Request`.
    public var tasks: [URLSessionTask] {
        afRequest.tasks
    }

    /// Constants for determining the current state of a request.
    public enum State {
        /// `State` set when `cancel()` is called
        case cancelled

        /// `State` set when all response serialization completion closures have been cleared on the `Request` and
        /// enqueued on their respective queues.
        case finished

        /// Initial state of the `Request`.
        case initialized

        /// `State` set when the `Request` is resumed.
        case resumed

        /// `State` set when the `Request` is suspended.
        case suspended
    }

    // MARK: Initializers

    /// Creates a  new instance of the `Request`.
    ///
    /// - Parameters:
    ///   - id: Unique identifier for the `Request`.
    ///   - request: The underlying `AFRequest`.
    ///   - interceptor: The `Request`'s interceptor.
    ///   - monitor: The `RequestMonitor` used for events.
    init(id: UUID = UUID(), request: Alamofire.Request, interceptor: RequestInterceptor?, monitor: RequestMonitor?) {
        self.id = id
        self.afRequest = request
        self.interceptor = interceptor
        self.monitor = monitor
    }

    // MARK: Public methods

    /// Cancels the request.
    @discardableResult
    public func cancel() -> Self {
        afRequest.cancel()
        return self
    }

    /// cURL representation of the instance.
    ///
    /// - Returns: The cURL equivalent of the instance.
    public func cURLDescription() -> String {
        afRequest.cURLDescription()
    }

    /// Sets the redirect handler for the instance which will be used if a redirect response is encountered.
    ///
    /// - Parameter redirector: The `Redirector` to to be used.
    /// - Returns: The current request instance.
    @discardableResult
    public func redirect(using redirector: @escaping Redirector) -> Self {
        afRequest.redirect(using: .modify(using: redirector))
        return self
    }

    /// Resumes the request, if it is suspended.
    @discardableResult
    public func resume() -> Self {
        afRequest.resume()
        return self
    }

    /// Temporarily suspends a request.
    @discardableResult
    public func suspend() -> Self {
        afRequest.resume()
        return self
    }
}

/// A URL session task that returns downloaded data directly to the app in memory.
///
/// ## Discussion
///
/// A DataRequest is a concrete subclass of ``Request``. The methods in the
/// DataRequest class are documented in ``Request``.
///
/// A data task returns data directly to the app (in memory) as one or more Data objects.
public class DataRequest: Request {
    let dataRequest: Alamofire.DataRequest

    // MARK: Initializers

    /// Creates a `DataRequest` using the provided parameters.
    ///
    /// - Parameters:
    ///   - id: `UUID` used for the `Hashable` and `Equatable` implementations. `UUID()` by default.
    ///   - dataRequest: The underliying AF request.
    ///   - interceptor: The `Request`'s interceptor.
    ///   - monitor: The `RequestMonitor` used for events.
    init(
        id: UUID = UUID(),
        dataRequest: Alamofire.DataRequest,
        interceptor: RequestInterceptor?,
        monitor: RequestMonitor?
    ) {

        self.dataRequest = dataRequest

        super.init(id: id, request: dataRequest, interceptor: interceptor, monitor: monitor)
    }

    // MARK: Public methods

    /// Decodes a top-level value of the given type from the remote  response representation.
    ///
    ///  - Parameters:
    ///     - type: The object type to use when decoding the response.
    ///     - serializer: The callback to invoke when serializing the response.
    ///  - Returns: An instance of the ``AsyncDataTask`` containing the serialized data response.
    @discardableResult
    public func serializing<Value: Decodable>(
        _ type: Value.Type,
        serializer: @escaping ((URLRequest?, HTTPURLResponse?, Data?, Error?) throws -> Value)
    ) -> AsyncDataTask<Value> {

        AsyncDataTask(dataTask: dataRequest.serializingResponse(using: ResponseSerializer(serializer)))
    }

    /// Decodes a top-level value of the given type from the remote JSON response representation.
    ///
    ///  - Parameters:
    ///     - type: The object type to use when decoding the response.
    ///     - decoder: The `JSONDecoder` to use when decoding the response.
    ///     - emptyResponseCodes: The HTTP response codes for which empty responses are allowed. nil by default.
    ///  - Returns: An instance of the ``AsyncDataTask`` containing the serialized response.
    @discardableResult
    public func serializing<Value: Decodable>(
        _ type: Value.Type,
        decoder: JSONDecoder = JSONDecoder(),
        emptyResponseCodes: Set<Int>? = nil
    ) -> AsyncDataTask<Value> {
        
        AsyncDataTask(
            dataTask: dataRequest.serializingDecodable(
                Value.self,
                decoder: decoder,
                emptyResponseCodes: emptyResponseCodes ?? DecodableResponseSerializer<Value>.defaultEmptyResponseCodes
            )
        )
    }

    /// Creates a `AsyncDataTask` to `await` a `Data` value.
    ///
    ///  - Parameter emptyResponseCodes: The HTTP response codes for which empty responses are allowed. nil by default.
    ///  - Returns: An instance of the ``AsyncDataTask`` containing the serialized data response.
    @discardableResult
    public func serializingData(emptyResponseCodes: Set<Int>? = nil) -> AsyncDataTask<Data> {
        AsyncDataTask(
            dataTask: dataRequest.serializingData(
                emptyResponseCodes: emptyResponseCodes ?? DataResponseSerializer.defaultEmptyResponseCodes
            )
        )
    }

    /// Validates that the response has a status code in the default acceptable range of 200...299, and that the content
    /// type matches any specified in the Accept HTTP header field.
    ///
    ///  - Returns: The current request instance.
    @discardableResult
    public func validate() -> Self {
        dataRequest.validate()
        return self
    }

    /// Validates the request using the specified closure.
    ///
    ///  - Parameter callback: A closure used to validate the response.
    ///  - Returns: The current request instance.
    @discardableResult
    public func validate(_ callback: @escaping ValidationCallback) -> Self {
        dataRequest.validate(callback)
        return self
    }

    /// Validates that the response has a status code in the specified sequence.
    ///
    ///  - Parameter acceptableStatusCodes: A list of acceptable status codes for the response.
    ///  - Returns:  The current request instance.
    @discardableResult
    public func validate<S: Sequence>(acceptableStatusCodes: S) -> Self where S.Iterator.Element == Int {
        dataRequest.validate(statusCode: acceptableStatusCodes)
        return self
    }
}
