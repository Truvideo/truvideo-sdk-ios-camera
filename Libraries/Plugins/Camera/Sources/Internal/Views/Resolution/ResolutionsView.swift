//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

struct ResolutionsView: View {
    // MARK: - Environment Properties

    @Environment(\.theme)
    var theme

    // MARK: - State Object

    @StateObject private var viewModel = OrientationViewModel()

    // MARK: - Binding Properties

    @Binding var isPresented: Bool
    @Binding var selection: VideoResolution

    // MARK: - Body

    var body: some View {
        VStack(spacing: theme.spacingTheme.sm) {
            Text(Localizations.resolutions.uppercased())
                .style(theme.textTheme.callout.copyWith(color: .white))

            ForEach(VideoResolution.allCases, id: \.self) { resolution in
                ResolutionButton(resolution: resolution) {
                    selection = resolution
                    isPresented.toggle()
                }
                .selected(selection == resolution)
            }
        }
        .if(viewModel.deviceOrientationSource == .sensors) { view in
            view
                .rotationEffect(viewModel.rotationAngle)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .topLeading) {
            CircleButton {
                Icon(icon: DSIcons.xmark, size: CGSize(theme.sizeTheme.lg))
            } action: {
                isPresented.toggle()
            }
            .padding(theme.spacingTheme.md)
        }
        .background {
            EmptyView()
                .background(style: .dark)
                .ignoresSafeArea()
        }
    }
}

private struct ResolutionButton: View {
    // MARK: - Environment Properties

    @Environment(\.theme)
    var theme

    // MARK: - Properties

    let resolution: VideoResolution
    let action: () -> Void

    // MARK: - Computed Properties

    private var buttonTheme: ButtonTheme {
        theme.buttonTheme.copyWith(
            color: DSStateProperty { state in
                state.contains(.selected) ? theme.colorScheme.tertiary : theme.colorScheme.onTertiary.opacity(0.3)
            },
            textStyle: DSStateProperty { state in
                theme.textTheme.callout.copyWith(
                    color: state.contains(.selected) ? theme.colorScheme.onSecondary : theme.colorScheme.onPrimary
                )
            }
        )
    }

    // MARK: - Body

    var body: some View {
        Button("\(resolution.size.width)x\(resolution.size.height)", action: action)
            .buttonStyle(.primary)
            .frame(maxWidth: theme.sizeTheme.x(75))
            .theme(theme.copyWith(buttonTheme: buttonTheme))
    }
}
