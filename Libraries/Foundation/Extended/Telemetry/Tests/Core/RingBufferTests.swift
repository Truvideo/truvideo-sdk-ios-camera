//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Testing

@testable import Telemetry

struct RingBufferTests {
    // MARK: - Tests

    @Test
    func testThatInitAndIsEmpty() {
        // Given
        var buffer = RingBuffer<Int>(maxCapacity: 3)

        // When, Then
        #expect(buffer.count == 0)
        #expect(buffer.snapshot().isEmpty)
    }

    @Test
    func testThatAddAndSnapshot() {
        // Given
        var buffer = RingBuffer<String>(maxCapacity: 3)

        // When
        buffer.add("A")
        buffer.add("B")

        // Then
        #expect(buffer.snapshot() == ["A", "B"])
    }

    @Test
    func testThatAddAndShouldReturnNilIfThereIsNoCapacity() {
        // Given
        var buffer = RingBuffer<String>(maxCapacity: 0)

        // When, Then
        #expect(buffer.add("A") == nil)
        #expect(buffer.count == 0)
    }

    @Test
    func testThatBufferShouldDropFirstElementWhenFull() {
        // Given
        var buffer = RingBuffer<Int>(maxCapacity: 2)

        // When
        buffer.add(0)
        buffer.add(1)
        buffer.add(2)

        // Then
        #expect(buffer.isFull)
        #expect(buffer.snapshot() == [1, 2])
    }

    @Test
    func testThatRemoveAll() {
        // Given
        var buffer = RingBuffer<String>(maxCapacity: 2)

        // When
        buffer.add("A")
        buffer.add("B")

        buffer.removeAll()

        // Then
        #expect(buffer.snapshot().isEmpty)
    }

    @Test
    func testThatSubscript() {
        // Given
        var buffer = RingBuffer<Int>(maxCapacity: 2)

        // When
        buffer.add(10)
        buffer.add(20)

        // Then
        #expect(buffer[0] == 10)
        #expect(buffer[1] == 20)
        #expect(buffer[2] == nil, "Subscript out of bounds should return nil")
    }

    @Test
    func testThatRingBufferIsNotFullOnInit() {
        // Given, // When
        let buffer = RingBuffer<Int>(maxCapacity: 2)

        // Then
        #expect(!buffer.isFull)
    }

    @Test
    func testThatRingBufferShouldBeFull() {
        // Given
        var buffer = RingBuffer<Int>(maxCapacity: 2)

        // When
        buffer.add(1)
        buffer.add(2)

        // Then
        #expect(buffer.isFull)
        #expect(buffer.count == 2)
    }

    @Test
    func testThatSequenceConformance() {
        // Given
        var buffer = RingBuffer<String>(maxCapacity: 3)
        var collected: [String] = []

        // When
        buffer.add("A")
        buffer.add("B")
        buffer.add("C")

        for value in buffer {
            collected.append(value)
        }

        // Then
        #expect(collected == ["A", "B", "C"])
    }
}
