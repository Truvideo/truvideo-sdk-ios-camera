//
//  RequestMonitor.swift
//
//  Created by TruVideo on 8/08/23.
//  Copyright © TruVideo. All rights reserved.
//

@_implementationOnly import Alamofire
import Foundation

/// Protocol outlining the lifetime events inside `Network`. It includes  various events from the lifetime of `Request` and its subclasses.
public protocol RequestMonitor {
    /// The dispatch queue associated to this monitor
    var queue: DispatchQueue { get }

    /// Event called when a `DataRequest` calls a `Validation`.
    func request(
        _ request: DataRequest,
        didValidateRequest urlRequest: URLRequest?,
        response: HTTPURLResponse,
        data: Data?,
        result: Result<Void, Error>
    )

    /// Event called when a `DataRequest` creates a `Response<Data?>` value without calling a `ResponseSerializer`.
    func request(_ request: DataRequest, didParseResponse response: Response<Data?>)

    /// Event called when a `DataRequest` calls a `ResponseSerializer` and creates a generic `Response<Value>`.
    func request<Value>(_ request: DataRequest, didParseResponse response: Response<Value>)

    /// Called when the initial `URLSessionTaskMetrics` has been collected.
    func request(_ request: Request, didCollectMetrics metrics: URLSessionTaskMetrics)

    /// Event called when a `Request`'s task completes, possibly with an error.
    func request(_ request: Request, didCompleteTask task: URLSessionTask, with error: NetworkError?)

    /// Event called when the attempt to create a `URLRequest` from a `Request` fails.
    func request(_ request: Request, didCreateSesionTask task: URLSessionTask)

    /// Called when the initial `URLRequest` has been created.
    func request(_ request: Request, didCreateURLRequest urlRequest: URLRequest)

    /// Event called when the attempt to create a `URLRequest` from a `Request` fails.
    func request(_ request: Request, didFailToCreateURLRequest error: NetworkError)

    /// Event called when a `RequestInterceptor` fails to intercept the `Request`'s initial `URLRequest`.
    func request(
        _ request: Request,
        didFailToInterceptURLRequest request: URLRequest,
        withError error: NetworkError
    )

    /// Event called when a `RequestInterceptor` intercept the `Request`'s initial `URLRequest`.
    func request(_ request: Request, didInterceptRequest urlRequest: URLRequest, to modifiedRequest: URLRequest)

    /// Called when cancellation is completed.
    func requestDidCancel(_ request: Request)

    /// Called when `Request` has been completed.
    func requestDidComplete(_ request: Request)

    /// Called when the request has been resumed.
    func requestDidResume(_ request: Request)

    /// Called when the request has been suspended.
    func requestDidSuspend(_ request: Request)

    /// Event called when a `Request` is about to be retried.
    func requestIsRetrying(_ request: Request)
}

extension RequestMonitor {

    // MARK: RequestMonitor

    /// Event called when a `DataRequest` calls a `Validation`.
    public func request(
        _ request: DataRequest,
        didValidateRequest urlRequest: URLRequest?,
        response: HTTPURLResponse,
        data: Data?,
        result: Result<Void, Error>
    ) {}

    /// Event called when a `DataRequest` creates a `Response<Data?>` value without calling a `ResponseSerializer`.
    public func request(_ request: DataRequest, didParseResponse response: Response<Data?>) {}

    /// Event called when a `DataRequest` calls a `ResponseSerializer` and creates a generic `Response<Value>`.
    public func request<Value>(_ request: DataRequest, didParseResponse response: Response<Value>) {}

    /// Called when the initial `URLSessionTaskMetrics` has been collected.
    public func request(_ request: Request, didCollectMetrics metrics: URLSessionTaskMetrics) {}

    /// Event called when a `Request`'s task completes, possibly with an error.
    public func request(_ request: Request, didCompleteTask task: URLSessionTask, with error: NetworkError?) {}

    /// Event called when the attempt to create a `URLRequest` from a `Request` fails.
    public func request(_ request: Request, didCreateSesionTask task: URLSessionTask) {}

