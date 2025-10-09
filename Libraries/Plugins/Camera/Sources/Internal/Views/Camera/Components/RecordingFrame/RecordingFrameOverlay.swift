//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

/// A SwiftUI view that displays a corner-bracket frame overlay for video recording.
///
/// This view renders four corner brackets (L-shaped lines) at the corners of its frame,
/// typically used to indicate the active recording area in a camera interface. The overlay
/// is rendered in the error color from the current theme, providing a visual indicator
/// that recording is in progress.
struct RecordingFrameOverlay: View {
    // MARK: - Private Properties

    /// The length of each corner bracket arm in points.
    ///
    /// This defines how far each L-shaped bracket extends from its corner position.
    /// A value of 70 points provides a noticeable visual indicator without overwhelming
    /// the frame.
    private let lineLength: CGFloat = 70

    /// The width of the bracket lines in points.
    ///
    /// This defines the stroke width for all corner brackets. A value of 5 points
    /// provides good visibility while maintaining a clean appearance.
    private let lineWidth: CGFloat = 5

    // MARK: - Environment Properties

    /// The current theme providing color scheme and styling information.
    ///
    /// The theme is used to retrieve the error color for rendering the corner brackets,
    /// providing consistent visual styling across the application.
    @Environment(\.theme)
    var theme

    // MARK: - Body

    var body: some View {
        GeometryReader { geometryProxy in
            let inset = lineWidth / 2
            let size = geometryProxy.size

            ZStack {
                Path { path in
                    // TOP-LEFT
                    // Draws an L-shaped bracket at the top-left corner
                    // Starting from the vertical line, moving to the corner, then horizontal
                    path.move(to: CGPoint(x: inset, y: lineLength))
                    path.addLine(to: CGPoint(x: inset, y: inset))
                    path.addLine(to: CGPoint(x: lineLength, y: inset))

                    // TOP-RIGHT
                    // Draws an L-shaped bracket at the top-right corner
                    // Starting from the horizontal line, moving to the corner, then vertical
                    path.move(to: CGPoint(x: size.width - lineLength, y: inset))
                    path.addLine(to: CGPoint(x: size.width - inset, y: inset))
                    path.addLine(to: CGPoint(x: size.width - inset, y: lineLength))

                    // BOTTOM-LEFT
                    // Draws an L-shaped bracket at the bottom-left corner
                    // Starting from the horizontal line, moving to the corner, then vertical
                    path.move(to: CGPoint(x: lineLength, y: size.height - inset))
                    path.addLine(to: CGPoint(x: inset, y: size.height - inset))
                    path.addLine(to: CGPoint(x: inset, y: size.height - lineLength))

                    // BOTTOM-RIGHT
                    // Draws an L-shaped bracket at the bottom-right corner
                    // Starting from the vertical line, moving to the corner, then horizontal
                    path.move(to: CGPoint(x: size.width - inset, y: size.height - lineLength))
                    path.addLine(to: CGPoint(x: size.width - inset, y: size.height - inset))
                    path.addLine(to: CGPoint(x: size.width - lineLength, y: size.height - inset))
                }
                .stroke(theme.colorScheme.error, lineWidth: lineWidth)
            }
        }
        .allowsHitTesting(false)
    }
}
