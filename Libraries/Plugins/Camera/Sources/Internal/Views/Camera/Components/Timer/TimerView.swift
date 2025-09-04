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
    // MARK: - Environment Properties

    @Environment(\.theme)
    var theme

    // MARK: - EnvironmentObject Properties

    @EnvironmentObject var viewModel: CameraViewModel

    // MARK: - Body

    var body: some View {
        Text(viewModel.secondsRecorded)
            .style(theme.textTheme.callout.copyWith(color: theme.colorScheme.onSurface))
            .padding(.horizontal, theme.spacingTheme.sm)
            .padding(.vertical, theme.spacingTheme.xs)
            .background {
                RoundedRectangle(cornerRadius: theme.radiusTheme.xs)
                    .fill(true ? theme.colorScheme.error.opacity(0.8) : theme.colorScheme.surface.opacity(0.8))
            }
            .padding(.top, theme.spacingTheme.x(1.5))
            .transition(.opacity)
    }
}
