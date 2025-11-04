//
//  ARCameraViewModel.swift
//  TruvideoSdkCamera
//
//  Created by Luis Francisco Piura Mejia on 9/7/24.
//

import ARKit
import Foundation
import SwiftUI

// MARK: - ARCameraViewModel
final class ARCameraViewModel: CameraViewModelDeprecation {

    /// Current deletion actions aligment in ZStack
    @Published private(set) var deletionActionsAlignment: Alignment = .topLeading
    @Published private(set) var clearButtonOffset: CGSize = CGSize(width: 0, height: 0)
    @Published private(set) var undoButtonOffset: CGSize = CGSize(width: 0, height: 0)
    @Published private(set) var toggleIcon: Image = TruVideoImage.arrows3D
    @Published var enableDeletionActions = false
    var selectedPinObjects: Bool { toggleIcon == TruVideoImage.arrows3D }
    var selectedVideo: Bool { toggleIcon == TruVideoImage.video }
    var selectedRuler: Bool { toggleIcon == TruVideoImage.ruler }
    @Published var selectedCentimeters = true
    @Published var selectedInches = false
    @Published var showClearDataAlert = false

    private var pendingAction: ARActionType?
    private var hasClipsOrPhotos: Bool { clips.count > 0 || photos.count > 0 }
    private var availableResolutions: [TruvideoSdkCameraResolutionFormat] = []
    private var defaultResolution: TruvideoSdkCameraResolutionFormat = .defaultResolutionFormat
    private var arVideoFormats: [ARConfiguration.VideoFormat] = []
    private var arConfiguration: ARWorldTrackingConfiguration?
    private var registeredPublishers = false

    @Published var shouldShowAROnboarding = false
    private let arOnboardingManager = AROnboardingManager.shared
    private var shouldCheckOnboardingOnReturn = false

    var arRenderer: ARRenderer? {
        recorder.arRenderer
    }

    init(
        recorder: TruVideoRecorder,
        preset: TruvideoSdkCameraConfiguration,
        eventsHandler: @escaping (TruvideoSdkCameraEventType) -> Void = { _ in }
    ) {
        super.init(recorder: recorder, preset: preset, eventsHandler: eventsHandler)

        refreshARResolutions()
        registerPagePublishers()
    }

    override func updateUIConstraintsForPortraitMode() {
        super.updateUIConstraintsForPortraitMode()
        deletionActionsAlignment = .topLeading
        clearButtonOffset = CGSize(width: 0, height: 0)
        undoButtonOffset = CGSize(width: 0, height: 0)
    }

    override func updateUIConstraintsForLandscapeLeftMode() {
        super.updateUIConstraintsForLandscapeLeftMode()
        deletionActionsAlignment = .topLeading
        clearButtonOffset = CGSize(width: 10, height: -10)
        undoButtonOffset = CGSize(width: 10, height: -10)
    }

    override func updateUIConstraintsForLandscapeRightMode() {
        super.updateUIConstraintsForLandscapeRightMode()
        deletionActionsAlignment = .bottomTrailing
        clearButtonOffset = CGSize(width: 10, height: -20)
        undoButtonOffset = CGSize(width: 10, height: -20)
    }

    override func updateUIConstraintsForPortraitReverseMode() {
        super.updateUIConstraintsForPortraitReverseMode()
        deletionActionsAlignment = .bottomTrailing
        clearButtonOffset = CGSize(width: 0, height: 0)
        undoButtonOffset = CGSize(width: 0, height: 0)
    }

    override func takePhoto() {
        guard canProceedWithPhotoCapture() else { return }

        super.takePhoto()
    }

    override func capturePhoto() async throws -> TruVideoPhoto? {
        guard canKeepTakingPhotos() else {
            // show alert and return
            if recordStatus != .recording {
                DispatchQueue.main.async { [weak self] in
                    self?.toastType = .maxPictureCountReached
                }
            }
            return nil
        }
        recorder.updateOutputVideoOrientation(to: currentOrientation)
        let notRecording = recordStatus != .recording
        var photo: TruVideoPhoto?
        if recorder.isTorchAvailable, torchStatus == .on, notRecording {
            try? recorder.setTorchMode(TorchStatus.on.torchMode)
            try await Task.sleep(nanoseconds: 150_000_000)
            photo = recorder.capturePhotoFromVideo()
            try? recorder.setTorchMode(TorchStatus.off.torchMode)
        } else {
            photo = recorder.capturePhotoFromVideo()
        }
        return photo
    }

