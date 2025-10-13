//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
internal import Utilities

extension ErrorReason {
    /// Error reasons specific to file chunk streaming operations.
    ///
    /// This extension provides error reasons for failures that can occur during
    /// chunk-based file streaming, including stream lifecycle and I/O operations.
    struct ChunkErrorReason: Sendable {
        /// Error reason for failures when closing a chunk input stream.
        ///
        /// This error is captured when the chunk's file handle cannot be properly
        /// closed, which may indicate file system issues or resource cleanup problems.
        static let closeStreamFailed = ErrorReason(rawValue: "CLOSE_STREAM_FAILED")

        /// Error reason for failures when opening a chunk input stream.
        ///
        /// This error is captured when the chunk's file handle cannot be opened,
        /// typically due to missing files, permission issues, or file system errors.
        static let openStreamFailed = ErrorReason(rawValue: "OPEN_STREAM_FAILED")

        /// Error reason for failures when reading data from a chunk.
        ///
        /// This error is captured when reading from the chunk's file handle fails,
        /// which may indicate I/O errors, corrupted data, or file access issues.
        static let readChunkFailed = ErrorReason(rawValue: "READ_CHUNK_FAILED")
    }
}

/// An asynchronous sequence that streams file data in fixed-size chunks.
///
/// `FileChunkSequence` monitors a file for changes and automatically yields chunks
/// of data as the file grows. This is particularly useful for streaming large files
/// that are being written in real-time, such as video recordings, allowing for
/// concurrent processing or uploading while the file is still being written.
///
/// ## Use Cases
///
/// **Live Video Upload:**
/// ```swift
/// let recordingURL = tempDirectory.appendingPathComponent("recording.mp4")
/// let chunkSequence = FileChunkSequence(url: recordingURL)
///
/// // Upload chunks as recording progresses
/// for await chunk in chunkSequence {
///     try await s3.uploadPart(chunk, partNumber: partNum)
///     partNum += 1
/// }
/// ```
///
/// **Background Processing:**
/// ```swift
/// // Process large file in chunks
/// for await chunk in FileChunkSequence(url: videoURL) {
///     try await processChunk(chunk)
/// }
/// ```
///
/// ## Chunk Size
///
/// Chunks are emitted in 5MB increments, which is optimal for:
/// - AWS S3 multipart upload (5MB minimum part size)
/// - Network efficiency (balanced between overhead and throughput)
/// - Memory usage (moderate buffer size)
///
/// ## File Monitoring
///
/// The sequence monitors file system events including:
/// - `.write` - File data written
/// - `.delete` - File deleted (triggers cancellation)
/// - `.rename` - File moved/renamed (triggers cancellation)
///
/// - Note: Each chunk is an `InputStream` subclass that streams its byte range
///         on-demand without loading the entire chunk into memory.
struct FileChunkSequence: AsyncSequence {
    typealias Element = Chunk

    // MARK: - Private Properties

    private let asyncIterator: AsyncIterator

    // MARK: - Types

    /// An async iterator that yields file chunks as the file grows in real-time.
    ///
    /// This iterator monitors file system events to detect when new data is written
    /// to the file and automatically emits chunks as they become available. It handles
    /// the complete lifecycle including initialization, active monitoring, and cleanup.
    final class AsyncIterator: AsyncIteratorProtocol {
        // MARK: - Private Properties

        private var continuation: AsyncStream<Chunk>.Continuation?
        private var fileSystemObjectSource: DispatchSourceFileSystemObject?
        private var nextByteOffset: Int64 = 0
        private let queue = DispatchQueue(label: "com.truvideo.fileChunkSequence.queue")
        private let url: URL

        /// The minimum size in bytes for each chunk (5 MB).
        ///
        /// This size is optimal for AWS S3 multipart uploads and balances
        /// network efficiency with memory usage. Chunks smaller than this
        /// are only emitted when `finish()` is called to handle the final
        /// partial chunk.
        private let minimumChunkSize: Int64 = 5 * 1_024 * 1_024

        // MARK: - Lazy Properties

        private lazy var stream: AsyncStream<Chunk>.Iterator? = {
            let stream = AsyncStream<Element> { continuation in
                self.continuation = continuation
            }

            return stream.makeAsyncIterator()
        }()

        // MARK: - Types

