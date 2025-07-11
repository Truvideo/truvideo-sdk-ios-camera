//
// Created by TruVideo on 17/09/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import Foundation
import TruvideoSdkFoundation

/// A structure representing a log record, encapsulating various details about a logging event.
///
/// `LogRecord` is used to capture and store detailed information about a logging event,
/// including the source file, function, log level, line number, message, metadata, and source.
/// This structure helps in providing a comprehensive log entry for debugging and analysis purposes.
public struct LogRecord {
    /// The name of the file from which the log record originated.
    public let file: String?
    
    /// The name of the function from which the log record originated.
    public let function: String?
    
    /// The severity level of the log record.
    public let level: Logger.LogLevel?
    
    /// The line number in the source code where the log record was generated.
    public let line: UInt?
    
    /// The message associated with the log record.
    public let message: Logger.Message?
    
    /// Additional metadata associated with the log record.
    public let metadata: Logger.Metadata?
    
    /// The source or category of the log record.
    public let source: String?
}

/// `DestinationMock` is a simple implementation of `LogDestination` for directing.
public final class LogDestinationMock: LogDestination {
    public let label: String

    /// Get or set the configured log level.
    public var logLevel: Logger.LogLevel = .info

    /// Get or set the entire metadata storage as a dictionary.
    public var metadata = Logger.Metadata()

    /// The list of records recorded in this mock.
    public private(set) var records: [LogRecord] = []

    /// Add, remove, or change the logging metadata.
    ///
    /// - Parameter metadataKey: The key for the metadata item
    public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get {
            metadata[metadataKey]
        }
        set {
            metadata[metadataKey] = newValue
        }
    }

    // MARK: Initializer

    public init(label: String = "foo") {
        self.label = label
    }

    // MARK: LogDestination

    public func log(
        level: Logger.LogLevel,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {

        let record = LogRecord(
            file: file,
            function: function,
            level: level,
            line: line,
            message: message,
            metadata: metadata,
            source: source
        )

        records.append(record)
    }
}
