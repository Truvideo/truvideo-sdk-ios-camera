//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A protocol that defines an interface for writing codable objects to a file.
///
/// Types conforming to `FileWriter` are responsible for implementing the logic to persist
/// any `Codable` object to a file, handling encoding and file operations as needed.
public protocol FileWriter {
    /// Removes the file or directory located at the specified URL.
    ///
    /// - Parameter url: The `URL` of the file or directory to be removed.
    /// - Throws: An error if the item does not exist, or if the file system
    ///   cannot remove the specified item (for example, due to permissions issues).
    func remove(at url: URL) throws(UtilityError)

    /// Writes a `Codable` object to the specified file URL as JSON.
    ///
    /// - Parameters:
    ///   - content: The object conforming to `Codable` that will be serialized and written to disk.
    ///   - url: The destination `URL` where the serialized data will be saved.
    /// - Throws: An error if the encoding fails or the data cannot be written to the file system.
    func write(_ content: some Codable, to url: URL) throws(UtilityError)
}
