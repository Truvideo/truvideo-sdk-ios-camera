//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A protocol defining methods for caching and retrieving network responses within a session.
///
/// `HTTPURLCache` provides an interface for managing cached responses in a network session.
/// Implementations of this protocol can determine how responses are stored and retrieved,
/// enabling caching strategies such as returning previously stored responses or storing new ones
/// for future use.
public protocol HTTPURLCache: Sendable {
    /// Retrieves a cached response for the given `Request`, if available.
    ///
    /// - Parameter request: The `HTTPURLDataRequest` instance for which the cached response is being requested.
    /// - Returns: A `URLCachedResponse` instance if a cached response exists, otherwise `nil`.
    func cachedResponse(for request: HTTPURLDataRequest) -> URLCachedResponse?

    /// Called when a request is about to cache a response.
    ///
    /// This method allows the cache to decide whether to store the response and how it should be stored.
    ///
    /// - Parameters:
    ///   - response: The `URLCachedResponse` representing the response to be cached.
    ///   - request: The `HTTPURLDataRequest` for which the response is being cached.
    func cache(_ response: URLCachedResponse, for request: HTTPURLDataRequest)

    /// Removes the cached response for a specific `Request`, if it exists.
    ///
    /// This method clears any previously stored response for the given request,
    /// ensuring that future requests will fetch fresh data from the network instead
    /// of using a cached response.
    ///
    /// - Parameter request: The `HTTPURLDataRequest` instance for which the cached response should be removed.
    func removeCachedResponse(for request: HTTPURLDataRequest)
}

extension HTTPURLCache where Self == InMemoryURLCache {
    /// A shared instance of `InMemoryURLCache` with default configuration.
    public static var inMemory: InMemoryURLCache {
        InMemoryURLCache()
    }

    // MARK: - Static methods

    /// Creates a new `InMemoryURLCache` instance with a specified memory capacity.
    ///
    /// - Parameter capacity: The maximum amount of memory (in bytes) allocated for caching.
    /// - Returns: A configured `InMemoryURLCache` instance.
    public static func inMemory(capacity: Int) -> InMemoryURLCache {
        InMemoryURLCache(memoryCapacity: capacity)
    }
}

/// An in-memory implementation of `URLCache`, providing a fast, volatile caching mechanism.
///
/// `InMemoryURLCache` uses `NSCache` to store cached responses for network requests, allowing quick
/// retrieval of responses without persisting them to disk. This cache is useful for temporary
/// storage of network responses where speed is prioritized over long-term persistence.
///
/// - The cache automatically removes objects based on memory constraints.
/// - The default memory capacity is set to 20% of the device's physical memory.
/// - Implements `URLCache` to support standard caching operations.
public struct InMemoryURLCache: HTTPURLCache, @unchecked Sendable {
    private let cache = NSCache<NSString, ValueWrapper>()

    // MARK: - Properties

    /// The maximum amount of memory the cache can use in bytes.
    let memoryCapacity: Int

    // MARK: - Types

    private class ValueWrapper: NSObject {
        let request: HTTPURLRequest
        let value: URLCachedResponse

        // MARK: - Initializer

        init(request: HTTPURLRequest, value: URLCachedResponse) {
            self.request = request
            self.value = value
        }
    }

    // MARK: - Initializer

    /// Initializes a new in-memory cache with an optional memory capacity.
    ///
    /// - Parameter memoryCapacity: The maximum amount of memory the cache can use in bytes.
    ///   If `nil`, defaults to 20% of the device's physical memory.
    public init(memoryCapacity: Int? = nil) {
        self.memoryCapacity = memoryCapacity ?? Int(ProcessInfo.processInfo.physicalMemory) / 5 // 20% of total RAM

        cache.totalCostLimit = self.memoryCapacity
    }

    // MARK: - URLCache

    /// Retrieves a cached response for the given `Request`, if available.
    ///
    /// - Parameter request: The `HTTPURLDataRequest` instance for which the cached response is being requested.
    /// - Returns: A `URLCachedResponse` instance if a cached response exists, otherwise `nil`.
    public func cachedResponse(for request: HTTPURLDataRequest) -> URLCachedResponse? {
        guard let cacheKey = request.cacheKey else {
            return nil
        }

        return cache.object(forKey: cacheKey)?.value
    }

    /// Called when a request is about to cache a response.
    ///
    /// This method allows the cache to decide whether to store the response and how it should be stored.
    ///
    /// - Parameters:
    ///   - response: The `URLCachedResponse` representing the response to be cached.
    ///   - request: The `HTTPURLDataRequest` for which the response is being cached.
    public func cache(_ response: URLCachedResponse, for request: HTTPURLDataRequest) {
        if let cacheKey = request.cacheKey {
            let wrapped = ValueWrapper(request: request, value: response)

            cache.setObject(wrapped, forKey: cacheKey, cost: response.data.count)
        }
    }

    /// Removes the cached response for a specific `Request`, if it exists.
    ///
    /// This method clears any previously stored response for the given request,
    /// ensuring that future requests will fetch fresh data from the network instead
    /// of using a cached response.
    ///
    /// - Parameter request: The `HTTPURLDataRequest` instance for which the cached response should be removed.
    public func removeCachedResponse(for request: HTTPURLDataRequest) {
        if let cacheKey = request.cacheKey {
            cache.removeObject(forKey: cacheKey)
        }
    }
}

extension HTTPURLDataRequest {
    /// Returns the key to use when caching the request.
    fileprivate var cacheKey: NSString? {
        guard
            /// The absolute string.
            let urlString = request?.url?.absoluteString,

            /// The HTTP method.
            let methodString = request?.method.rawValue
        else {
            return nil
        }

        return urlString.appending("-\(methodString)") as NSString
    }
}
