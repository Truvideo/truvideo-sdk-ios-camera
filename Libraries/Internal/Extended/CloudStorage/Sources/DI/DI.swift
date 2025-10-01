//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
internal import Networking

/// Provides a `DependencyKey` for injecting a `Session` dependency.
///
/// `SessionDependencyKey` allows consumers to override the default storage
/// mechanism used in the system. By default, this uses `HTTPURLSession`.
struct SessionDependencyKey: DependencyKey {
    /// The default file-based storage used if none is explicitly provided.
    static let defaultValue: any Session = HTTPURLSession(
        cache: InMemoryURLCache(),
        middleware: Middleware(interceptors: [], retriers: [UploadRequestRetrier()]),
        monitors: []
    )
}

extension DependencyValues {
    /// Accessor for resolving or overriding the current `Session` implementation.
    var session: any Session {
        get { self[SessionDependencyKey.self] }
        set { self[SessionDependencyKey.self] = newValue }
    }
}
