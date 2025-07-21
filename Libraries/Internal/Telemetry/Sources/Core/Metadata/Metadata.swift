//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// `Metadata` is a typealias for `[String: MetadataValue]` the type of the metadata storage.
public typealias Metadata = [String: MetadataValue]

extension Metadata {
    /// Converts a metadata dictionary into a compact JSON string representation.
    ///
    /// This method serializes the dictionary into JSON using `JSONSerialization` and returns it
    /// as a UTF-8 encoded string. If the dictionary is empty or serialization fails, `nil` is returned.
    ///
    /// - Returns: A compact JSON string representation of the dictionary, or `nil` if the dictionary is empty or serialization fails.
    func prettify() -> String? {
        guard !isEmpty else { return nil }

        guard let data = try? JSONSerialization.data(withJSONObject: self) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }
}

/// A  metadata value. `MetadataValue` is string, array, and dictionary literal convertible.
public enum MetadataValue: Sendable {
    /// A metadata value which is an array of `MetadataValue`s.
    case array([Metadata.Value])

    /// A metadata value which is a `Bool`.
    case bool(Bool)

    /// A metadata value which is a dictionary from `String` to `MetadataValue`.
    case dictionary(Metadata)

    /// A metadata value which is a `Double`.
    case double(Double)

    /// A metadata value which is a `Int`.
    case int(Int)

    /// A metadata value which is a `String`.
    case string(String)
}

extension MetadataValue: CustomStringConvertible {

    // MARK: - CustomStringConvertible

    /// A textual representation of this instance.
    public var description: String {
        switch self {
        case .array(let list):
            return list.map(\.description).description

        case .bool(let bool):
            return bool.description

        case .dictionary(let dict):
            return dict.mapValues(\.description).description

        case .double(let double):
            return double.description

        case .int(let int):
            return int.description

        case .string(let str):
            return str
        }
    }
}

extension MetadataValue: Decodable {

    // MARK: - Decodable

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let value = try? container.decode([MetadataValue].self) {
            self = .array(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode([String: MetadataValue].self) {
            self = .dictionary(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        }

        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid MetadataValue")
    }
}

extension MetadataValue: Encodable {

    // MARK: - Encodable

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws {
        switch self {
        case .array(let array):
            try array.encode(to: encoder)

        case .bool(let bool):
            try bool.encode(to: encoder)

        case .dictionary(let dictionary):
            try dictionary.encode(to: encoder)

        case .double(let double):
            try double.encode(to: encoder)

        case .int(let int):
            try int.encode(to: encoder)

        case .string(let string):
            try string.encode(to: encoder)
        }
    }
}

extension MetadataValue: Equatable {

    // MARK: - Equatable

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: Metadata.Value, rhs: Metadata.Value) -> Bool {
        switch (lhs, rhs) {
        case let (.array(lhs), .array(rhs)):
            return lhs == rhs

        case let (.bool(lhs), .bool(rhs)):
            return lhs == rhs

        case let (.dictionary(lhs), .dictionary(rhs)):
            return lhs == rhs

        case let (.double(lhs), .double(rhs)):
            return lhs == rhs

        case let (.int(lhs), .int(rhs)):
            return lhs == rhs

        case let (.string(lhs), .string(rhs)):
            return lhs == rhs

        default:
            return false
        }
    }
}

extension MetadataValue: ExpressibleByArrayLiteral {

    // MARK: - ExpressibleByArrayLiteral

    /// Creates an instance initialized with the given array elements.
    public init(arrayLiteral elements: Metadata.Value...) {
        self = .array(elements)
    }
}

extension MetadataValue: ExpressibleByBooleanLiteral {

    // MARK: - ExpressibleByBooleanLiteral

    /// Creates an instance initialized to the given Boolean value.
    public init(booleanLiteral value: Bool) {
        self = .bool(value)
    }
}

extension MetadataValue: ExpressibleByDictionaryLiteral {

    // MARK: - ExpressibleByDictionaryLiteral

    /// Creates an instance initialized with the given key-value pairs.
    public init(dictionaryLiteral elements: (String, Metadata.Value)...) {
        self = .dictionary(.init(uniqueKeysWithValues: elements))
    }
}

extension MetadataValue: ExpressibleByFloatLiteral {

    // MARK: - ExpressibleByFloatLiteral

    /// Creates an instance initialized to the specified floating-point value.
    public init(floatLiteral value: Double) {
        self = .double(value)
    }
}

extension MetadataValue: ExpressibleByIntegerLiteral {

    // MARK: - ExpressibleByIntegerLiteral

    /// Creates an instance initialized to the specified integer value.
    public init(integerLiteral value: Int) {
        self = .int(value)
    }
}

extension MetadataValue: ExpressibleByStringLiteral {

    // MARK: - ExpressibleByStringLiteral

    /// Creates an instance initialized to the given string value.
    ///
    /// - Parameter value: The value of the new instance.
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension MetadataValue: ExpressibleByStringInterpolation {}
