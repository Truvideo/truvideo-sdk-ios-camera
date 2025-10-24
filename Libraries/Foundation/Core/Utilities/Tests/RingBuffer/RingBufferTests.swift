//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Testing

@testable import Utilities

struct RingBufferTests {
    // MARK: - Tests

    @Test
    func testThatInitializationWithBufferingNewest() {
        // Given, When
        let buffer = RingBuffer<String>(bufferingPolicy: .bufferingNewest(5))

        // Then
        #expect(buffer.capacity == 5)
        #expect(buffer.count == 0)
        #expect(buffer.isEmpty)
        #expect(!buffer.isFull)
    }

    @Test
    func testThatInitializationWithBufferingOldest() {
        // Given, When
        let buffer = RingBuffer<String>(bufferingPolicy: .bufferingOldest(3))

        // Then
        #expect(buffer.capacity == 3)
        #expect(buffer.count == 0)
        #expect(buffer.isEmpty)
        #expect(!buffer.isFull)
    }

    @Test
    func testThatInitializationWithUnbounded() {
        // Given, When
        let buffer = RingBuffer<String>(bufferingPolicy: .unbounded)

        // Then
        #expect(buffer.capacity == 0)
        #expect(buffer.count == 0)
        #expect(buffer.isEmpty)
        #expect(!buffer.isFull)
    }

    @Test
    func testThatBufferingNewestAddsElements() {
        // Given
        var buffer = RingBuffer<String>(bufferingPolicy: .bufferingNewest(3))

        // When
        let result1 = buffer.add("A")
        let result2 = buffer.add("B")
        let result3 = buffer.add("C")

        // Then
        #expect(result1 == "A")
        #expect(result2 == "B")
        #expect(result3 == "C")
        #expect(buffer.count == 3)
        #expect(buffer.isFull)
        #expect(buffer[0] == "A")
        #expect(buffer[1] == "B")
        #expect(buffer[2] == "C")
    }

    @Test
    func testThatBufferingNewestEvictsOldestWhenFull() {
        // Given
        var buffer = RingBuffer<String>(bufferingPolicy: .bufferingNewest(2))

        // When
        buffer.add("A")
        buffer.add("B")

        let result = buffer.add("C")

        // Then
        #expect(result == "C")
        #expect(buffer.count == 2)
        #expect(buffer.isFull)
        #expect(buffer[0] == "B")
        #expect(buffer[1] == "C")
    }

    @Test
    func testThatBufferingNewestEvictsMultipleOldestElements() {
        // Given
        var buffer = RingBuffer<String>(bufferingPolicy: .bufferingNewest(2))

        // When
        buffer.add("A")
        buffer.add("B")
        buffer.add("C")
        buffer.add("D")
        buffer.add("E")

        // Then
        #expect(buffer.count == 2)
        #expect(buffer.isFull)
        #expect(buffer[0] == "D")
        #expect(buffer[1] == "E")
    }

    @Test
    func testThatBufferingOldestAddsElements() {
        // Given
        var buffer = RingBuffer<String>(bufferingPolicy: .bufferingOldest(3))

        // When
        let result1 = buffer.add("A")
        let result2 = buffer.add("B")
        let result3 = buffer.add("C")

        // Then
        #expect(result1 == "A")
        #expect(result2 == "B")
        #expect(result3 == "C")
        #expect(buffer.count == 3)
        #expect(buffer.isFull)
        #expect(buffer[0] == "A")
        #expect(buffer[1] == "B")
        #expect(buffer[2] == "C")
    }

    @Test
    func testThatBufferingOldestRejectsNewElementsWhenFull() {
        // Given
        var buffer = RingBuffer<String>(bufferingPolicy: .bufferingOldest(2))

        // When
        buffer.add("A")
        buffer.add("B")
        let result = buffer.add("C")

        // Then
        #expect(result == nil)
        #expect(buffer.count == 2)
        #expect(buffer.isFull)
        #expect(buffer[0] == "A")
        #expect(buffer[1] == "B")
    }

    @Test
    func testThatBufferingOldestPreservesOriginalElements() {
        // Given
        var buffer = RingBuffer<String>(bufferingPolicy: .bufferingOldest(2))

        // When
        buffer.add("A")
        buffer.add("B")
        buffer.add("C")
        buffer.add("D")
        buffer.add("E")

        // Then
        #expect(buffer.count == 2)
        #expect(buffer.isFull)
        #expect(buffer[0] == "A")
        #expect(buffer[1] == "B")
    }