    /// Called when the initial `URLRequest` has been created.
    public func request(_ request: Request, didCreateURLRequest urlRequest: URLRequest) {}

    /// Event called when the attempt to create a `URLRequest` from a `Request` fails.
    public func request(_ request: Request, didFailToCreateURLRequest error: NetworkError) {}

    /// Event called when a `RequestInterceptor` fails to intercept the `Request`'s initial `URLRequest`.
    public func request(
        _ request: Request,
        didFailToInterceptURLRequest urlRequest: URLRequest,
        withError error: NetworkError
    ) {}

    /// Event called when a `RequestInterceptor` intercept the `Request`'s initial `URLRequest`.
    public func request(
        _ request: Request,
        didInterceptRequest urlRequest: URLRequest,
        to modifiedRequest: URLRequest
    ) {}

    /// Called when cancellation is completed.
    public func requestDidCancel(_ request: Request) {}

    /// Called when `Request` has been completed.
    public func requestDidComplete(_ request: Request) {}

    /// Called when the request has been resumed.
    public func requestDidResume(_ request: Request) {
        print("")
    }

    /// Called when the request has been suspended.
    public func requestDidSuspend(_ request: Request) {}

    /// Event called when a `Request` is about to be retried.
    public func requestIsRetrying(_ request: Request) {}
}

public struct CompositeRequestMonitor: RequestMonitor {
    private let monitors: [RequestMonitor]

    /// The dispatch queue associated to this monitor
    public let queue = DispatchQueue(label: "com.TruVideoNetworking.compositeRequestMonitor", qos: .utility)

    // MARK: Initializers

    init(monitors: [RequestMonitor]) {
        self.monitors = monitors
    }

    // MARK: RequestMonitor

    /// Event called when a `DataRequest` calls a `Validation`.
    public func request(
        _ request: DataRequest,
        didValidateRequest urlRequest: URLRequest?,
        response: HTTPURLResponse,
        data: Data?,
        result: Result<Void, Error>
    ) {
        queue.async {
            for monitor in self.monitors {
                monitor.queue.async {
                    monitor.request(
                        request,
                        didValidateRequest: urlRequest,
                        response: response,
                        data: data,
                        result: result
                    )
                }
            }
        }
    }

    /// Event called when a `DataRequest` creates a `Response<Data?>` value without calling a `ResponseSerializer`.
    public func request(_ request: DataRequest, didParseResponse response: Response<Data?>) {
        queue.async {
            for monitor in self.monitors {
                monitor.queue.async { monitor.request(request, didParseResponse: response) }
            }
        }
    }

    /// Event called when a `DataRequest` calls a `ResponseSerializer` and creates a generic `Response<Value>`.
    public func request<Value>(_ request: DataRequest, didParseResponse response: Response<Value>) {
        queue.async {
            for monitor in self.monitors {
                monitor.queue.async { monitor.request(request, didParseResponse: response) }
            }
        }
    }

    /// Called when the initial `URLSessionTaskMetrics` has been collected.
    public func request(_ request: Request, didCollectMetrics metrics: URLSessionTaskMetrics) {
        queue.async {
            for monitor in self.monitors {
                monitor.queue.async { monitor.request(request, didCollectMetrics: metrics) }
            }
        }
    }

    /// Event called when a `Request`'s task completes, possibly with an error.
    public func request(_ request: Request, didCompleteTask task: URLSessionTask, with error: NetworkError?) {
        queue.async {
            for monitor in self.monitors {
                monitor.queue.async { monitor.request(request, didCompleteTask: task, with: error) }
            }
        }
    }

    /// Event called when the attempt to create a `URLRequest` from a `Request` fails.
    public func request(_ request: Request, didCreateSesionTask task: URLSessionTask) {
        queue.async {
            for monitor in self.monitors {
                monitor.queue.async { monitor.request(request, didCreateSesionTask: task) }
            }
        }
    }

    /// Called when the initial `URLRequest` has been created.
    public func request(_ request: Request, didCreateURLRequest urlRequest: URLRequest) {
        queue.async {
            for monitor in self.monitors {
                monitor.queue.async { monitor.request(request, didCreateURLRequest: urlRequest) }
            }
        }
    }

