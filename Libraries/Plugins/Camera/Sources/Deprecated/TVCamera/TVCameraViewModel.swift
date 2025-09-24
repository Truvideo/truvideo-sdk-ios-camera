//
//  TVCameraViewModel.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 3/26/25.
//

import AVKit
import Combine
import Foundation
import SwiftUI

class TVCameraViewModel: ObservableObject {
    // - MARK: TVCameraPreviewV1
    @Published var timerViewOffset: CGSize = CGSize(width: 0.0, height: 12.0)
    @Published private(set) var continueButtonOffset: CGSize = .zero
    @Published private(set) var toastOffset: CGSize = .zero
    @Published var mediaCounterOffset: CGSize = .zero

    @Published private(set) var zoomViewAlignment: Alignment = .bottom
    @Published private(set) var closeButtonAlignment: Alignment = .topTrailing
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

    // - MARK: Class name
    let className = String(describing: TVCameraViewModel.self)

    // - MARK: Segmented Option
    @Published var segmendtedOption: TVMediaCounterPickerButton.SegmentedOption

    // - MARK: Public properties
    @Published private(set) var isAuthenticated = false

    @Published private(set) var isRecording = false {
        didSet {
            if isRecording {
                recordStatus = .recording
            } else {
                recordStatus = .initial
            }
        }
    }

    @Published private(set) var photos = [TruVideoPhoto]()
    @Published private(set) var videos = [TruVideoClip]()

    @Published private(set) var overlayPage: CameraOverlayPage?

    /// The current camera position.
    @Published private(set) var cameraPosition: TruVideoDevicePosition

    var previewLayer: AVCaptureVideoPreviewLayer {
        cameraManager.previewLayer
    }

    @Published var resolutionImage: Image = ResolutionImageFactory.image(for: .fullHD)

    let preset: TruvideoSdkCameraConfiguration

    // - MARK: Private properties
    private let cameraManager: TVCameraManagerProtocol

    private var store = Set<AnyCancellable>()

    // - MARK: Delegates
    weak var cameraPreviewDelegate: CameraPreviewDelegate?

    weak var mediaCounterDelegate: MediaCounterProtocol?

    // - MARK: Orientation
    /// An object used for indicating whether the app supports portrait mode to rotate and adjust the UI
    private let orientationManager: TruvideoOrientationInterface
    @Published private(set) var layoutOrientation: UIDeviceOrientation
    @Published private(set) var currentOrientation: UIDeviceOrientation
    @Published var rotationAngleValue: Angle = .zero

    // - MARK: Torch
    @Published var torchStatus: TorchStatus = .off

    // - MARK: Flash
    @Published var shouldShowFlashButton: Bool

    // - MARK: Resolution
    @Published var showResolutionPickerButton: Bool

    // MARK: - Permissions
    @Published var showPermissionDeniedAlert = false

    let resolutionsManager: TruvideoSdkCameraResolutionManager

    // MARK: - Resolution
    @Published var cameraPreviewAspectRatio: CGFloat = .zero

    var selectedResolution: TruvideoSdkCameraResolutionFormat {
        resolutionsManager.getSelectedResolution(
            for: cameraPosition == .back ? .back : .front
        ) ?? .defaultResolutionFormat
    }

    // - MARK: Camera Mode
    let isOneModeOnly: Bool
    @Published var isSinglePictureMode: Bool
    @Published var showToast = false

    // For limiting media feature
    private var maxVideoCount = 10_000
    private var maxPictureCount = 10_000
    private var maxMediaCount = 10_000
    private(set) var maxVideoDuration: CGFloat?

    private(set) var isTakingNewPhoto = false
    private(set) var isRecordingNewVideo = false

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

    // - MARK: Record
    @Published var recordStatus: RecordStatus = .initial
    @Published var recordingIsPaused: Bool = false

    // - MARK: Camera Preview
    /// The amount of seconds recorded.
    @Published private(set) var secondsRecorded: Double = 0

    // - MARK: Zoom
    @Published var zoomFactor: CGFloat = 1.0 {
        didSet {
            cameraManager.configureZoomFactor(to: zoomFactor)
        }
    }

    /// Continuous zoom range values
    let zoomFactorRange: ClosedRange<Int> = 1 ... 10
    private let zooming: CGFloat = 0.05

