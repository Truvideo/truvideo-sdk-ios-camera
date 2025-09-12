//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

extension FileManager {
    /// A computed property that returns the directory URL used for storing telemetry-related data.
    ///
    /// The method attempts to resolve the user's caches directory using `FileManager`. If unavailable,
    /// it falls back to the system’s temporary directory. The returned path is appended with a
    /// fixed telemetry folder name (`"com.truvideo.telemetry"`), which can be used by the app or SDK
    /// to persist telemetry events, sessions, and diagnostics.
    ///
    /// - Returns: A `URL` pointing to the telemetry storage directory.
    public var telemetryDirectory: URL {
        let fileManager = FileManager.default
        let url = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first ?? fileManager.temporaryDirectory

        return url.appendingPathComponent("com.truvideo.telemetry")
    }
}