    /// Event called when the attempt to create a `URLRequest` from a `Request` fails.
    public func request(_ request: Request, didFailToCreateURLRequest error: NetworkError) {
        queue.async {
            for monitor in self.monitors {
                monitor.queue.async { monitor.request(request, didFailToCreateURLRequest: error) }
            }
        }
    }

    /// Event called when a `RequestInterceptor` fails to intercept the `Request`'s initial `URLRequest`.
    public func request(
        _ request: Request,
        didFailToInterceptURLRequest urlRequest: URLRequest,
        withError error: NetworkError
    ) {
        queue.async {
            for monitor in self.monitors {
                monitor.queue.async {
                    monitor.request(
                        request,
                        didFailToInterceptURLRequest: urlRequest,
                        withError: error.asNetworkError(or: .unknown)
                    )
                }
            }
        }
    }

    /// Event called when a `RequestInterceptor` intercept the `Request`'s initial `URLRequest`.
    public func request(
        _ request: Request,
        didInterceptRequest urlRequest: URLRequest,
        to modifiedRequest: URLRequest
    ) {

        queue.async {
            for monitor in self.monitors {
                monitor.queue.async { monitor.request(request, didInterceptRequest: urlRequest, to: modifiedRequest) }
            }
        }
    }

    /// Called when cancellation is completed.
    public func requestDidCancel(_ request: Request) {
        queue.async {
            for monitor in self.monitors {
                monitor.queue.async { monitor.requestDidCancel(request) }
            }
        }
    }

    /// Called when `Request` has been completed.
    public func requestDidComplete(_ request: Request) {
        queue.async {
            for monitor in self.monitors {
                monitor.queue.async { monitor.requestDidComplete(request) }
            }
        }
    }

    /// Called when the request has been resumed.
    public func requestDidResume(_ request: Request) {
        queue.async {
            for monitor in self.monitors {
                monitor.queue.async { monitor.requestDidResume(request) }
            }
        }
    }

    /// Called when the request has been suspended.
    public func requestDidSuspend(_ request: Request) {
        queue.async {
            for monitor in self.monitors {
                monitor.queue.async { monitor.requestDidSuspend(request) }
            }
        }
    }

    /// Event called when a `Request` is about to be retried.
    public func requestIsRetrying(_ request: Request) {
        queue.async {
            for monitor in self.monitors {
                monitor.queue.async { monitor.requestIsRetrying(request) }
            }
        }
    }
}

struct AFRequestMonitor: Alamofire.EventMonitor {
    private let client: HTTPApiClient
    private let monitor: RequestMonitor?

    // MARK: Initializers

    init(client: HTTPApiClient, monitor: RequestMonitor?) {
        self.client = client
        self.monitor = monitor
    }

    // MARK: RequestMonitor

    /// Event called when the attempt to create a `URLRequest` from a `Request`'s original `URLRequestConvertible` value fails.
    func request(_ request: Alamofire.Request, didFailToCreateURLRequestWithError error: AFError) {
        Task {
            guard let request = await client.getRequest(with: request.id) else { return }
            monitor?.request(request, didFailToCreateURLRequest: error.asNetworkError(or: .unknown))
        }
    }

    /// Event called when a `RequestAdapter` adapts the `Request`'s initial `URLRequest`.
    func request(
        _ request: Alamofire.Request,
        didAdaptInitialRequest initialRequest: URLRequest,
        to adaptedRequest: URLRequest
    ) {
        Task {
            guard let request = await client.getRequest(with: request.id) else { return }
            monitor?.request(request, didInterceptRequest: initialRequest, to: adaptedRequest)
        }
    }

    /// Event called when a `RequestAdapter` fails to adapt the `Request`'s initial `URLRequest`.
    func request(
        _ request: Alamofire.Request,
        didFailToAdaptURLRequest initialRequest: URLRequest,
        withError error: AFError
    ) {
        Task {
            guard let request = await client.getRequest(with: request.id) else { return }
            monitor?.request(
                request, didFailToInterceptURLRequest: initialRequest,
                withError: error.asNetworkError(or: .unknown)
            )
        }
    }

