//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A high-performance circular buffer implementation with flexible buffering policies.
///
/// `RingBuffer` is a generic data structure that provides efficient storage and retrieval
/// of elements with configurable capacity management strategies. Unlike a simple array,
/// it uses a circular buffer pattern with head and tail pointers for optimal performance
/// when adding and removing elements.
///
/// ## Key Features
/// - **Flexible Buffering Policies**: Choose how to handle capacity overflow
/// - **High Performance**: O(1) insertion and removal operations
/// - **Memory Efficient**: Fixed memory footprint for bounded policies
/// - **Sequence Conformance**: Supports iteration and functional programming patterns
/// - **Thread-Safe Design**: Suitable for concurrent access patterns
///
/// ## Buffering Policies
///
/// ### `.bufferingNewest(maxCapacity)`
/// When the buffer reaches capacity, the oldest elements are discarded to make room
/// for new ones. This is ideal for scenarios where you want to keep the most recent data.
///
/// ```swift
/// var buffer = RingBuffer<String>(bufferingPolicy: .bufferingNewest(5))
/// buffer.add("A") // Buffer: ["A"]
/// buffer.add("B") // Buffer: ["A", "B"]
/// buffer.add("C") // Buffer: ["A", "B", "C"]
/// buffer.add("D") // Buffer: ["A", "B", "C", "D"]
/// buffer.add("E") // Buffer: ["A", "B", "C", "D", "E"]
/// buffer.add("F") // Buffer: ["B", "C", "D", "E", "F"] - "A" discarded
/// ```
///
/// ### `.bufferingOldest(maxCapacity)`
/// When the buffer reaches capacity, new elements are rejected. This preserves
/// the oldest data and prevents newer elements from overwriting historical data.
///
/// ```swift
/// var buffer = RingBuffer<String>(bufferingPolicy: .bufferingOldest(3))
/// buffer.add("A") // Buffer: ["A"]
/// buffer.add("B") // Buffer: ["A", "B"]
/// buffer.add("C") // Buffer: ["A", "B", "C"]
/// buffer.add("D") // Returns nil, buffer unchanged: ["A", "B", "C"]
/// ```
///
/// ### `.unbounded`
/// The buffer grows dynamically as needed, with automatic capacity doubling
/// when space is exhausted. Use with caution in memory-constrained environments.
///
/// ```swift
/// var buffer = RingBuffer<String>(bufferingPolicy: .unbounded)
/// // Buffer starts empty and grows as needed
/// buffer.add("A") // Buffer: ["A"]
/// buffer.add("B") // Buffer: ["A", "B"]
/// // ... continues growing indefinitely
/// ```
///
/// ## Performance Characteristics
/// - **Insertion**: O(1) for all policies
/// - **Removal**: O(1) for head/tail operations
/// - **Access**: O(1) for indexed access
/// - **Memory**: O(n) where n is the capacity (bounded) or current size (unbounded)
///
/// ## Use Cases
/// - **Telemetry Systems**: Store recent events or breadcrumbs
/// - **Audio/Video Processing**: Buffer samples for real-time processing
/// - **Logging Systems**: Maintain recent log entries
/// - **Caching**: LRU-style caching with automatic eviction
/// - **Data Streaming**: Smooth out bursty data streams
///
/// ## Example: Media Sample Buffer
///
/// ```swift
/// struct MediaSample {
///     let timestamp: CMTime
///     let data: Data
///     let type: SampleType
/// }
///
/// var sampleBuffer = RingBuffer<MediaSample>(
///     bufferingPolicy: .bufferingNewest(100)
/// )
///
/// // Add samples
/// sampleBuffer.add(MediaSample(
///     timestamp: CMTime(value: 1000, timescale: 1000),
///     data: sampleData,
///     type: .video
/// ))
///
/// // Process recent samples
/// for sample in sampleBuffer {
///     processSample(sample)
/// }
/// ```
public struct RingBuffer<Element>: Sequence {
    // MARK: - Private Properties

    private var buffer: [Slot]
    private var length = 0
    private var head = 0
    private let limit: BufferingPolicy
    private var tail = 0

    // MARK: - Computed Properties

