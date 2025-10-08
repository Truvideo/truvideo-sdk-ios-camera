//
// Copyright © 2025 TruVideo. All rights reserved.
//

import DI
import Foundation
import Utilities

/// Provides a `DependencyKey` for injecting a `EnvironmentDependencyKey` dependency.
///
/// `EnvironmentDependencyKey` is used by the dependency system to resolve the default `Environment`.
public struct EnvironmentDependencyKey: DependencyKey {
    /// The default configuration used if none is explicitly set.
    public static let defaultValue = Environment.prod
}

extension DependencyValues {
    /// Accessor for resolving or overriding the current `Environment`.
    public var environment: Environment {
        get { self[EnvironmentDependencyKey.self] }
        set { self[EnvironmentDependencyKey.self] = newValue }
    }
}
