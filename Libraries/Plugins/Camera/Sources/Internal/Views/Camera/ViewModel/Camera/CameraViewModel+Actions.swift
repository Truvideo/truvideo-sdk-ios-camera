//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation
import UIKit
internal import Utilities

extension CameraViewModel {

    // MARK: - Private Computed Properties

    /// Determines whether more photos can be captured based on configuration limits.
    ///
    /// This computed property checks the camera configuration mode to determine if
    /// additional photos can be taken. It respects different limit configurations:
    /// - Individual photo count limits (`maxPictureCount`)
    /// - Combined media count limits (`maxMediaCount`)
    ///
    /// - Returns: `true` if more photos can be captured, `false` if limit is reached
    private var canTakeMorePhotos: Bool {
        let mode = configuration.mode

        guard mode.maxPictureCount == 0, mode.maxVideoCount == 0, mode.maxMediaCount > 0 else {
            return photosTaken < mode.maxPictureCount
        }

        return mediasTaken < mode.maxMediaCount
    }

    /// The time interval to wait between photo captures to prevent rapid successive captures.
    ///
    /// This computed property returns a debounce window based on the flash mode configuration.
    /// When flash is enabled, a longer debounce window (0.45 seconds) is applied to allow
    /// the flash hardware to reset and the preview to stabilize. When flash is disabled,
    /// no debounce is applied (0 seconds).
    ///
    /// - Returns: Time interval in seconds to wait between photo captures
    private var debounceWindow: TimeInterval {
        configuration.flashMode != .off ? 0.45 : 0
    }

    // MARK: - Actions

    /// Captures a photo using the photo device and adds it to the photos collection.
    ///
    /// This function initiates an asynchronous photo capture operation on the main actor.
    /// If the capture is successful, the captured photo is appended to the photos array.
    /// If an error occurs during capture, the error's localized description is stored
    /// in the localizedError property for user feedback.
    func capturePhoto() {
        Task { @MainActor in
            guard canTakeMorePhotos else {
                didReceiveError(Localizations.maxNumberOfPicturesReached)
                return
            }

            let debounceWindow = configuration.flashMode != .off ? 0.45 : 0
            let systemUptime = ProcessInfo.processInfo.systemUptime

            if systemUptime - lastPhotoCaptureUptime < debounceWindow || isTorchEnabled, isCaptureInFlight {
                return
            }

            isCaptureInFlight = true
            lastPhotoCaptureUptime = systemUptime

            mediasTaken += 1
            photosTaken += 1

            defer { isCaptureInFlight = false }

            do {
                allowsHitTesting = false

                await reportCapturePhotoTelemetry(message: "Photo capture started")
                Task.delayed(milliseconds: 600) { allowsHitTesting = true }

                let photo = try await videoDevice.capturePhoto()

                await reportCapturePhotoTelemetry(message: "Photo captured successfully")

                medias.insert(.photo(photo), at: 0)
            } catch {
                mediasTaken -= 1
                photosTaken -= 1

                await telemetryManager.captureError(
                    error,
                    name: .photoCaptureFailed,
                    metadata: [
                        "devicePosition": .int(videoDevice.position.rawValue),
                        "flashMode": .string(configuration.flashMode.rawValue),
                        "resolution": .string(selectedPreset.rawValue),
                    ]
                )

                didReceiveError(error.localizedDescription)
            }
        }
    }

    /// Adjusts the current zoom level based on a magnification value.
    ///
    /// This method applies a magnification factor to the last known zoom factor
    /// and clamps the result to the valid range of `zoomFactors`.
    ///
    /// - The zoom factor is always kept within the minimum and maximum supported values.
    /// - If the calculated factor is below the minimum, the minimum zoom is applied.
    /// - If the factor is between the first two levels, the raw factor is used.
    /// - If the factor exceeds the second level, it is clamped to the maximum zoom.
    ///
    /// - Parameter value: The magnification multiplier from a gesture
    func magnify(by value: CGFloat) {
        if zoomFactors.count > 1 {
            Task { @DeviceActor in
                telemetryManager.captureBreadcrumb(
                    severity: .info,
                    category: .cameraUI,
                    message: "Zoom magnification started",
                    metadata: [
                        "devicePosition": .int(videoDevice.position.rawValue),
                        "magnificationValue": .double(value),
                        "lastZoomFactor": .double(lastZoomFactor),
                    ]
                )
            }

            let rawFactor = max(lastZoomFactor * value, zoomFactors[0])

            guard rawFactor <= zoomFactors[1] else {
                let zoomFactor = min(rawFactor, zoomFactors[zoomFactors.count - 1])
                rampZoomFactor(to: zoomFactor, rate: 0)

                return
            }

            rampZoomFactor(to: rawFactor)
        }
    }

