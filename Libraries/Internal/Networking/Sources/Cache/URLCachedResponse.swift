//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A structure representing a cached HTTP response.
///
/// `URLCachedResponse` encapsulates the data, request, and response associated with a cached HTTP request.
/// It is primarily used to store and retrieve cached network responses efficiently.
public struct URLCachedResponse {
    /// The response body data associated with the cached request.
    public let data: Data

    /// The `HTTPURLResponse` containing metadata, such as status code and headers.
    public let response: HTTPURLResponse
}
