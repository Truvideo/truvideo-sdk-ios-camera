//
//  CameraViewModel.swift
//
//  Created by TruVideo on 6/16/22.
//  Copyright © 2023 TruVideo. All rights reserved.
//

import ARKit
import AVFoundation
import Combine
import SwiftUI

extension TruvideoSdkCameraMediaMode {
    var canTakePhotos: Bool {
        maxPictureCount > 0 || maxMediaCount > 0
    }

    var canRecordVideos: Bool {
        maxVideoCount > 0 || maxMediaCount > 0
    }

    var isOneModeOnly: Bool {
        (maxPictureCount == 1 && maxMediaCount == 1) || (maxVideoCount == 1 && maxMediaCount == 1)
    }

    var shouldAutoClose: Bool {
        maxPictureCount == 1 || maxMediaCount == 1 || maxVideoCount == 1
    }

    var isSinglePicture: Bool {
        maxPictureCount == 1 || maxMediaCount == 1
    }
}

enum CameraMediaMode {
    case videoAndPicture(videoCount: Int? = nil, pictureCount: Int? = nil, videoDuration: Int? = nil)
    case media(mediaCount: Int? = nil, videoDuration: Int? = nil)
    case video(videoCount: Int? = nil, videoDuration: Int? = nil)
    case picture(pictureCount: Int? = nil)
    case singleVideo(videoDuration: Int? = nil)
    case singlePicture
    case singleVideoOrPicture(videoDuration: Int? = nil)
}

extension URL {
    /// An URL object containing the URL of the output file.
    fileprivate static var outputFileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .first!
    }
}

/// Represents the posibles status of a
/// capture photo process.
enum CapturePhotoStatus {
    /// Initial state
    case initial

    /// When photo is being captured
    case capturing

    /// Whether the capture photo has failed
    case failed

    /// Whether the recording has finished
    case finished
}

/// Represents the posibles status of the
/// recording video process.
enum RecordStatus: Equatable {
    /// Initial state
    case initial

    /// When the camera has been initialized
    case initialized

    /// Whether the recording has finished
    case finished

    /// Whether is paused
    case paused

    /// Whether is recording
    case recording

    /// Whether video is being saved
    case saving
}

/// Represents the posibles status for the torch.
enum TorchStatus: String {
    /// When the camera has been initialized
    case notSupported

    /// Whether is paused
    case off

    /// Whether the recording has finished
    case on

    /// Returns the `TruVideoFlashMode` for the current status.
    var flashMode: TruVideoFlashMode {
        self == .on ? .on : .off
    }

    /// Returns the `TruVideoTorchMode` for the current status.
    var torchMode: TruVideoTorchMode {
        self == .on ? .on : .off
    }
}

/// Handles the comunication between the `CameraViewModel` with its state and events.
class CameraViewModelDeprecation: ObservableObject {

    typealias Handler = () throws -> Void

    var onStartHandler: Handler?
    var onRestartHandler: Handler?
    var cancellables = Set<AnyCancellable>()
    let preset: TruvideoSdkCameraConfiguration

    private var didStartRecorder = false
    private var backTorchStatus: TorchStatus = .notSupported
    private var frontTorchStatus: TorchStatus = .notSupported
    private let outputFileURL: URL
    private(set) var recorder: TruVideoRecorder
    let eventsHandler: (TruvideoSdkCameraEventType) -> Void

    @Published var page: Page {
        didSet {
            isShowingBlurView = page != .camera
        }
    }
    private(set) var allowRecordingVideos: Bool
    private(set) var isOneModeOnly: Bool
    private(set) var isSinglePictureMode: Bool

    /// The current camera position.
    @Published private(set) var cameraPosition: TruVideoDevicePosition = .back

    /// Current capture photo status.
    @Published private(set) var capturePhotoStatus: CapturePhotoStatus = .initial

    /// The clips generated during the session.
    private(set) var clips: [TruVideoClip] = []

    /// The photos taken in this session.
    @Published private(set) var photos: [TruVideoPhoto] = []

    /// Current record status.
    @Published var recordStatus: RecordStatus = .initial

    /// The amount of seconds recorded.
    @Published private(set) var secondsRecorded: Double = 0

    /// Current loading status.
    @Published private(set) var status: DataLoadStatus = .initial

    /// The current torch status depending of the camera position.
    @Published var torchStatus: TorchStatus = .notSupported

    /// Current availability of flash button.
    @Published var shouldShowFlashButton: Bool = false

    /// The current image quality of the camera.
    @Published var selectedResolution: TruvideoSdkCameraResolutionFormat {
        didSet {
            beginConfiguration()
        }
    }

    /// Current rotation angle used for rotating icons and views
    @Published private(set) var rotationAngle: Angle = .degrees(0)

    /// Current textview aligment in ZStack
    @Published private(set) var timerViewAlignment: Alignment = .top {
        didSet {
            if timerViewAlignment == .top {
                timerViewOffset = CGSize(width: 0.0, height: 12.0)
            } else if timerViewAlignment == .bottom {
                timerViewOffset = CGSize(width: 0.0, height: -12.0)
            } else if timerViewAlignment == .leading {
                timerViewOffset = CGSize(width: -20.0, height: 0.0)
            } else if timerViewAlignment == .trailing {
                timerViewOffset = CGSize(width: 20.0, height: 0.0)
            }
        }
    }
    /// Current textview offset
    @Published var timerViewOffset: CGSize = CGSize(width: 0.0, height: 12.0)

