//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

protocol BufferStorage {
    func flush() throws
    func readAll() throws -> [Breadcrumb]
    func write(_ breadcrumb: Breadcrumb)
}

struct FileSystemBufferStorage: BufferStorage {
    // MARK: - Private Properties
    
    private let fileHandle: FileHandle
    private let fileManager: FileManager
    private let storageURL: URL
    
    // MARK: - Initializer
    
    init(fileManager: FileManager = .default) throws {
        let storageURL = fileManager
            .telemetryDirectory
            .appendingPathComponent("breadcrumbs.dat")
        
        self.fileManager = fileManager
        self.fileHandle = try FileHandle(forWritingTo: storageURL)
        self.storageURL = storageURL
    }
    
    // MARK: - BufferStorage
    
    func flush() throws {
        do {
            try fileHandle.close()
            try fileManager.removeItem(at: storageURL)
        } catch {
            // LOG error internally
        }
    }
    
    func readAll() throws -> [Breadcrumb] {
        []
    }
    
    func write(_ breadcrumb: Breadcrumb) {
        do {
            let fileSize = try fileHandle.seekToEnd()
            let data = try JSONEncoder().encode(breadcrumb)
            
            try fileHandle.write(contentsOf: data)
            
            if let breakLine = "\n".data(using: .utf8) {
                try fileHandle.write(contentsOf: breakLine)
            }
        } catch {
            // LOG error internally
        }
    }
}

struct BreadcrumbBuffer: Sequence, Codable {
    // MARK: - Private Properties
    
    private var buffer: [Breadcrumb?]
    private var bufferIndex: Array<Breadcrumb>.Index
    private let maxCapacity: Int

    // MARK: - Subscript
    
    subscript(index: Int) -> Breadcrumb? {
        guard index < buffer.count else { return nil }
        
        return buffer[index]
    }
    
    // MARK: - Initializer
    
    init(maxCapacity: Int = 100) {
        self.buffer = Array(repeating: nil, count: 100)
        self.bufferIndex = buffer.startIndex
        self.maxCapacity = maxCapacity
    }
    
    // MARK: - Instance methods
    
    @discardableResult
    mutating func add(_ breadcrumb: Breadcrumb) -> Breadcrumb? {
        guard buffer.count > 0 else {
            return nil
        }
        
        if maxCapacity > 1 {
            buffer[bufferIndex] = breadcrumb
            bufferIndex += 1
            
            if buffer.count > maxCapacity {
                buffer.removeFirst()
                bufferIndex -= 1
            }
        }
        
        return breadcrumb
    }
    
    /// Removes all elements from the array.    
    mutating func removeAll() {
        buffer.removeAll(keepingCapacity: true)
        bufferIndex = buffer.startIndex
    }
    
    mutating func snapshot() -> [Breadcrumb] {
        buffer.compactMap(\.self)
    }
    
    // MARK: - Sequence
    
    /// Returns an iterator over the elements of this sequence.
    func makeIterator() -> some IteratorProtocol {
        buffer
            .compactMap(\.self)
            .makeIterator()
    }
}
