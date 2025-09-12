//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// Represents a user session, typically used to track application usage,
/// stability, and crash diagnostics for a specific installation.
///
/// The `Session` structure holds information about the session lifecycle,
/// including its start and end time, number of associated errors, and the
/// final status indicating how the session ended. This can be used for
/// telemetry, analytics, or error reporting purposes.
public struct Session: Codable, Equatable, Identifiable, Sendable {
    /// A unique identifier for the session.
    public let id: UUID

    /// A unique identifier for the installation associated with this session.
    public let installationId: UUID

    /// The time at which the session ended, if applicable.
    public private(set) var endedAt: Date?

    /// The number of errors recorded during the session.
    public internal(set) var errors: Int

    /// The time at which the session started.
    public let startedAt: Date

    /// The final status of the session, indicating how it ended.
    public private(set) var status: Status

    // MARK: - Types

    /// Represents the possible final states of a session.
    public enum Status: String, Codable, Sendable {
        /// The session ended abnormally (e.g., due to OS termination).
        case abnormal

        /// The session ended due to an application crash.
        case crashed

        /// The session ended gracefully via an exit.
        case exited

        /// The session completed successfully without issues.
        case ok
    }

    // MARK: - Initializer

    /// Initializes a new session with the given installation ID and optional start time.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the session. Defaults to a new UUID.
    ///   - installationId: The identifier of the installation the session belongs to.
    ///   - startedAt: The timestamp when the session started. Defaults to the current date.
    public init(id: UUID = UUID(), installationId: UUID, startedAt: Date = Date()) {
        self.id = id
        self.errors = 0
        self.installationId = installationId
        self.startedAt = startedAt
        self.status = .ok
    }

    // MARK: - Instance methods

    /// Marks the session as ended, recording the given date and status.
    ///
    /// - Parameters:
    ///   - date: The time the session ended. Defaults to the current time.
    ///   - status: The final status of the session. Defaults to `.ok`.
    mutating func endSession(at date: Date = Date(), status: Status = .ok) {
        self.endedAt = date
        self.status = status
    }
}
