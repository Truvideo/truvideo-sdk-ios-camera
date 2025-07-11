//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// Creates an `NSPredicate` for equality comparison (`==`) between two `NSExpression` objects.
///
/// - Parameters:
///   - left: The left-hand side `NSExpression`.
///   - right: The right-hand side `NSExpression`.
/// - Returns: An `NSPredicate` representing the equality comparison.
public func == (left: NSExpression, right: NSExpression) -> NSPredicate {
    NSComparisonPredicate(
        leftExpression: left,
        rightExpression: right,
        modifier: .direct,
        type: .equalTo,
        options: .init(rawValue: 0)
    )
}

/// Creates an `NSPredicate` for inequality comparison (`!=`) between two `NSExpression` objects.
///
/// - Parameters:
///   - left: The left-hand side `NSExpression`.
///   - right: The right-hand side `NSExpression`.
/// - Returns: An `NSPredicate` representing the inequality comparison.
public func != (left: NSExpression, right: NSExpression) -> NSPredicate {
    NSComparisonPredicate(
        leftExpression: left,
        rightExpression: right,
        modifier: .direct,
        type: .notEqualTo,
        options: .init(rawValue: 0)
    )
}

/// Creates an `NSPredicate` for greater-than comparison (`>`) between two `NSExpression` objects.
///
/// - Parameters:
///   - left: The left-hand side `NSExpression`.
///   - right: The right-hand side `NSExpression`.
/// - Returns: An `NSPredicate` representing the greater-than comparison.
public func > (left: NSExpression, right: NSExpression) -> NSPredicate {
    NSComparisonPredicate(
        leftExpression: left,
        rightExpression: right,
        modifier: .direct,
        type: .greaterThan,
        options: .init(rawValue: 0)
    )
}

/// Creates an `NSPredicate` for greater-than-or-equal-to comparison (`>=`) between two `NSExpression` objects.
///
/// - Parameters:
///   - left: The left-hand side `NSExpression`.
///   - right: The right-hand side `NSExpression`.
/// - Returns: An `NSPredicate` representing the greater-than-or-equal-to comparison.
public func >= (left: NSExpression, right: NSExpression) -> NSPredicate {
    NSComparisonPredicate(
        leftExpression: left,
        rightExpression: right,
        modifier: .direct,
        type: .greaterThanOrEqualTo,
        options: .init(rawValue: 0)
    )
}

/// Creates an `NSPredicate` for less-than comparison (`<`) between two `NSExpression` objects.
///
/// - Parameters:
///   - left: The left-hand side `NSExpression`.
///   - right: The right-hand side `NSExpression`.
/// - Returns: An `NSPredicate` representing the less-than comparison.
public func < (left: NSExpression, right: NSExpression) -> NSPredicate {
    NSComparisonPredicate(
        leftExpression: left,
        rightExpression: right,
        modifier: .direct,
        type: .lessThan,
        options: .init(rawValue: 0)
    )
}

/// Creates a `NSPredicate` that compares whether the value of the left-hand `NSExpression`
/// is less than or equal to the value of the right-hand `NSExpression`.
///
/// This function is typically used in the context of building Core Data predicates
/// to perform queries that check if one value is less than or equal to another.
///
/// - Parameters:
///   - left: The left-hand expression to compare.
///   - right: The right-hand expression to compare.
/// - Returns: An `NSPredicate` that represents the `<=` comparison.
public func <= (left: NSExpression, right: NSExpression) -> NSPredicate {
    NSComparisonPredicate(
        leftExpression: left,
        rightExpression: right,
        modifier: .direct,
        type: .lessThanOrEqualTo,
        options: .init(rawValue: 0)
    )
}

/// Creates a `NSPredicate` that checks if the value of the left-hand `NSExpression`
/// matches the pattern defined by the right-hand `NSExpression`.
///
/// This function is typically used in the context of building Core Data predicates
/// to perform pattern matching queries, such as wildcard searches.
///
/// - Parameters:
///   - left: The left-hand expression to match.
///   - right: The right-hand expression representing the pattern to match.
/// - Returns: An `NSPredicate` that represents the pattern matching (`LIKE`) comparison.
public func ~= (left: NSExpression, right: NSExpression) -> NSPredicate {
    NSComparisonPredicate(
        leftExpression: left,
        rightExpression: right,
        modifier: .direct,
        type: .like,
        options: .init(rawValue: 0)
    )
}

/// Creates a `NSPredicate` that checks if the value of the left-hand `NSExpression`
/// is contained within the values of the right-hand `NSExpression`.
///
/// This function is typically used in the context of building Core Data predicates
/// to perform queries that check if a value is within a specific set or range of values.
///
/// - Parameters:
///   - left: The left-hand expression to check for inclusion.
///   - right: The right-hand expression representing the set or range of values.
/// - Returns: An `NSPredicate` that represents the `IN` comparison.
public func << (left: NSExpression, right: NSExpression) -> NSPredicate {
    NSComparisonPredicate(
        leftExpression: left,
        rightExpression: right,
        modifier: .direct,
        type: .in,
        options: .init(rawValue: 0)
    )
}
