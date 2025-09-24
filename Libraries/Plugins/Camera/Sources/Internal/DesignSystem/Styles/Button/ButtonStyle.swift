//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

extension ButtonStyle where Self == PrimaryButtonStyle {
    /// A static instance of `PrimaryButtonStyle` for applying a primary button appearance.
    ///
    /// This style creates buttons with a solid background color, typically used for
    /// the main call-to-action in your interface.
    public static var primary: PrimaryButtonStyle {
        .init(backgroundColor: nil, textColor: nil)
    }

    // MARK: - Static methods

    /// Creates a primary button style with custom background and text colors.
    ///
    /// - Parameters:
    ///   - backgroundColor: The background color of the button.
    ///   - textColor: The text color of the button.
    /// - Returns: A `PrimaryButtonStyle` instance with the specified colors.
    public static func primary(backgroundColor: Color?, textColor: Color? = nil) -> PrimaryButtonStyle {
        .init(backgroundColor: backgroundColor, textColor: textColor)
    }
}

extension ButtonStyle where Self == TextButtonStyle {
    /// A static instance of `TextButtonStyle` for applying a text-only button appearance.
    ///
    /// This style creates buttons with no background or border, appearing as clickable text.
    /// Ideal for secondary actions or navigation elements.
    public static var text: TextButtonStyle {
        .init()
    }
}

/// A button style that provides a primary, solid appearance for main call-to-action buttons.
///
/// `PrimaryButtonStyle` creates buttons with a solid background color and contrasting text,
/// designed to draw attention and indicate the primary action in your interface. The style
/// automatically adapts to the current theme and provides state-based visual feedback.
///
/// ## Visual Characteristics
///
/// - **Background**: Solid color that changes based on button state
/// - **Text**: High contrast text color for readability
/// - **Shape**: Rounded corners with configurable radius
/// - **States**: Visual feedback for normal, pressed, and disabled states
/// - **Layout**: Full-width with minimum size constraints
///
/// ## Example Usage
///
/// ```swift
/// // Basic primary button
/// Button("Save", action: saveAction)
///     .buttonStyle(.primary)
///
/// // Custom colored primary button
/// Button("Delete", action: deleteAction)
///     .buttonStyle(.primary(backgroundColor: .red, textColor: .white))
///
/// // Disabled state
/// Button("Submit", action: submitAction)
///     .buttonStyle(.primary)
///     .disabled(!isFormValid)
/// ```
public struct PrimaryButtonStyle: ButtonStyle {
    // MARK: - Properties

    /// The background color of the button.
    let backgroundColor: Color?

    /// The text color of the button.
    let textColor: Color?

    /// A wrapper view that provides access to environment variables and theme properties.
    ///
    /// This private view is necessary because `ButtonStyle` cannot directly access
    /// environment values. It handles the actual rendering of the button with
    /// proper theming and state management.
    private struct PrimaryButton: View {
        // MARK: - Properties

        /// The background color of the button.
        let backgroundColor: Color?

        /// The properties of a button.
        let configuration: ButtonStyleConfiguration

        /// The text color of the button.
        let textColor: Color?

        // MARK: - Environment Properties

        @Environment(\.isEnabled)
        var isEnabled

        @Environment(\.isSelected)
        var isSelected

        @Environment(\.theme)
        var theme

        // MARK: - Computed Properties

        private var effectiveBackgroundColor: DSStateProperty<Color> {
            guard let backgroundColor else {
                guard let backgroundColor = theme.buttonTheme.color else {
                    return DSStateProperty { state in
                        guard state.contains(.disabled) else {
                            return state.contains(.selected) ? theme.colorScheme.tertiary : theme.colorScheme.primary
                        }

                        return theme.colorScheme.primary.opacity(0.78)
                    }
                }

                return backgroundColor
            }

            return DSStateProperty { state in
                state.contains(.disabled) ? backgroundColor.opacity(0.78) : backgroundColor
            }
        }

        private var effectiveTextStyle: DSStateProperty<TextStyle> {
            guard let textStyle = theme.buttonTheme.textStyle else {
                return DSStateProperty { state in
                    let textStyle = theme.textTheme.callout.copyWith(weight: .semiBold)

                    if state.contains(.disabled) {
                        return textStyle.copyWith(color: theme.colorScheme.primary.opacity(0.78))
                    }

                    if state.contains(.selected) {
                        return textStyle.copyWith(color: theme.colorScheme.onSecondary)
                    }

                    return textStyle.copyWith(color: theme.colorScheme.onPrimary)
                }
            }

            return textStyle
        }

        private var state: DSState {
            guard isEnabled else {
                return .disabled
            }

            guard isSelected else {
                return configuration.isPressed ? .highlighted : .normal
            }

            return .selected
        }

        // MARK: - Body