    /// Current textview aligment in ZStack
    @Published private(set) var zoomViewAlignment: Alignment = .bottom

    /// Current close aligment in ZStack
    @Published private(set) var closeButtonAlignment: Alignment = .topTrailing

    /// Current continuebutton aligment in ZStack
    @Published private(set) var continueButtonAlignment: Alignment = .topTrailing {
        didSet {
            if continueButtonAlignment == .topLeading {
                continueButtonOffset = CGSize(
                    width: -16,
                    height: 32
                )
            } else if continueButtonAlignment == .bottomTrailing {
                continueButtonOffset = CGSize(
                    width: 16,
                    height: -32
                )
            } else {
                continueButtonOffset = .zero
            }
        }
    }

    /// Current continue button offset
    @Published private(set) var continueButtonOffset: CGSize = .zero

    /// Current media counter button aligment in ZStack
    @Published private(set) var mediaCounterAlignment: Alignment = .topLeading {
        didSet {
            if mediaCounterAlignment == .topTrailing {
                mediaCounterOffset = CGSize(
                    width: 0,
                    height: 16
                )
            } else if mediaCounterAlignment == .bottomLeading {
                mediaCounterOffset = CGSize(
                    width: 0,
                    height: -16
                )
            } else {
                mediaCounterOffset = .zero
            }
        }
    }

    /// Current toastOffset button offset
    @Published private(set) var toastOffset: CGSize = .zero

    /// The offset that must be applied to MediaCounter so it's correctly aligned when presented in landscape mode
    @Published var mediaCounterOffset: CGSize = .zero

    @Published var currentOrientation: UIDeviceOrientation {
        didSet {
            isPortrait = currentOrientation == .portrait || currentOrientation == .portraitUpsideDown
        }
    }

    /// The current `AVCaptureVideoPreviewLayer`.
    var previewLayer: AVCaptureVideoPreviewLayer {
        recorder.previewLayer
    }

    @Published var isAuthenticated: Bool

    /// Current zoom Factor
    @Published var zoomFactor: CGFloat = 1.0 {
        didSet {
            recorder.configureZoomFactor(to: zoomFactor)
        }
    }

    @Published var showResolutionPickerButton: Bool

    @Published var galleryCount: Int = 0 {
        didSet {
            guard galleryCount == 0 else { return }
            page = .camera
        }
    }

    @Published var previewImage: Image? {
        didSet {
            galleryCount += 1
        }
    }

    @Published var galleryItems = [GalleryItem]()
    @Published var galleryHeight = CGFloat.zero

    @Published var isPortrait: Bool
    @Published var isShowingBlurView: Bool = false

    private let zooming: CGFloat = 0.05
    var zoomFactorValues: [Int] = [1, 2, 3, 4, 5, 10]
    weak var cameraPreviewDelegate: CameraPreviewDelegate?
    let resolutionsManager: TruvideoSdkCameraResolutionManager
    var focusPoint: CGPoint = .zero
    private var isFlippingCameraInProgress = false
    let mediaScrollViewPadding: CGFloat = 12
    let mediaSizeExtraPadding: CGFloat = 16

    // For limiting media feature
    private var maxVideoCount = 10_000
    private var maxPictureCount = 10_000
    private var maxMediaCount = 10_000
    private(set) var maxVideoDuration: CGFloat?

    @Published var showToast = false

    var toastType = ToastType.none {
        didSet {
            switch toastType {
            case .none:
                showToast = false
            default:
                showToast = true
            }
        }
    }

    @Published var recordingIsPaused = false

    private(set) var isTakingNewPhoto = false
    private(set) var isRecordingNewVideo = false

    private var media: [TruvideoSdkCameraMedia] {
        get async {
            let mediaPhotos = photos.map(\.mediaRepresentation)
            var mediaClips: [TruvideoSdkCameraMedia] = []

            for clip in clips {
                await mediaClips.append(clip.toMediaRepresentation())
            }

            let allmedias = mediaPhotos + mediaClips
            return allmedias.sorted(by: { $0.createdAt < $1.createdAt })
        }
    }

    var updateVideoCounter: ((Int) -> Void)?
    var updatePictureCounter: ((Int) -> Void)?

    /// An object used for indicating whether the app supports portrait mode to rotate and adjust the UI
    private let orientationManager: TruvideoOrientationInterface

    @Published private(set) var layoutOrientation: UIDeviceOrientation

    private var outputWasConfigured = false

    // - MARK: Initializers