    /// Discrete zoom values shown in the UI
    var zoomFactorValues: [Int] = Array(1 ... 5) + [10]

    // - MARK: Tap to focus
    var focusPoint: CGPoint = .zero

    // - MARK: Gallery
    @Published var galleryItems = [GalleryItem]()
    @Published var galleryItemSize = CGFloat.zero
    @Published var gallerySize = CGFloat.zero

    let mediaScrollViewPadding: CGFloat = 12
    let mediaSizeExtraPadding: CGFloat = 16

    // - MARK: On Complete Method
    let onComplete: ((TruvideoSdkCameraResult) -> Void)?

    // - MARK: Event Handler
    private let eventsHandler: (TruvideoSdkCameraEventType) -> Void

    private var isFlippingCameraInProgress = false

    @Published var showPreview: Bool

    private var outputWasConfigured = false

    var onDismiss: (() -> Void)?

    init(
        preset: TruvideoSdkCameraConfiguration,
        cameraManager: TVCameraManagerProtocol,
        authValidator: AuthValidator = AuthValidatorImp(),
        showPreview: Bool = true,
        eventsHandler: @escaping (TruvideoSdkCameraEventType) -> Void = { _ in },
        onComplete: @escaping (TruvideoSdkCameraResult) -> Void
    ) {
        // Orientation configuration
        self.orientationManager = TruvideoSdkOrientationManager.shared

        self.layoutOrientation = .currentAppOrientation()
        self.currentOrientation = .currentAppOrientation()
        self.onComplete = { result in
            TruvideoSdkOrientationManager.shared.unlockAppOrientation()
            onComplete(result)
        }

        self.preset = preset
        self.cameraManager = cameraManager
        self.eventsHandler = eventsHandler
        self.isAuthenticated = authValidator.isAuthenticated()

        // Camera configuration
        self.torchStatus = preset.flashMode == .on ? .on : .off
        self.cameraPosition = preset.lensFacing == .front ? .front : .back
        self.shouldShowFlashButton = cameraManager.isFlashAvailable

        // Resolution
        self.resolutionsManager = .init(
            backResolutions: [],
            frontResolutions: [],
            backResolution: .init(width: 1_280, height: 720),
            frontResolution: .init(width: 1_280, height: 720)
        )

        self.showResolutionPickerButton = resolutionsManager.hasMultipleResolutions(
            for: preset.lensFacing == .front ? .front : .back
        )

        // Camera Mode
        self.isOneModeOnly = preset.mode.isOneModeOnly
        self.isSinglePictureMode = preset.mode.isSinglePicture
        self.segmendtedOption = preset.mode.canRecordVideos ? .videos : .photos
        self.showPreview = showPreview

        updateResolutionAspectRatio(using: selectedResolution)
        setMaxVideoCount(preset.mode.maxVideoCount)
        setMaxPictureCount(preset.mode.maxPictureCount)
        setMaxVideoDuration(Int(preset.mode.maxVideoDuration))

        rotationAngleValue = computeRotationAngle()
        updateUIElementsIfNecessary()
        subscribeToOrientationUpdates()
        subscribeToManagerUpdates()
        subscribeToPermissionsUpdates()
        recheckPermissions()

        let position = preset.lensFacing == .back ? TruVideoDevicePosition.back : .front

        if let currentResolution = resolutionsManager.getSelectedResolution(for: position) {
            updateResolutionButton(with: currentResolution)
        }
    }

    func setupInitialCameraPreview() {
        Task {
            while !outputWasConfigured {
                outputWasConfigured = cameraManager.updateVideoPreviewOrientation(layoutOrientation)
                if !outputWasConfigured {
                    try? await Task.sleep(nanoseconds: 100_000_000)
                }
            }

            cameraManager.updateVideoConnectionOrientation(currentOrientation)
        }
    }

    // - MARK: Private methods
    private func subscribeToOrientationUpdates() {
        orientationManager.appOrientationPublisher
            .removeDuplicates()
            .sink { [weak self] newOrientation in
                self?.handleLayoutRotation(to: newOrientation)
            }.store(in: &store)

        if UIDevice.current.userInterfaceIdiom != .pad {
            orientationManager.physicalOrientationPublisher
                .removeDuplicates()
                .sink { [weak self] newOrientation in
                    self?.handlePhysicalRotation(to: newOrientation)
                }.store(in: &store)
        }
    }

