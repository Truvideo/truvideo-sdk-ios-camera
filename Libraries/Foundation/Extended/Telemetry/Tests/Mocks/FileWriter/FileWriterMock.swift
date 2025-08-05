//
// Copyright © 2025 TruVideo. All rights reserved.
//

@testable import Telemetry

final class FileWriterMock: FileWriter {
    // MARK: - Properties

    var writtenReport: TelemetryReport?
    var error: Error?

    // MARK: - FileWriter

    /// Writes a `Codable` object to the specified file URL as JSON.
    ///
    /// - Parameters:
    ///   - content: The object conforming to `Codable` that will be serialized and written to disk.
    ///   - url: The destination `URL` where the serialized data will be saved.
    /// - Throws: An error if the encoding fails or the data cannot be written to the file system.
    func write<T: Codable>(_ file: T, to url: URL) throws {
        if let error {
            throw error
        }

        if let report = file as? TelemetryReport {
            writtenReport = report
        }
    }
}
