//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

/// Environment key for tracking selection state across the view hierarchy.
///
/// This environment key provides a way to pass selection state down through the view hierarchy
/// without explicitly passing it as a parameter to each view. It allows child views to access
/// the current selection state from their parent or ancestor views.
///
/// ## Usage
///
/// ```swift
/// // Set selection state in parent view
/// .environment(\.isSelected, true)
///
/// // Access selection state in child view
/// @Environment(\.isSelected) var isSelected: Bool
/// ```
struct SelectionEnvironmentKey: EnvironmentKey {
    /// The default value for the environment key.
    ///
    /// When no selection state is explicitly set in the environment, this value
    /// will be used as the fallback. The default is `false`, meaning views
    /// are unselected by default.
    static var defaultValue = false
}

/// Extension to provide convenient access to selection state in the environment.
///
/// This extension adds an `isSelected` property to `EnvironmentValues`, making it
/// easy to read and write selection state throughout the view hierarchy.
extension EnvironmentValues {
    /// Indicates whether the current view or its parent is in a selected state.
    ///
    /// This property can be used to conditionally style views, show selection indicators,
    /// or modify behavior based on the current selection state.
    ///
    /// - Returns: `true` if the view is selected, `false` otherwise.
    var isSelected: Bool {
        get { self[SelectionEnvironmentKey.self] }
        set { self[SelectionEnvironmentKey.self] = newValue }
    }
}
