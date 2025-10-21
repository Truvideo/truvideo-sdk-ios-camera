//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A property wrapper that provides additional functionality for working with Core Data attributes,
/// such as generating `NSExpression` and `NSSortDescriptor` instances.
///
/// The `Attribute` property wrapper is designed to be used with properties in Core Data managed objects.
/// It allows for the creation of `NSExpression` and `NSSortDescriptor` instances based on the key path of the attribute
/// facilitating query building and sorting in a type-safe manner.
///
/// ### Usage Example:
///
/// ```swift
/// import CoreData
///
/// class MyEntity: NSManagedObject {
///     @NSManaged var name: String
///     @NSManaged var age: Int
///
///     static var name: Attribute<MyEntity, String> {
///         Attribute(\.name)
///     }
/// }
///
/// // Example usage:
/// let nameAttribute = Attribute(\MyEntity.name)
/// let sortDescriptor = nameAttribute.ascending()  // Creates an ascending sort descriptor for "name"
/// let expression = nameAttribute.expression        // Creates an NSExpression for "name"
/// ```
@propertyWrapper
public struct Attribute<Value>: Equatable {
    /// The key path of the attribute that this property wrapper is associated with.
    public let expression: NSExpression

    // MARK: - Computed Properties

    /// The wrapped value of the attribute.
    public var wrappedValue: Value {
        fatalError("@Attribute is a property wrapper that should only be used with @Type properties")
    }

    // MARK: Initializer

    /// Initializes a new instance of the `Attribute` property wrapper with the specified key path.
    ///
    /// - Parameter keyPath: The key path of the attribute that this property wrapper will manage.
    public init(_ keyPath: KeyPath<some Any, Value>) {
        self.expression = NSExpression(forKeyPath: keyPath)
    }

    /// Initializes a new instance of the `Attribute` property wrapper with the specified key path.
    ///
    /// - Parameter keyPath: The key path of the attribute that this property wrapper will manage.
    public init(_ keyPath: String) {
        self.expression = NSExpression(forKeyPath: keyPath)
    }

    // MARK: Public methods

    /// Creates an `NSSortDescriptor` that sorts the attribute in ascending order.
    ///
    /// This method generates a sort descriptor that can be used to sort query results based on the attribute.
    ///
    /// - Returns: An `NSSortDescriptor` instance that sorts the attribute in ascending order.
    public func ascending() -> NSSortDescriptor {
        NSSortDescriptor(key: expression.keyPath, ascending: true)
    }

    /// Creates an `NSSortDescriptor` that sorts the attribute in descending order.
    ///
    /// This method generates a sort descriptor that can be used to sort query results based on the attribute.
    ///
    /// - Returns: An `NSSortDescriptor` instance that sorts the attribute in descending order.
    public func descending() -> NSSortDescriptor {
        NSSortDescriptor(key: expression.keyPath, ascending: false)
    }
}

// MARK: - Equality and Comparison Operators

/// Compares two `Attribute` instances to determine if they represent the same property by comparing their key paths.
///
/// - Parameters:
///   - lhs: The left-hand side `Attribute`.
///   - rhs: The right-hand side `Attribute`.
/// - Returns: `true` if both attributes represent the same property, `false` otherwise.
public func == <AttributeType>(lhs: Attribute<AttributeType>, rhs: Attribute<AttributeType>) -> Bool {
    lhs.expression == rhs.expression
}

/// Creates an equality `NSPredicate` comparing an `Attribute` with a constant value.
///
/// - Parameters:
///   - left: The `Attribute` to compare.
///   - right: The value to compare against.
/// - Returns: An `NSPredicate` representing the equality comparison between the `Attribute` and the provided value.
public func == <AttributeType>(left: Attribute<AttributeType>, right: AttributeType?) -> NSPredicate {
    left.expression == NSExpression(forConstantValue: right)
}

/// Creates an inequality `NSPredicate` comparing an `Attribute` with a constant value.
///
/// - Parameters:
///   - left: The `Attribute` to compare.
///   - right: The value to compare against.
/// - Returns: An `NSPredicate` representing the inequality comparison between the `Attribute` and the provided value.
public func != <AttributeType>(left: Attribute<AttributeType>, right: AttributeType?) -> NSPredicate {
    left.expression != NSExpression(forConstantValue: right)
}

