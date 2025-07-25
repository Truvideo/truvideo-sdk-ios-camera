//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A fixed-size, first-in-first-out (FIFO) circular buffer that stores a limited number of elements.
///
/// The `RingBuffer` stores elements in a fixed-size array and overwrites the oldest elements
/// once the maximum capacity is reached. It is particularly useful for tracking recent events,
/// telemetry breadcrumbs, or any scenario where you want to retain only the most recent items.
///
/// This implementation conforms to `Sequence` and `Codable`, making it easy to iterate over elements
/// and serialize/deserialize its contents.
///
/// Example usage:
///
/// ```swift
/// var buffer = RingBuffer<String>(maxCapacity: 5)
/// buffer.add("One")
/// buffer.add("Two")
/// print(buffer.snapshot()) // ["One", "Two"]
/// ```
struct RingBuffer<Element>: Sequence {
    // MARK: - Private Properties

    private var buffer: [Element?]
    private var bufferIndex: Array<Element>.Index
    private let maxCapacity: Int

    // MARK: - Computed Properties

    /// The number of elements in the array.
    var count: Int {
        bufferIndex
    }

    /// A boolean indicating if the ring is full.
    var isFull: Bool {
        bufferIndex == maxCapacity
    }

    // MARK: - Subscript

    /// Accesses the element at the specified index in the buffer.
    ///
    /// - Parameter index: The index into the buffer array.
    /// - Returns: The element at the given index, or `nil` if out of bounds.
    subscript(index: Int) -> Element? {
        guard index < buffer.count else { return nil }
        return buffer[index]
    }

    // MARK: - Initializer

    /// Initializes a new ring buffer with a given maximum capacity.
    ///
    /// - Parameter maxCapacity: The maximum number of elements the buffer can store. Defaults to 100.
    init(maxCapacity: Int = 100) {
        self.buffer = Array(repeating: nil, count: maxCapacity)
        self.bufferIndex = buffer.startIndex
        self.maxCapacity = maxCapacity
    }

    // MARK: - Instance Methods

    /// Adds a new element to the ring buffer.
    ///
    /// If the buffer is at capacity, the oldest element will be overwritten.
    ///
    /// - Parameter element: The element to add.
    /// - Returns: The inserted element, or `nil` if the buffer is empty.
    @discardableResult
    mutating func add(_ element: Element) -> Element? {
        guard !buffer.isEmpty else {
            return nil
        }

        if isFull {
            buffer.removeFirst()
            buffer.append(nil)
            bufferIndex -= 1
        }

        buffer[bufferIndex] = element
        bufferIndex += 1

        return element
    }

    /// Removes all elements from the buffer, resetting its state but keeping capacity.
    mutating func removeAll() {
        buffer = Array(repeating: nil, count: maxCapacity)
        bufferIndex = buffer.startIndex
    }

    /// Returns a compact snapshot of the buffer, removing `nil` entries.
    ///
    /// - Returns: An array of all currently stored (non-nil) elements.
    mutating func snapshot() -> [Element] {
        buffer.compactMap(\.self)
    }

    // MARK: - Sequence

    /// Returns an iterator over the non-nil elements in the buffer.
    func makeIterator() -> IndexingIterator<[Element]> {
        buffer
            .compactMap(\.self)
            .makeIterator()
    }
}

extension RingBuffer: Codable where Element: Codable {}
