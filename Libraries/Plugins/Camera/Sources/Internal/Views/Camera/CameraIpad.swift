//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

struct CameraIpad: View {
    // MARK: - Environment Properties

    @Environment(\.dismiss)
    var dismiss

    @Environment(\.theme)
    var theme

    // MARK: - EnvironmentObject Properties

    @EnvironmentObject var viewModel: CameraViewModel

    // MARK: - State Properties

    @State var isPresented = false
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
            .onTapGesture(perform: onTap(at:))
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
            .overlay(alignment: .topLeading, content: makeHeaderControlsView)
            .overlay(alignment: .topTrailing, content: makeContinueButton)
            .overlay {
                TimerView(secondsRecorded: $viewModel.secondsRecorded)
                    .selected([.paused, .running].contains(viewModel.state))
                    .padding(.top, theme.spacingTheme.lg)
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
    }

    private func makeMagnificationGesture() -> some Gesture {
        MagnificationGesture()
            .onChanged(viewModel.magnify(by:))
            .onEnded { _ in
                viewModel.lastZoomFactor = viewModel.zoomFactor
            }
    }

    private func makeHeaderControlsView() -> some View {
        HStack(spacing: theme.spacingTheme.sm) {
            CircleButton {
                Icon(icon: DSIcons.xmark, size: CGSize(theme.sizeTheme.lg))
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
        .padding(.leading, theme.spacingTheme.xxl)
        .padding(.top, theme.spacingTheme.xxxxxl)
    }

    private func onTap(at point: CGPoint) {
        viewModel.setFocusPoint(at: point)
        isZoomPickerExpanded = false
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
            makeSwitchCameraButton()
            makePlayPauseButton()
            RecordButton()
            makeTakePhotoButton()
            PresetButton()
        }
        .allowsHitTesting(viewModel.allowsHitTesting)
    }

    // MARK: - Private methods

    private func makePlayPauseButton() -> some View {
        CircleButton {
            Icon(icon: viewModel.state == .paused ? DSIcons.play : DSIcons.pause, size: CGSize(theme.sizeTheme.x(3.5)))
                .padding(theme.spacingTheme.sm)
        } action: {
            viewModel.togglePause()
        }
        .hidden([.finished, .initialized].contains(viewModel.state))
        .allowsHitTesting(viewModel.allowsHitTesting)
    }

    private func makeSwitchCameraButton() -> some View {
        CircleButton {
            Icon(icon: DSIcons.cameraTrianglehead)
                .padding(theme.spacingTheme.sm)
        } action: {
            viewModel.switchCamera()
        }
        .hidden([.running, .paused].contains(viewModel.state))
        .allowsHitTesting(viewModel.allowsHitTesting)
    }

    private func makeTakePhotoButton() -> some View {
        CircleButton {
            Icon(icon: DSIcons.camera)
                .padding(theme.spacingTheme.sm)
        } action: {
            viewModel.capturePhoto()
        }
        .allowsHitTesting(viewModel.allowsHitTesting)
    }
}