/// Creates a greater-than `NSPredicate` comparing an `Attribute` with a constant value.
///
/// - Parameters:
///   - left: The `Attribute` to compare.
///   - right: The value to compare against.
/// - Returns: An `NSPredicate` representing the greater-than comparison between the `Attribute` and the provided value.
public func > <AttributeType>(left: Attribute<AttributeType>, right: AttributeType?) -> NSPredicate {
    left.expression > NSExpression(forConstantValue: right)
}

/// Creates a greater-than-or-equal-to `NSPredicate` comparing an `Attribute` with a constant value.
///
/// - Parameters:
///   - left: The `Attribute` to compare.
///   - right: The value to compare against.
/// - Returns: An `NSPredicate` representing the greater-than-or-equal-to comparison between the
///           `Attribute` and the provided value.
public func >= <AttributeType>(left: Attribute<AttributeType>, right: AttributeType?) -> NSPredicate {
    left.expression >= NSExpression(forConstantValue: right)
}

/// Creates a less-than `NSPredicate` comparing an `Attribute` with a constant value.
///
/// - Parameters:
///   - left: The `Attribute` to compare.
///   - right: The value to compare against.
/// - Returns: An `NSPredicate` representing the less-than comparison between the `Attribute` and the provided value.
public func < <AttributeType>(left: Attribute<AttributeType>, right: AttributeType?) -> NSPredicate {
    left.expression < NSExpression(forConstantValue: right)
}

/// Creates a less-than-or-equal-to `NSPredicate` comparing an `Attribute` with a constant value.
///
/// - Parameters:
///   - left: The `Attribute` to compare.
///   - right: The value to compare against.
/// - Returns: An `NSPredicate` representing the less-than-or-equal-to comparison between the
///            `Attribute` and the provided value.
public func <= <AttributeType>(left: Attribute<AttributeType>, right: AttributeType?) -> NSPredicate {
    left.expression <= NSExpression(forConstantValue: right)
}

/// Creates a pattern-matching `NSPredicate` comparing an `Attribute` with a constant value using the `like` operator.
///
/// - Parameters:
///   - left: The `Attribute` to compare.
///   - right: The value to compare against.
/// - Returns: An `NSPredicate` representing the pattern-matching comparison between the
///            `Attribute` and the provided value.
public func ~= <AttributeType>(left: Attribute<AttributeType>, right: AttributeType?) -> NSPredicate {
    left.expression ~= NSExpression(forConstantValue: right)
}

/// Creates an `NSPredicate` that checks if the attribute's value is within a given array.
///
/// - Parameters:
///   - left: The `Attribute` to compare.
///   - right: The array of values to check against.
/// - Returns: An `NSPredicate` representing the containment check between the `Attribute` and the provided array.
public func << <AttributeType>(left: Attribute<AttributeType>, right: [AttributeType]) -> NSPredicate {
    left.expression << NSExpression(forConstantValue: right)
}

/// Creates an `NSPredicate` that checks if the attribute's value is within a given range.
///
/// - Parameters:
///   - left: The `Attribute` to compare.
///   - right: The range of values to check against.
/// - Returns: An `NSPredicate` representing the range check between the `Attribute` and the provided range.
public func << <AttributeType>(left: Attribute<AttributeType>, right: Range<AttributeType>) -> NSPredicate {
    let value = [right.lowerBound, right.upperBound]
    let rightExpression = NSExpression(forConstantValue: value)

    return NSComparisonPredicate(
        leftExpression: left.expression,
        rightExpression: rightExpression,
        modifier: .direct,
        type: .between,
        options: []
    )
}

/// Creates a negation `NSPredicate` for a boolean `Attribute`.
///
/// - Parameter left: The boolean `Attribute` to negate.
/// - Returns: An `NSPredicate` that checks if the boolean `Attribute` is `false`.
public prefix func ! (left: Attribute<Bool>) -> NSPredicate {
    left == false
}
