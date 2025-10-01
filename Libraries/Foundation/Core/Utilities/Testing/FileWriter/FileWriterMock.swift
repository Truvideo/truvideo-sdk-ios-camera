//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import Telemetry

@testable import Utilities

/// A mock implementation of `FileWriter` used for unit testing.
public final class FileWriterMock: FileWriter {
    // MARK: - Properties

    /// A list of URLs that have been "removed" during testing.
    public var removeURLs: [URL] = []

    /// The last `TelemetryReport` that was written using `write(_:to:)`.
    public var writtenReport: TelemetryReport?

    /// The `Data` that should be returned by `write(_:to:)`.
    public var data: Data?

    /// An optional error to simulate failures when writing or removing files.
    public var error: UtilityError?

    // MARK: - Initializer
    
    /// Creates an instance of the `FileWriterMock`.
    public init() {}

    // MARK: - FileWriter

    /// Simulates removing a file at the specified URL.
    ///
    /// - Parameter url: The URL of the file to remove.
    /// - Throws: `UtilityError` if the `error` property is set to simulate a failure.
    public func remove(at url: URL) throws(UtilityError) {
        if let error {
            throw error
        }

        removeURLs.append(url)
    }

    /// Simulates writing a Codable object to a file.
    ///
    /// - Parameters:
    ///   - content: The object conforming to `Codable` to write.
    ///   - url: The destination URL where the data would be written.
    /// - Returns: The `Data` specified in the `data` property.
    /// - Throws: `UtilityError` if the `error` property is set to simulate a failure.
    public func write<T>(_ content: T, to url: URL) throws(UtilityError) where T: Codable {
        if let error {
            throw error
        }

        if let report = content as? TelemetryReport {
            writtenReport = report
        }
    }
}