    /// Smoothly animates the camera to a target zoom factor.
    ///
    /// This method updates the published `zoomFactor` and requests the underlying
    /// `VideoDevice` to ramp the zoom to the specified level. The zoom transition
    /// can be performed at a configurable rate, or using the device's default rate
    /// if none is provided. Execution is dispatched to the main actor for UI safety,
    /// and any errors encountered are forwarded through `didReceiveError(_:)`.
    ///
    /// - Parameters:
    ///   - zoomFactor: The target zoom factor to apply to the camera.
    ///   - rate: The optional speed of the zoom ramp, in device-specific units.
    func rampZoomFactor(to newZoomFactor: CGFloat, rate: Float = 10) {
        Task { @MainActor in
            do {
                zoomFactor = newZoomFactor
                try await videoDevice.setZoomFactor(zoomFactor, rate: rate)

                await telemetryManager.captureBreadcrumb(
                    severity: .info,
                    category: .cameraUI,
                    message: "Zoom changed",
                    metadata: [
                        "devicePosition": .int(videoDevice.position.rawValue),
                        "zoomFactor": .double(zoomFactor),
                    ]
                )
            } catch {
                didReceiveError(error.localizedDescription)
            }
        }
    }

    /// Sets the camera focus point to the specified location asynchronously.
    ///
    /// This method sets the focus point of the video device to the provided coordinates
    /// and handles any errors that may occur during the operation. The focus point
    /// change is performed on the main actor to ensure thread safety for UI updates.
    /// If an error occurs during the focus point setting, the localized error is
    /// cleared to prevent displaying stale error messages.
    ///
    /// - Parameter point: The normalized point (0.0 to 1.0) where focus should be set
    func setFocusPoint(at point: CGPoint) {
        Task { @MainActor in
            let focusPoint = previewLayer.captureDevicePointConverted(fromLayerPoint: point)

            do {
                try await videoDevice.setFocusPoint(at: focusPoint)

                await telemetryManager.captureBreadcrumb(
                    severity: .info,
                    category: .cameraUI,
                    message: "Focus changed",
                    metadata: [
                        "devicePosition": .int(videoDevice.position.rawValue),
                        "focusPoint": .string("(\(focusPoint.x), \(focusPoint.y))"),
                    ]
                )
            } catch {
                await telemetryManager.captureError(
                    error,
                    name: .focusChangeFailed,
                    metadata: [
                        "devicePosition": .int(videoDevice.position.rawValue),
                        "focusPoint": .string("(\(focusPoint.x), \(focusPoint.y))"),
                    ]
                )

                didReceiveError(error.localizedDescription)
            }
        }
    }

    /// Sets the capture session resolution to the specified preset.
    ///
    /// This method attempts to update the `AVCaptureSession` resolution.
    /// If the session supports the given preset, the configuration is applied
    /// within a begin/commit configuration block to ensure consistency.
    ///
    /// - Parameter preset: The `AVCaptureSession.Preset` to apply (e.g., `.hd720`, `.hd1080`).
    @MainActor
    func setPreset(_ preset: AVCaptureSession.Preset) {
        guard captureSession.canSetSessionPreset(preset) else {
            didReceiveError(Localizations.presetNotSupported)
            return
        }

        Task { @SessionActor in
            captureSession.beginUpdates()
            defer { captureSession.endUpdates() }

            captureSession.sessionPreset = preset

            Task { @DeviceActor in
                do {
                    try videoDevice.setZoomFactor(zoomFactor, rate: 0)

                    videoDevice.configuration.preset = preset

                    await MainActor.run { selectedPreset = preset }
                } catch {
                    await didReceiveError(Localizations.failedToSetPreset)
                    captureSession.sessionPreset = selectedPreset
                }
            }
        }
    }

