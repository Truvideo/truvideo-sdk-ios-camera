//
//  HTTPHeader.swift
//
//  Created by TruVideo on 8/08/23.
//  Copyright © TruVideo. All rights reserved.
//

import Foundation

private extension Array where Element == HTTPHeader {
    /// Case-insensitively finds the index of an `HTTPHeader` with the provided name, if it exists.
    func index(of name: String) -> Index? {
        let lowercasedName = name.lowercased()
        return firstIndex(where: { $0.name.lowercased() == lowercasedName })
    }
}

private extension Sequence where Element == String {
    /// Returns the Quality Encoded header.
    func qualityEncoded() -> String {
        enumerated().map { index, value in
            let quality = 1.0 - (Double(index) * 0.1)
            return "\(value);q=\(quality)"
        }
        .joined(separator: ", ")
    }
}

func +(lhs: HTTPHeaders, rhs: HTTPHeaders) -> HTTPHeaders {
    var httpHeaders = lhs
    rhs.dictionary.map(HTTPHeader.init).forEach { header in
        httpHeaders.append(header)
    }

    return httpHeaders
}

extension URLRequest {
    /// Returns the `HTTPHeaders` representation.
    public var allHTTPHeaders: HTTPHeaders {
        get {
            allHTTPHeaderFields.map(HTTPHeaders.init) ?? .init()
        }

        set {
            allHTTPHeaderFields = newValue.dictionary
        }
    }
}

extension URLSessionConfiguration {
    /// Returns the `HTTPHeaders` representation.
    public var allHTTPHeaders: HTTPHeaders {
        get {
            (httpAdditionalHeaders as? [String: String]).map(HTTPHeaders.init) ?? []
        }

        set {
            httpAdditionalHeaders = newValue.dictionary
        }
    }
}

/// A representation of a single HTTP header's name / value pair.
public struct HTTPHeader: Hashable {
    /// The name of the header.
    public let name: String

    /// The value of the header.
    public let value: String

    /// Returns the default `Accept-Language` header.
    public static var defaultAcceptLanguage: HTTPHeader {
        let value = Locale.preferredLanguages.prefix(6)
        return .acceptLanguage(value.qualityEncoded())
    }

    // MARK: Static methods

    /// Returns an `Accept-Language` header.
    ///
    /// - Parameter value: The header value.
    /// - Returns: A instance of `HTTPHeader`.
    public static func acceptLanguage(_ value: String) -> HTTPHeader {
        .init(name: "Accept-Language", value: value)
    }

    /// Returns an `Authorization` header.
    ///
    /// - Parameter value: The header value.
    /// - Returns: A instance of `HTTPHeader`.
    public static func authorization(_ value: String) -> HTTPHeader {
        .init(name: "Authorization", value: value)
    }

    /// Returns a `Bearer` `Authorization` header using the `bearerToken` provided
    ///
    /// - Parameter value: The header value.
    /// - Returns: A instance of `HTTPHeader`.
    public static func bearerToken(_ value: String) -> HTTPHeader {
        .init(name: "Authorization", value: "Bearer \(value)")
    }

    /// Returns a `Content-Type` header.
    ///
    /// - Parameter value: The header value.
    /// - Returns: A instance of `HTTPHeader`.
    public static func contentType(_ value: String) -> HTTPHeader {
        .init(name: "Content-Type", value: value)
    }

    // MARK: Initializers

    /// Creates a new instance of the `HTTPHeader` with the
    /// given name and value.
    ///
    /// - Parameters:
    ///   - name: The name of the header.
    ///   - value: The value of the header.
    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }
}

/// An order-preserving and case-insensitive representation of HTTP headers.
public struct HTTPHeaders {
    private var headers: [HTTPHeader] = []

    /// The dictionary representation of all headers.
    public var dictionary: [String: String] {
            .init(uniqueKeysWithValues: headers.map { ($0.name, $0.value) })
    }

    /// Case-insensitively access the header with the given name.
    public subscript(_ name: String) -> String? {
        get {
            guard let index = headers.index(of: name) else {
                return nil
            }

            return headers[index].value
        }

        set {
            guard let newValue = newValue else {
                removeHeader(forKey: name)
                return
            }

            insertOrReplace(.init(name: name, value: newValue))
        }
    }

    /// The default `HTTPHeaders` used.
    public static var `default`: HTTPHeaders {
        [.defaultAcceptLanguage]
    }

    // MARK: Initializers

    public init(array: [HTTPHeader] = []) {
        array.forEach {
            insertOrReplace($0)
        }
    }

    public init(dictionary: [String: String]) {
        self.init(array: dictionary.map(HTTPHeader.init))
    }

    // MARK: Instance methods

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
        guard let index = headers.index(of: key) else { return }

        headers.remove(at: index)
    }

    /// Case-insensitively updates or appends an `HTTPHeader` into the instance using the provided `header` and `key`.
    ///
    ///  - Parameters:
    ///     - value: The header value.
    ///     - key: The name of the header.
    public mutating func setHeader(_ value: String, forKey key: String) {
        insertOrReplace(.init(name: key, value: value))
    }

    // MARK: Private methods

    mutating private func insertOrReplace(_ header: HTTPHeader) {
        guard let index = headers.index(of: header.name) else {
            headers.append(header)
            return
        }

        headers.replaceSubrange(index...index, with: [header])
    }
}

extension HTTPHeaders: ExpressibleByArrayLiteral {

    // MARK: ExpressibleByArrayLiteral

    public init(arrayLiteral elements: HTTPHeader...) {
        self.init(array: elements)
    }
}

extension HTTPHeaders: ExpressibleByDictionaryLiteral {

    // MARK: ExpressibleByDictionaryLiteral

    public init(dictionaryLiteral elements: (String, String)...) {
        let headers = elements.map(HTTPHeader.init)
        self.init(array: headers)
    }
}

extension HTTPHeaders: Collection {

    public var endIndex: Int {
        headers.endIndex
    }

    public var startIndex: Int {
        headers.startIndex
    }

    public subscript(position: Int) -> HTTPHeader {
        headers[position]
    }

    public func index(after i: Int) -> Int {
        headers.index(after: i)
    }
}

extension HTTPHeaders: Sequence {

    // MARK: Sequence

    public func makeIterator() -> IndexingIterator<[HTTPHeader]> {
        headers.makeIterator()
    }
}
