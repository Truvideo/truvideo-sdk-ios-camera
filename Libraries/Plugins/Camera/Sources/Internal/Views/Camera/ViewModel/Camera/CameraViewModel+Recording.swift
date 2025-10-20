//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation
import UIKit

extension CameraViewModel {

    // MARK: - Private Computed Properties

    /// Determines whether more video clips can be recorded based on configuration limits.
    ///
    /// This computed property checks the camera configuration mode to determine if
    /// additional video clips can be recorded.
    ///
    /// - Returns: `true` if more video clips can be recorded, `false` if limit is reached
    private var canTakeMoreClips: Bool {
        let mode = configuration.mode

        guard mode.maxPictureCount == 0, mode.maxVideoCount == 0, mode.maxMediaCount > 0 else {
            return medias.lazy.filter(\.isClip).count < mode.maxVideoCount
        }

        return mediasTaken < mode.maxMediaCount
    }

    // MARK: - Recording

    /// Toggles the recording state between pause and record.
    ///
    /// This function manages the recording lifecycle by checking the current state
    /// of the video device and performing the appropriate action. If the device
    /// is currently running, it pauses the recording by pausing the movie processing.
    func togglePause() {
        Task { @MainActor in
            switch movieOutputProcessor.state {
            case .paused:
                do {
                    guard await audioDevice.isAvailable else {
                        localizedError = Localizations.anotherAppIsUsingMicrophone
                        isSnackbarPresented = true

                        return
                    }

                    try await audioDevice.startCapturing()
                    try await videoDevice.startCapturing()

                    await movieOutputProcessor.startProcessing()

                    state = .running

                    await ensureTorchCompatibility()
                    await reportVideoRecordingResumed()
                    UIApplication.shared.isIdleTimerDisabled = true
                } catch {
                    didReceiveError(error.localizedDescription)
                }

            case .writing:
                pauseSession()

            default:
                break
            }
        }
    }

    /// Toggles the recording state between start and stop.
    ///
    /// This function manages the recording lifecycle by checking the current state
    /// of the video device and performing the appropriate action. If the device
    /// is currently running, it stops the recording by ending movie processing
    /// and stopping the recorder. If the device is not running, it starts
    /// recording by calling the recorder's record method.
    ///
    /// The function operates on the main actor to ensure UI updates are performed
    /// safely and handles errors by setting the localized error description
    /// for user feedback. It uses async/await for proper coordination between
    /// the video device state and recorder operations.
    func toggleRecord() {
        Task { @MainActor in
            do {
                switch movieOutputProcessor.state {
                case .initialized, .finished, .failed:
                    guard canTakeMoreClips else {
                        didReceiveError(Localizations.maxNumberOfClipsReached)
                        return
                    }

                    guard await audioDevice.isAvailable else {
                        localizedError = Localizations.anotherAppIsUsingMicrophone
                        isSnackbarPresented = true
                        return
                    }

                    mediasTaken += 1

                    try await videoDevice.startCapturing()
                    try await audioDevice.startCapturing()

                    await movieOutputProcessor.startProcessing()

                    state = .running

                    await ensureTorchCompatibility()
                    await reportVideoRecordingStarted()

                    let torchMode = await videoDevice.torchMode

                    if torchMode == .off, isTorchEnabled, isTorchAvailable {
                        try await videoDevice.setTorchMode(.on)
                    }

                    UIApplication.shared.isIdleTimerDisabled = true

                case .paused where state.canTransition(to: .finished),
                    .writing where state.canTransition(to: .finished):

                    try await endRecording()

                default:
                    break
                }
            } catch {
                mediasTaken -= 1

                await reportVideoRecordingError(error)
                didReceiveError(error.localizedDescription)
            }
        }
    }

    // MARK: - Internal methods

