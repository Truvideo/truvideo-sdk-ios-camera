//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Utilities

/// A concrete implementation of the `FileWriter` protocol that writes codable objects to a file on the local file system.
///
/// `SystemFileWriter` uses a specified `FileManager`, `JSONEncoder`, and file URL to encode and append codable objects
/// to a file. Each object is written as a JSON line (NDJSON format), making it suitable for log or report storage.
final class SystemFileWriter: FileWriter {
    // MARK: - Private Properties

    private let encoder: JSONEncoder
    private let fileManager: FileManager

    // MARK: - Initializer

    /// Initializes a new instance of `SystemFileWriter`.
    ///
    /// - Parameters:
    ///   - encoder: The JSON encoder used to encode codable objects.
    ///   - fileManager: The file manager used for file operations.
    init(
        encoder: JSONEncoder = JSONEncoder(),
        fileManager: FileManager = FileManager()
    ) {
        self.encoder = encoder
        self.fileManager = fileManager
    }

    // MARK: - FileWriter

    /// Writes a `Codable` object to the specified file URL as JSON.
    ///
    /// - Parameters:
    ///   - content: The object conforming to `Codable` that will be serialized and written to disk.
    ///   - url: The destination `URL` where the serialized data will be saved.
    /// - Throws: An error if the encoding fails or the data cannot be written to the file system.
    func write<T: Codable>(_ content: T, to url: URL) throws {
        do {
            if !fileManager.fileExists(atPath: url.path) {
                fileManager.createFile(atPath: url.path, contents: nil)
            }

            let fileHandle = try FileHandle(forWritingTo: url)
            let data = try encoder.encode(content)

            try fileHandle.seekToEnd()
            try fileHandle.write(contentsOf: data)

            try fileHandle.write(contentsOf: Data("\n".utf8))
            try fileHandle.close()
        } catch {
            throw UtilityError(kind: .TelemetryErrorReason.writeToFileFailed, underlyingError: error)
        }
    }
}
