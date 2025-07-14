//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A store of dependencies to be accessed by key.
///
/// This structure provides a mechanism for managing dependencies in a type-safe way.
/// Dependencies are stored in an internal dictionary and can be accessed using
/// custom key types that conform to `DependencyKey`.
public final class DependencyValues: @unchecked Sendable {
    // MARK: - Private Properties
    
    private let lock = NSLock()
    private var storage: [ObjectIdentifier: any Sendable] = [:]
    
    // MARK: - Properties
    
    /// A task-local storage for managing the current dependency values.
    @TaskLocal public static var current = DependencyValues()

    // MARK: - Subscript
    
    /// Allows accessing a dependency by its key type.
    ///
    /// - Parameter key: The key type used to retrieve its associated dependency.
    /// - Returns: The value associated with the given key.
    public subscript<Key: DependencyKey>(key: Key.Type) -> Key.Value {
        get {
            lock.lock()
            defer { lock.unlock() }
            
            if let dependency = storage[ObjectIdentifier(key)] as? Key.Value {
                return dependency
            } else if let dependency = key.defaultValue {
                return dependency
            }
            
            fatalError("The requested dependency for key: \(key) has not been set.")
        }
        set {
            lock.lock()
            storage[ObjectIdentifier(key)] = newValue
            lock.unlock()
        }
    }
    
    // MARK: - Instance methods

    /// Merges the current dependency values with another set of values.
    ///
    /// - Parameter other: Another `DependencyValues` instance to merge with.
    /// - Returns: A new `DependencyValues` instance with merged dependencies.
    func merging(_ other: DependencyValues) -> Self {
        lock.lock()
        
        defer { lock.unlock() }
        
        let values = self
        values.storage.merge(other.storage, uniquingKeysWith: { $1 })
        return values
    }
}

/// Executes an operation within a new set of dependency values.
///
/// This function initializes a fresh instance of `DependencyValues` and provides it to the given asynchronous operation.
/// It ensures that dependencies are properly scoped within the operation's execution context.
///
/// - Parameters:
///   - operation: An asynchronous closure that receives the newly created `DependencyValues` instance.
///   - isolation: The actor isolation level for the execution. Defaults to `#isolation`.
///   - file: The file in which this function is called, used for debugging. Defaults to `#fileID`.
///   - line: The line number where this function is called, used for debugging. Defaults to `#line`.
/// - Returns: The result of the operation, of type `R`.
/// - Throws: Any error thrown by the `operation` closure.
public func withDependencyValues<R>(
    _ operation: (DependencyValues) async throws -> R,
    isolation: isolated (any Actor)? = #isolation,
    file: String = #fileID,
    line: UInt = #line
) async rethrows -> R {
    
    let dependencyValues = DependencyValues()
    
    return try await DependencyValues.$current.withValue(dependencyValues) {
        try await operation(dependencyValues)
    }
}
