//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

/// A timer display view that shows the current recording duration with visual styling.
///
/// This view displays the elapsed recording time in a formatted string (e.g., "00:00:20")
/// with a semi-transparent background and rounded corners. The timer automatically
/// updates to reflect the current recording duration and provides visual feedback
/// through its background styling.
struct TimerView: View {
    // MARK: - Binding Properties

    @Binding var secondsRecorded: String

    // MARK: - Environment Properties

    @Environment(\.isSelected)
    var isSelected

    @Environment(\.theme)
    var theme

    // MARK: - StateObject Properties

    @StateObject var viewModel = TimerViewModel()

    // MARK: - Computed Properties

    var fillColor: Color {
        guard isSelected else {
            return UIDevice.current.isPad ? theme.colorScheme.surface.opacity(0.6) : .clear
        }

        return theme.colorScheme.error.opacity(0.8)
    }

    var textStyle: TextStyle {
        UIDevice.current.isPad ? theme.textTheme.title2 : theme.textTheme.callout
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Text(secondsRecorded)
                .style(textStyle.copyWith(color: theme.colorScheme.onSurface))
                .padding(.horizontal, theme.spacingTheme.sm)
                .padding(.vertical, theme.spacingTheme.xs)
                .background {
                    RoundedRectangle(cornerRadius: theme.radiusTheme.xs)
                        .fill(fillColor)
                }
                .padding(.top, theme.spacingTheme.x(1.5))
                .rotationEffect(viewModel.rotationAngle)
                .transition(.opacity)
                .id(viewModel.rotationAngle)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: viewModel.alignment)
        .animation(.easeInOut(duration: 0.8), value: viewModel.alignment)
    }
}