    /// Switches between the front and back camera positions.
    ///
    /// This function toggles the camera position between the front-facing camera (selfie camera)
    /// and the back-facing camera (main camera). It attempts to change the camera position
    /// and updates the error state if the operation fails.
    func switchCamera() {
        Task { @MainActor in
            allowsHitTesting = false

            let previousDevicePosition = await videoDevice.position
            let position = previousDevicePosition == .back ? AVCaptureDevice.Position.front : .back

            do {
                try await videoDevice.setTorchMode(.off)
                try await videoDevice.setPosition(position)

                telemetryManager.captureBreadcrumb(
                    severity: .info,
                    category: .cameraUI,
                    message: "Camera switched",
                    metadata: [
                        "previousDevicePosition": .int(previousDevicePosition.rawValue),
                        "newDevicePosition": .int(position.rawValue),
                    ]
                )

                let isTorchAvailable = await videoDevice.isTorchAvailable
                let isFlashAvailable = await videoDevice.isFlashAvailable

                self.isTorchAvailable = isTorchAvailable || isFlashAvailable

                if !self.isTorchAvailable && isTorchEnabled {
                    switchTorch()
                }

                zoomFactors = await videoDevice.displayVideoZoomFactors.sorted()
                lastZoomFactor = 1
                zoomFactor = 1

                Task.delayed(milliseconds: 600) { allowsHitTesting = true }
            } catch {
                telemetryManager.captureError(
                    error,
                    name: .cameraSwitchFailed,
                    metadata: [
                        "previousDevicePosition": .int(previousDevicePosition.rawValue),
                        "newDevicePosition": .int(position.rawValue),
                    ]
                )

                didReceiveError(error.localizedDescription)
                allowsHitTesting = true
            }
        }
    }

    /// Toggles the camera's torch on or off with error handling.
    ///
    /// This function switches the torch state between enabled and disabled modes.
    /// It optimistically updates the UI state first, then attempts to change the
    /// actual torch mode. If the torch operation fails, it reverts the UI state
    /// to maintain consistency between the visual state and the actual hardware state.
    func switchTorch() {
        Task { @DeviceActor in
            await MainActor.run { isTorchEnabled.toggle() }

            guard videoDevice.isTorchAvailable || videoDevice.isFlashAvailable else {
                try videoDevice.setTorchMode(.off)
                videoDevice.flashMode = .off

                let error = UtilityError(kind: .unknown, failureReason: "Torch is not available on this device")
                telemetryManager.captureError(
                    error,
                    name: .torchNotAvailable,
                    metadata: [
                        "devicePosition": .int(videoDevice.position.rawValue)
                    ]
                )

                await didReceiveError(Localizations.torchNotAvailable)
                return
            }

            do {
                let torchMode = isTorchEnabled ? AVCaptureDevice.TorchMode.on : .off

                try videoDevice.setTorchMode(torchMode)

                if videoDevice.isFlashAvailable {
                    videoDevice.flashMode = isTorchEnabled ? .on : .off
                }

                telemetryManager.captureBreadcrumb(
                    severity: .info,
                    category: .cameraUI,
                    message: "Torch toggled",
                    metadata: [
                        "devicePosition": .int(videoDevice.position.rawValue),
                        "isTorchEnabled": .bool(isTorchEnabled),
                    ]
                )
            } catch {
                await MainActor.run {
                    isTorchEnabled.toggle()
                    didReceiveError(error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Private methods

    @DeviceActor
    private func reportCapturePhotoTelemetry(message: String) {
        let metadata: Metadata = [
            "devicePosition": .int(videoDevice.position.rawValue),
            "flashMode": .string(configuration.flashMode.rawValue),
            "resolution": .string(selectedPreset.rawValue),
        ]

        telemetryManager.captureBreadcrumb(message, severity: .info, category: .photoCapture, metadata: metadata)
    }
}