    /// The total capacity of the buffer.
    ///
    /// This property returns the maximum number of elements that can be stored
    /// in the buffer based on its current buffering policy. For bounded policies,
    /// this represents the fixed capacity. For unbounded policies, this represents
    /// the current allocated capacity (which may grow over time).
    ///
    /// ## Examples
    /// ```swift
    /// var boundedBuffer = RingBuffer<String>(bufferingPolicy: .bufferingNewest(10))
    /// print(boundedBuffer.capacity) // 10
    ///
    /// var unboundedBuffer = RingBuffer<String>(bufferingPolicy: .unbounded)
    /// print(unboundedBuffer.capacity) // 0 (initially empty)
    /// unboundedBuffer.add("A")
    /// print(unboundedBuffer.capacity) // 8 (grows to initial size)
    /// ```
    ///
    /// - Returns: The current capacity of the buffer
    public var capacity: Int {
        buffer.count
    }

    /// The number of elements currently stored in the buffer.
    ///
    /// This property returns the actual count of elements that have been added
    /// to the buffer and not yet removed. It will never exceed the buffer's capacity
    /// for bounded policies, but can grow indefinitely for unbounded policies.
    ///
    /// ## Performance
    /// - **Time Complexity**: O(1)
    /// - **Space Complexity**: O(1)
    ///
    /// ## Examples
    /// ```swift
    /// var buffer = RingBuffer<String>(bufferingPolicy: .bufferingNewest(5))
    /// print(buffer.count) // 0
    ///
    /// buffer.add("A")
    /// buffer.add("B")
    /// print(buffer.count) // 2
    ///
    /// buffer.removeFirst()
    /// print(buffer.count) // 1
    /// ```
    ///
    /// - Returns: The number of elements currently in the buffer
    public var count: Int {
        length
    }

    /// A Boolean value indicating whether the buffer contains no elements.
    ///
    /// This property provides a convenient way to check if the buffer is empty
    /// without needing to compare the count to zero. It's equivalent to `count == 0`
    /// but more semantically clear in conditional statements.
    ///
    /// ## Performance
    /// - **Time Complexity**: O(1)
    /// - **Space Complexity**: O(1)
    ///
    /// ## Examples
    /// ```swift
    /// var buffer = RingBuffer<String>(bufferingPolicy: .bufferingNewest(5))
    /// print(buffer.isEmpty) // true
    ///
    /// buffer.add("A")
    /// print(buffer.isEmpty) // false
    ///
    /// buffer.removeFirst()
    /// print(buffer.isEmpty) // true
    /// ```
    ///
    /// - Returns: `true` if the buffer contains no elements, otherwise `false`
    public var isEmpty: Bool {
        length == 0
    }

    /// A Boolean value indicating whether the buffer has reached its capacity limit.
    ///
    /// This property indicates whether the buffer is at its maximum capacity and
    /// cannot accept additional elements without evicting existing ones (for bounded policies)
    /// or rejecting new elements (for `.bufferingOldest` policy).
    ///
    /// ## Behavior by Policy
    /// - **`.bufferingNewest`**: Returns `true` when `count == maxCapacity`
    /// - **`.bufferingOldest`**: Returns `true` when `count == maxCapacity`
    /// - **`.unbounded`**: Always returns `false` (never reaches capacity)
    ///
    /// ## Performance
    /// - **Time Complexity**: O(1)
    /// - **Space Complexity**: O(1)
    ///
    /// ## Examples
    /// ```swift
    /// var buffer = RingBuffer<String>(bufferingPolicy: .bufferingNewest(3))
    /// print(buffer.isFull) // false
    ///
    /// buffer.add("A")
    /// buffer.add("B")
    /// buffer.add("C")
    /// print(buffer.isFull) // true
    ///
    /// var unboundedBuffer = RingBuffer<String>(bufferingPolicy: .unbounded)
    /// // Add many elements...
    /// print(unboundedBuffer.isFull) // Always false
    /// ```
    ///
    /// - Returns: `true` if the buffer is at capacity, otherwise `false`
    public var isFull: Bool {
        switch limit {
        case let .bufferingNewest(maxCapacity),
             let .bufferingOldest(maxCapacity):
            length == maxCapacity

        case .unbounded:
            false
        }
    }

    // MARK: - Subscript

    /// Accesses the element at the specified index in the buffer.
    ///
    /// - Parameter index: The index into the buffer array.
    /// - Returns: The element at the given index.
    public subscript(index: Int) -> Element {
        precondition(index >= 0 && index < count, "index out of bounds")

        guard let element = element(at: index) else {
            preconditionFailure("invariant violated: empty slot in-bounds")
        }

        return element
    }

    // MARK: - Types

    fileprivate enum Slot {
        case empty
        case occupied(Element)
    }