    override func getResolutions() -> [TruvideoSdkCameraResolutionFormat] {
        availableResolutions
    }

    override func beginConfiguration() {
        super.beginConfiguration()
        recorder.videoConfiguration.selectedResolution = availableResolutions.first ?? .defaultResolutionFormat
    }

    override func setSelectedResolution(_ resolution: TruvideoSdkCameraResolutionFormat) {
        selectedResolution = resolution
        recorder.videoConfiguration.selectedResolution = resolution

        cleanupARSession()
        resetTrackingAndAnchors(for: createARConfiguration())
    }

    override func record() {
        guard canProceedWithRecording() else { return }

        super.record()
    }

    private func canProceedWithRecording() -> Bool {
        if hasClipsOrPhotos,
            let arRenderer,
            arRenderer.hasActiveActions,
            pendingAction == nil
        {
            pendingAction = .record
            showClearDataAlert = true
            return false
        }

        return true
    }

    private func canProceedWithPhotoCapture() -> Bool {
        guard recordStatus != .recording else {
            return true
        }

        if hasClipsOrPhotos,
            let arRenderer,
            arRenderer.hasActiveActions,
            pendingAction == nil
        {
            pendingAction = .capturePhoto
            showClearDataAlert = true
            return false
        }

        return true
    }

    private func cleanupARSession() {
        guard let arRenderer = recorder.arRenderer else { return }

        arRenderer.session.getCurrentWorldMap { _, _ in }
        arRenderer.session.pause()
        arRenderer.clear()
        autoreleasepool {}
    }

