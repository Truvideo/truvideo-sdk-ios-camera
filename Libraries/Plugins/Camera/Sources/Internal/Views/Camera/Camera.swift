//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

/// The main camera view that displays the video preview and camera controls.
///
/// This view provides a complete camera interface with video preview, zoom controls,
/// recording indicators, and various overlays for camera interaction. It manages the
/// camera UI layout and responds to user gestures including tap-to-focus and pinch-to-zoom.
struct Camera: View {
    // MARK: - Environment Properties

    @Environment(\.theme)
    var theme

    // MARK: - EnvironmentObject Properties

    @EnvironmentObject var viewModel: CameraViewModel

    // MARK: - State Properties

    @State var isZoomPickerExpanded = false

    // MARK: - Body

    var body: some View {
        VideoPreview(previewLayer: viewModel.previewLayer)
            .videoOrientation(viewModel.deviceOrientation)
            .simultaneousGesture(makeMagnificationGesture())
            .overlay {
                RecordingFrameOverlay()
                    .hidden(viewModel.state != .running)
            }
            .overlay(content: makeContinueButton)
            .aspectRatio(viewModel.aspectRatio, contentMode: .fit)
            .overlay(alignment: .bottom) {
                ToolBar(isZoomPickerExpanded: $isZoomPickerExpanded)
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier(AccessibilityLabel.toolBar)
                    .padding(.bottom, theme.spacingTheme.sm)
                    .hidden(viewModel.deviceOrientation.isLandscape)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding(.top, theme.spacingTheme.xxxl)
            .onTapGesture { point in
                viewModel.setFocusPoint(at: point)
                isZoomPickerExpanded = false
            }
            .overlay {
                AdaptiveOrientationLayoutView {
                    VStack(spacing: theme.spacingTheme.lg) {
                        TimeRecordedView(timeRecorded: $viewModel.timeRecorded)
                        .accessibilityIdentifier(AccessibilityLabel.timerView)
                        RemainingTimeView(remainingTime: $viewModel.remainingTime)
                            .opacity(!viewModel.shouldDisplayRemainingTime ? 0 : 1)
                    }
                    .selected([.paused, .running].contains(viewModel.state))
                }
            }
            .overlay(alignment: .topLeading) {
                TopBar()
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier(AccessibilityLabel.topBar)
                    .padding(.horizontal, theme.spacingTheme.md)
            }
            .overlay(alignment: .trailing) {
                ToolBar(isZoomPickerExpanded: $isZoomPickerExpanded)
                    .accessibilityIdentifier(AccessibilityLabel.toolBar)
                    .hidden(viewModel.deviceOrientation.isPortrait)
            }
            .overlay {
                ExitConfirmationView(isPresented: $viewModel.requiresConfirmation)
                    .accessibilityIdentifier(AccessibilityLabel.exitConfirmationView)
                    .hidden(!viewModel.requiresConfirmation)
            }
    }

    // MARK: - Private methods

    @ViewBuilder
    private func makeContinueButton() -> some View {
        ContinueButton(onTap: viewModel.onContinue)
            .accessibilityIdentifier(AccessibilityLabel.continueButton)
            .padding(.top)
            .padding(.horizontal, theme.spacingTheme.sm)
            .hidden(viewModel.medias.isEmpty || [.paused, .running].contains(viewModel.state))
            .allowsHitTesting(viewModel.allowsHitTesting)
            .animation(.linear(duration: 0.1).delay(0.7), value: viewModel.medias)
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

    // MARK: - Binding Properties

    @Binding var isZoomPickerExpanded: Bool
    var zoomFactor: Binding<CGFloat> {
        Binding {
            viewModel.zoomFactor
        } set: { zoomFactor in
            viewModel.rampZoomFactor(to: zoomFactor)
        }
    }

    // MARK: - Body

    var body: some View {
        if viewModel.deviceOrientation.isPortrait {
            VStack {
                ZoomPicker(options: viewModel.zoomFactors, selection: zoomFactor, isExpanded: $isZoomPickerExpanded)
                    .accessibilityIdentifier(Camera.AccessibilityLabel.zoomPicker)
                HStack {
                    makeTakePhotoButton()
                    RecordButton()
                        .accessibilityIdentifier(Camera.AccessibilityLabel.recordVideo)
                    makePlayPauseButton()
                    makeSwitchCameraButton()
                }
            }
            .accessibilityElement(children: .contain)
            .allowsHitTesting(viewModel.allowsHitTesting)
        } else if viewModel.deviceOrientation.isLandscape {
            HStack {
                ZoomPicker(options: viewModel.zoomFactors, selection: zoomFactor, isExpanded: $isZoomPickerExpanded)
                VStack {
                    makeSwitchCameraButton()
                    makePlayPauseButton()
                    RecordButton()
                        .accessibilityIdentifier(Camera.AccessibilityLabel.recordVideo)
                    makeTakePhotoButton()
                }
            }
            .accessibilityElement(children: .contain)
            .allowsHitTesting(viewModel.allowsHitTesting)
        }
    }

    // MARK: - Private methods

    private func makePlayPauseButton() -> some View {
        CircleButton {
            Icon(icon: viewModel.state == .paused ? DSIcons.play : DSIcons.pause, size: CGSize(theme.sizeTheme.x(3.5)))
                .padding(theme.spacingTheme.sm)
        } action: {
            viewModel.togglePause()
        }
        .accessibilityIdentifier(Camera.AccessibilityLabel.playAndPauseButton)
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
        .accessibilityIdentifier(Camera.AccessibilityLabel.switchCameraButton)
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
        .accessibilityIdentifier(Camera.AccessibilityLabel.takePhotoButton)
        .allowsHitTesting(viewModel.allowsHitTesting)
    }
}

private struct TopBar: View {
    // MARK: - Environment Properties

    @Environment(\.theme)
    var theme

    // MARK: - EnvironmentObject Properties

    @EnvironmentObject var viewModel: CameraViewModel

    // MARK: - State Properties

    @State var isPresented = false

    // MARK: - Computed Properties

    var animationDuration: TimeInterval {
        viewModel.deviceOrientation.isLandscape ? 0 : 1
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            if viewModel.deviceOrientation.isPortrait {
                HStack(spacing: theme.spacingTheme.xs) {
                    HStack(spacing: theme.spacingTheme.sm) {
                        makeCloseButton()
                        makeMediaCounterView()
                    }

                    Spacer()
                    PresetButton()
                        .allowsHitTesting(viewModel.allowsHitTesting)
                        .accessibilityIdentifier(Camera.AccessibilityLabel.presetButton)
                    TorchButton()
                        .accessibilityIdentifier(Camera.AccessibilityLabel.flashButton)
                }
            } else if viewModel.deviceOrientation.isLandscape {
                VStack(spacing: theme.spacingTheme.sm) {
                    makeCloseButton()
                    PresetButton()
                        .allowsHitTesting(viewModel.allowsHitTesting)
                        .accessibilityIdentifier(Camera.AccessibilityLabel.presetButton)
                    TorchButton()
                    makeMediaCounterView()
                }
                .padding(.top)
            }
        }
    }

    // MARK: - Private methods

    private func makeCloseButton() -> some View {
        CircleButton {
            Icon(icon: DSIcons.xmark, size: CGSize(theme.sizeTheme.lg))
        } action: {
            viewModel.onDismiss()
        }
        .accessibilityIdentifier(Camera.AccessibilityLabel.closeButton)
        .disabled(viewModel.state == .running)
    }

    private func makeMediaCounterView() -> some View {
        Button {
            isPresented.toggle()
        } label: {
            MediaCounterView()
        }
        .accessibilityIdentifier(Camera.AccessibilityLabel.mediaCounterView)
        .allowsHitTesting(!viewModel.medias.isEmpty)
        .disabled(viewModel.state == .running)
        .scaledFullScreenCover(isPresented: $isPresented) {
            GalleryView(medias: $viewModel.medias, isPresented: $isPresented)
        }
    }
}