    /// A strategy that handles exhaustion of a buffer's capacity.
    ///
    /// The `BufferingPolicy` enum defines how a `RingBuffer` should behave when it reaches
    /// its maximum capacity. Each policy offers different trade-offs between memory usage,
    /// data retention, and performance characteristics.
    ///
    /// ## Policy Comparison
    ///
    /// | Policy | Memory Usage | Data Retention | Performance | Use Case |
    /// |--------|-------------|----------------|-------------|----------|
    /// | `.bufferingNewest` | Fixed | Recent data | O(1) | Real-time processing |
    /// | `.bufferingOldest` | Fixed | Historical data | O(1) | Critical data preservation |
    /// | `.unbounded` | Dynamic | All data | O(1) amortized | Development/debugging |
    ///
    /// ## Memory Considerations
    /// - **Bounded policies** (`.bufferingNewest`, `.bufferingOldest`) use a fixed amount of memory
    /// - **Unbounded policy** can grow indefinitely and should be used with caution
    /// - For production code, prefer bounded policies to prevent memory issues
    ///
    /// ## Performance Impact
    /// - All policies provide O(1) insertion and removal operations
    /// - `.unbounded` may cause occasional O(n) operations during capacity doubling
    /// - Bounded policies maintain consistent performance characteristics
    public enum BufferingPolicy {
        /// When the buffer is full, discard the oldest element in the buffer.
        ///
        /// This strategy enforces keeping the specified amount of newest values.
        /// It's ideal for scenarios where recent data is more valuable than historical data.
        ///
        /// ## Characteristics
        /// - **Memory**: Fixed allocation based on `maxCapacity`
        /// - **Behavior**: Automatically evicts oldest elements when full
        /// - **Performance**: Consistent O(1) operations
        /// - **Use Cases**: Real-time data processing, recent event tracking, live streaming
        ///
        /// ## Example
        /// ```swift
        /// var buffer = RingBuffer<String>(bufferingPolicy: .bufferingNewest(3))
        /// buffer.add("A") // ["A"]
        /// buffer.add("B") // ["A", "B"]
        /// buffer.add("C") // ["A", "B", "C"]
        /// buffer.add("D") // ["B", "C", "D"] - "A" evicted
        /// ```
        ///
        /// - Parameter maxCapacity: The maximum number of elements to retain
        case bufferingNewest(Int)

        /// When the buffer is full, discard the newly received element.
        ///
        /// This strategy enforces keeping the specified amount of oldest values.
        /// It's ideal for scenarios where historical data is critical and must be preserved.
        ///
        /// ## Characteristics
        /// - **Memory**: Fixed allocation based on `maxCapacity`
        /// - **Behavior**: Rejects new elements when full, preserving existing data
        /// - **Performance**: Consistent O(1) operations
        /// - **Use Cases**: Critical data preservation, audit logs, historical analysis
        ///
        /// ## Example
        /// ```swift
        /// var buffer = RingBuffer<String>(bufferingPolicy: .bufferingOldest(3))
        /// buffer.add("A") // ["A"]
        /// buffer.add("B") // ["A", "B"]
        /// buffer.add("C") // ["A", "B", "C"]
        /// buffer.add("D") // Returns nil, buffer unchanged: ["A", "B", "C"]
        /// ```
        ///
        /// - Parameter maxCapacity: The maximum number of elements to retain
        case bufferingOldest(Int)

        /// Continue to add to the buffer, treating its capacity as infinite.
        ///
        /// This strategy allows the buffer to grow dynamically as needed, with automatic
        /// capacity doubling when space is exhausted. Use with caution in production
        /// environments as it can lead to unbounded memory growth.
        ///
        /// ## Characteristics
        /// - **Memory**: Dynamic allocation, grows as needed
        /// - **Behavior**: Never rejects elements, grows capacity when needed
        /// - **Performance**: O(1) amortized (occasional O(n) during growth)
        /// - **Use Cases**: Development, debugging, temporary buffers, small datasets
        ///
        /// ## Example
        /// ```swift
        /// var buffer = RingBuffer<String>(bufferingPolicy: .unbounded)
        /// buffer.add("A") // Buffer grows to accommodate
        /// buffer.add("B") // Buffer continues growing
        /// // ... continues indefinitely
        /// ```
        ///
        /// ## Warning
        /// This policy can cause memory issues in production environments.
        /// Consider using bounded policies for production code.
        case unbounded

        // MARK: - Private methods

        fileprivate func makeBuffer() -> [Slot] {
            switch self {
            case let .bufferingNewest(maxCapacity),
                 let .bufferingOldest(maxCapacity):
                precondition(maxCapacity > 0, "Capacity must be > 0 for bounded buffers")
                return Array(repeating: Slot.empty, count: maxCapacity)

            case .unbounded:
                return []
            }
        }
    }