    /// Creates a new instance of the `CameraViewModel`.
    ///
    /// - Parameters:
    ///    - recorder: The Raw Media Capture object.
    ///    - outputFileURL: The  output file URL for video recording.
    ///    - tokenProvider: The class that retrieving and refreshing the existing access token.
    init(
        recorder: TruVideoRecorder,
        preset: TruvideoSdkCameraConfiguration,
        authValidator: AuthValidator = AuthValidatorImp(),
        eventsHandler: @escaping (TruvideoSdkCameraEventType) -> Void = { _ in }
    ) {
        self.orientationManager = TruvideoSdkOrientationManager.shared
        self.layoutOrientation = .currentAppOrientation()
        self.currentOrientation = .currentAppOrientation()
        self.isPortrait = UIDeviceOrientation.currentAppOrientation().isPortrait

        self.eventsHandler = eventsHandler
        self.outputFileURL = URL(string: preset.outputPath) ?? .outputFileURL
        self.recorder = recorder
        self.preset = preset
        self.allowRecordingVideos = preset.mode.canRecordVideos
        self.isSinglePictureMode = preset.mode.isSinglePicture
        self.isOneModeOnly = preset.mode.isOneModeOnly
        self.resolutionsManager = .init(
            backResolutions: [],
            frontResolutions: [],
            backResolution: .defaultResolution,
            frontResolution: .defaultResolution
        )
        self.showResolutionPickerButton = resolutionsManager.hasMultipleResolutions(
            for: preset.lensFacing == .front ? .front : .back
        )
        self.selectedResolution =
            resolutionsManager.getSelectedResolution(
                for: preset.lensFacing == .front ? .front : .back
            ) ?? .init(width: 0, height: 0, type: .back, format: nil)
        self.isAuthenticated = authValidator.isAuthenticated()
        self.page = .camera

        cameraPosition = preset.lensFacing == .front ? .front : .back
        setMaxVideoCount(preset.mode.maxVideoCount)
        setMaxPictureCount(preset.mode.maxPictureCount)
        setMaxVideoDuration(Int(preset.mode.maxVideoDuration))

        recorder.$isInterrupted
            .removeDuplicates()
            .filter { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.handlePauseRecording()
            }
            .store(in: &cancellables)

        recorder.isVideoRecordingPublisher
            .sink { [weak self] recordingIsPaused in
                DispatchQueue.main.async {
                    self?.recordingIsPaused = recordingIsPaused
                }
            }.store(in: &cancellables)

        orientationManager.appOrientationPublisher
            .sink { [weak self] newOrientation in
                self?.handleLayoutRotation(to: newOrientation)
            }.store(in: &cancellables)

        orientationManager.physicalOrientationPublisher
            .sink { [weak self] newOrientation in
                self?.handlePhysicalRotation(to: newOrientation)
            }.store(in: &cancellables)
    }

