//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A protocol that defines a type capable of generating a telemetry context snapshot.
///
/// Conforming to `ContextProvider` allows objects to supply system context information—
/// such as device, OS, memory, and disk details—that can be attached to telemetry events
/// or diagnostic reports.
///
/// This protocol is intended for use within a telemetry system to encapsulate the logic
/// required to construct a complete [`Context`](Context) object at the time of logging.
///
/// Types conforming to this protocol must be `Sendable` to ensure thread safety
/// across concurrent telemetry operations.
public protocol ContextProvider: Sendable {
    /// Creates and returns a `Context` object representing the current system and environment state.
    ///
    /// - Returns: A `Context` instance containing up-to-date device and OS information.
    func makeContext() -> Context
}