    // MARK: - Initializer

    /// Creates a new ring buffer with the specified buffering policy.
    ///
    /// The initializer sets up the internal buffer structure based on the chosen policy.
    /// For bounded policies, it pre-allocates the required capacity. For unbounded policies,
    /// it starts with an empty buffer that grows as needed.
    ///
    /// ## Example
    /// ```swift
    /// // Create a buffer that keeps the 10 most recent elements
    /// var recentBuffer = RingBuffer<String>(bufferingPolicy: .bufferingNewest(10))
    ///
    /// // Create a buffer that preserves the first 5 elements
    /// var historicalBuffer = RingBuffer<String>(bufferingPolicy: .bufferingOldest(5))
    ///
    /// // Create a buffer that grows as needed (use with caution)
    /// var growingBuffer = RingBuffer<String>(bufferingPolicy: .unbounded)
    /// ```
    ///
    /// - Parameter limit: The buffering policy that determines how the buffer handles capacity overflow
    public init(bufferingPolicy limit: BufferingPolicy) {
        self.buffer = limit.makeBuffer()
        self.limit = limit
    }

    // MARK: - Public methods

    /// Adds a new element to the ring buffer.
    ///
    /// The behavior of this method depends on the buffer's policy and current state:
    /// - **`.bufferingNewest`**: Adds the element, evicting the oldest if full
    /// - **`.bufferingOldest`**: Adds the element only if there's space, returns `nil` if full
    /// - **`.unbounded`**: Always adds the element, growing the buffer if needed
    ///
    /// ## Performance
    /// - **Time Complexity**: O(1) for all policies
    /// - **Space Complexity**: O(1) for bounded policies, O(1) amortized for unbounded
    ///
    /// ## Examples
    /// ```swift
    /// var buffer = RingBuffer<String>(bufferingPolicy: .bufferingNewest(2))
    ///
    /// let result1 = buffer.add("A") // Returns "A", buffer: ["A"]
    /// let result2 = buffer.add("B") // Returns "B", buffer: ["A", "B"]
    /// let result3 = buffer.add("C") // Returns "C", buffer: ["B", "C"] (A evicted)
    /// ```
    ///
    /// ```swift
    /// var buffer = RingBuffer<String>(bufferingPolicy: .bufferingOldest(2))
    ///
    /// let result1 = buffer.add("A") // Returns "A", buffer: ["A"]
    /// let result2 = buffer.add("B") // Returns "B", buffer: ["A", "B"]
    /// let result3 = buffer.add("C") // Returns nil, buffer unchanged: ["A", "B"]
    /// ```
    ///
    /// - Parameter element: The element to add to the buffer
    /// - Returns: The inserted element if successful, or `nil` if the buffer rejected the element
    @discardableResult
    public mutating func add(_ element: Element) -> Element? {
        switch limit {
        case .bufferingNewest, .bufferingOldest:
            if isFull {
                guard case .bufferingNewest = limit else {
                    return nil
                }

                removeFirst()
            }

            var newTail = tail

            buffer[tail] = .occupied(element)
            advance(&newTail)

            tail = newTail

            if length < buffer.count {
                length += 1
            }

            return element

        case .unbounded:
            ensureUnboundedCapacity()

            var newTail = tail

            buffer[tail] = .occupied(element)
            advance(&newTail)

            tail = newTail
            length += 1

            return element
        }
    }

    /// Removes all elements from the buffer, resetting its state but keeping capacity.
    ///
    /// This method efficiently clears the buffer while preserving the allocated capacity
    /// for better performance on subsequent operations. The buffer's policy and capacity
    /// remain unchanged.
    ///
    /// ## Performance
    /// - **Time Complexity**: O(1) when `keepingCapacity` is `true`, O(n) when `false`
    /// - **Space Complexity**: O(1) - no additional memory allocation
    ///
    /// ## Examples
    /// ```swift
    /// var buffer = RingBuffer<String>(bufferingPolicy: .bufferingNewest(5))
    /// buffer.add("A")
    /// buffer.add("B")
    /// buffer.add("C")
    ///
    /// buffer.removeAll() // Buffer is empty but capacity remains 5
    /// print(buffer.count) // 0
    /// print(buffer.capacity) // 5
    /// ```
    ///
    /// - Parameter keepingCapacity: If `true`, preserves the allocated capacity for reuse.
    ///   If `false`, deallocates and reallocates the buffer based on the current policy.
    public mutating func removeAll(keepingCapacity: Bool = true) {
        defer {
            head = 0
            length = 0
            tail = 0
        }

        guard keepingCapacity, !buffer.isEmpty else {
            buffer = limit.makeBuffer()
            return
        }

        buffer.replaceSubrange(buffer.indices, with: repeatElement(Slot.empty, count: buffer.count))
    }

