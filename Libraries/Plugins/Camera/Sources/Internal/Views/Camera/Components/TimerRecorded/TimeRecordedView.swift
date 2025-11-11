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
struct TimeRecordedView: View {
    // MARK: - Binding Properties

    @Binding var timeRecorded: String

    // MARK: - Environment Properties

    @Environment(\.isSelected)
    var isSelected

    @Environment(\.theme)
    var theme

    // MARK: - Computed Properties

    var fillColor: Color {
        isSelected ? theme.colorScheme.error.opacity(0.8) : .clear
    }

    // MARK: - Body

    var body: some View {
        Text(timeRecorded)
            .style(theme.textTheme.callout.copyWith(color: theme.colorScheme.onSurface))
            .padding(.horizontal, theme.spacingTheme.sm)
            .padding(.vertical, theme.spacingTheme.xs)
            .background {
                RoundedRectangle(cornerRadius: theme.radiusTheme.xs)
                    .fill(fillColor)
            }
            .padding(.top, theme.spacingTheme.x(1.5))
            .transition(.opacity)
    }
}
