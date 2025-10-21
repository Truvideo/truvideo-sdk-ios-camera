//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A collection of HTTP headers, maintaining order and case-insensitive lookups.
///
/// `HTTPHeaders` allows for easy management of HTTP header key-value pairs, ensuring
/// that headers are case-insensitively matched when accessing or modifying their values.
///
/// Example usage:
/// ```swift
/// var headers = HTTPHeaders()
/// headers.setHeader("application/json", forKey: "Content-Type")
/// print(headers["Content-Type"]) // "application/json"
/// ```
public struct HTTPHeaders: Hashable, Sendable {
    // MARK: - Private Properties

    private var headers: [HTTPHeader] = []

    // MARK: - Public Properties

    /// The dictionary representation of all headers.
    public var dictionary: [String: String] {
        .init(uniqueKeysWithValues: headers.map { ($0.name, $0.value) })
    }

    /// The default `HTTPHeaders` used.
    public static var `default`: HTTPHeaders {
        [.defaultAcceptLanguage]
    }

    // MARK: - Subscript

    /// Case-insensitively access the header with the given name.
    public subscript(_ name: String) -> String? {
        get {
            guard let index = headers.index(of: name) else {
                return nil
            }

            return headers[index].value
        }

        set {
            guard let newValue else {
                removeHeader(forKey: name)
                return
            }

            insertOrReplace(.init(name: name, value: newValue))
        }
    }

    // MARK: - Initializers

    /// Creates a new `HTTPHeaders` instance from an array of `HTTPHeader` values.
    ///
    /// - Parameter array: An array of `HTTPHeader` values to initialize the collection.
    public init(array: [HTTPHeader] = []) {
        for item in array {
            insertOrReplace(item)
        }
    }

    /// Creates a new `HTTPHeaders` instance from a dictionary of key-value pairs.
    ///
    /// - Parameter dictionary: A dictionary where keys represent header names and values represent their corresponding
    /// values.
    public init(dictionary: [String: String]) {
        self.init(array: dictionary.map(HTTPHeader.init))
    }

    // MARK: - Instance methods

    /// Case-insensitively updates or appends the provided `HTTPHeader` into the instance.
    ///
    /// - Parameter value: The header to append.
    public mutating func append(_ header: HTTPHeader) {
        insertOrReplace(header)
    }

    /// Case-insensitively removes an `HTTPHeader`, if it exists, from the instance.
    ///
    /// - Parameter key: The name of the header.
    public mutating func removeHeader(forKey key: String) {
        if let index = headers.index(of: key) {
            headers.remove(at: index)
        }
    }

    /// Case-insensitively updates or appends an `HTTPHeader` into the instance using the provided `header` and `key`.
    ///
    ///  - Parameters:
    ///    - value: The header value.
    ///    - key: The name of the header.
    public mutating func setHeader(_ value: String, forKey key: String) {
        insertOrReplace(.init(name: key, value: value))
    }

    // MARK: - Private methods

    private mutating func insertOrReplace(_ header: HTTPHeader) {
        guard let index = headers.index(of: header.name) else {
            headers.append(header)
            return
        }

        headers.replaceSubrange(index ... index, with: [header])
    }
}

extension HTTPHeaders: ExpressibleByArrayLiteral {
    // MARK: ExpressibleByArrayLiteral

    /// Creates an instance of `HTTPHeaders` from an array literal of `HTTPHeader` elements.
    ///
    /// - Parameter elements: A variadic list of `HTTPHeader` instances.
    public init(arrayLiteral elements: HTTPHeader...) {
        self.init(array: elements)
    }
}

extension HTTPHeaders: ExpressibleByDictionaryLiteral {
    // MARK: ExpressibleByDictionaryLiteral

    /// Creates an instance initialized with the given elements.
    public init(dictionaryLiteral elements: (String, String)...) {
        let headers = elements.map(HTTPHeader.init)
        self.init(array: headers)
    }
}

extension HTTPHeaders: Collection {
    // MARK: - Collection

    /// The collection's "past the end" position---that is, the position one
    /// greater than the last valid subscript argument.
    public var endIndex: Int {
        headers.endIndex
    }

    /// The position of the first element in a nonempty collection.
    ///
    /// If the collection is empty, `startIndex` is equal to `endIndex`.
    public var startIndex: Int {
        headers.startIndex
    }

    /// Accesses the element at the specified position.
    ///
    /// - Parameter position: The position of the element to access.
    /// - Returns: The `HTTPHeader` at the given index.
    public subscript(position: Int) -> HTTPHeader {
        headers[position]
    }

    /// Returns the index after the given index in the collection.
    ///
    /// This method advances the index within the `HTTPHeaders` collection.
    ///
    /// - Parameter index: A valid index of the collection.
    /// - Returns: The index immediately after `index`.
    public func index(after indx: Int) -> Int {
        headers.index(after: indx)
    }
}

extension HTTPHeaders: Sequence {
    // MARK: - Sequence

    /// Returns an iterator over the elements of this sequence.
    public func makeIterator() -> IndexingIterator<[HTTPHeader]> {
        headers.makeIterator()
    }
}

/// Combines two `HTTPHeaders` instances, returning a new collection containing all unique headers.
///
/// If a header exists in both `lhs` and `rhs`, the value from `rhs` replaces the one in `lhs`.
///
/// - Parameters:
///   - lhs: The first set of HTTP headers.
///   - rhs: The second set of HTTP headers.
/// - Returns: A new `HTTPHeaders` instance containing all unique headers from both inputs.
///
/// Example usage:
/// ```swift
/// let headers1: HTTPHeaders = [.contentType("application/json")]
/// let headers2: HTTPHeaders = [.authorization("Bearer token123")]
///
/// let mergedHeaders = headers1 + headers2
/// print(mergedHeaders.dictionary) // ["Content-Type": "application/json", "Authorization": "Bearer token123"]
/// ```
public func + (lhs: HTTPHeaders, rhs: HTTPHeaders) -> HTTPHeaders {
    var httpHeaders = lhs
    for header in rhs.dictionary.map(HTTPHeader.init) {
        httpHeaders.append(header)
    }

    return httpHeaders
}

extension [HTTPHeader] {
    /// Case-insensitively finds the index of an `HTTPHeader` with the provided name, if it exists.
    fileprivate func index(of name: String) -> Index? {
        let lowercasedName = name.lowercased()
        return firstIndex(where: { $0.name.lowercased() == lowercasedName })
    }
}
