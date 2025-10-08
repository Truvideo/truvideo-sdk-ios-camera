//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
internal import InternalUtilities

extension Environment {
    /// The base URL for all API requests to the TruVideo backend.
    ///
    /// This computed property returns the appropriate base URL based on the current environment.
    /// It serves as the foundation for constructing full API endpoints throughout the SDK.
    /// The URL is automatically determined by the environment type, ensuring that requests
    /// are directed to the correct backend instance.
    var baseURL: String {
        switch self {
        case .beta:
            "https://upload-api-beta.truvideo.com"

        case .dev:
            "https://upload-api-dev.truvideo.com"

        case .prod:
            "https://upload-api.truvideo.com"

        case .rc:
            "https://upload-api-rc.truvideo.com"

        default:
            "https://upload-api.truvideo.com"
        }
    }
}