    @Test
    func testThatUnboundedGrowsInitially() {
        // Given
        var buffer = RingBuffer<String>(bufferingPolicy: .unbounded)

        // When
        let result = buffer.add("A")

        // Then
        #expect(result == "A")
        #expect(buffer.count == 1)
        #expect(buffer.capacity == 8)
        #expect(buffer[0] == "A")
    }

    @Test
    func testThatUnboundedGrowsWhenNeeded() {
        // Given
        var buffer = RingBuffer<String>(bufferingPolicy: .unbounded)

        // When
        for i in 0 ..< 9 {
            buffer.add("\(i)")
        }

        // Then
        #expect(buffer.count == 9)
        #expect(buffer.capacity == 16)
        #expect(buffer[0] == "0")
        #expect(buffer[8] == "8")
    }

    @Test
    func testThatUnboundedNeverBecomesFull() {
        // Given
        var buffer = RingBuffer<String>(bufferingPolicy: .unbounded)

        // When
        for i in 0 ..< 100 {
            buffer.add("\(i)")
        }

        // Then
        #expect(buffer.count == 100)
        #expect(!buffer.isFull)
    }

    // MARK: - Computed Properties Tests

    @Test
    func testThatCapacityProperty() {
        // Given
        let boundedBuffer = RingBuffer<String>(bufferingPolicy: .bufferingNewest(5))
        var unboundedBuffer = RingBuffer<String>(bufferingPolicy: .unbounded)

        // When
        unboundedBuffer.add("A")

        // Then
        #expect(boundedBuffer.capacity == 5)
        #expect(unboundedBuffer.capacity == 8)
    }

    @Test
    func testThatCountProperty() {
        // Given
        var buffer = RingBuffer<String>(bufferingPolicy: .bufferingNewest(3))

        // When
        buffer.add("A")
        buffer.add("B")

        // Then
        #expect(buffer.count == 2)
    }

    @Test
    func testThatIsEmptyProperty() {
        // Given
        var buffer = RingBuffer<String>(bufferingPolicy: .bufferingNewest(3))

        // When, Then
        #expect(buffer.isEmpty)

        buffer.add("A")
        #expect(!buffer.isEmpty)

        buffer.removeFirst()
        #expect(buffer.isEmpty)
    }

    @Test
    func testThatIsFullProperty() {
        // Given
        var boundedBuffer = RingBuffer<String>(bufferingPolicy: .bufferingNewest(2))
        var unboundedBuffer = RingBuffer<String>(bufferingPolicy: .unbounded)

        // When
        boundedBuffer.add("A")
        boundedBuffer.add("B")

        unboundedBuffer.add("A")
        unboundedBuffer.add("B")

        // Then
        #expect(boundedBuffer.isFull)
        #expect(!unboundedBuffer.isFull)
    }

    // MARK: - Subscript Tests

    @Test
    func testThatSubscriptAccess() {
        // Given
        var buffer = RingBuffer<String>(bufferingPolicy: .bufferingNewest(3))

        // When
        buffer.add("A")
        buffer.add("B")
        buffer.add("C")

        // Then
        #expect(buffer[0] == "A")
        #expect(buffer[1] == "B")
        #expect(buffer[2] == "C")
    }

    @Test
    func testThatSubscriptWithCircularBuffer() {
        // Given
        var buffer = RingBuffer<String>(bufferingPolicy: .bufferingNewest(3))

        // When
        buffer.add("A")
        buffer.add("B")
        buffer.add("C")
        buffer.add("D") // Evicts "A"

        // Then
        #expect(buffer[0] == "B")
        #expect(buffer[1] == "C")
        #expect(buffer[2] == "D")
    }

    @Test
    func testThatRemoveFirst() {
        // Given
        var buffer = RingBuffer<String>(bufferingPolicy: .bufferingNewest(3))

        // When
        buffer.add("A")
        buffer.add("B")
        buffer.add("C")

        let first = buffer.removeFirst()
        let second = buffer.removeFirst()
        let third = buffer.removeFirst()
        let empty = buffer.removeFirst()

        // Then
        #expect(first == "A")
        #expect(second == "B")
        #expect(third == "C")
        #expect(empty == nil)
        #expect(buffer.isEmpty)
    }

