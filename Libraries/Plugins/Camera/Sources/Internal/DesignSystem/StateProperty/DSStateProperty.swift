//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

/// A structure that represents various visual and interaction states for a view.
///
/// `DSState` conforms to `OptionSet` and `Sendable`, allowing you to combine multiple states using set algebra.
/// It is primarily used for managing UI components' interactive or visual states, such as highlighting, selection,
/// errors, or being disabled.
///
/// This structure supports combining multiple states for complex UI behavior, enabling more responsive and intuitive
/// user interactions.
///
/// ### Example Usage:
/// ```swift
/// var buttonState: State = [.highlighted, .selected]
///
/// if buttonState.contains(.highlighted) {
///     print("Button is currently highlighted.")
/// }
/// ```
public struct DSState: OptionSet, Sendable {
    /// The element type of the option set.
    public let rawValue: Int

    /// The state when this view is disabled and cannot be interacted with.
    public static let disabled = DSState(rawValue: 1 << 1)

    /// The state when the widget has entered some form of invalid state.
    public static let error = DSState(rawValue: 1 << 3)

    /// The state when the user is actively pressing down on the given view.
    public static let highlighted = DSState(rawValue: 1 << 0)

    /// The normal state of view.
    public static let normal = DSState([])

    /// The state when this item has been selected.
    public static let selected = DSState(rawValue: 1 << 2)

    // MARK: - Initializer

    /// Creates a new option set from the given raw value.
    ///
    /// - Parameter rawValue: The element type of the option set.
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

/// A structure that represents a state-dependent property, allowing dynamic resolution of values based on the current
/// state.
///
/// `DSStateProperty` allows defining a property whose value can vary depending on the provided `DSState`.
/// This is particularly useful for customizing UI elements, such as colors, sizes, or styles, depending on different
/// interaction states l
/// ike `.highlighted`, `.selected`, or `.disabled`.
///
/// This structure offers flexibility for state-specific customization while also providing a convenient way to resolve
/// a constant value for all states.
///
/// ### Example Usage:
/// ```swift
/// let backgroundColor = DSStateProperty<Color> { state in
///     if state.contains(.highlighted) {
///         return .red
///     } else if state.contains(.disabled) {
///         return .gray
///     } else {
///         return .blue
///     }
/// }
///
/// let defaultFont = DSStateProperty.all(Font.system(size: 14))
/// ```
public struct DSStateProperty<T>: Sendable {
    /// A callback to invoke when resolving the current `T`
    /// value based on the given state.
    public let resolve: @MainActor @Sendable (DSState) -> T

    // MARK: - Static methods

    /// Creates a new property state that will resolve the `T`
    /// value without taking care of the current state.
    ///
    /// - Parameter resolve: A callback to invoke when resolving the current `T` value based on the given state.
    public static func all(_ resolve: @MainActor @Sendable @autoclosure @escaping () -> T) -> DSStateProperty<T> {
        DSStateProperty { _ in
            resolve()
        }
    }

    // MARK: - Initializer

    /// Creates a new property state.
    ///
    /// - Parameter resolve: A callback to invoke when resolving the current `T` value based on the given state.
    public init(resolve: @MainActor @Sendable @escaping (DSState) -> T) {
        self.resolve = resolve
    }
}
