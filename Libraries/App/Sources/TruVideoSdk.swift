//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

// swiftlint:disable identifier_name
///
public let TruvideoSdk: any TruVideoSDK = TruVideoApp()
// swiftlint:enable identifier_name

/// Version information for the TruVideo SDK
public struct TruVideoSDKVersion {
    /// The current version string of the TruVideo SDK
    public static let version: String = {
        // Use the automatically generated version string from the framework
        return String(cString: TruVideoSdkVersionString)
    }()
    
    /// The current version number of the TruVideo SDK
    public static let versionNumber: Double = TruVideoSdkVersionNumber
}
