//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A property wrapper that provides dependency injection functionality.
///
/// This wrapper allows values to be dynamically resolved from `DependencyValues`,
/// ensuring that dependencies are properly injected and updated when needed.
///
/// - Note: The wrapped value is computed based on a merging of initial values
///         and the current dependency values at runtime.
@propertyWrapper
public struct Dependency<Value>: Sendable {
    // MARK: - Private Properties

    private let keyPath: KeyPath<DependencyValues, Value> & Sendable

    // MARK: - Properties

    /// The initial set of dependency values when the property wrapper is created.
    let initialValues: DependencyValues

    // MARK: - Computed Properties

    /// The resolved dependency value.
    public var wrappedValue: Value {
        let dependencies = initialValues.merging(DependencyValues.current)
        return dependencies[keyPath: keyPath]
    }

    // MARK: - Initializer

    /// Initializes the dependency wrapper with a key path to a value in `DependencyValues`.
    ///
    /// - Parameter keyPath: A key path to the dependency value in `DependencyValues`.
    public init(_ keyPath: KeyPath<DependencyValues, Value> & Sendable) {
        self.initialValues = DependencyValues.current
        self.keyPath = keyPath
    }
}
