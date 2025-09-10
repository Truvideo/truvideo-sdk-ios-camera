//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

struct CameraView: View {
    // MARK: - Environment Properties

    @Environment(\.theme)
    var theme

    // MARK: - StateObject Properties

    @StateObject var viewModel: CameraViewModel

    // MARK: - Body

    var body: some View {
        ZStack {
            Camera()
                .hidden(!viewModel.isAuthorized)

            PermissionsView()
                .hidden(viewModel.isAuthorized)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.colorScheme.surfaceContainer)
        .snackbar(isPresented: $viewModel.isSnackbarPresented) {
            Text(viewModel.localizedError)
                .fixedSize(horizontal: false, vertical: true)
        }
        .environmentObject(viewModel)
    }

    // MARK: - Initializer

    /// Creates a new instance with completion handler.
    ///
    /// This initializer sets up the instance with a completion callback that will be
    /// invoked when the operation completes.
    ///
    /// - Parameters:
    ///    - configuration: The camera configuration containing settings and preferences.
    ///    - onCompleted: Closure to be called when the operation completes with the result
    init(configuration: TruvideoSdkCameraConfiguration, onCompleted: @escaping (TruvideoSdkCameraResult) -> Void) {
        self._viewModel = StateObject(
            wrappedValue: CameraViewModel(configuration: configuration, onCompleted: onCompleted)
        )
    }
}

private struct Camera: View {
    // MARK: - Environment Properties

    @Environment(\.dismiss)
    var dismiss

    @Environment(\.theme)
    var theme

    // MARK: - EnvironmentObject Properties

    @EnvironmentObject var viewModel: CameraViewModel

    // MARK: - Body

    var body: some View {
        VideoPreview(previewLayer: viewModel.previewLayer)
            .simultaneousGesture(makeMagnificationGesture())
            .overlay {
                RecordingFrameOverlay()
                    .hidden(viewModel.state != .running)
            }
            .overlay(alignment: .topTrailing, content: makeContinueButton)
            .aspectRatio(viewModel.aspectRatio, contentMode: .fit)
            .overlay(alignment: .bottom) {
                ToolBar()
                    .padding(.bottom, theme.spacingTheme.sm)
                    .hidden(viewModel.deviceOrientation.isLandscape)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding(.top, theme.spacingTheme.xxxl)
            .onTapGesture(perform: viewModel.setFocusPoint(at:))
            .onChange(of: viewModel.validationState) { validationState in
                if validationState == .valid {
                    dismiss()
                }
            }
            .overlay {
                TimerView(secondsRecorded: $viewModel.secondsRecorded)
                    .selected([.paused, .running].contains(viewModel.state))
            }
            .overlay(alignment: .topLeading) {
                TopBar()
                    .padding(.horizontal, theme.spacingTheme.md)
            }
            .overlay(alignment: .trailing) {
                ToolBar()
                    .hidden(viewModel.deviceOrientation.isPortrait)
            }
            .overlay {
                ExitConfirmationView(isPresented: $viewModel.requiresConfirmation)
                    .hidden(!viewModel.requiresConfirmation)
            }
    }

    // MARK: - Private methods

    @ViewBuilder
    private func makeContinueButton() -> some View {
        ContinueButton()
            .padding(.top)
            .padding(.trailing, theme.spacingTheme.sm)
            .hidden(viewModel.medias.isEmpty || [.paused, .running].contains(viewModel.state))
            .animation(.linear(duration: 0.1).delay(0.7), value: viewModel.medias)
    }

    private func makeMagnificationGesture() -> some Gesture {
        MagnificationGesture()
            .onChanged { _ in }
    }
}

private struct RecordingFrameOverlay: View {
    // MARK: - Private Properties

    private let lineLength: CGFloat = 70
    private let lineWidth: CGFloat = 5

    // MARK: - Environment Properties

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
                    path.move(to: CGPoint(x: inset, y: lineLength))
                    path.addLine(to: CGPoint(x: inset, y: inset))
                    path.addLine(to: CGPoint(x: lineLength, y: inset))

                    // TOP-RIGHT
                    path.move(to: CGPoint(x: size.width - lineLength, y: inset))
                    path.addLine(to: CGPoint(x: size.width - inset, y: inset))
                    path.addLine(to: CGPoint(x: size.width - inset, y: lineLength))

                    // BOTTOM-RIGHT
                    path.move(to: CGPoint(x: size.width - inset, y: size.height - lineLength))
                    path.addLine(to: CGPoint(x: size.width - inset, y: size.height - inset))
                    path.addLine(to: CGPoint(x: size.width - lineLength, y: size.height - inset))

                    // BOTTOM-LEFT
                    path.move(to: CGPoint(x: lineLength, y: size.height - inset))
                    path.addLine(to: CGPoint(x: inset, y: size.height - inset))
                    path.addLine(to: CGPoint(x: inset, y: size.height - lineLength))
                }
                .stroke(theme.colorScheme.error, lineWidth: lineWidth)
            }
        }
        .allowsHitTesting(false)
    }
}

private struct ToolBar: View {
    // MARK: - Environment Properties

    @Environment(\.theme)
    var theme

    // MARK: - EnvironmentObject Properties

    @EnvironmentObject var viewModel: CameraViewModel

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
        if viewModel.deviceOrientation.isPortrait {
            VStack {
                ZoomPicker(options: viewModel.zoomFactors, selection: zoomFactor)
                HStack {
                    makeTakePhotoButton()
                    RecordButton()
                    makePlayPauseButton()
                    makeSwitchCameraButton()
                }
            }
        } else if viewModel.deviceOrientation.isLandscape {
            HStack {
                ZoomPicker(options: viewModel.zoomFactors, selection: zoomFactor)
                VStack {
                    makeSwitchCameraButton()
                    makePlayPauseButton()
                    RecordButton()
                    makeTakePhotoButton()
                }
            }
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
        .hidden([.finished, .initialized].contains(viewModel.state))
    }

    private func makeSwitchCameraButton() -> some View {
        CircleButton {
            Icon(icon: DSIcons.cameraTrianglehead)
                .padding(theme.spacingTheme.sm)
        } action: {
            viewModel.switchCamera()
        }
        .hidden([.running, .paused].contains(viewModel.state))
    }

    private func makeTakePhotoButton() -> some View {
        CircleButton {
            Icon(icon: DSIcons.camera)
                .padding(theme.spacingTheme.sm)
        } action: {
            viewModel.capturePhoto()
        }
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
                    TorchButton()
                }
            } else if viewModel.deviceOrientation.isLandscape {
                VStack(spacing: theme.spacingTheme.sm) {
                    makeCloseButton()
                    PresetButton()
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
        .disabled(viewModel.state == .running)
    }

    private func makeMediaCounterView() -> some View {
        Button {
            isPresented.toggle()
        } label: {
            MediaCounterView()
        }
        .overlay {
            GeometryReader { geometryProxy in
                ScaledTransitionView(isPresented: $isPresented) {
                    GalleryView(medias: $viewModel.medias, isPresented: $isPresented)
                }
                .startingFrame(geometryProxy.frame(in: .global))
                .hidden(!isPresented)
            }
        }
        .allowsHitTesting(!viewModel.medias.isEmpty)
    }
}