        var body: some View {
            configuration.label
                .padding(theme.buttonTheme.padding ?? .all(theme.spacingTheme.sm))
                .frame(
                    minWidth: theme.buttonTheme.minimunSize?.width,
                    maxWidth: .infinity,
                    minHeight: theme.buttonTheme.minimunSize?.height,
                    alignment: theme.buttonTheme.alignment
                )
                .opacity(configuration.isPressed ? 0.5 : 1)
                .background(effectiveBackgroundColor.resolve(state))
                .clipShape(.rect(cornerRadius: theme.buttonTheme.cornerRadius ?? theme.radiusTheme.sm))
                .textStyle(
                    effectiveTextStyle.resolve(state)
                        .copyWith(color: textColor?.opacity(state.contains(.disabled) ? 0.78 : 1))
                )
        }
    }

    // MARK: - ButtonStyle

    /// Creates a view that represents the body of a button.
    ///
    /// This method is called by SwiftUI to create the visual representation of the button.
    /// It delegates to the `PrimaryButton` wrapper view to handle environment access.
    ///
    /// - Parameter configuration: The properties of the button provided by SwiftUI.
    /// - Returns: A view representing the styled button.
    public func makeBody(configuration: Configuration) -> some View {
        PrimaryButton(backgroundColor: backgroundColor, configuration: configuration, textColor: textColor)
    }
}

/// A button style that provides a text-only appearance for tertiary action buttons.
///
/// `TextButtonStyle` creates buttons with no background or border, appearing as clickable text.
/// This style is ideal for secondary actions, navigation elements, or when you want minimal
/// visual impact. The style automatically adapts to the current theme and provides
/// state-based visual feedback.
///
/// ## Visual Characteristics
///
/// - **Background**: Transparent
/// - **Border**: None
/// - **Text**: Colored text that changes based on button state
/// - **Shape**: Rounded corners with configurable radius (for touch target)
/// - **States**: Visual feedback for normal, pressed, and disabled states
/// - **Layout**: Full-width with minimum size constraints
///
/// ## Example Usage
///
/// ```swift
/// // Basic text button
/// Button("Learn More", action: learnMoreAction)
///     .buttonStyle(.text)
///
/// // Disabled state
/// Button("Skip", action: skipAction)
///     .buttonStyle(.text)
///     .disabled(!canSkip)
/// ```
public struct TextButtonStyle: ButtonStyle {
    /// A wrapper view that provides access to environment variables and theme properties.
    ///
    /// This private view is necessary because `ButtonStyle` cannot directly access
    /// environment values. It handles the actual rendering of the button with
    /// proper theming and state management.
    private struct TextButton: View {
        // MARK: - Environment Properties

        @Environment(\.isEnabled)
        var isEnabled

        @Environment(\.theme)
        var theme

        // MARK: - Properties

        let configuration: ButtonStyleConfiguration

        // MARK: - Computed Properties

        private var effectiveTextStyle: DSStateProperty<TextStyle> {
            guard let textStyle = theme.buttonTheme.textStyle else {
                return .init { state in
                    let color =
                        state.contains(.disabled) ? theme.colorScheme.primary.opacity(0.78) : theme.colorScheme.primary

                    return theme.textTheme.callout.copyWith(color: color, weight: .semiBold)
                }
            }

            return textStyle
        }

        private var state: DSState {
            guard isEnabled else {
                return .disabled
            }

            return configuration.isPressed ? .highlighted : .normal
        }

        // MARK: - Body

        var body: some View {
            configuration.label
                .textStyle(effectiveTextStyle.resolve(state))
                .padding(theme.buttonTheme.padding ?? .all(theme.spacingTheme.sm))
                .frame(
                    minWidth: theme.buttonTheme.minimunSize?.width,
                    maxWidth: .infinity,
                    minHeight: theme.buttonTheme.minimunSize?.height,
                    alignment: theme.buttonTheme.alignment
                )
                .opacity(configuration.isPressed ? 0.5 : 1)
                .clipShape(.rect(cornerRadius: theme.buttonTheme.cornerRadius ?? theme.radiusTheme.sm))
                .contentShape(.rect)
        }
    }

    // MARK: - ButtonStyle

    /// Creates a view that represents the body of a button.
    ///
    /// This method is called by SwiftUI to create the visual representation of the button.
    /// It delegates to the `TextButton` wrapper view to handle environment access.
    ///
    /// - Parameter configuration: The properties of the button provided by SwiftUI.
    /// - Returns: A view representing the styled button.
    public func makeBody(configuration: Configuration) -> some View {
        TextButton(configuration: configuration)
    }
}

#Preview {
    VStack {
        Button("Primary Button", action: {})
            .buttonStyle(.primary)

        Button("Primary Button Disabled", action: {})
            .buttonStyle(.primary)
            .disabled(true)

        Button("Text Button", action: {})
            .buttonStyle(.text)

        Button("Text Button Disabled", action: {})
            .buttonStyle(.text)
            .disabled(true)
    }
    .padding()
}
