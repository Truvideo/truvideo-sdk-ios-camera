//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

/// A view that displays the remaining time during a recording or playback session.
///
/// `RemainingTimeView` presents the remaining time as a formatted string (e.g., `"00:01:45"`)
/// using the app’s theme for consistent text styling and layout. The view features
/// horizontal padding and a rounded rectangular background with a transparent fill.
struct RemainingTimeView: View {
    // MARK: - Binding Properties

    @Binding var remainingTime: String

    // MARK: - Environment Properties

    @Environment(\.theme)
    var theme

    // MARK: - Body

    var body: some View {
        Text(remainingTime)
            .style(theme.textTheme.callout.copyWith(color: theme.colorScheme.onSurface))
            .padding(.horizontal, theme.spacingTheme.sm)
            .background {
                RoundedRectangle(cornerRadius: theme.radiusTheme.xs)
                    .fill(.clear)
            }
            .transition(.opacity)
    }
}
