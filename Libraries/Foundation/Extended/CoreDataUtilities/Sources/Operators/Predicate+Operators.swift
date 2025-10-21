//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

// MARK: - Predicate Operators

/// Creates a `Predicate` for testing equality between the value at a given key path and a provided value.
///
/// - Parameters:
///   - left: The key path to the value to be compared.
///   - right: The value to compare the key path's value to.
/// - Returns: A `Predicate` that tests for equality.
public func == <Element, Value>(left: KeyPath<Element, Value>, right: Value) -> QueryPredicate<Element> {
    QueryPredicate(predicate: left == right)
}

/// Creates a `Predicate` for testing inequality between the value at a given key path and a provided value.
///
/// - Parameters:
///   - left: The key path to the value to be compared.
///   - right: The value to compare the key path's value to.
/// - Returns: A `Predicate` that tests for inequality.
public func != <Element, Value>(left: KeyPath<Element, Value>, right: Value) -> QueryPredicate<Element> {
    QueryPredicate(predicate: left != right)
}

/// Creates a `Predicate` for testing whether the value at a given key path is greater than a provided value.
///
/// - Parameters:
///   - left: The key path to the value to be compared.
///   - right: The value to compare the key path's value to.
/// - Returns: A `Predicate` that tests whether the value is greater.
public func > <Element, Value>(left: KeyPath<Element, Value>, right: Value) -> QueryPredicate<Element> {
    QueryPredicate(predicate: left > right)
}

/// Creates a `Predicate` for testing whether the value at a given key path is greater than or equal to
/// a provided value.
///
/// - Parameters:
///   - left: The key path to the value to be compared.
///   - right: The value to compare the key path's value to.
/// - Returns: A `Predicate` that tests whether the value is greater than or equal.
public func >= <Element, Value>(left: KeyPath<Element, Value>, right: Value) -> QueryPredicate<Element> {
    QueryPredicate(predicate: left >= right)
}

/// Creates a `Predicate` for testing whether the value at a given key path is less than a provided value.
///
/// - Parameters:
///   - left: The key path to the value to be compared.
///   - right: The value to compare the key path's value to.
/// - Returns: A `Predicate` that tests whether the value is less.
public func < <Element, Value>(left: KeyPath<Element, Value>, right: Value) -> QueryPredicate<Element> {
    QueryPredicate(predicate: left < right)
}

/// Creates a `Predicate` for testing whether the value at a given key path is less than or equal to a provided value.
///
/// - Parameters:
///   - left: The key path to the value to be compared.
///   - right: The value to compare the key path's value to.
/// - Returns: A `Predicate` that tests whether the value is less than or equal.
public func <= <Element, Value>(left: KeyPath<Element, Value>, right: Value) -> QueryPredicate<Element> {
    QueryPredicate(predicate: left <= right)
}

/// Creates a `Predicate` for testing whether the value at a given key path matches a pattern using the `LIKE` operator.
///
/// - Parameters:
///   - left: The key path to the value to be matched.
///   - right: The pattern to match the key path's value against.
/// - Returns: A `Predicate` that tests for pattern matching.
public func ~= <Element, Value>(left: KeyPath<Element, Value>, right: Value) -> QueryPredicate<Element> {
    QueryPredicate(predicate: left ~= right)
}

/// Creates a `Predicate` for testing whether the value at a given key path is in a provided array of values.
///
/// - Parameters:
///   - left: The key path to the value to be checked.
///   - right: The array of values to check the key path's value against.
/// - Returns: A `Predicate` that tests for membership in the array.
public func << <Element, Value>(left: KeyPath<Element, Value>, right: [Value]) -> QueryPredicate<Element> {
    QueryPredicate(predicate: left << right)
}

/// Creates a `Predicate` for testing whether the value at a given key path is within a provided range.
///
/// - Parameters:
///  - left: The key path to the value to be checked.
///  - right: The range of values to check the key path's value against.
/// - Returns: A `Predicate` that tests for membership in the range.
public func << <Element, Value>(
    left: KeyPath<Element, Value>,
    right: Range<Value>
) -> QueryPredicate<Element> where Value: Strideable, Value.Stride: SignedInteger {
    QueryPredicate(predicate: left << right)
}

// MARK: - Predicate Combinators

/// Combines two `Predicate` instances with an `AND` logical operation.
///
/// - Parameters:
///   - left: The first `Predicate`.
///   - right: The second `Predicate`.
/// - Returns: A `Predicate` that combines the two predicates with an `AND` operation.
public func && <Element>(left: QueryPredicate<Element>, right: QueryPredicate<Element>) -> QueryPredicate<Element> {
    QueryPredicate(predicate: left.predicate && right.predicate)
}

/// Combines two `Predicate` instances with an `OR` logical operation.
///
/// - Parameters:
///   - left: The first `Predicate`.
///   - right: The second `Predicate`.
/// - Returns: A `Predicate` that combines the two predicates with an `OR` operation.
public func || <Element>(left: QueryPredicate<Element>, right: QueryPredicate<Element>) -> QueryPredicate<Element> {
    QueryPredicate(predicate: left.predicate || right.predicate)
}

/// Negates a `Predicate` instance, applying a `NOT` logical operation.
///
/// - Parameter predicate: The `Predicate` to negate.
/// - Returns: A `Predicate` that negates the provided predicate.
public prefix func ! <Element>(predicate: QueryPredicate<Element>) -> QueryPredicate<Element> {
    QueryPredicate(predicate: !predicate.predicate)
}

// MARK: - NSPredicate Combination Operators

/// Combines two `NSPredicate` instances using a logical AND.
///
/// - Parameters:
///   - left: The left-hand side `NSPredicate`.
///   - right: The right-hand side `NSPredicate`.
/// - Returns: An `NSPredicate` representing the logical AND of the two predicates.
public func && (left: NSPredicate, right: NSPredicate) -> NSPredicate {
    NSCompoundPredicate(type: .and, subpredicates: [left, right])
}

/// Combines two `NSPredicate` instances using a logical OR.
///
/// - Parameters:
///   - left: The left-hand side `NSPredicate`.
///   - right: The right-hand side `NSPredicate`.
/// - Returns: An `NSPredicate` representing the logical OR of the two predicates.
public func || (left: NSPredicate, right: NSPredicate) -> NSPredicate {
    NSCompoundPredicate(type: .or, subpredicates: [left, right])
}

/// Negates an `NSPredicate`.
///
/// - Parameter left: The `NSPredicate` to negate.
/// - Returns: An `NSPredicate` representing the negation of the predicate.
public prefix func ! (left: NSPredicate) -> NSPredicate {
    NSCompoundPredicate(type: .not, subpredicates: [left])
}
