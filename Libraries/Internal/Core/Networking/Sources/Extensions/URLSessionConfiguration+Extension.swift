//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

extension URLSessionConfiguration {
    /// Returns the `HTTPHeaders` representation.
    public var headers: HTTPHeaders {
        get {
            (httpAdditionalHeaders as? [String: String]).map(HTTPHeaders.init) ?? []
        }

        set {
            httpAdditionalHeaders = newValue.dictionary
        }
    }

    // MARK: - Public methods

    /// Returns the default implementation of the session configuration
    /// used accross the networking calls.
    ///
    /// - Returns: A default `URLSessionConfiguration` object.
    public static func createDefault() -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        configuration.headers = .default
        configuration.httpCookieStorage = HTTPCookieStorage.shared
        configuration.urlCache = nil
        configuration.urlCredentialStorage = nil
        #if os(iOS)
            configuration.multipathServiceType = .handover
        #endif

        return configuration
    }
}
