//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

/// A collapsible zoom factor picker with smooth animations and theme integration.
///
/// `ZoomPicker` provides an interactive interface for selecting zoom factors with a collapsible
/// design that expands to show all available options and collapses to show only the current
/// selection. It features smooth spring animations and automatically applies theme-based styling.
///
/// ## Example Usage
///
/// ```swift
/// @State private var zoomLevel: Double = 1.0
/// let zoomOptions = [0.5, 1.0, 2.0, 3.0, 5.0]
///
/// ZoomPicker(
///     options: zoomOptions,
///     selection: $zoomLevel
/// )
/// ```
struct ZoomPicker: View {
    // MARK: - Environment Properties

    @Environment(\.theme)
    var theme

    // MARK: - Properties

    /// The available zoom factor options to choose from.
    let options: [CGFloat]

    // MARK: - Binding Properties

    /// Optional binding to an external expanded state that can override the local state.
    ///
    /// This property allows external views to control the expansion state of this component.
    /// If provided, it takes precedence over the local `isExpanded` state. If not provided,
    /// the component uses its own internal expansion state.
    let isExpandedBinding: Binding<Bool>?

    /// Binding to the currently selected zoom factor.
    @Binding var selection: CGFloat

    /// A computed binding that provides unified access to the expansion state.
    ///
    /// This computed property creates a binding that automatically handles the relationship
    /// between the external binding (if provided) and the local expansion state. It ensures
    /// that changes to the expansion state are properly propagated to the appropriate source,
    /// whether that's the external binding or the local state.
    var binding: Binding<Bool> {
        Binding {
            isExpandedBinding?.wrappedValue ?? isExpanded
        } set: { newValue in
            guard let isExpandedBinding else {
                isExpanded = newValue
                return
            }

            isExpandedBinding.wrappedValue = newValue
        }
    }

    // MARK: - State Properties

    /// Controls whether the picker is in expanded or collapsed state.
    @State var isExpanded = false

    /// The transition animation used for state changes.
    @State var transition = AnyTransition.opacity.animation(.easeInOut(duration: 0))

    // MARK: - StateObject Properties

    @StateObject var viewModel = ZoomPickerViewModel()

    // MARK: - Body

    var body: some View {
        let maxSizeForCollapsibleMask = viewModel.maxSizeForCollapsibleMask(isExpanded: isExpanded)
        let maxSizeForAnimatableMask = viewModel.maxSizeForAnimatableMask(isExpanded: isExpanded)

        LayoutThatFits(isExpanded: $isExpanded) {
            ForEach(options, id: \.self) { option in
                Chip(viewModel.format(option), isSelected: selection == option) {
                    guard binding.wrappedValue else { return }

                    selection = option
                    transition = .opacity.animation(.easeInOut(duration: 1))
                    withAnimation {
                        binding.wrappedValue = false
                    }
                }
                .allowsHitTesting(selection != option)
            }
        }
        .padding(.horizontal, theme.spacingTheme.sm)
        .mask(
            Rectangle()
                .frame(
                    maxWidth: maxSizeForCollapsibleMask.width,
                    maxHeight: maxSizeForCollapsibleMask.height
                )
        )
        .background(theme.colorScheme.surfaceContainer.opacity(0.4))
        .mask(
            RoundedRectangle(cornerRadius: theme.radiusTheme.xxl)
                .frame(
                    maxWidth: maxSizeForAnimatableMask.width,
                    maxHeight: maxSizeForAnimatableMask.height
                )
        )
        .overlay {
            Chip(viewModel.format(selection), isSelected: true) {
                transition = .opacity.animation(.easeInOut(duration: 0))
                withAnimation {
                    binding.wrappedValue = true
                }
            }
            .hidden(binding.wrappedValue)
            .transition(transition)
        }
        .animation(.interpolatingSpring(mass: 1, stiffness: 200, damping: 22), value: isExpanded)
        .environmentObject(viewModel)
    }

    // MARK: - Initializer

    init(options: [CGFloat], selection: Binding<CGFloat>, isExpanded: Binding<Bool>? = nil) {
        self.isExpandedBinding = isExpanded
        self._selection = selection
        self.options = options
        self.transition = transition
    }
}

private struct Chip: View {
    // MARK: - Environment Properties

    @Environment(\.theme)
    var theme

    // MARK: - EnvironmentObject Properties

    @EnvironmentObject var viewModel: ZoomPickerViewModel

    // MARK: - State Properties

    @State var rotationAngle = Angle.degrees(0)

    // MARK: - Properties

    let action: @MainActor () -> Void
    let isSelected: Bool
    let label: String

    // MARK: - Computed Properties

    var foregroundColor: Color {
        isSelected ? theme.colorScheme.tertiary : theme.colorScheme.onPrimary
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: 0) {
            Text(label)
                .foregroundColor(foregroundColor)

            Text("×")
                .style(theme.textTheme.footnote.copyWith(color: foregroundColor))
        }
        .rotationEffect(rotationAngle)
        .frame(width: theme.sizeTheme.x(11), height: theme.sizeTheme.x(11))
        .monospacedDigit()
        .onTapGesture(perform: action)
        .onAppear {
            rotationAngle = viewModel.rotationAngle
        }
        .onChange(of: viewModel.rotationAngle) { rotationAngle in
            withAnimation(.spring(duration: 0.3)) {
                self.rotationAngle = rotationAngle
            }

            if viewModel.deviceOrientation.orientation == .portrait {
                self.rotationAngle = .degrees(0)
            }
        }
    }

    // MARK: - Initializer

    init(_ label: String, isSelected: Bool = false, action: @escaping @MainActor () -> Void) {
        self.action = action
        self.isSelected = isSelected
        self.label = label
    }
}

private struct LayoutThatFits<Content: View>: View {
    // MARK: - Binding Properties

    @Binding var isExpanded: Bool

    // MARK: - Environment Properties

    @Environment(\.theme)
    var theme

    // MARK: - EnvironmentObject Properties

    @EnvironmentObject var viewModel: ZoomPickerViewModel

    // MARK: - Properties

    let content: @MainActor () -> Content

    // MARK: - Body

    var body: some View {
        if viewModel.deviceOrientation.orientation.isLandscape && viewModel.deviceOrientation.source == .system {
            VStack(spacing: theme.spacingTheme.sm) {
                content()
            }
        } else {
            HStack(spacing: theme.spacingTheme.sm) {
                content()
            }
            .rotationEffect(viewModel.collapsibleAngle)
        }
    }
}
