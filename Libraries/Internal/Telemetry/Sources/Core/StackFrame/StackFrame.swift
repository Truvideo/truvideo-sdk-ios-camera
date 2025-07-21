//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// Represents a single frame in the program's call stack, providing contextual information
/// about where an event (e.g., error or telemetry capture) was triggered.
///
/// The `StackFrame` struct is used to record the location in source code—function name,
/// file path, and line number—where an event occurred. This is particularly useful in
/// telemetry systems for tracing the origin of exceptions, errors, or custom logs.
///
/// - Parameters:
///   - function: The name of the function where the stack frame was captured (default is `#function`).
///   - file: The file path where the function is defined (default is `#file`).
///   - line: The line number in the file where the stack frame was captured (default is `#line`).
public struct StackFrame: Codable, Hashable, Sendable {
    /// The name of the function where the stack frame was captured.
    public let function: String

    /// The file path where the function is defined.
    public let file: String

    /// The line number in the file where the stack frame was captured.
    public let line: Int

    // MARK: - Initializer

    /// Initializes a new instance of `StackFrame` with the provided function, file, and line.
    ///
    /// - Parameters:
    ///    - function: The name of the function where the stack frame was captured (default is `#function`).
    ///    - file: The file path where the function is defined (default is `#file`).
    ///    - line: The line number in the file where the stack frame was captured (default is `#line`).
    public init(function: String = #function, file: String = #file, line: Int = #line) {
        self.function = function
        self.file = file
        self.line = line
    }
}
