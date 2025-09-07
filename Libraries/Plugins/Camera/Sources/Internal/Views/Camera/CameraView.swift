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

    // MARK: - State Properties

    @State var isPresented = false

    // MARK: - Computed Properties

    var animationDuration: TimeInterval {
        [.landscapeLeft, .landscapeRight].contains(viewModel.deviceOrientation) ? 1 : 0
    }

    // MARK: - Body

    var body: some View {
        VideoPreview(previewLayer: viewModel.previewLayer)
            .overlay {
                RecordingFrameOverlay()
                    .hidden(viewModel.state != .running)
            }
            .aspectRatio(viewModel.aspectRatio, contentMode: .fit)
            .overlay(alignment: .bottom) {
                ToolBar()
                    .padding(.bottom, theme.spacingTheme.sm)
                    .hidden(viewModel.deviceOrientation.isLandscape)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding(.top, theme.spacingTheme.xxxl)
            .overlay(alignment: .top, content: makeTimerView)
            .onChange(of: viewModel.validationState) { validationState in
                if validationState == .invalid {
                    isPresented = true
                } else if validationState == .valid {
                    dismiss()
                }
            }
            .onTapGesture { location in
                viewModel.setFocusPoint(at: location)
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
                ExitConfirmationView(isPresented: $isPresented)
                    .hidden(!isPresented)
            }
    }

    // MARK: - Private methods

    private func makeTimerView() -> some View {
        ZStack {
            TimerView()
                .padding(.top, theme.spacingTheme.xxxl)
                .transition(.opacity)
                .hidden(viewModel.deviceOrientation.isPortrait)
        }
        .animation(.easeInOut(duration: animationDuration), value: viewModel.deviceOrientation)
    }
}

private struct FocusView: View {
    // MARK: - EnvironmentObject Properties

    @EnvironmentObject var viewModel: CameraViewModel

    // MARK: - State

    @State var opacity = 1.0
    @State var scale = 2.5

    // MARK: - Body

    var body: some View {
        DSIcons.viewFinder
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 0.2)) {
                    scale = 1.0
                }

                withAnimation(.easeInOut.delay(3)) {
                    opacity = 0.5
                }
            }
            .onDisappear {
                scale = 1.5
            }
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

    // MARK: - Body

    var body: some View {
        if viewModel.deviceOrientation.isPortrait {
            VStack {
                ZoomPicker(options: viewModel.zoomFactors, selection: $viewModel.zoomFactor)
                HStack {
                    makeTakePhotoButton()
                    RecordButton()
                    makePlayPauseButton()
                    makeSwitchCameraButton()
                }
            }
        } else if viewModel.deviceOrientation.isLandscape {
            HStack {
                ZoomPicker(options: viewModel.zoomFactors, selection: $viewModel.zoomFactor)
                VStack {
                    makeTakePhotoButton()
                    RecordButton()
                    makePlayPauseButton()
                    makeSwitchCameraButton()
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
        .overlay(alignment: .top) {
            ZStack {
                TimerView()
                    .padding(.bottom, theme.spacingTheme.xs)
                    .hidden(viewModel.deviceOrientation.isLandscape)
            }
            .animation(.easeInOut(duration: animationDuration), value: viewModel.deviceOrientation)
        }
    }

    // MARK: - Private methods

    private func makeCloseButton() -> some View {
        CircleButton {
            Icon(icon: DSIcons.xmark, size: CGSize(theme.sizeTheme.lg))
        } action: {
            viewModel.onDismiss()
        }
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
