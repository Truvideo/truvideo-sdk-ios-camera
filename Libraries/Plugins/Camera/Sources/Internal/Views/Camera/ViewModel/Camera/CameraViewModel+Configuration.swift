//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation
import UIKit
internal import Utilities

extension CameraViewModel {
    // MARK: - Configuration

    /// Initializes the camera system by configuring devices and starting the capture session.
    ///
    /// This method performs the initial setup of the camera system, including device
    /// configuration, authorization checks, and capture session startup. The initialization
    /// is performed asynchronously with user-initiated priority to ensure responsive UI
    /// during the setup process.
    ///
    /// ## Telemetry
    ///
    /// Records a `camera_lifecycle` breadcrumb when initialization starts and when it
    /// completes successfully, including device position and available zoom factors.
    func initialize() {
        Task(priority: .userInitiated) { @SessionActor in
            do {
                telemetryManager.captureBreadcrumb(
                    severity: .info,
                    category: .cameraLifecycle,
                    message: "Camera initialization started"
                )

                try await configureDevices()

                if captureSession.canSetSessionPreset(selectedPreset) {
                    captureSession.sessionPreset = selectedPreset
                }

                captureSession.startRunning()

                Task.delayed(milliseconds: 1_200) { @MainActor in
                    allowsHitTesting = true
                }

                let displayVideoZoomFactors = await videoDevice.displayVideoZoomFactors

                await MainActor.run { self.zoomFactors = displayVideoZoomFactors }

                await telemetryManager.captureBreadcrumb(
                    severity: .info,
                    category: .cameraLifecycle,
                    message: "Camera initialized successfully",
                    metadata: [
                        "devicePosition": .int(videoDevice.position.rawValue),
                        "isAuthorized": .bool(isAuthorized),
                        "isTorchAvailable": .bool(isTorchAvailable),
                        "resolution": .string(selectedPreset.rawValue)
                    ].merging(configuration.metadata, uniquingKeysWith: { lhs, _ in lhs })
                )
            } catch {
                telemetryManager.captureError(
                    error,
                    name: .cameraInitializationFailed,
                    metadata: [
                        "isAuthorized": .bool(isAuthorized)
                    ]
                )

                await MainActor.run { allowsHitTesting = true }
                await didReceiveError(error.localizedDescription)
            }
        }
    }

    // MARK: - Private methods

    @DeviceActor
    private func configureDevices() async throws {
        if audioDevice.authorizationStatus == .notDetermined, videoDevice.authorizationStatus == .notDetermined {
            await requestDeviceAccess()
        }

        guard audioDevice.authorizationStatus == .authorized, videoDevice.authorizationStatus == .authorized else {
            await MainActor.run { isAuthorized = false }
            return
        }

        try videoDevice.configure(in: captureSession)
        if audioDevice.isAvailable {
            try audioDevice.configure(in: captureSession)
        }

        audioDevice.add(movieOutputProcessor)
        videoDevice.add(movieOutputProcessor)

        let position = configuration.lensFacing == .front ? AVCaptureDevice.Position.front : .back
        let torchMode = configuration.flashMode == .on ? AVCaptureDevice.TorchMode.on : .off

        videoDevice.configuration.isHighResolutionEnabled = configuration.isHighResolutionPhotoEnabled
        videoDevice.configuration.imageFormat = configuration.imageFormat.value

        isTorchAvailable = videoDevice.isTorchAvailable || videoDevice.isFlashAvailable

        if videoDevice.isFlashAvailable {
            videoDevice.flashMode = configuration.flashMode.value
        }

        try videoDevice.setPosition(position)
        try videoDevice.setTorchMode(torchMode)

        let presets = position == .back ? configuration.backResolutions : configuration.frontResolutions
        let selectedPreset = await defaultPreset

        await MainActor.run {
            self.presets = presets.map(\.preset)
            self.selectedPreset = selectedPreset
        }
    }

    @DeviceActor
    private func reportAccessDenied() {
        guard videoDevice.authorizationStatus == .denied else {
            let error = UtilityError(
                kind: .CameraViewModelErrorReason.deviceNotAuthorized,
                failureReason: "Microphone permission denied by user"
            )

            telemetryManager.captureError(
                error,
                name: .microphonePermissionDenied,
                metadata: [
                    "device": .string("microphone"),
                    "status": .string("\(audioDevice.authorizationStatus)")
                ]
            )
            return
        }

        let error = UtilityError(
            kind: .CameraViewModelErrorReason.deviceNotAuthorized,
            failureReason: "Camera permission denied by user"
        )

        telemetryManager.captureError(
            error,
            name: .cameraPermissionDenied,
            metadata: [
                "device": .string("camera"),
                "status": .string("\(videoDevice.authorizationStatus)")
            ]
        )
    }

    @DeviceActor
    private func requestDeviceAccess() async {
        telemetryManager.captureBreadcrumb(
            severity: .info,
            category: .authorization,
            message: "Authorization requested",
            metadata: [
                "devices": .array([.string("camera"), .string("microphone")])
            ]
        )

        await audioDevice.requestAccess()
        await videoDevice.requestAccess()

        if audioDevice.authorizationStatus == .authorized, videoDevice.authorizationStatus == .authorized {
            telemetryManager.captureBreadcrumb(
                severity: .info,
                category: .authorization,
                message: "Authorization granted",
                metadata: [
                    "devices": .array([.string("camera"), .string("microphone")])
                ]
            )

            return
        }

        reportAccessDenied()
    }
}