    /// Pauses the current recording session and all associated capture devices.
    ///
    /// This function safely pauses an active recording session by stopping the movie
    /// output processor and pausing both audio and video capture devices. It performs
    /// the pause operation asynchronously and handles any errors that occur during
    /// the process by displaying them to the user through the error handling system.
    ///
    /// ## Error Handling
    ///
    /// Any errors that occur during the pause operation are automatically caught
    /// and displayed to the user through the snackbar interface via `didReceiveError(_:)`,
    /// ensuring that users are informed of any issues that prevent proper session pausing.
    @MainActor
    func pauseSession() {
        Task {
            do {
                try await movieOutputProcessor.pause()

                await audioDevice.pause()
                await videoDevice.pause()

                state = .paused

                await ensureTorchCompatibility()
                await telemetryManager.captureBreadcrumb(
                    severity: .info,
                    category: .videoRecording,
                    message: "Video recording paused",
                    metadata: [
                        "devicePosition": .int(videoDevice.position.rawValue),
                        "duration": .double(movieOutputProcessor.recordingDuration.seconds),
                        "clipCount": .int(medias.lazy.filter(\.isClip).count),
                        "zoomFactor": .double(zoomFactor),
                    ]
                )

                UIApplication.shared.isIdleTimerDisabled = false
            } catch {
                didReceiveError(error.localizedDescription)
            }
        }
    }

    // MARK: - Private methods

    @MainActor
    private func endRecording() async throws {
        state = .finished

        let clip = try await movieOutputProcessor.endProcessing()

        await ensureTorchCompatibility()
        await telemetryManager.captureBreadcrumb(
            severity: .info,
            category: .videoRecording,
            message: "Video recording stopped",
            metadata: [
                "devicePosition": .int(videoDevice.position.rawValue),
                "duration": .double(clip.duration),
                "clipCount": .int(medias.lazy.filter(\.isClip).count + 1),
                "zoomFactor": .double(zoomFactor),
            ]
        )

        medias.insert(.clip(clip), at: 0)

        await videoDevice.pause()
        await audioDevice.pause()

        UIApplication.shared.isIdleTimerDisabled = false
    }

    @DeviceActor
    private func ensureTorchCompatibility() {
        isTorchAvailable =
            switch state {
            case .running:
                videoDevice.isTorchAvailable

            default:
                videoDevice.isTorchAvailable || videoDevice.isFlashAvailable
            }

        if !isTorchAvailable, isTorchEnabled {
            switchTorch()
        }
    }

    @DeviceActor
    private func reportVideoRecordingResumed() {
        telemetryManager.captureBreadcrumb(
            severity: .info,
            category: .videoRecording,
            message: "Video recording resumed",
            metadata: [
                "devicePosition": .int(videoDevice.position.rawValue),
                "duration": .double(movieOutputProcessor.recordingDuration.seconds),
                "clipCount": .int(medias.lazy.filter(\.isClip).count),
                "zoomFactor": .double(zoomFactor),
            ]
        )
    }

    @DeviceActor
    private func reportVideoRecordingStarted() {
        telemetryManager.captureBreadcrumb(
            severity: .info,
            category: .videoRecording,
            message: "Video recording started",
            metadata: [
                "devicePosition": .int(videoDevice.position.rawValue),
                "resolution": .string(selectedPreset.rawValue),
                "isTorchAvailable": .bool(isTorchAvailable),
                "isTorchEnabled": .bool(isTorchEnabled),
                "codec": .string(videoDevice.configuration.codec.rawValue),
                "aspectRatio": .string("\(aspectRatio)"),
                "zoomFactor": .double(zoomFactor),
                "stabilizationMode": .int(videoDevice.stabilizationMode.rawValue),
                "maxDuration": .double(configuration.mode.maxVideoDuration),
                "isAudioAvailable": .bool(audioDevice.isAvailable),
            ]
        )
    }

    @DeviceActor
    private func reportVideoRecordingError(_ error: Error) {
        telemetryManager.captureError(
            error,
            name: .videoRecordingFailed,
            metadata: [
                "devicePosition": .int(videoDevice.position.rawValue),
                "resolution": .string(selectedPreset.rawValue),
                "duration": .double(movieOutputProcessor.recordingDuration.seconds),
                "processorState": .string("\(movieOutputProcessor.state)"),
                "isAudioAvailable": .bool(audioDevice.isAvailable),
            ]
        )
    }
}