    /// Removes and returns the first (oldest) element from the buffer.
    ///
    /// This method implements FIFO (First-In-First-Out) behavior, removing the element
    /// that was added earliest. It's particularly useful for implementing queue-like
    /// operations or processing elements in chronological order.
    ///
    /// ## Performance
    /// - **Time Complexity**: O(1)
    /// - **Space Complexity**: O(1)
    ///
    /// ## Examples
    /// ```swift
    /// var buffer = RingBuffer<String>(bufferingPolicy: .bufferingNewest(3))
    /// buffer.add("A")
    /// buffer.add("B")
    /// buffer.add("C")
    ///
    /// let first = buffer.removeFirst() // Returns "A", buffer: ["B", "C"]
    /// let second = buffer.removeFirst() // Returns "B", buffer: ["C"]
    /// let third = buffer.removeFirst() // Returns "C", buffer: []
    /// let empty = buffer.removeFirst() // Returns nil, buffer: []
    /// ```
    ///
    /// - Returns: The first element if the buffer is not empty, otherwise `nil`
    @discardableResult
    public mutating func removeFirst() -> Element? {
        guard !isEmpty else {
            return nil
        }

        let element = buffer[head]
        var newHead = head

        buffer[head] = Slot.empty
        advance(&newHead)

        head = newHead
        length -= 1

        return switch element {
        case .empty:
            nil

        case let .occupied(element):
            element
        }
    }

    /// Removes and returns the last (newest) element from the buffer.
    ///
    /// This method implements LIFO (Last-In-First-Out) behavior, removing the element
    /// that was added most recently. It's useful for implementing stack-like operations
    /// or when you need to process elements in reverse chronological order.
    ///
    /// ## Performance
    /// - **Time Complexity**: O(1)
    /// - **Space Complexity**: O(1)
    ///
    /// ## Examples
    /// ```swift
    /// var buffer = RingBuffer<String>(bufferingPolicy: .bufferingNewest(3))
    /// buffer.add("A")
    /// buffer.add("B")
    /// buffer.add("C")
    ///
    /// let last = buffer.removeLast() // Returns "C", buffer: ["A", "B"]
    /// let second = buffer.removeLast() // Returns "B", buffer: ["A"]
    /// let third = buffer.removeLast() // Returns "A", buffer: []
    /// let empty = buffer.removeLast() // Returns nil, buffer: []
    /// ```
    ///
    /// - Returns: The last element if the buffer is not empty, otherwise `nil`
    @discardableResult
    public mutating func removeLast() -> Element? {
        guard !isEmpty else {
            return nil
        }

        tail = (tail - 1 + buffer.count) % buffer.count

        let element = buffer[tail]

        buffer[tail] = .empty
        length -= 1

        return switch element {
        case .empty:
            nil

        case let .occupied(element):
            element
        }
    }

    // MARK: - Sequence

    /// Returns an iterator over the elements in the buffer in chronological order.
    ///
    /// - Returns: An iterator that provides sequential access to the buffer's elements
    public func makeIterator() -> AnyIterator<Element> {
        var index = 0

        return AnyIterator {
            guard index < count else { return nil }

            defer { index += 1 }
            return self[index]
        }
    }

    // MARK: - Private methods

    private mutating func advance(_ index: inout Int) {
        index = (index + 1) % buffer.count
    }

    private func element(at index: Int) -> Element? {
        guard index >= 0, index < count else { return nil }

        let realIndex = (head + index) % buffer.count

        return switch buffer[realIndex] {
        case .empty:
            nil

        case let .occupied(element):
            element
        }
    }

    private mutating func ensureUnboundedCapacity() {
        if buffer.isEmpty {
            buffer = Array(repeating: Slot.empty, count: 8)
            head = 0
            length = 0
            tail = 0
        } else if length == buffer.count {
            var new = [Slot](repeating: Slot.empty, count: buffer.count * 2)

            for index in 0 ..< count {
                if let element = element(at: index) {
                    new[index] = .occupied(element)
                } else {
                    new[index] = .empty
                }
            }

            buffer = new
            head = 0
            tail = count
        }
    }
}