    private func resetTrackingAndAnchors(for configuration: ARWorldTrackingConfiguration) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.recorder.arRenderer?.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        }
    }

    func draw() {
        registerPublishersIfNeeded()
        arRenderer?.draw()
    }

    func enablePinObjects() {
        arRenderer?.enablePinObjectsMode()
    }

    func enableRulerWithPreviouslySelectedUnit() {
        selectedCentimeters
            ? arRenderer?.enableRulerMode(unit: .centimeters) : arRenderer?.enableRulerMode(unit: .inches)
    }

    func enableRulerWithCentimeters() {
        selectedCentimeters.toggle()
        selectedInches.toggle()
        arRenderer?.enableRulerMode(unit: .centimeters)
    }

    func enableRulerWithInches() {
        selectedCentimeters.toggle()
        selectedInches.toggle()
        arRenderer?.enableRulerMode(unit: .inches)
    }

    func disableModes() {
        arRenderer?.disableModes()
    }

    func openARSettings() {
        registerPublishersIfNeeded()
        page = .arSettingsView
    }

    func undo() {
        arRenderer?.undo()
    }

    func clear() {
        arRenderer?.clear()
    }

    func handle(buffer: CVPixelBuffer) {
        recorder.handleVideoBuffer(pixelBuffer: buffer)
    }

    func getARSupportedResolutions() -> [TruvideoSdkCameraResolutionFormat] {
        let supportedFormats = ARWorldTrackingConfiguration.supportedVideoFormats
        arVideoFormats = supportedFormats

        let uniqueResolutionFormats = supportedFormats.reduce(into: [TruvideoSdkCameraResolutionFormat]()) {
            result,
            format in
            let width = Int32(format.imageResolution.width)
            let height = Int32(format.imageResolution.height)

            if !result.contains(where: { $0.width == width && $0.height == height }) {
                result.append(
                    TruvideoSdkCameraResolutionFormat(
                        width: width,
                        height: height,
                        type: .back,
                        format: nil
                    )
                )
            }
        }

        let sortedFormats = uniqueResolutionFormats.sorted { $0.width * $0.height > $1.width * $1.height }

        return Array(sortedFormats.prefix(3))
    }

    func refreshARResolutions() {
        arVideoFormats = ARWorldTrackingConfiguration.supportedVideoFormats
        availableResolutions = getARSupportedResolutions()

        if let firstResolution = availableResolutions.first {
            selectedResolution = firstResolution
            recorder.videoConfiguration.selectedResolution = firstResolution
        }

        showResolutionPickerButton = availableResolutions.count > 1
    }

    func createARConfiguration() -> ARWorldTrackingConfiguration {
        if arConfiguration == nil {
            arConfiguration = ARWorldTrackingConfiguration()
            arConfiguration?.planeDetection = [.horizontal, .vertical]
        }

        let matchingFormat = arVideoFormats.first { format in
            return Int(format.imageResolution.width) == Int(selectedResolution.width)
                && Int(format.imageResolution.height) == Int(selectedResolution.height)
        }

        if let matchingFormat = matchingFormat {
            arConfiguration?.videoFormat = matchingFormat
        }

        return arConfiguration ?? ARWorldTrackingConfiguration()
    }

    func clearDataAndProceed() {
        cleanupARSession()
        resetTrackingAndAnchors(for: createARConfiguration())

        let actionToPerform = pendingAction
        pendingAction = nil

        // Add a delay to wait for resetTrackingAndAnchors
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.executeAction(actionToPerform)
        }
    }

    private func executeAction(_ action: ARActionType?) {
        switch action {
        case .record:
            super.record()
        case .capturePhoto:
            super.takePhoto()
        case .none:
            break
        }
    }

    func keepDataAndProceed() {
        switch pendingAction {
        case .record:
            super.record()
        case .capturePhoto:
            super.takePhoto()
        case .none:
            break
        }

        pendingAction = nil
    }

    func dismissAROnboarding() {
        withAnimation(.easeInOut(duration: 0.3)) {
            shouldShowAROnboarding = false
        }

        let currentMode = getCurrentARMode()
        arOnboardingManager.markOnboardingAsSeenForMode(currentMode)
    }

    func getAROnboardingContent() -> AROnboardingContent {
        let currentMode = getCurrentARMode()

        switch currentMode {
        case .pinObjects:
            return .pinObjectsMode
        case .ruler:
            return .rulerMode
        case .none:
            return .noneMode
        }
    }

    private func registerPagePublishers() {
        $page
            .sink(receiveValue: { [weak self] newPage in
                self?.handlePageChange(newPage)
            })
            .store(in: &cancellables)
    }

    private func registerPublishersIfNeeded() {
        if !registeredPublishers {
            recorder.arRenderer?.enableDeletionActions
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] in
                    self?.enableDeletionActions = $0
                })
                .store(in: &cancellables)
            recorder.arRenderer?.mode
                .dropFirst()
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] in
                    self?.toggleMode(mode: $0)
                })
                .store(in: &cancellables)
            registeredPublishers = true
        }
    }

    private func toggleMode(mode: ARRendererMode) {
        switch mode {
        case .none:
            toggleIcon = TruVideoImage.video
        case .pinObjects:
            toggleIcon = TruVideoImage.arrows3D
        case .ruler:
            toggleIcon = TruVideoImage.ruler
        }

        shouldCheckOnboardingOnReturn = true
        cleanupARSession()
        resetTrackingAndAnchors(for: createARConfiguration())
    }

    private func getCurrentARMode() -> ARRendererMode {
        if selectedPinObjects {
            return .pinObjects
        } else if selectedRuler && selectedCentimeters {
            return .ruler(unit: .centimeters)
        } else if selectedRuler && selectedInches {
            return .ruler(unit: .inches)
        } else if selectedVideo {
            return .none
        } else {
            return .pinObjects
        }
    }

    // MARK: - AR Onboarding

    private func handlePageChange(_ newPage: Page) {
        if newPage == .camera && shouldCheckOnboardingOnReturn {
            shouldCheckOnboardingOnReturn = false

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.checkOnboardingForCurrentMode()
            }
        }
    }

    private func checkOnboardingForCurrentMode() {
        let mode = getCurrentARMode()

        if arOnboardingManager.shouldShowOnboardingForMode(mode) {
            shouldShowAROnboarding = true
        }
    }

    func handleARCameraViewAppeared() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.checkOnboardingForCurrentMode()
        }
    }
}

// MARK: - ARActionType
enum ARActionType {
    case record
    case capturePhoto
}
