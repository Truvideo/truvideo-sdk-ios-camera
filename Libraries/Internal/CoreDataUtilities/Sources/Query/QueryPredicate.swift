//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A structure that represents a filtering condition for a collection of elements, based on an `NSPredicate`.
///
/// The `Predicate` struct is used to encapsulate an `NSPredicate` that can be applied to filter collections of elements
/// (e.g., Core Data entities) by using key paths and comparison operations. It supports a variety of comparison
/// operators, allowing for complex queries to be constructed in a type-safe manner.
///
/// ### Example Usage:
/// ```swift
/// let predicate = \Model.name == "John"
/// let filteredArray = array.filter { predicate.evaluate(with: $0) }
/// ```
public struct QueryPredicate<Element>: ExpressibleByBooleanLiteral {
    /// The underlying `NSPredicate` that defines the filtering condition.
    public let predicate: NSPredicate

    // MARK: Initializer

    /// Creates a new instance of `Predicate` with the specified `NSPredicate`.
    ///
    /// - Parameter predicate: The `NSPredicate` that defines the filtering condition.
    init(predicate: NSPredicate) {
        self.predicate = predicate
    }

    // MARK: ExpressibleByBooleanLiteral

    /// Creates an instance initialized to the given Boolean value.
    ///
    /// - Parameter value: The value of the new instance.
    public init(booleanLiteral value: BooleanLiteralType) {
        self.predicate = NSPredicate(value: value)
    }
}
