//
// Copyright © 2025 TruVideo. All rights reserved.
//

import CoreData
import Foundation

/// Converts a `KeyPath` into an `NSExpression` that can be used for building `NSPredicate` objects.
///
/// This function utilizes the underlying KVC (Key-Value Coding) key path string of the `KeyPath` to create
/// an `NSExpression` instance.
///
/// - Parameter keyPath: The `KeyPath` to convert into an `NSExpression`.
/// - Returns: An `NSExpression` representing the `KeyPath`.
func expression(for keyPath: KeyPath<some Any, some Any>) -> NSExpression {
    NSExpression(forKeyPath: keyPath)
}

// MARK: - NSPredicate

/// Creates an `NSPredicate` that compares if the value for the given `KeyPath` is equal to the specified value.
///
/// - Parameters:
///   - lhs: The `KeyPath` to compare.
///   - rhs: The value to compare against.
/// - Returns: An `NSPredicate` representing the equality comparison.
public func == <Value>(lhs: KeyPath<some Any, Value>, rhs: Value) -> NSPredicate {
    expression(for: lhs) == NSExpression(forConstantValue: rhs)
}

/// Creates an `NSPredicate` that compares if the value for the given `KeyPath` is not equal to the specified value.
///
/// - Parameters:
///   - lhs: The `KeyPath` to compare.
///   - rhs: The value to compare against.
/// - Returns: An `NSPredicate` representing the inequality comparison.
public func != <Value>(lhs: KeyPath<some Any, Value>, rhs: Value) -> NSPredicate {
    expression(for: lhs) != NSExpression(forConstantValue: rhs)
}

/// Creates an `NSPredicate` that compares if the value for the given `KeyPath` is greater than the specified value.
///
/// - Parameters:
///   - lhs: The `KeyPath` to compare.
///   - rhs: The value to compare against.
/// - Returns: An `NSPredicate` representing the greater than comparison.
public func > <Value>(lhs: KeyPath<some Any, Value>, rhs: Value) -> NSPredicate {
    expression(for: lhs) > NSExpression(forConstantValue: rhs)
}

/// Creates an `NSPredicate` that compares if the value for the given `KeyPath` is greater than or
/// equal to the specified value.
///
/// - Parameters:
///   - lhs: The `KeyPath` to compare.
///   - rhs: The value to compare against.
/// - Returns: An `NSPredicate` representing the greater than or equal to comparison.
public func >= <Value>(lhs: KeyPath<some Any, Value>, rhs: Value) -> NSPredicate {
    expression(for: lhs) >= NSExpression(forConstantValue: rhs)
}

/// Creates an `NSPredicate` that compares if the value for the given `KeyPath` is less than the specified value.
///
/// - Parameters:
///   - lhs: The `KeyPath` to compare.
///   - rhs: The value to compare against.
/// - Returns: An `NSPredicate` representing the less than comparison.
public func < <Value>(lhs: KeyPath<some Any, Value>, rhs: Value) -> NSPredicate {
    expression(for: lhs) < NSExpression(forConstantValue: rhs)
}

/// Creates an `NSPredicate` that compares if the value for the given `KeyPath` is less than or equal
/// to the specified value.
///
/// - Parameters:
///   - lhs: The `KeyPath` to compare.
///   - rhs: The value to compare against.
/// - Returns: An `NSPredicate` representing the less than or equal to comparison.
public func <= <Value>(lhs: KeyPath<some Any, Value>, rhs: Value) -> NSPredicate {
    expression(for: lhs) <= NSExpression(forConstantValue: rhs)
}

/// Creates an `NSPredicate` that checks if the value for the given `KeyPath` matches the specified value.
///
/// - Parameters:
///   - lhs: The `KeyPath` to compare.
///   - rhs: The value to compare against using pattern matching.
/// - Returns: An `NSPredicate` representing the pattern matching comparison.
public func ~= <Value>(lhs: KeyPath<some Any, Value>, rhs: Value) -> NSPredicate {
    expression(for: lhs) ~= NSExpression(forConstantValue: rhs)
}

/// Creates an `NSPredicate` that checks if the value for the given `KeyPath` is contained within the
/// specified array of values.
///
/// - Parameters:
///   - lhs: The `KeyPath` to compare.
///   - rhs: The array of values to check for inclusion.
/// - Returns: An `NSPredicate` representing the `IN` comparison.
public func << <Value>(lhs: KeyPath<some Any, Value>, rhs: [Value]) -> NSPredicate {
    expression(for: lhs) << NSExpression(forConstantValue: rhs)
}

/// Creates an `NSPredicate` that checks if the value for the given `KeyPath` is contained within the
/// specified range of values.
///
/// - Parameters:
///   - lhs: The `KeyPath` to compare.
///   - rhs: The range of values to check for inclusion.
/// - Returns: An `NSPredicate` representing the range comparison.
public func << <Value>(
    lhs: KeyPath<some Any, Value>,
    rhs: Range<Value>
) -> NSPredicate where Value: Strideable, Value.Stride: SignedInteger {
    expression(for: lhs) << NSExpression(forConstantValue: Array(rhs))
}
