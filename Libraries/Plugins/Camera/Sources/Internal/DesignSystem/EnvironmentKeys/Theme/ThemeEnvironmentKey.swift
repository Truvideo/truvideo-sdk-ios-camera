//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

/// A key for accessing values in the environment.
public struct ThemeEnvironmentKey: EnvironmentKey {
    /// The default value for the environment key.
    public static let defaultValue: Theme = .default
}

/// A helper properties for accessing values in the `EnvironmentValues`.
extension EnvironmentValues {
    /// Default visual properties, like colors fonts and shapes, for components.
    public var theme: Theme {
        get { self[ThemeEnvironmentKey.self] }
        set { self[ThemeEnvironmentKey.self] = newValue }
    }
}