    private func handleLayoutRotation(to newOrientation: UIDeviceOrientation) {
        guard layoutOrientation != newOrientation else { return }

        recorder.previewOrientation = newOrientation
        recorder.updateOutputVideoOrientation(to: currentOrientation)

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.layoutOrientation = newOrientation
            self.updateUI()
        }
    }

    private func handlePhysicalRotation(to newOrientation: UIDeviceOrientation) {
        if UIDevice.current.userInterfaceIdiom == .phone && newOrientation == .portraitUpsideDown { return }

        guard
            currentOrientation != newOrientation,
            recordStatus != .recording
        else {
            return
        }

        recorder.updateOutputVideoOrientation(to: newOrientation)

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.currentOrientation = newOrientation
            self.updateUI()
        }
    }

    private func updateUI() {
        rotationAngle = computeRotationAngle()

        if layoutOrientation == currentOrientation {
            timerViewAlignment = .top
            zoomViewAlignment = .bottom
            mediaCounterAlignment = .topLeading
            continueButtonAlignment = .topTrailing
            return
        }

        switch (layoutOrientation, currentOrientation) {
        case (.portrait, .portraitUpsideDown):
            timerViewAlignment = .bottom
            zoomViewAlignment = .top
        case (.portrait, .landscapeRight):
            timerViewAlignment = .trailing
            zoomViewAlignment = .leading
            mediaCounterAlignment = .topTrailing
            continueButtonAlignment = .bottomTrailing
        case (.portrait, .landscapeLeft):
            timerViewAlignment = .leading
            zoomViewAlignment = .trailing
            mediaCounterAlignment = .bottomLeading
            continueButtonAlignment = .topLeading

        case (.landscapeRight, .portrait):
            timerViewAlignment = .leading
            zoomViewAlignment = .trailing
            mediaCounterAlignment = .bottomLeading
            continueButtonAlignment = .topLeading
        case (.landscapeRight, .portraitUpsideDown):
            timerViewAlignment = .trailing
            zoomViewAlignment = .leading
            mediaCounterAlignment = .topTrailing
            continueButtonAlignment = .bottomTrailing
        case (.landscapeRight, .landscapeLeft):
            timerViewAlignment = .bottom
            zoomViewAlignment = .top
            mediaCounterAlignment = .bottomTrailing
            continueButtonAlignment = .bottomLeading

        case (.landscapeLeft, .portrait):
            timerViewAlignment = .trailing
            zoomViewAlignment = .leading
            mediaCounterAlignment = .topTrailing
            continueButtonAlignment = .bottomTrailing
        case (.landscapeLeft, .portraitUpsideDown):
            timerViewAlignment = .leading
            zoomViewAlignment = .trailing
            mediaCounterAlignment = .bottomLeading
            continueButtonAlignment = .topLeading
        case (.landscapeLeft, .landscapeRight):
            timerViewAlignment = .bottom
            zoomViewAlignment = .top
            mediaCounterAlignment = .bottomTrailing
            continueButtonAlignment = .bottomLeading

        case (.portraitUpsideDown, .portrait):
            timerViewAlignment = .bottom
            zoomViewAlignment = .top
        case (.portraitUpsideDown, .landscapeLeft):
            timerViewAlignment = .trailing
            zoomViewAlignment = .leading
            mediaCounterAlignment = .topTrailing
            continueButtonAlignment = .bottomTrailing
        case (.portraitUpsideDown, .landscapeRight):
            timerViewAlignment = .leading
            zoomViewAlignment = .trailing
            mediaCounterAlignment = .bottomLeading
            continueButtonAlignment = .topLeading
        default:
            return
        }
    }

    private func computeRotationAngle() -> Angle {
        if currentOrientation == layoutOrientation {
            return .degrees(0)
        }
        switch (layoutOrientation, currentOrientation) {
        case (.portrait, .landscapeRight):
            return .degrees(90)
        case (.portrait, .landscapeLeft):
            return .degrees(-90)
        case (.portrait, .portraitUpsideDown):
            return .degrees(180)

        case (.landscapeLeft, .landscapeRight):
            return .degrees(180)
        case (.landscapeLeft, .portrait):
            return .degrees(90)
        case (.landscapeLeft, .portraitUpsideDown):
            return .degrees(-90)

        case (.landscapeRight, .landscapeLeft):
            return .degrees(180)
        case (.landscapeRight, .portrait):
            return .degrees(-90)
        case (.landscapeRight, .portraitUpsideDown):
            return .degrees(90)

        case (.portraitUpsideDown, .landscapeRight):
            return .degrees(-90)
        case (.portraitUpsideDown, .landscapeLeft):
            return .degrees(90)
        case (.portraitUpsideDown, .portrait):
            return .degrees(180)

        default:
            return .degrees(0)
        }
    }

    private func setMaxVideoCount(_ videoCount: Int?) {
        if let videoCount = videoCount {
            maxVideoCount = videoCount
        }
    }

    private func setMaxPictureCount(_ pictureCount: Int?) {
        if let pictureCount = pictureCount {
            maxPictureCount = pictureCount
        }
    }

    private func setMaxMediaCount(_ mediaCount: Int?) {
        if let mediaCount = mediaCount {
            maxMediaCount = mediaCount
        }
    }

    private func setMaxVideoDuration(_ videoDuration: Int?) {
        if let videoDuration = videoDuration {
            maxVideoDuration = CGFloat(videoDuration) / 1000.0
        }
    }

    deinit {
        TruvideoSdkOrientationManager.shared.stopOrientationTracking()
        recorder.cleanSession()
    }

    func getMediaResult() async -> TruvideoSdkCameraResult {
        let media = await media
        let result = TruvideoSdkCameraResult(media: media)
        if !media.isEmpty {
            eventsHandler(.truvideoSdkCameraEventMediaContinue(media: media))
        }
        Logger.addLog(event: .continueButtonPressed, eventMessage: .continueButtonPressed(result: result))
        return result
    }

    // - MARK: Instance methods

    /// Handles the `BeginConfigurationEvent` and emits the updated state for the view.
    func beginConfiguration() {
        guard recorder.renderDestinationProvider != nil else {
            return
        }

        status = .loading

        Task { @MainActor in
            do {
                if TruVideoRecorder.authorizationStatus(for: .video) != .authorized {
                    try await recorder.requestAuhorization(for: .video)
                }

                if TruVideoRecorder.authorizationStatus(for: .audio) != .authorized {
                    try await recorder.requestAuhorization(for: .audio)
                }

                recorder.outputDirectory = outputFileURL
                recorder.videoStabilizationMode = .off
                recorder.videoConfiguration.selectedResolution = resolutionsManager.getSelectedResolution(
                    for: cameraPosition
                )
                if !didStartRecorder {
                    didStartRecorder = true
                    if preset.lensFacing == .front {
                        await recorder.setDevicePosition(cameraPosition, fromConfiguration: true)
                    }
                    try onStartHandler?()
                    if recorder.isTorchAvailable {
                        torchStatus = preset.flashMode == .on ? .on : .off
                    } else {
                        torchStatus = .notSupported
                    }
                } else {
                    try onRestartHandler?()
                }

                recorder.photoConfiguration.flashMode = preset.flashMode == .on ? .on : .off
                recordStatus = .initialized
                updateShowFlashButton()
                status = .success
            } catch {
                Logger.logError(event: .initialConfiguration, eventMessage: .initialConfigurationFailed(error: error))
                status = .failure
            }
        }

        Task {
            while !outputWasConfigured {
                try? await Task.sleep(nanoseconds: 100_000_000)
                outputWasConfigured = recorder.updateOutputVideoOrientation(to: currentOrientation)
            }
        }
    }

    func updateUIConstraints(for newOrientation: UIDeviceOrientation) {
        if let angle = newOrientation.angle {
            rotationAngle = angle
        }

        switch newOrientation {
        case .portrait:
            updateUIConstraintsForPortraitMode()
        case .landscapeLeft:
            updateUIConstraintsForLandscapeLeftMode()
        case .landscapeRight:
            updateUIConstraintsForLandscapeRightMode()
        case .portraitUpsideDown:
            updateUIConstraintsForPortraitReverseMode()
        default:
            break
        }
    }

    func updateUIConstraintsForPortraitMode() {
        timerViewOffset = CGSize(width: 0.0, height: 10.0)
        timerViewAlignment = .top
        zoomViewAlignment = .bottom
        toastOffset = .zero

        closeButtonAlignment = .topTrailing
    }

    func updateUIConstraintsForLandscapeLeftMode() {
        timerViewOffset = CGSize(width: 0.0, height: -20.0)
        //        timerViewAlignment = .trailing
        //        zoomViewAlignment = .leading
        //        closeButtonAlignment = .bottomTrailing
        continueButtonOffset = CGSize(width: -32.0, height: -20.0)
        toastOffset = CGSize(width: -48.0, height: 0.0)
        mediaCounterAlignment = .topTrailing
    }

    func updateUIConstraintsForLandscapeRightMode() {
        timerViewOffset = CGSize(width: 0.0, height: -20.0)
        timerViewAlignment = .leading
        zoomViewAlignment = .trailing
        closeButtonAlignment = .topLeading
        continueButtonOffset = CGSize(width: -32.0, height: -20.0)
        toastOffset = CGSize(width: 48.0, height: 0.0)

        mediaCounterAlignment = .bottomLeading
    }

    func updateUIConstraintsForPortraitReverseMode() {
        timerViewOffset = CGSize(width: 0.0, height: 10.0)
        timerViewAlignment = .bottom
        zoomViewAlignment = .top
        toastOffset = .zero

        closeButtonAlignment = .bottomLeading
    }

    func setSelectedResolution(_ resolution: TruvideoSdkCameraResolutionFormat) {
        Logger.addLog(event: .changeResolution, eventMessage: .changeResolution(cameraFormat: resolution))
        resolutionsManager.setSelectedResolution(resolution)
        selectedResolution = resolution
        eventsHandler(.truvideoSdkCameraEventResolutionChanged(resolution: resolution))
    }

    func getResolutions() -> [TruvideoSdkCameraResolutionFormat] {
        cameraPosition == .back ? resolutionsManager.backResolutions : resolutionsManager.frontResolutions
    }

    func setupMediaSize(geometry: GeometryProxy) {
        let mediaSize = (geometry.size.width / 2) - mediaScrollViewPadding
        var rows: Int = galleryCount / 2
        rows += (galleryCount % 2 == 0 ? 0 : 1)
        galleryHeight = CGFloat(rows) * (mediaSize + mediaSizeExtraPadding)
    }

    func handlePauseVideoRecording(propagatingEvents: Bool = true) {
        if propagatingEvents {
            handlePauseAndResumeEvents()
        }
        recorder.handlePauseVideoRecording()
        recordingIsPaused.toggle()
    }

    /// Flips the video camera's video output.
    ///
    /// - Note: This method allows you to flip the video camera's video output, which can be useful for
    /// applying various transformations or adjusting the camera orientation.
    @MainActor
    func flipCamera() {
        if isFlippingCameraInProgress { return }

        if isRecordingNewVideo && (clips.count >= maxVideoCount - 1 || clips.count + photos.count >= maxMediaCount - 1)
        {
            return
        }

        Task {
            guard status == .success else {
                return
            }

            isFlippingCameraInProgress = true
            let resumeRecording = recorder.isRecording

            let cameraPosition = cameraPosition == .back ? AVCaptureDevice.Position.front : .back
            Logger.addLog(event: .flipCamera, eventMessage: .flipCameraTo(lensFacing: cameraPosition))
            eventsHandler(
                .truvideoSdkCameraEventCameraFlipped(lensFacing: cameraPosition == .back ? .back : .front)
            )
            recorder.videoConfiguration.selectedResolution = resolutionsManager.getSelectedResolution(
                for: cameraPosition
            )

            showResolutionPickerButton = resolutionsManager.hasMultipleResolutions(
                for: cameraPosition
            )

            await recorder.setDevicePosition(cameraPosition)

            if !recorder.isTorchAvailable {
                if cameraPosition == .front {
                    self.cameraPosition = cameraPosition
                    frontTorchStatus = .notSupported
                } else {
                    self.cameraPosition = cameraPosition
                    torchStatus = .notSupported
                }
            } else {
                self.cameraPosition = cameraPosition
            }
            updateShowFlashButton()

            let deadline = resumeRecording ? 2.0 : 0.0
            DispatchQueue.main.asyncAfter(deadline: .now() + deadline) { [weak self] in
                self?.isFlippingCameraInProgress = false
            }
        }
    }

    /// Pauses the current video recording.
    ///
    /// - Note: This method allows you to pause the current video recording that is in progress.
    func pause() {
        Logger.addLog(event: .stopRecording, eventMessage: .stopRecording)
        updateUI()
        if recordingIsPaused {
            handlePauseVideoRecording(propagatingEvents: false)
        }
        handlePauseRecording()
    }

    /// Starts recording a video using the specified camera device.
    ///
    /// - Note: This method allows you to start recording a video using the camera device.
    func record() {
        guard status == .success else {
            return
        }

        if recordingIsPaused {
            handlePauseVideoRecording(propagatingEvents: false)
        }
        recorder.videoConfiguration.transform = .identity
        recorder.updateOutputVideoOrientation(to: currentOrientation)

        recorder.setNeedsUpdateConfiguration()

        if torchStatus != .notSupported {
            do {
                try recorder.setTorchMode(torchStatus.torchMode)
            } catch {
                Logger.logError(event: .flash, eventMessage: .toggleFlashFailed(error: error))
                torchStatus = .notSupported
            }
        }

        DispatchQueue.main.asyncAfter(
            deadline: .now().advanced(by: DispatchTimeInterval.milliseconds(300))
        ) { [weak self] in
            guard let self else { return }

            Logger.addLog(event: .startRecording, eventMessage: .startRecording)
            eventsHandler(
                .truvideoSdkCameraEventRecordingStarted(
                    resolution: resolutionsManager.getSelectedResolution(
                        for: cameraPosition
                    ) ?? .init(width: 0, height: 0, type: .back, format: nil),
                    orientation: .portrait,
                    lensFacing: cameraPosition == .back ? .back : .front
                )
            )

            guard canKeepRecordingVideos() else {
                // show alert and return
                self.toastType = .maxVideoCountReached
                return
            }
            self.isRecordingNewVideo = true
            self.recorder.$secondsRecorded
                .receive(on: DispatchQueue.main)
                .removeDuplicates()
                .sink { [weak self] value in
                    guard let self else { return }
                    self.secondsRecorded = value
                    if let maxVideoDuration, value > maxVideoDuration {
                        Logger.addLog(
                            event: .maxVideoDurationReached,
                            eventMessage: .videoDurationLimitReached(limit: maxVideoDuration)
                        )
                        self.toastType = .maxVideoDurationReached
                        self.pause()
                        return
                    }
                }
                .store(in: &self.cancellables)

            self.recorder.record()
            self.recordStatus = .recording

            if self.torchStatus != .notSupported {
                Task {
                    do {
                        try await self.configureTorchForRecording()
                    } catch {
                        Logger.logError(event: .flash, eventMessage: .toggleFlashFailed(error: error))
                        DispatchQueue.main.async {
                            self.torchStatus = .notSupported
                        }
                    }
                }
            }
        }
    }

    /// Configures torch for recording on a background queue to avoid deadlocks
    private func configureTorchForRecording() async throws {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self else { return }

                do {
                    guard self.recorder.isTorchAvailable else {
                        DispatchQueue.main.async {
                            self.torchStatus = .notSupported
                        }
                        continuation.resume()
                        return
                    }

                    try self.recorder.setTorchMode(self.torchStatus.torchMode)
                    continuation.resume()

                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Stops the current video recording.
    ///
    /// - Note: This method allows you to stop the current video recording that is in progress.
    func stopRecording() {
        guard status == .success else {
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.status = .loading
            self.recordStatus = .finished
        }
    }

    func closeCamera() {
        Logger.addLog(event: .closeButtonPressed, eventMessage: .closeButtonPressed)
        guard galleryCount == 0 else {
            Logger.addLog(event: .openDiscardPanel, eventMessage: .openDiscardPanel)
            page = .close
            return
        }
        closeCameraAndDeleteMedia()
    }

    func closeCameraAndDeleteMedia() {
        Task { @MainActor in
            let media = await media
            Logger.addLog(event: .discard, eventMessage: .discardAllMedia)
            eventsHandler(.truvideoSdkCameraEventMediaDiscard(media: media))
            Task { @MainActor in
                defer {
                    recordStatus = .finished
                }

                status = .loading
                recorder.session?.deleteClips()
                clips = []
                deletePhotos()
                photos = []
            }
        }
    }

    private func deletePhotos() {
        for photo in photos {
            do {
                try FileManager.default.removeItem(at: photo.url)
            } catch {
                Logger.logError(event: .deleteMedia, eventMessage: .deleteMediaFailed(error: error))
                print("[TruVideoSession]: 🛑 failed to delete photo at: \(photo.url).")
            }
        }
    }

    private func deleteGalleryItem(at url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("[TruVideoSession]: 🛑 failed to delete photo at: \(url).")
        }
    }

    func canKeepRecordingVideos() -> Bool {
        if isTakingNewPhoto {
            if clips.count >= maxVideoCount {
                Logger.addLog(event: .startRecording, eventMessage: .videoLimitReached)
                return false
            } else if clips.count + photos.count >= maxMediaCount - 1 {
                Logger.addLog(event: .takePicture, eventMessage: .mediaLimitReached)
                return false
            }
            return true
        } else {
            if clips.count >= maxVideoCount {
                Logger.addLog(event: .startRecording, eventMessage: .videoLimitReached)
                return false
            } else if clips.count + photos.count >= maxMediaCount {
                Logger.addLog(event: .takePicture, eventMessage: .mediaLimitReached)
                return false
            }
            return true
        }
    }

    func canKeepTakingPhotos() -> Bool {
        if isRecordingNewVideo {
            if photos.count >= maxPictureCount {
                Logger.addLog(event: .takePicture, eventMessage: .pictureLimitReached)
                return false
            } else if clips.count + photos.count >= maxMediaCount - 1 {
                Logger.addLog(event: .takePicture, eventMessage: .mediaLimitReached)
                return false
            }
            return true
        } else {
            if photos.count >= maxPictureCount {
                Logger.addLog(event: .takePicture, eventMessage: .pictureLimitReached)
                return false
            } else if clips.count + photos.count >= maxMediaCount {
                Logger.addLog(event: .takePicture, eventMessage: .mediaLimitReached)
                return false
            }
            return true
        }
    }

    /// Takes a photo using the specified camera device.
    ///
    /// - Note: This method allows you to capture a photo using the camera device.
    func takePhoto() {
        Task { @MainActor in
            guard status == .success else {
                return
            }
            Logger.addLog(event: .takePicture, eventMessage: .takePicture)
            capturePhotoStatus = .capturing
            let photo = try? await capturePhoto()
            guard let photo = photo else {
                Logger.logError(event: .takePicture, eventMessage: .takePhotoFailed)
                capturePhotoStatus = .failed
                return
            }
            capturePhotoStatus = .finished
            photos.append(photo)
            eventsHandler(.truvideoSdkCameraEventPictureTaken(media: photo.mediaRepresentation))
            isTakingNewPhoto = false
            if shouldCloseCamera {
                stopRecording()
            } else {
                updatePictureCounter?(1)
                updatePreviewImage(photo.image, mediaType: .photo(photo: photo))
            }
        }
    }

    private var shouldCloseCamera: Bool {
        preset.mode.shouldAutoClose
            && (clips.count == maxVideoCount || photos.count == maxPictureCount
                || clips.count + photos.count == maxMediaCount)
    }

    func addClip(_ clip: TruVideoClip, withPreview image: UIImage?) {
        Task { @MainActor in
            let media = await clip.toMediaRepresentation()
            clips.append(clip)
            eventsHandler(.truvideoSdkCameraEventRecordingFinished(media: media))
            if shouldCloseCamera {
                stopRecording()
            } else {
                isRecordingNewVideo = false
                updateVideoCounter?(1)
                updatePreviewImage(image, mediaType: .video(clip: clip))
            }
        }
    }

    func updatePreviewImage(_ image: UIImage?, mediaType: MediaType) {
        Logger.addLog(event: .media, eventMessage: .newMedia(media: mediaType))
        guard let image else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.previewImage = Image(uiImage: image)
            self.galleryItems.append(.init(image: image, type: mediaType))
        }
    }

    func deleteClip(_ clip: TruVideoClip) {
        Task { @MainActor in
            var indexToDelete: Int?

            for (index, galleryItem) in galleryItems.enumerated() {
                switch galleryItem.type {
                case .video(let newClip):
                    if clip.url == newClip.url {
                        indexToDelete = index
                        break
                    }
                default:
                    continue
                }
            }

            guard let index = indexToDelete else {
                return
            }

            let media = await clip.toMediaRepresentation()

            Logger.addLog(event: .deleteMedia, eventMessage: .deleteMedia(media: .video(clip: clip)))
            eventsHandler(.truvideoSdkCameraEventMediaDeleted(media: media))
            deleteGalleryItem(at: clip.url)
            clips.removeAll { $0.url == clip.url }
            updateVideoCounter?(-1)
            galleryCount -= 1
            galleryItems.remove(at: index)

            returnToGalleryPreview()
        }
    }

    func deletePhoto(_ photo: TruVideoPhoto) {
        var indexToDelete: Int?

        for (index, galleryItem) in galleryItems.enumerated() {
            switch galleryItem.type {
            case .photo(let newPhoto):
                if photo.url == newPhoto.url {
                    indexToDelete = index
                    break
                }
            default:
                continue
            }
        }

        guard let index = indexToDelete else {
            return
        }

        Logger.addLog(event: .deleteMedia, eventMessage: .deleteMedia(media: .photo(photo: photo)))
        eventsHandler(.truvideoSdkCameraEventMediaDeleted(media: photo.mediaRepresentation))
        galleryItems.remove(at: index)
        photos.removeAll { $0 == photo }
        updatePictureCounter?(-1)
        deleteGalleryItem(at: photo.url)
        galleryCount -= 1

        returnToGalleryPreview()
    }

    /// Toggles the torch (flashlight) on the specified camera device.
    ///
    /// - Note: This method allows you to toggle the torch (flashlight) on or off for the specified camera device.
    func toggleTorch() {
        guard recorder.isTorchAvailable, status == .success else {
            return
        }

        do {
            Logger.addLog(event: .flash, eventMessage: .toggleFlashTo(currentFlashMode: torchStatus))
            let torchStatus = torchStatus == .off ? TorchStatus.on : .off
            Logger.addLog(event: .flash, eventMessage: .newFlashMode(flasModeName: torchStatus))

            if recordStatus == .recording {
                try recorder.setTorchMode(torchStatus.torchMode)
            }

            recorder.flashMode = torchStatus.flashMode
            self.torchStatus = torchStatus
            eventsHandler(
                .truvideoSdkCameraEventFlashModeChanged(flashMode: torchStatus == .on ? .on : .off)
            )

            if cameraPosition == .front {
                frontTorchStatus = torchStatus
            } else {
                backTorchStatus = torchStatus
            }
        } catch {
            Logger.logError(event: .flash, eventMessage: .toggleFlashFailed(error: error))
            if cameraPosition == .front {
                frontTorchStatus = .notSupported
            } else {
                backTorchStatus = .notSupported
            }
        }
    }

    func capturePhoto() async throws -> TruVideoPhoto? {
        guard canKeepTakingPhotos() else {
            // show alert and return
            if recordStatus != .recording {
                DispatchQueue.main.async { [weak self] in
                    self?.toastType = .maxPictureCountReached
                }
            }
            return nil
        }
        isTakingNewPhoto = true
        let isRecording = recordStatus == .recording
        return isRecording ? recorder.capturePhotoFromVideo() : try? await recorder.capturePhoto()
    }

    // - MARK: Private methods

    /// Handles the `PauseRecordingEvent` and emits the updated state for the view.
    private func handlePauseRecording() {
        Task { @MainActor in
            guard recorder.isRecording, status == .success else {
                return
            }

            if torchStatus != .notSupported {
                do {
                    try recorder.setTorchMode(.off)
                } catch {
                    Logger.logError(event: .flash, eventMessage: .toggleFlashFailed(error: error))
                    torchStatus = .notSupported
                }
            }

            do {
                recordStatus = .paused
                try await recorder.pause()
            } catch {
                Logger.logError(event: .stopRecording, eventMessage: .stopRecordingFailed(error: error))
                status = .failure
            }
        }
    }

    /// This function turns the torch on for every orientation change
    private func turnTorchOnIfNeeded() {
        if recordStatus == .recording && torchStatus == .on {
            do {
                try recorder.setTorchMode(.on, force: true)
            } catch {
                Logger.logError(event: .flash, eventMessage: .toggleFlashFailed(error: error))
            }
        }
    }

    private func updateShowFlashButton() {
        shouldShowFlashButton = cameraPosition == .back && recorder.isFlashAvailable
    }

    func increaseZoomFactor() {
        let currentIndex = zoomFactorValues.firstIndex { CGFloat($0) >= zoomFactor } ?? 0
        guard currentIndex < zoomFactorValues.count - 1 else { return }

        Logger.addLog(event: .zoom, eventMessage: .zoom(value: zoomFactor))
        eventsHandler(
            .truvideoSdkCameraEventZoomChanged(zoom: Float(zoomFactor))
        )
    }

    func decreaseZoomFactor() {
        let currentIndex = zoomFactorValues.lastIndex { CGFloat($0) <= zoomFactor } ?? zoomFactorValues.count - 1
        guard currentIndex > 0 else { return }

        Logger.addLog(event: .zoom, eventMessage: .zoom(value: zoomFactor))
        eventsHandler(
            .truvideoSdkCameraEventZoomChanged(zoom: Float(zoomFactor))
        )
    }

    func applyFocusOnFocusPoint() {
        Logger.addLog(event: .focus, eventMessage: .focusRequested)
        cameraPreviewDelegate?.addImageAt(focusPoint)
        recorder.focus(at: previewLayer.captureDevicePointConverted(fromLayerPoint: focusPoint))
    }

    func showPreview(of mediaType: MediaType) {
        Logger.addLog(event: .openMediaDetailPanel, eventMessage: .openDetailMediaPanel(media: mediaType))
        switch mediaType {
        case .photo(let photo):
            page = .photoPreview(photo: photo)
        case .video(let clip):
            page = .videoPreview(clip: clip)
        }
    }

    func navigateToGalleryPreview() {
        guard recordStatus != .recording else { return }
        guard galleryItems.count == 1 else {
            Logger.addLog(event: .openMediaPanel, eventMessage: .openMediaPanel)
            page = .galleryPreview
            return
        }
        Logger.addLog(event: .openMediaPanel, eventMessage: .openDetailMediaPanel(media: galleryItems[0].type))
        showPreview(of: galleryItems[0].type)
    }

    func returnToGalleryPreview() {
        guard galleryItems.count <= 1 else {
            page = .galleryPreview
            return
        }

        page = .camera
    }

    func navigateToCameraView() {
        page = .camera
    }

    func navigateToResolutionPickerView() {
        Logger.addLog(event: .openResolutionPanel, eventMessage: .openResolutionPanel)
        page = .resolutionPicker
    }

    private func handlePauseAndResumeEvents() {
        if recordingIsPaused {
            eventsHandler(
                .truvideoSdkCameraEventRecordingResumed(
                    resolution: resolutionsManager.getSelectedResolution(
                        for: cameraPosition
                    ) ?? .init(width: 0, height: 0, type: .back, format: nil),
                    orientation: .portrait,
                    lensFacing: cameraPosition == .back ? .back : .front
                )
            )
        } else {
            eventsHandler(
                .truvideoSdkCameraEventRecordingPaused(
                    resolution: resolutionsManager.getSelectedResolution(
                        for: cameraPosition
                    ) ?? .init(width: 0, height: 0, type: .back, format: nil),
                    orientation: .portrait,
                    lensFacing: cameraPosition == .back ? .back : .front
                )
            )
        }
    }
}

extension CameraViewModelDeprecation: PreviewImageDelegate {}

protocol PreviewImageDelegate: AnyObject {
    func addClip(_ clip: TruVideoClip, withPreview image: UIImage?)
}
