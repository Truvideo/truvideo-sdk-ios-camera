//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

struct CameraIpad: View {
    // MARK: - Environment Properties

    @Environment(\.theme)
    var theme

    // MARK: - EnvironmentObject Properties

    @EnvironmentObject var viewModel: CameraViewModel

    // MARK: - State Properties

    @State var isZoomPickerExpanded = false

    // MARK: - Binding Properties

    var zoomFactor: Binding<CGFloat> {
        Binding {
            viewModel.zoomFactor
        } set: { zoomFactor in
            viewModel.rampZoomFactor(to: zoomFactor)
        }
    }

    // MARK: - Body

    var body: some View {
        VideoPreview(previewLayer: viewModel.previewLayer)
            .videoOrientation(viewModel.deviceOrientation)
            .simultaneousGesture(makeMagnificationGesture())
            .onTapGesture { point in
                viewModel.setFocusPoint(at: point)
                isZoomPickerExpanded = false
            }
            .overlay {
                RecordingFrameOverlay()
                    .hidden(viewModel.state != .running)
            }
            .overlay(alignment: .trailing) {
                ToolBar()
                    .padding(.trailing, theme.spacingTheme.sm)
            }
            .overlay(alignment: .leading) {
                ZoomPicker(options: viewModel.zoomFactors, selection: zoomFactor, isExpanded: $isZoomPickerExpanded)
                    .padding(.leading, theme.spacingTheme.md)
            }
            .overlay(alignment: .topLeading) {
                CloseButton()
                    .padding(.leading, theme.spacingTheme.md)
                    .padding(.top, theme.spacingTheme.x(6.5))
            }
            .overlay(alignment: .topTrailing, content: makeContinueButton)
            .overlay {
                AdaptiveOrientationLayoutView {
                    VStack(spacing: theme.spacingTheme.lg) {
                        TimeRecordedView(timeRecorded: $viewModel.timeRecorded)
                        RemainingTimeView(remainingTime: $viewModel.remainingTime)
                            .opacity(!viewModel.shouldDisplayRemainingTime ? 0 : 1)
                    }
                    .padding(.top, theme.spacingTheme.lg)
                    .selected([.paused, .running].contains(viewModel.state))
                }
            }
            .overlay {
                ExitConfirmationView(isPresented: $viewModel.requiresConfirmation)
                    .hidden(!viewModel.requiresConfirmation)
            }
    }

    // MARK: - Private methods

    @ViewBuilder
    private func makeContinueButton() -> some View {
        ContinueButton(onTap: viewModel.onContinue)
            .padding(.top, theme.spacingTheme.xxxl)
            .padding(.trailing, theme.spacingTheme.xs)
            .hidden(viewModel.medias.isEmpty || [.paused, .running].contains(viewModel.state))
            .animation(.linear(duration: 0.1).delay(0.7), value: viewModel.medias)
            .id(viewModel.deviceOrientation)
            .allowsHitTesting(viewModel.allowsHitTesting)
    }

    private func makeMagnificationGesture() -> some Gesture {
        MagnificationGesture()
            .onChanged(viewModel.magnify(by:))
            .onEnded { _ in
                viewModel.lastZoomFactor = viewModel.zoomFactor
            }
    }
}

private struct ToolBar: View {
    // MARK: - Environment Properties

    @Environment(\.theme)
    var theme

    // MARK: - EnvironmentObject Properties

    @EnvironmentObject var viewModel: CameraViewModel

    // MARK: - Body

    var body: some View {
        VStack(spacing: theme.spacingTheme.md) {
            TorchButton()
            CircleButton {
                Icon(
                    icon: DSIcons.cameraTrianglehead,
                    size: CGSize(width: theme.sizeTheme.xl, height: theme.sizeTheme.lg)
                )
                .padding(theme.spacingTheme.sm)
            } action: {
                viewModel.switchCamera()
            }
            .hidden([.running, .paused].contains(viewModel.state))
            .allowsHitTesting(viewModel.allowsHitTesting)

            CircleButton {
                Icon(
                    icon: viewModel.state == .paused ? DSIcons.play : DSIcons.pause,
                    size: CGSize(theme.sizeTheme.lg)
                )
                .padding(theme.spacingTheme.sm)
            } action: {
                viewModel.togglePause()
            }
            .hidden([.finished, .initialized].contains(viewModel.state))
            .allowsHitTesting(viewModel.allowsHitTesting)

            RecordButton()
            CircleButton {
                Icon(
                    icon: DSIcons.camera,
                    size: CGSize(width: theme.sizeTheme.xl, height: theme.sizeTheme.lg)
                )
                .padding(theme.spacingTheme.sm)
            } action: {
                viewModel.capturePhoto()
            }
            .allowsHitTesting(viewModel.allowsHitTesting)

            PresetButton()
        }
        .allowsHitTesting(viewModel.allowsHitTesting)
    }
}

private struct CloseButton: View {
    // MARK: - Environment Properties

    @Environment(\.theme)
    var theme

    // MARK: - EnvironmentObject Properties

    @EnvironmentObject var viewModel: CameraViewModel

    // MARK: - State Properties

    @State var isPresented = false

    // MARK: - Body

    var body: some View {
        HStack(spacing: theme.spacingTheme.sm) {
            CircleButton {
                Icon(icon: DSIcons.xmark, size: CGSize(theme.sizeTheme.xl))
            } action: {
                viewModel.onDismiss()
            }
            .disabled(viewModel.state == .running)

            Button {
                isPresented.toggle()
            } label: {
                MediaCounterView()
            }
            .allowsHitTesting(!viewModel.medias.isEmpty)
            .disabled(viewModel.state == .running)
            .scaledFullScreenCover(isPresented: $isPresented) {
                GalleryView(medias: $viewModel.medias, isPresented: $isPresented)
            }
        }
        .frame(height: theme.spacingTheme.md)
    }
}