    @Test
    func testThatRemoveLast() {
        // Given
        var buffer = RingBuffer<String>(bufferingPolicy: .bufferingNewest(3))

        // When
        buffer.add("A")
        buffer.add("B")
        buffer.add("C")

        let last = buffer.removeLast()
        let second = buffer.removeLast()
        let third = buffer.removeLast()
        let empty = buffer.removeLast()

        // Then
        #expect(last == "C")
        #expect(second == "B")
        #expect(third == "A")
        #expect(empty == nil)
        #expect(buffer.isEmpty)
    }

    @Test
    func testThatRemoveAllKeepingCapacity() {
        // Given
        var buffer = RingBuffer<String>(bufferingPolicy: .bufferingNewest(5))

        // When
        buffer.add("A")
        buffer.add("B")
        buffer.add("C")
        buffer.removeAll(keepingCapacity: true)

        // Then
        #expect(buffer.isEmpty)
        #expect(buffer.capacity == 5)
    }

    @Test
    func testThatRemoveAllNotKeepingCapacity() {
        // Given
        var buffer = RingBuffer<String>(bufferingPolicy: .bufferingNewest(5))

        // When
        buffer.add("A")
        buffer.add("B")
        buffer.add("C")
        buffer.removeAll(keepingCapacity: false)

        // Then
        #expect(buffer.isEmpty)
        #expect(buffer.capacity == 5)
    }

    @Test
    func testThatRemoveAllWithUnbounded() {
        // Given
        var buffer = RingBuffer<String>(bufferingPolicy: .unbounded)

        // When
        buffer.add("A")
        buffer.add("B")
        buffer.add("C")

        buffer.removeAll()

        // Then
        #expect(buffer.isEmpty)
        #expect(buffer.capacity == 8)
    }

    @Test
    func testThatSequenceConformance() {
        // Given
        var buffer = RingBuffer<String>(bufferingPolicy: .bufferingNewest(3))
        var collected: [String] = []

        // When
        buffer.add("A")
        buffer.add("B")
        buffer.add("C")

        for element in buffer {
            collected.append(element)
        }

        // Then
        #expect(collected == ["A", "B", "C"])
    }

    @Test
    func testThatSequenceWithCircularBuffer() {
        // Given
        var buffer = RingBuffer<String>(bufferingPolicy: .bufferingNewest(2))
        var collected: [String] = []

        // When
        buffer.add("A")
        buffer.add("B")
        buffer.add("C")

        for element in buffer {
            collected.append(element)
        }

        // Then
        #expect(collected == ["B", "C"])
    }

    @Test
    func testThatSequenceWithEmptyBuffer() {
        // Given
        let buffer = RingBuffer<String>(bufferingPolicy: .bufferingNewest(3))
        var collected: [String] = []

        // When
        for element in buffer {
            collected.append(element)
        }

        // Then
        #expect(collected.isEmpty)
    }

    // MARK: - Edge Cases Tests

    @Test
    func testThatSingleElementBuffer() {
        // Given
        var buffer = RingBuffer<String>(bufferingPolicy: .bufferingNewest(1))

        // When
        buffer.add("A")
        let result = buffer.add("B")

        // Then
        #expect(result == "B")
        #expect(buffer.count == 1)
        #expect(buffer[0] == "B")
    }

    @Test
    func testThatSingleElementBufferingOldest() {
        // Given
        var buffer = RingBuffer<String>(bufferingPolicy: .bufferingOldest(1))

        // When
        buffer.add("A")
        let result = buffer.add("B")

        // Then
        #expect(result == nil)
        #expect(buffer.count == 1)
        #expect(buffer[0] == "A")
    }

    @Test
    func testThatEmptyBufferOperations() {
        // Given
        var buffer = RingBuffer<String>(bufferingPolicy: .bufferingNewest(3))

        // When
        let first = buffer.removeFirst()
        let last = buffer.removeLast()

        // Then
        #expect(first == nil)
        #expect(last == nil)
        #expect(buffer.isEmpty)
    }

    @Test
    func testThatUnboundedEmptyBufferOperations() {
        // Given
        var buffer = RingBuffer<String>(bufferingPolicy: .unbounded)

        // When
        let first = buffer.removeFirst()
        let last = buffer.removeLast()

        // Then
        #expect(first == nil)
        #expect(last == nil)
        #expect(buffer.isEmpty)
    }

