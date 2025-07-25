//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A key associated with a dependency value for lookup.
public protocol DependencyKey<Value>: Sendable {
    /// The associated type representing the type of the dependency key's value.
    associatedtype Value: Sendable = Self

    /// A default value for they key.
    static var defaultValue: Value { get }
}
