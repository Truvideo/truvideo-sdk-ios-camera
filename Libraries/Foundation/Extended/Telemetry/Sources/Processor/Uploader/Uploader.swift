//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A protocol that defines a generic interface for uploading `Encodable` objects to a remote storage service.
///
/// Implementations of this protocol should handle the encoding of the object into a suitable format (e.g., JSON)
/// and manage the upload process, including error handling and network communication.
///
/// This abstraction allows for dependency injection and easy mocking in unit tests.
protocol Uploader {
    /// Uploads raw `Data` to an S3 bucket using the specified file name and content type.
    ///
    /// This method performs an asynchronous upload operation using AWS S3.
    /// It throws an error if the upload fails or is interrupted.
    ///
    /// - Parameters:
    ///   - data: The binary data to be uploaded to S3.
    ///   - fileName: The key (path/name) under which the file will be stored in the S3 bucket.
    ///   - contentType: The type of the data (e.g., "image/jpeg", "application/json").
    /// - Throws: An error of type `CommonUtilityError` if the upload fails.
    func upload(_ data: Data, fileName: String, contentType: ContentType) async throws
}

/// `ContentType` provides a set of predefined MIME types commonly used when uploading
/// files to services like Amazon S3. It conforms to `RawRepresentable`, `Equatable`,
/// and `Hashable`, allowing for safe comparisons and dictionary usage.
struct ContentType: RawRepresentable, Equatable, Hashable {
    /// The raw MIME type string (e.g., `"application/json"`).
    let rawValue: String

    // MARK: - Static Properties

    /// `application/json`
    static let json = ContentType(rawValue: "application/json")
}