    @Test
    func testThatLargeCapacityBuffer() {
        // Given
        var buffer = RingBuffer<Int>(bufferingPolicy: .bufferingNewest(1000))

        // When
        for i in 0 ..< 1000 {
            buffer.add(i)
        }

        // Then
        #expect(buffer.count == 1000)
        #expect(buffer.isFull)
        #expect(buffer[0] == 0)
        #expect(buffer[999] == 999)
    }

    @Test
    func testThatMixedOperations() {
        // Given
        var buffer = RingBuffer<String>(bufferingPolicy: .bufferingNewest(4))

        // When
        buffer.add("A")
        buffer.add("B")
        buffer.add("C")
        buffer.add("D")

        let first = buffer.removeFirst()
        buffer.add("E")

        let last = buffer.removeLast()
        buffer.add("F")

        // Then
        #expect(first == "A")
        #expect(last == "E")
        #expect(buffer.count == 4)
        #expect(buffer[0] == "B")
        #expect(buffer[1] == "C")
        #expect(buffer[2] == "D")
        #expect(buffer[3] == "F")
    }

    @Test
    func testThatAddPerformance() {
        // Given
        var buffer = RingBuffer<Int>(bufferingPolicy: .bufferingNewest(100))

        // When, Then
        let startTime = Date()
        for i in 0 ..< 1000 {
            buffer.add(i)
        }
        let endTime = Date()

        #expect(endTime.timeIntervalSince(startTime) < 0.1)
        #expect(buffer.count == 100)
    }

    @Test
    func testThatRemovePerformance() {
        // Given
        var buffer = RingBuffer<Int>(bufferingPolicy: .bufferingNewest(100))

        // When
        for i in 0 ..< 100 {
            buffer.add(i)
        }

        let startTime = Date()
        for _ in 0 ..< 100 {
            buffer.removeFirst()
        }
        
        let endTime = Date()

        // Then
        #expect(endTime.timeIntervalSince(startTime) < 0.1)
        #expect(buffer.isEmpty)
    }

    @Test
    func testThatGenericTypeSupport() {
        // Given
        var intBuffer = RingBuffer<Int>(bufferingPolicy: .bufferingNewest(3))
        var stringBuffer = RingBuffer<String>(bufferingPolicy: .bufferingNewest(3))
        var doubleBuffer = RingBuffer<Double>(bufferingPolicy: .bufferingNewest(3))

        // When
        intBuffer.add(42)
        stringBuffer.add("Hello")
        doubleBuffer.add(3.14)

        // Then
        #expect(intBuffer[0] == 42)
        #expect(stringBuffer[0] == "Hello")
        #expect(doubleBuffer[0] == 3.14)
    }

    @Test
    func testThatOptionalTypeSupport() {
        // Given
        var buffer = RingBuffer<Int?>(bufferingPolicy: .bufferingNewest(3))

        // When
        buffer.add(42)
        buffer.add(nil)
        buffer.add(84)

        // Then
        #expect(buffer[0] == 42)
        #expect(buffer[1] == nil)
        #expect(buffer[2] == 84)
    }

    @Test
    func testThatCircularBufferWrapping() {
        // Given
        var buffer = RingBuffer<String>(bufferingPolicy: .bufferingNewest(3))

        // When
        buffer.add("A")
        buffer.add("B")
        buffer.add("C")
        buffer.add("D")
        buffer.add("E")

        // Then
        #expect(buffer.count == 3)
        #expect(buffer[0] == "C")
        #expect(buffer[1] == "D")
        #expect(buffer[2] == "E")
    }

    @Test
    func testThatUnboundedGrowthPattern() {
        // Given
        var buffer = RingBuffer<Int>(bufferingPolicy: .unbounded)

        // When
        for i in 0 ..< 9 {
            buffer.add(i)
        }

        // Then
        #expect(buffer.capacity == 16)
        #expect(buffer.count == 9)

        // When
        for i in 9 ..< 17 {
            buffer.add(i)
        }

        // Then
        #expect(buffer.capacity == 32)
        #expect(buffer.count == 17)
    }

    @Test
    func testThatBufferingOldestWithRemovals() {
        // Given
        var buffer = RingBuffer<String>(bufferingPolicy: .bufferingOldest(3))

        // When
        buffer.add("A")
        buffer.add("B")
        buffer.add("C")
        buffer.removeFirst()

        let result = buffer.add("D")

        // Then
        #expect(result == "D")
        #expect(buffer.count == 3)
        #expect(buffer[0] == "B")
        #expect(buffer[1] == "C")
        #expect(buffer[2] == "D")
    }
}