    private func subscribeToManagerUpdates() {
        cameraManager.isRecordingPublisher
            .sink { [weak self] isRecording in
                self?.executeOnMainThread {
                    self?.isRecording = isRecording
                }
            }.store(in: &store)

        cameraManager.isVideoPausedPublisher
            .sink { [weak self] recordingIsPaused in
                self?.executeOnMainThread {
                    self?.recordingIsPaused = recordingIsPaused
                }
            }.store(in: &store)

        cameraManager.photosPublisher
            .sink { [weak self] photo in
                self?.handleNewPhoto(photo)
            }.store(in: &store)

        cameraManager.videosPublisher
            .sink { [weak self] video in
                self?.handleNewVideo(video)
            }.store(in: &store)

        cameraManager.torchPublisher
            .sink { [weak self] torchStatus in
                self?.executeOnMainThread {
                    self?.torchStatus = torchStatus
                }
            }.store(in: &store)

        cameraManager.recordedDurationPublisher
            .sink { [weak self] recordedDuration in
                self?.executeOnMainThread {
                    self?.handleRecordedDurationUpdate(recordedDuration)
                }
            }.store(in: &store)

        cameraManager.flipCameraPublisher
            .sink { [weak self] torchStatus in
                self?.executeOnMainThread {
                    self?.isFlippingCameraInProgress = false
                    self?.shouldShowFlashButton = self?.cameraManager.isFlashAvailable ?? true
                }
            }.store(in: &store)

        cameraManager.showLoaderPublisher
            .sink { [weak self] showLoader in
                self?.executeOnMainThread {
                    if showLoader {
                        self?.overlayPage = .loading
                    } else {
                        self?.overlayPage = nil
                    }
                }
            }.store(in: &store)
    }

