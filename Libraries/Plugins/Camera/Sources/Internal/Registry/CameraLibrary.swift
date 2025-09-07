//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
internal import Registry

/// A registry for the TruVideo SDK Camera library that provides library metadata and configuration.
@objcMembers
public final class SDKCameraLibrary: NSObject {
    // MARK: - Static methods

    /// Registers the camera library with the SDK's library registry.
    ///
    /// This static method registers the camera library instance with the global
    /// library registry system. It should be called during SDK initialization
    /// to ensure the camera library is properly registered and available for
    /// dependency injection and service discovery.
    public static func register() {
        LibraryRegistry.register(CameraLibrary())
    }
}

private struct CameraLibrary: Library {
    /// The unique name of the library.
    var name: String {
        "TruvideoSdkCamera"
    }

    /// The current semantic version of the library.
    var version: String {
        "0.0.1"
    }

    // MARK: - Library

    /// Configures the library with the provided SDK configuration.
    ///
    /// This method is called during SDK initialization to set up library-specific
    /// dependencies, services, or configurations.
    func configure() {}
}
