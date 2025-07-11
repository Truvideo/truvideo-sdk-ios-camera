//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// Represents a severity level for log messages.
///
/// `LogLevel` is a flexible and extensible structure that assigns both a string identifier and a numeric priority
/// to a particular level of severity. It is used to classify log messages by importance and control their visibility
/// based on configured thresholds.
///
/// You can use the provided static values (e.g., `.debug`, `.info`, `.error`) or create custom levels
/// as needed.
public struct Severity: Codable, Hashable, RawRepresentable, Sendable {
    // MARK: - Properties

    /// The priority value.
    public let priority: Int

    /// The corresponding value of the raw type.
    public let rawValue: String

    // MARK: - Static Properties

    /// Appropriate for critical error conditions that usually require immediate
    /// attention.
    ///
    /// When a `critical` message is logged, the logging backend (`LogDestination`) is free to perform
    /// more heavy-weight operations to capture system state (such as capturing stack traces) to facilitate
    /// debugging.
    public static let critical = Severity(rawValue: "CRITICAL", priority: 6)

    /// Appropriate for messages that contain information normally of use only when
    /// debugging a program.
    public static let debug = Severity(rawValue: "DEBUG", priority: 1)

    /// Appropriate for error conditions.
    public static let error = Severity(rawValue: "ERROR", priority: 5)

    /// Appropriate for informational messages.
    public static let info = Severity(rawValue: "INFO", priority: 2)

    /// Appropriate for conditions that are not error conditions, but that may require
    /// special handling.
    public static let notice = Severity(rawValue: "NOTICE", priority: 3)

    /// Appropriate for messages that contain information normally of use only when
    /// tracing the execution of a program.
    public static let trace = Severity(rawValue: "TRACE")

    /// Appropriate for messages that are not error conditions, but more severe than
    /// `.notice`.
    public static let warning = Severity(rawValue: "WARNING", priority: 4)

    // MARK: - Initializers

    /// Creates a new instance with the specified raw value.
    ///
    /// - Parameter rawValue: The raw value to use for the new instance.
    public init(rawValue: String) {
        self.priority = 0
        self.rawValue = rawValue
    }

    /// Creates a new instance with the specified raw value.
    ///
    /// - Parameters:
    ///    - rawValue: The raw value to use for the new instance.
    ///    - priority: The priority of this `LogLevel`.
    public init(rawValue: String, priority: Int) {
        self.priority = priority
        self.rawValue = rawValue
    }
}