    private func subscribeToPermissionsUpdates() {
        cameraManager.permissionStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.showPermissionDeniedAlert = !status
            }
            .store(in: &store)
    }

    private func recheckPermissions() {
        Task { @MainActor in
            let currentPermissionStatus = cameraManager.getCurrentPermissionStatus()
            self.showPermissionDeniedAlert = !currentPermissionStatus
        }
    }

    private func handleNewVideo(_ video: TruVideoClip) {
        Task { @MainActor in
            dprint(className, "handle new video")
            guard let lastFrameImage = video.thumbnailImage else { return }

            let media = await video.toMediaRepresentation()
            dprint(className, "handle new video - 2")
            self.videos.append(video)
            self.isRecordingNewVideo = false
            self.secondsRecorded = 0
            self.galleryItems.append(.init(image: lastFrameImage, type: .video(clip: video)))
            self.mediaCounterDelegate?.updateVideoCounter(increment: 1)
            self.mediaCounterDelegate?.addPreview(lastFrameImage)

            eventsHandler(.truvideoSdkCameraEventRecordingFinished(media: media))

            if self.shouldCloseCamera() {
                closeCameraWithSaving()
            }
        }
    }

    private func handleNewPhoto(_ photo: TruVideoPhoto) {
        executeOnMainThread { [weak self] in
            guard let self, let image = photo.image else { return }
            self.photos.append(photo)
            self.isTakingNewPhoto = false
            self.galleryItems.append(.init(image: photo.image ?? UIImage(), type: .photo(photo: photo)))
            self.mediaCounterDelegate?.updatePictureCounter(increment: 1)
            self.mediaCounterDelegate?.addPreview(image)

            eventsHandler(.truvideoSdkCameraEventPictureTaken(media: photo.mediaRepresentation))

            if self.shouldCloseCamera() {
                closeCameraWithSaving()
            }
        }
    }

    private func handleRecordedDurationUpdate(_ recordedDuration: Double) {
        executeOnMainThread { [weak self] in
            guard let self else { return }
            self.secondsRecorded = recordedDuration
            if let maxVideoDuration = self.maxVideoDuration, recordedDuration > maxVideoDuration {
                Logger.addLog(
                    event: .maxVideoDurationReached,
                    eventMessage: .videoDurationLimitReached(limit: maxVideoDuration)
                )
                self.toastType = .maxVideoDurationReached
                self.recordTapped()
                return
            }
        }
    }

    private func handleLayoutRotation(to newOrientation: UIDeviceOrientation) {
        dprint(className, "handle new layout orientation [\(newOrientation.title)]")
        guard layoutOrientation != newOrientation else {
            dprint(className, "same layout orientation [RECEIVED]")
            return
        }

        if cameraManager.updateVideoPreviewOrientation(newOrientation) {
            dprint(className, "new video preview was [CONFIGURED]")
        } else {
            dprint(className, "new video preview was [NOT CONFIGURED]")
        }

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.layoutOrientation = newOrientation
            self.updateResolutionAspectRatio(using: selectedResolution)
            self.rotationAngleValue = .zero
        }
    }

    private func handlePhysicalRotation(to newOrientation: UIDeviceOrientation) {
        dprint(className, "handle new physical orientation [\(newOrientation.title)]")

        if UIDevice.current.userInterfaceIdiom == .phone && newOrientation == .portraitUpsideDown {
            dprint(className, "iPhone portrait upside down [RECEIVED]")
            return
        }

        guard currentOrientation != newOrientation else {
            dprint(className, "same orientation [RECEIVED]")
            return
        }

        guard !isRecording else { return }

        mediaCounterDelegate?.updateVideoCounter(increment: 0)
        self.currentOrientation = newOrientation
        let rotationAngle = computeRotationAngle()

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            dprint(className, "UI with \(newOrientation.title) [UPDATED]")
            rotationAngleValue = rotationAngle
            updateUIElementsIfNecessary()
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

    private func updateUIElementsIfNecessary() {
        if layoutOrientation == currentOrientation {
            timerViewAlignment = .top
            zoomViewAlignment = .bottom
            mediaCounterAlignment = .topLeading
            continueButtonAlignment = .topTrailing
            return
        }

        if UIDevice.current.userInterfaceIdiom == .pad {
            timerViewAlignment = .top
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

    private func executeOnMainThread(_ block: @escaping () -> Void) {
        DispatchQueue.main.async {
            block()
        }
    }

    // MARK: - Capture input
    func capture() {
        switch segmendtedOption {
        case .photos:
            takePhoto()
        case .videos:
            recordTapped()
        }
    }

    private func recordTapped() {
        if isFlippingCameraInProgress {
            return
        } else if isRecording {
            cameraManager.toggleRecord()  // finish recording
        } else if isRecordingNewVideo {
            return  // wait for availability
        } else if canKeepRecordingVideos() {
            isRecordingNewVideo = true  // start new recording
            cameraManager.updateVideoConnectionOrientation(currentOrientation)
            cameraManager.toggleRecord()
            eventsHandler(
                .truvideoSdkCameraEventRecordingStarted(
                    resolution: resolutionsManager.getSelectedResolution(
                        for: cameraPosition
                    ) ?? .init(width: 0, height: 0, type: .back, format: nil),
                    orientation: .portrait,
                    lensFacing: cameraPosition == .back ? .back : .front
                )
            )
        } else {
            toastType = .maxVideoCountReached
        }
    }

    func takePhoto() {
        if isFlippingCameraInProgress || isTakingNewPhoto {
            return  // wait for availability
        } else if canKeepTakingPhotos() {
            isTakingNewPhoto = true
            cameraManager.updateVideoConnectionOrientation(currentOrientation)
            cameraManager.takePhoto()
        } else {
            toastType = .maxPictureCountReached
        }
    }

    func getCameraResult() async -> TruvideoSdkCameraResult {
        var media: [TruvideoSdkCameraMedia] = photos.map { $0.mediaRepresentation }
        var mediaClips: [TruvideoSdkCameraMedia] = []

        for clip in videos {
            await mediaClips.append(clip.toMediaRepresentation())
        }

        media += mediaClips
        eventsHandler(.truvideoSdkCameraEventMediaContinue(media: media))

        return .init(media: media)
    }

    func pauseTapped() {
        if isFlippingCameraInProgress { return }
        cameraManager.pauseRecord()
    }

    func flipTapped() {
        if isFlippingCameraInProgress { return }

        if isRecordingNewVideo
            && (videos.count >= maxVideoCount - 1 || videos.count + photos.count >= maxMediaCount - 1)
        {
            return
        }

        isFlippingCameraInProgress = true

        if cameraPosition == .back {
            cameraPosition = .front
        } else {
            cameraPosition = .back
        }

        showResolutionPickerButton = resolutionsManager.hasMultipleResolutions(
            for: cameraPosition
        )

        cameraManager.flipCamera()
        zoomFactor = 1.0
        eventsHandler(
            .truvideoSdkCameraEventCameraFlipped(lensFacing: cameraPosition == .back ? .back : .front)
        )
    }

    func changeResolution(to resolution: TruvideoSdkCameraResolutionFormat) {
        if isFlippingCameraInProgress { return }
        cameraManager.changeResolution(to: resolution)
        updateResolutionButton(with: resolution)
        updateResolutionAspectRatio(using: resolution)
        eventsHandler(.truvideoSdkCameraEventResolutionChanged(resolution: resolution))
    }

    private func updateResolutionAspectRatio(using resolution: TruvideoSdkCameraResolutionFormat) {
        if self.layoutOrientation.isPortrait {
            self.cameraPreviewAspectRatio = 1.0 / resolution.aspectRatio
        } else {
            self.cameraPreviewAspectRatio = resolution.aspectRatio
        }
    }

    private func updateResolutionButton(with resolution: TruvideoSdkCameraResolution) {
        self.resolutionImage =
            switch (resolution.width, resolution.height) {
            case (640, 480):
                ResolutionImageFactory.image(for: .sd)
            case (1280, 720):
                ResolutionImageFactory.image(for: .hd)
            case (1920, 1080):
                ResolutionImageFactory.image(for: .fullHD)
            case (3840, 2160):
                ResolutionImageFactory.image(for: .uhd)
            default:
                ResolutionImageFactory.image(for: .fullHD)
            }
    }

    func toggleFlash() {
        if isFlippingCameraInProgress { return }
        cameraManager.toggleFlash()
        eventsHandler(
            .truvideoSdkCameraEventFlashModeChanged(flashMode: torchStatus == .on ? .on : .off)
        )
    }

    // Close camera
    func closeCameraWithoutSaving() {
        Logger.addLog(event: .closeButtonPressed, eventMessage: .closeButtonPressed)
        guard galleryItems.isEmpty else {
            Logger.addLog(event: .openDiscardPanel, eventMessage: .openDiscardPanel)
            overlayPage = .close
            return
        }

        deleteMedia()

        onComplete?(.init(media: []))
        onDismiss?()
    }

    func closeCameraAndDeleteMedia() {
        Task { @MainActor in
            var media: [TruvideoSdkCameraMedia] = photos.map { $0.mediaRepresentation }
            var mediaClips: [TruvideoSdkCameraMedia] = []

            for clip in videos {
                await mediaClips.append(clip.toMediaRepresentation())
            }

            media += mediaClips

            eventsHandler(.truvideoSdkCameraEventMediaDiscard(media: media))

            deleteMedia()

            onComplete?(.init(media: []))
            onDismiss?()
        }
    }

    private func deleteMedia() {
        Logger.addLog(event: .discard, eventMessage: .discardAllMedia)

        for photo in photos {
            do {
                try FileManager.default.removeItem(at: photo.url)
            } catch {
                Logger.logError(event: .deleteMedia, eventMessage: .deleteMediaFailed(error: error))
                print("[TruVideoCameraViewModel]: 🛑 failed to delete photo at: \(photo.url).")
            }
        }

        for video in videos {
            do {
                try FileManager.default.removeItem(at: video.url)
            } catch {
                print("[TruVideoCameraViewModel]: 🛑 failed to delete video at: \(video.url)")
            }
        }
    }

    func closeCameraWithSaving() {
        Task { @MainActor in
            var medias: [TruvideoSdkCameraMedia] = photos.map(\.mediaRepresentation)
            var mediaClips: [TruvideoSdkCameraMedia] = []

            for clip in videos {
                await mediaClips.append(clip.toMediaRepresentation())
            }

            medias += mediaClips
            let orderMedia = medias.sorted(by: { $0.createdAt < $1.createdAt })

            onComplete?(.init(media: orderMedia))
            onDismiss?()
        }
    }

    // - MARK: Navigation
    func navigateToResolutionPickerView() {
        overlayPage = .resolutionPicker
    }

    func navigateToGalleryPreview() {
        guard !isRecording, !galleryItems.isEmpty else { return }

        if galleryItems.count > 1 {
            Logger.addLog(event: .openMediaPanel, eventMessage: .openMediaPanel)
            overlayPage = .galleryPreview
            return
        }

        guard let firstGalleryItem = galleryItems.first else { return }

        Logger.addLog(event: .openMediaPanel, eventMessage: .openDetailMediaPanel(media: firstGalleryItem.type))
        showPreview(of: firstGalleryItem.type)
    }

    func navigateToCameraView() {
        overlayPage = nil
    }

    func returnToGalleryPreview() {
        guard galleryItems.count <= 1 else {
            overlayPage = .galleryPreview
            return
        }

        overlayPage = nil
    }

    // - MARK: Tap to focus
    func applyFocusOnFocusPoint() {
        Logger.addLog(event: .focus, eventMessage: .focusRequested)
        cameraPreviewDelegate?.addImageAt(focusPoint)
        cameraManager.focus(
            at: previewLayer.captureDevicePointConverted(fromLayerPoint: focusPoint)
        )
    }

    func increaseZoomFactor(useDiscrete: Bool = true) {
        if useDiscrete {
            let currentIndex = zoomFactorValues.firstIndex { CGFloat($0) >= zoomFactor } ?? 0
            guard currentIndex < zoomFactorValues.count - 1 else { return }

            zoomFactor = CGFloat(zoomFactorValues[currentIndex + 1])
        } else {
            guard zoomFactor + zooming <= CGFloat(zoomFactorRange.upperBound) else { return }

            zoomFactor += zooming
        }

        Logger.addLog(event: .zoom, eventMessage: .zoom(value: zoomFactor))
        eventsHandler(
            .truvideoSdkCameraEventZoomChanged(zoom: Float(zoomFactor))
        )
    }

    func decreaseZoomFactor(useDiscrete: Bool = true) {
        if useDiscrete {
            let currentIndex = zoomFactorValues.lastIndex { CGFloat($0) <= zoomFactor } ?? zoomFactorValues.count - 1
            guard currentIndex > 0 else { return }

            zoomFactor = CGFloat(zoomFactorValues[currentIndex - 1])
        } else {
            guard zoomFactor - zooming >= CGFloat(zoomFactorRange.lowerBound) else { return }

            zoomFactor -= zooming
        }

        Logger.addLog(event: .zoom, eventMessage: .zoom(value: zoomFactor))
        eventsHandler(
            .truvideoSdkCameraEventZoomChanged(zoom: Float(zoomFactor))
        )
    }

    func getResolutions() -> [TruvideoSdkCameraResolutionFormat] {
        cameraPosition == .back ? resolutionsManager.backResolutions : resolutionsManager.frontResolutions
    }

    // - MARK: Camera mode
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

    private func canKeepRecordingVideos() -> Bool {
        if isTakingNewPhoto {
            if videos.count >= maxVideoCount {
                Logger.addLog(event: .startRecording, eventMessage: .videoLimitReached)
                return false
            } else if videos.count + photos.count >= maxMediaCount - 1 {
                Logger.addLog(event: .takePicture, eventMessage: .mediaLimitReached)
                return false
            }
            return true
        } else {
            if videos.count >= maxVideoCount {
                Logger.addLog(event: .startRecording, eventMessage: .videoLimitReached)
                return false
            } else if videos.count + photos.count >= maxMediaCount {
                Logger.addLog(event: .takePicture, eventMessage: .mediaLimitReached)
                return false
            }
            return true
        }
    }

    private func canKeepTakingPhotos() -> Bool {
        if isRecordingNewVideo {
            if photos.count >= maxPictureCount {
                Logger.addLog(event: .takePicture, eventMessage: .pictureLimitReached)
                return false
            } else if videos.count + photos.count >= maxMediaCount - 1 {
                Logger.addLog(event: .takePicture, eventMessage: .mediaLimitReached)
                return false
            }
            return true
        } else {
            if photos.count >= maxPictureCount {
                Logger.addLog(event: .takePicture, eventMessage: .pictureLimitReached)
                return false
            } else if videos.count + photos.count >= maxMediaCount {
                Logger.addLog(event: .takePicture, eventMessage: .mediaLimitReached)
                return false
            }
            return true
        }
    }

    private func shouldCloseCamera() -> Bool {
        preset.mode.shouldAutoClose
            && (videos.count == maxVideoCount || photos.count == maxPictureCount
                || videos.count + photos.count == maxMediaCount)
    }

    // - MARK: Gallery
    func showPreview(of mediaType: MediaType) {
        Logger.addLog(event: .openMediaDetailPanel, eventMessage: .openDetailMediaPanel(media: mediaType))
        switch mediaType {
        case .photo(let photo):
            overlayPage = .photoPreview(photo: photo)
        case .video(let clip):
            overlayPage = .videoPreview(clip: clip)
        }
    }

    func setupMediaSize(geometry: GeometryProxy) {
        if layoutOrientation.isPortrait {
            galleryItemSize = (geometry.size.width / 2) - mediaScrollViewPadding
            var rows: Int = galleryItems.count / 2
            rows += (galleryItems.count % 2 == 0 ? 0 : 1)
            gallerySize = CGFloat(rows) * (galleryItemSize + mediaSizeExtraPadding)
        } else {
            galleryItemSize = (geometry.size.height / 2) - mediaScrollViewPadding
            var columns: Int = galleryItems.count / 2
            columns += (galleryItems.count % 2 == 0 ? 0 : 1)
            gallerySize = CGFloat(columns) * (galleryItemSize + mediaSizeExtraPadding)
        }
    }

    func deleteClip(_ clip: TruVideoClip) {
        Task { @MainActor in
            dprint(className, "video deletion [STARTED]")
            var indexToDelete: Int?

            for (index, galleryItem) in galleryItems.enumerated() {
                switch galleryItem.type {
                case .video(let newClip):
                    if clip.url == newClip.url {
                        indexToDelete = index
                        dprint(className, "index - video to delete [FOUND]")
                        break
                    }
                default:
                    continue
                }
            }

            guard let index = indexToDelete else {
                dprint(className, "video to delete was not [FOUND]")
                return
            }

            let media = await clip.toMediaRepresentation()
            Logger.addLog(event: .deleteMedia, eventMessage: .deleteMedia(media: .video(clip: clip)))
            eventsHandler(.truvideoSdkCameraEventMediaDeleted(media: media))
            galleryItems.remove(at: index)
            videos.removeAll { $0.url == clip.url }
            mediaCounterDelegate?.updateVideoCounter(increment: -1)
            mediaCounterDelegate?.removePreview()
            deleteGalleryItem(at: clip.url)

            dprint(className, "video to delete was [DELETED]")
            returnToGalleryPreview()
        }
    }

    private func deleteGalleryItem(at url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            dprint(className, "gallery item file could not be [DELETED]")
        }
    }

    func deletePhoto(_ photo: TruVideoPhoto) {
        dprint(className, "photo deletion [STARTED]")
        var indexToDelete: Int?

        for (index, galleryItem) in galleryItems.enumerated() {
            switch galleryItem.type {
            case .photo(let newPhoto):
                if photo.url == newPhoto.url {
                    indexToDelete = index
                    dprint(className, "index - photo to delete [FOUND]")
                    break
                }
            default:
                continue
            }
        }

        guard let index = indexToDelete else {
            dprint(className, "photo to delete was [NOT FOUND]")
            return
        }

        Logger.addLog(event: .deleteMedia, eventMessage: .deleteMedia(media: .photo(photo: photo)))
        eventsHandler(.truvideoSdkCameraEventMediaDeleted(media: photo.mediaRepresentation))
        galleryItems.remove(at: index)
        photos.removeAll { $0 == photo }
        mediaCounterDelegate?.updatePictureCounter(increment: -1)
        mediaCounterDelegate?.removePreview()
        deleteGalleryItem(at: photo.url)

        dprint(className, "photo to delete was [DELETED]")
        returnToGalleryPreview()
    }
}
