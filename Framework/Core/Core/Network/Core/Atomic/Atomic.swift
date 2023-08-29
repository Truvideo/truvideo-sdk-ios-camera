//
//  Atomic.swift
//
//  Created by TruVideo on 8/08/23.
//  Copyright © TruVideo. All rights reserved.
//

import Foundation

/// Thread-safe wrapper around a value.
@propertyWrapper
public class Atomic<T> {
    private let lock = NSLock()
    private var value: T

    /// Projected value of the property wrapper.
    public var projectedValue: Atomic<T> {
        self
    }

    /// The contained value. Unsafe for anything more than direct read or write.
    public var wrappedValue: T {
        get {
            lock.lock()
            defer { lock.unlock() }

            return value
        }

        set {
            lock.lock()
            value = newValue
            lock.unlock()
        }
    }

    // MARK: Initializers

    init(_ value: T) {
        self.value = value
    }

    // MARK: Instance methods

    /// Synchronously modify the wrapped value.
    @discardableResult
    func write<U>(_ closure: (inout T) -> U) -> U {
        lock.lock()
        defer { lock.unlock() }

        return closure(&value)
    }
}

extension Atomic where T: RangeReplaceableCollection {
    /// Adds a new element to the end of this protected collection.
    ///
    /// - Parameter value: The value to append into the current value.
    func append(_ value: T.Element) {
        write { (inner: inout T) in
            inner.append(value)
        }
    }

    /// Adds the elements of a sequence to the end of this protected collection.
    ///
    /// - Parameter newElements: The elements to append into the current value.
    func append<S: Sequence>(contentsOf newElements: S) where S.Element == T.Element {
        write { (inner: inout T) in
            inner.append(contentsOf: newElements)
        }
    }
}