        /// A global actor that serializes access to chunk emission operations.
        ///
        /// This actor ensures that chunk emission and file size checking operations
        /// are properly synchronized and don't race with each other when multiple
        /// file system events occur simultaneously.
        @globalActor
        actor AsyncIteratorActor {
            /// The shared global actor instance used to isolate operations.
            static let shared = AsyncIteratorActor()
        }

        // MARK: - Initializer

        /// Creates a new iterator for the specified file URL.
        ///
        /// Initializes the iterator and immediately begins monitoring the file
        /// for changes using file system events.
        ///
        /// - Parameter url: The URL of the file to monitor and chunk
        init(url: URL) {
            self.url = url

            subscribeToFileChanges()
        }

        // MARK: - AsyncIteratorProtocol

        /// Asynchronously advances to the next element and returns it, or ends the
        /// sequence if there is no next element.
        ///
        /// - Returns: The next element, if it exists, or `nil` to signal the end of the sequence.
        func next() async -> Element? {
            await stream?.next()
        }

        // MARK: - Instance methods

        /// Cancels file monitoring and finishes the stream without emitting remaining data.
        ///
        /// This method performs immediate cleanup by:
        /// 1. Finishing the continuation (no more chunks will be yielded)
        /// 2. Cancelling file system monitoring
        /// 3. Releasing the continuation reference
        ///
        /// Use this when you need to abort chunk streaming without processing
        /// any remaining data (e.g., when recording fails or is cancelled by user).
        func cancel() {
            continuation?.finish()
            fileSystemObjectSource?.cancel()
            continuation = nil
        }

        /// Finishes file monitoring and emits the final partial chunk if any data remains.
        ///
        /// This method should be called when the file writing is complete (e.g., when
        /// `AVAssetWriter.finishWriting()` completes). It ensures that any data smaller
        /// than the minimum chunk size is still emitted as a final chunk.
        ///
        /// ## Behavior
        ///
        /// 1. Cancels file system monitoring (no more automatic chunks)
        /// 2. Checks for remaining data beyond last emitted chunk
        /// 3. Emits final partial chunk if data exists
        /// 4. Finishes the continuation to signal sequence completion
        func finish() {
            fileSystemObjectSource?.cancel()

            Task {
                await didFinish()
            }
        }

        // MARK: - Private methods

        @AsyncIteratorActor
        private func didFinish() {
            let fileSize = try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64

            guard let fileSize else {
                // LOG Warning
                return
            }

            if nextByteOffset < fileSize {
                let chunk = Chunk(url: url, range: nextByteOffset ... fileSize - 1)

                continuation?.yield(chunk)
                nextByteOffset = fileSize
            }

            continuation?.finish()
            continuation = nil
        }

        @AsyncIteratorActor
        private func emitNext() {
            let fileSize = try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64

            guard let fileSize else {
                // LOG Warning
                return
            }

            var iterator = nextByteOffset

            while iterator + minimumChunkSize <= fileSize {
                let upperBound = iterator + minimumChunkSize - 1
                let chunk = Chunk(url: url, range: iterator ... upperBound)

                continuation?.yield(chunk)

                iterator += minimumChunkSize
            }

            nextByteOffset = iterator
        }

        func subscribeToFileChanges() {
            let fileDescriptor = open(url.path, O_EVTONLY)

            guard fileDescriptor >= 0 else {
                // LOG Warning
                return
            }

            let fileSystemObjectSource = DispatchSource.makeFileSystemObjectSource(
                fileDescriptor: fileDescriptor,
                eventMask: [.delete, .rename, .write],
                queue: queue
            )

            fileSystemObjectSource.setCancelHandler {
                close(fileDescriptor)
            }

            fileSystemObjectSource.setEventHandler { [weak self, weak fileSystemObjectSource] in
                guard let self, let fileSystemObjectSource else { return }

                Task {
                    let event = DispatchSource.FileSystemEvent(rawValue: fileSystemObjectSource.data)

                    await self.emitNext()

                    if event.contains(.delete) || event.contains(.rename) {
                        self.cancel()
                    }
                }
            }

            fileSystemObjectSource.resume()

            self.fileSystemObjectSource = fileSystemObjectSource

            Task {
                await emitNext()
            }
        }
    }

