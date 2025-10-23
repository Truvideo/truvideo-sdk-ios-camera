//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

/// A customizable record button view that toggles between recording and stopped states.
///
/// This view displays a circular button with a square inner shape that transforms
/// into a rounded rectangle when recording. The button uses theme-based styling
/// and provides smooth animations for state transitions.
struct RecordButton: View {
    // MARK: - Private Properties

    private let circleFactor = 0.1
    private let sideFactor = 0.88

    // MARK: - Environment Properties

    @Environment(\.theme)
    var theme

    // MARK: - EnvironmentObject Properties

    @EnvironmentObject var viewModel: CameraViewModel

    // MARK: - Computed Properties

    var cornerRadius: CGFloat {
        [.paused, .running].contains(viewModel.state) ? theme.radiusTheme.md : squareSize / 2
    }

    var fillColor: Color {
        [.paused, .running].contains(viewModel.state) ? theme.colorScheme.error : theme.colorScheme.onSurface
    }

    var lineWidth: Double {
        circleFactor * size / 2
    }

    var squareSize: Double {
        size * 0.88
    }

    var size: Double {
        UIDevice.current.isPad ? theme.sizeTheme.x(20) : theme.sizeTheme.x(18.5)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Circle()
                .stroke(theme.colorScheme.onSurface, lineWidth: lineWidth)

            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(fillColor)
                .frame(width: squareSize, height: squareSize)
                .scaleEffect([.paused, .running].contains(viewModel.state) ? 0.65 : 1)
                .animation(.easeInOut(duration: 0.25), value: viewModel.state)
        }
        .frame(width: size, height: size)
        .contentShape(.rect)
        .onTapGesture(perform: viewModel.toggleRecord)
        .allowsHitTesting(viewModel.allowsHitTesting)
    }
}
