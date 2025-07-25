//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
import Foundation
import Registry
import TruVideoApi

/// A concrete implementation of the `Library` protocol that configures the `TruVideoSdk`.
struct TruVideoSDKLibrary: Library {
    /// The unique name of the library.
    ///
    /// This should be a concise, URL-safe string using only alphanumeric characters,
    /// hyphens (`-`), underscores (`_`), or dots (`.`). It is used to register and
    /// reference the library in runtime systems.
    let name = "TruVideoSdk"

    /// The current semantic version of the library.
    ///
    /// Follows standard versioning schemes such as `"1.0.0"` or `"75.2.1-RC.3"`.
    /// Used for compatibility checks, debugging, and diagnostics.
    let version = TruVideoSDKVersion.version

    /// Configures the library with the provided SDK configuration.
    ///
    /// This method is called during SDK initialization to set up library-specific
    /// dependencies, services, or configurations.
    func configure() {
        DependencyValues.current.apiEnvironment = Environment(rawValue: "$(SDK_ENVIRONMENT)")
    }
}