    /// A chunk of file data that streams a specific byte range without loading it into memory.
    ///
    /// `Chunk` is an `InputStream` subclass that provides streaming read access to a
    /// specific range of bytes within a file. This allows large files to be processed
    /// in memory-efficient chunks, as data is read on-demand rather than loaded entirely.
    ///
    /// ## Features
    ///
    /// - Streams only the specified byte range from the file
    /// - Lazy loading - data read only when requested via `read(_:maxLength:)`
    /// - Standard `InputStream` interface for compatibility with APIs (AWS SDK, HTTP clients)
    /// - Independent file handle per chunk for thread safety
    /// - Proper error handling and status reporting
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let chunk = Chunk(url: fileURL, range: 0...5_242_879)  // 5MB range
    ///
    /// chunk.open()
    /// defer { chunk.close() }
    ///
    /// var buffer = [UInt8](repeating: 0, count: 8192)
    /// while chunk.hasBytesAvailable {
    ///     let bytesRead = chunk.read(&buffer, maxLength: buffer.count)
    ///     // Process buffer data
    /// }
    /// ```
    ///
    /// ## Memory Efficiency
    ///
    /// Even though a chunk may represent 5MB of data, it only loads small buffers
    /// (typically 8KB-64KB) at a time during read operations, keeping memory usage low.
    ///
    /// ## AWS S3 Compatibility
    ///
    /// This class is specifically designed to work with AWS SDK's multipart upload,
    /// which expects `InputStream` objects for each part.
    ///
    /// - Note: Always call `open()` before reading and `close()` when done to
    ///         properly manage file handles and prevent resource leaks.
    final class Chunk: InputStream {
        // MARK: - Private Properties

        /// The exclusive upper bound of the byte range (one past the last byte).
        ///
        /// Used to determine when all bytes in the chunk have been read.
        private let endIndex: UInt64

        /// The error that occurred during stream operations, if any.
        ///
        /// Set when open, close, or read operations fail. Accessible via
        /// the `streamError` property.
        private var error: Error?

        /// The file handle used to read data from the file.
        ///
        /// Created when `open()` is called and released when `close()` is called.
        /// Each chunk maintains its own file handle to enable concurrent chunk processing.
        private var fileHandle: FileHandle?

        /// The current read position within the chunk's byte range.
        ///
        /// Tracks how many bytes have been read relative to `startIndex`.
        /// Used to calculate remaining bytes and update read position.
        private var index: UInt64 = 0

        /// The starting byte offset of this chunk within the file.
        ///
        /// The file handle is seeked to this position when `open()` is called.
        private let startIndex: UInt64

        /// The current status of the input stream.
        ///
        /// Tracks the stream lifecycle: notOpen, open, atEnd, closed, error.
        private var status = Status.notOpen

        /// The URL of the file from which this chunk reads data.
        private let url: URL

        // MARK: - Overridden Properties

        /// Indicates whether there are bytes available to read from the chunk.
        ///
        /// Returns `true` when the stream is open and there are unread bytes
        /// remaining within the chunk's byte range.
        ///
        /// - Returns: `true` if bytes can be read, `false` otherwise
        override var hasBytesAvailable: Bool {
            streamStatus == .open && startIndex + index < endIndex
        }

        /// The error that occurred during stream operations, if any.
        ///
        /// - Returns: The error object, or `nil` if no error occurred
        override var streamError: Error? {
            error
        }

        /// The current status of the input stream.
        ///
        /// - Returns: The stream status (.notOpen, .open, .atEnd, .closed, or .error)
        override var streamStatus: Status {
            status
        }

        // MARK: - Initializer

        /// Creates a new chunk for the specified file URL and byte range.
        ///
        /// The chunk will stream data from the given byte range when read operations
        /// are performed. The file is not opened or read until `open()` is called.
        ///
        /// - Parameters:
        ///   - url: The URL of the file to read from
        ///   - range: The byte range to stream (inclusive of both bounds)
        init(url: URL, range: ClosedRange<Int64>) {
            self.endIndex = UInt64(range.upperBound + 1)
            self.startIndex = UInt64(range.lowerBound)
            self.url = url

            super.init(data: Data())
        }

        // MARK: - Overridden methods

