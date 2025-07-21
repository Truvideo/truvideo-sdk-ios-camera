//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

extension FileManager {
    var telemetryDirectory: URL {
        let fileManager = FileManager.default
        let url = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first ?? fileManager.temporaryDirectory

        return
            url
            .appendingPathComponent("com.truvideo.telemetry")
    }
}
