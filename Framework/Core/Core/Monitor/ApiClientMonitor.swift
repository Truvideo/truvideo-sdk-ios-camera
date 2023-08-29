//
//  ApiClientMonitor.swift
//
//  Created by TruVideo on 8/08/23.
//  Copyright © TruVideo. All rights reserved.
//

import Foundation

/// A monitor outlining the lifetime events inside `TruVideoCore`.
public struct ApiClientMonitor: RequestMonitor {
    /// The dispatch queue associated to this monitor
    public let queue: DispatchQueue = .init(label: "org.truvideo.cms.monitor")

    // MARK: Initializers

    public init() {}

    // MARK: RequestMonitor

    /// Called when the request has been resumed.
    public func requestDidResume(_ request: Request) {
        print("----------------------------- ✅ Request did resume -----------------------------")
        print("request: \(request.cURLDescription())")
    }

    /// Event called when a `DataRequest` calls a `ResponseSerializer` and creates a generic `Response<Value>`.
    public func request<Value>(_ request: DataRequest, didParseResponse response: Response<Value>) {
        switch response.result {
        case .failure(let error):
            print("------------------------------- ⚙️ Request did parse response --------------------------------")
            print("error: \(error.localizedDescription)")
            print("request: \(request.cURLDescription())")
            print("response: \(response.debugDescription)")

        case .success(let value):
            print("------------------------------- ⚙️ Request did parse response --------------------------------")
            print("value: \(String(describing: value))")
            print("request: \(request.cURLDescription())")
            print("response: \(response.debugDescription)")
        }
    }
}