        /// Closes the chunk's file handle and releases resources.
        ///
        /// After closing, no more data can be read from this chunk. Any subsequent
        /// read attempts will return -1. The stream status is updated to `.closed`
        /// on success or `.error` if closing fails.
        override func close() {
            do {
                try fileHandle?.close()

                fileHandle = nil
                status = .closed
            } catch {
                self.error = UtilityError(kind: .ChunkErrorReason.closeStreamFailed, underlyingError: error)
                self.status = .error
            }
        }

        /// Opens the chunk's file handle and seeks to the chunk's starting position.
        ///
        /// This method must be called before any read operations. It:
        /// 1. Opens a file handle for reading from the file
        /// 2. Seeks to the chunk's start position (`startIndex`)
        /// 3. Sets the stream status to `.open`
        ///
        /// If opening or seeking fails, the stream status is set to `.error` and
        /// the error is stored in the `streamError` property.
        override func open() {
            do {
                fileHandle = try FileHandle(forReadingFrom: url)

                try fileHandle?.seek(toOffset: startIndex)

                status = .open
            } catch {
                self.error = UtilityError(kind: .ChunkErrorReason.openStreamFailed, underlyingError: error)
                self.status = .error
            }
        }

        /// Reads bytes from the chunk into the provided buffer.
        ///
        /// This method reads up to `length` bytes from the chunk's byte range and
        /// copies them into the provided buffer. It automatically tracks the read
        /// position and ensures reads stay within the chunk's bounds.
        ///
        /// ## Read Behavior
        ///
        /// - Reads at most `min(remainingBytes, length)` bytes
        /// - Updates internal read position after each read
        /// - Returns 0 when all chunk bytes have been read
        /// - Returns -1 if stream is not open or an error occurs
        ///
        /// ## Parameters
        ///
        /// - Parameters:
        ///   - buffer: Pointer to the buffer where read bytes will be stored
        ///   - length: Maximum number of bytes to read
        /// - Returns: Number of bytes actually read, 0 if at end, or -1 on error
        override func read(_ buffer: UnsafeMutablePointer<UInt8>, maxLength length: Int) -> Int {
            guard let fileHandle, status == .open else {
                return -1
            }

            let remainingSize = Int(endIndex - startIndex - index)

            guard remainingSize > 0 else {
                return 0
            }

            do {
                let bytesToRead = Swift.min(remainingSize, length)
                let data = try fileHandle.read(upToCount: bytesToRead) ?? Data()

                data.copyBytes(to: buffer, count: data.count)

                index += UInt64(data.count)

                return data.count
            } catch {
                self.error = UtilityError(kind: .ChunkErrorReason.readChunkFailed, underlyingError: error)
                self.status = .error

                return -1
            }
        }
    }

    // MARK: - Initializer

    /// Creates a new file chunk sequence for the specified file URL.
    ///
    /// Initializes the sequence and begins monitoring the file for changes.
    /// Chunks will be automatically emitted as the file grows.
    ///
    /// - Parameter url: The URL of the file to monitor and chunk
    init(url: URL) {
        asyncIterator = AsyncIterator(url: url)
    }

    // MARK: - AsyncSequence

    /// Creates an asynchronous iterator that yields file chunks as they become available.
    ///
    /// This method is called automatically when using `for await` loops with the sequence.
    /// The returned iterator monitors the file and yields chunks as new data is written.
    ///
    /// - Returns: An `AsyncIterator` that provides file chunks in real-time
    func makeAsyncIterator() -> AsyncIterator {
        asyncIterator
    }

    // MARK: - Instance methods

    /// Cancels file monitoring and stops emitting chunks immediately.
    ///
    /// This method aborts chunk streaming without processing any remaining data.
    /// Use this when the operation needs to be cancelled (e.g., user cancellation,
    /// recording failure).
    ///
    /// - Note: Any unprocessed data in the file will not be emitted.
    func cancel() {
        asyncIterator.cancel()
    }

    /// Finishes file monitoring and emits the final partial chunk.
    ///
    /// This method should be called when file writing is complete to ensure
    /// all data is processed, including any final chunk smaller than 5MB.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// assetWriter.finishWriting {
    ///     chunkSequence.finish()  // Emits final chunk
    /// }
    /// ```
    ///
    /// - Note: This ensures complete data processing for uploads or processing.
    func finish() {
        asyncIterator.finish()
    }
}