    /// Event called when a final `URLRequest` is created for a `Request`.
    func request(_ request: Alamofire.Request, didCreateURLRequest urlRequest: URLRequest) {
        Task {
            guard let request = await client.getRequest(with: request.id) else { return }
            monitor?.request(request, didCreateURLRequest: urlRequest)
        }
    }

    /// Event called when a `URLSessionTask` subclass instance is created for a `Request`.
    func request(_ request: Alamofire.Request, didCreateTask task: URLSessionTask) {
        Task {
            guard let request = await client.getRequest(with: request.id) else { return }
            monitor?.request(request, didCreateSesionTask: task)
        }
    }

    /// Event called when a `Request` receives a `URLSessionTaskMetrics` value.
    func request(_ request: Alamofire.Request, didGatherMetrics metrics: URLSessionTaskMetrics) {
        Task {
            guard let request = await client.getRequest(with: request.id) else { return }
            monitor?.request(request, didCollectMetrics: metrics)
        }
    }

    /// Event called when a `Request`'s task completes, possibly with an error. A `Request` may receive this event
    /// multiple times if it is retried.
    func request(_ request: Alamofire.Request, didCompleteTask task: URLSessionTask, with error: AFError?) {
        Task {
            guard let request = await client.getRequest(with: request.id) else { return }
            monitor?.request(request, didCompleteTask: task, with: error?.asNetworkError(or: .unknown))
        }
    }

    /// Event called when a `Request` is about to be retried.
    func requestIsRetrying(_ request: Alamofire.Request) {
        Task {
            guard let request = await client.getRequest(with: request.id) else { return }
            monitor?.requestIsRetrying(request)
        }
    }

    /// Event called when a `Request` finishes and response serializers are being called.
    func requestDidFinish(_ request: Alamofire.Request) {
        Task {
            guard let request = await client.getRequest(with: request.id) else { return }
            monitor?.requestDidComplete(request)
            client.removeRequest(with: request.id)
        }
    }

    /// Event called when a `Request` receives a `resume` call.
    func requestDidResume(_ request: Alamofire.Request) {
        Task {
            guard let request = await client.getRequest(with: request.id) else { return }
            monitor?.requestDidResume(request)
        }
    }

    /// Event called when a `Request` receives a `suspend` call.
    func requestDidSuspend(_ request: Alamofire.Request) {
        Task {
            guard let request = await client.getRequest(with: request.id) else { return }
            monitor?.requestDidSuspend(request)
        }
    }

    /// Event called when a `Request` receives a `cancel` call.
    func requestDidCancel(_ request: Alamofire.Request) {
        Task {
            guard let request = await client.getRequest(with: request.id) else { return }
            monitor?.requestDidCancel(request)
        }
    }

    // MARK: DataRequest Events

    /// Event called when a `DataRequest` calls a `Validation`.
    func request(
        _ request: Alamofire.DataRequest,
        didValidateRequest urlRequest: URLRequest?,
        response: HTTPURLResponse,
        data: Data?,
        withResult result: Alamofire.Request.ValidationResult
    ) {
        Task {
            guard let request = await client.getRequest(with: request.id) as? DataRequest else { return }
            monitor?.request(
                request,
                didValidateRequest: urlRequest,
                response: response,
                data: data,
                result: result
            )
        }
    }

    /// Event called when a `DataRequest` creates a `DataResponse<Data?>` value without calling a `ResponseSerializer`.
    func request(_ request: Alamofire.DataRequest, didParseResponse response: DataResponse<Data?, AFError>) {
        Task {
            guard let request = await client.getRequest(with: request.id) as? DataRequest else { return }
            monitor?.request(request, didParseResponse: response.asResponse())
        }
    }

    /// Event called when a `DataRequest` calls a `ResponseSerializer` and creates a generic `DataResponse<Value, AFError>`.
    func request<Value>(_ request: Alamofire.DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        Task {
            guard let request = await client.getRequest(with: request.id) as? DataRequest else { return }
            monitor?.request(request, didParseResponse: response.asResponse())
        }
    }
}
