//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

/// A customizable icon view that applies consistent styling and theming.
///
/// `Icon` provides a standardized way to display icons throughout the interface with
/// consistent sizing, coloring, and opacity based on the current theme. It automatically
/// applies template rendering mode and uses theme-based colors and opacity values.
///
/// ## Example Usage
///
/// ```swift
/// // Basic usage with theme defaults
/// Icon(icon: DSIcons.camera)
///
/// // Custom color and size
/// Icon(icon: DSIcons.play, color: .blue, size: 24)
///
/// // Custom color only
/// Icon(icon: DSIcons.pause, color: .red)
/// ```
struct Icon: View {
    // MARK: - Environment Properties

    @Environment(\.isEnabled)
    var isEnabled

    @Environment(\.theme)
    var theme

    // MARK: - Properties

    /// The image to display as an icon.
    let icon: Image

    /// Optional custom color for the icon. If not provided, uses theme-based color.
    var color: Color?

    /// Optional custom size for the icon. If not provided, uses theme-based sizing.
    var size: CGSize?

    // MARK: - Body

    var body: some View {
        icon
            .resizable()
            .renderingMode(.template)
            .frame(size: size)
            .foregroundStyle(color ?? theme.iconTheme.color ?? theme.colorScheme.onSurface)
            .opacity(isEnabled ? theme.iconTheme.opacity : 0.5)
    }
}
