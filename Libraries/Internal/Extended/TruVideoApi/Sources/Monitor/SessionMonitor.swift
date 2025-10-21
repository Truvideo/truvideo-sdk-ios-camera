//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Networking

/// A monitoring utility for tracking network request lifecycle events.
///
/// `SessionMonitor` integrates with a `Logger` to log significant request events,
/// such as request resumption and response parsing. It helps debug network operations
/// by providing detailed request and response metadata.
///
/// - Note: This monitor is useful for debugging API calls, tracking request states, and capturing errors during request
/// execution.
public struct SessionMonitor: Monitor {
    // MARK: - Public Properties

    /// The dispatch queue associated to this monitor
    public let queue: DispatchQueue = .init(label: "com.session.monitor")

    // MARK: - Initializer

    /// Creates a new instance of the `SessionMonitor` configured with the given `Logger`.
    ///
    /// - Parameter logger: The logger in charge to emit log messages.
    public init() {}

    // MARK: - Monitor

    /// Called when a request is resumed after being suspended.
    ///
    /// - Parameter request: The `Request` instance that resumed execution.
    public func requestDidResume(_ request: any Request) {
        print(
            """
            ----------------------------- ✅ Request did resume -----------------------------
            "request": \(request.debugDescription)
            """
        )
    }

    /// Called when a `DataRequest` parses a response with a specified value type.
    ///
    /// - Parameters:
    ///   - request: The `DataRequest` instance being parsed.
    ///   - response: The `Response` containing the parsed value or an error.
    public func request(
        _ request: any DataRequest,
        didParseResponse response: Response<some Sendable, NetworkingError>
    ) {
        switch response.result {
        case let .failure(error):
            print(
                """
                ------------------------------- ⚙️ Request did parse response --------------------------------
                error: \(error.localizedDescription),
                request: \(request.debugDescription),
                response: \(response.debugDescription)
                """
            )

        case let .success(value):
            print(
                """
                ------------------------------- ⚙️ Request did parse response --------------------------------
                value: \(String(describing: value)),
                request: \(request.debugDescription),
                response: \(response.debugDescription)
                """
            )
        }
    }
}
