//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit

extension CameraViewModel {

    // MARK: - Instance methods

    /// Configures observers for application lifecycle events and state changes.
    ///
    /// This function sets up notification observers to monitor key application lifecycle
    /// events including when the app becomes active, enters background, and returns to
    /// foreground. These observers enable the camera system to respond appropriately to
    /// app state changes, ensuring proper resource management and user experience.
    func configureObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveDidBecomeActiveNotification(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveDidEnterBackgroundNotification(_:)),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveWillEnterForegroundNotification(_:)),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    /// Configures observers for capture session and audio system events.
    ///
    /// This function sets up notification observers to monitor critical capture session
    /// and audio system events that can affect camera functionality. These observers
    /// enable the camera system to handle interruptions, errors, and system-level
    /// changes that may impact recording or capture operations.
    func configureSessionObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveMediaServicesWereResetNotification(_:)),
            name: AVAudioSession.mediaServicesWereResetNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveRouteChangeNotification(_:)),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveRuntimeErrorNotification(_:)),
            name: AVCaptureSession.runtimeErrorNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveSessionWasInterruptedNotification(_:)),
            name: AVCaptureSession.wasInterruptedNotification,
            object: nil
        )
    }

    // MARK: - Notification methods

    @MainActor
    @objc
    func didReceiveDidBecomeActiveNotification(_ notification: Notification) {
        Task.delayed(milliseconds: 300) { @SessionActor in
            if !captureSession.isRunning {
                captureSession.startRunning()
            }
        }
    }

    @MainActor
    @objc
    func didReceiveDidEnterBackgroundNotification(_ notification: Notification) {
        if state == .running {
            pauseSession()
        }
    }

    @MainActor
    @objc
    func didReceiveMediaServicesWereResetNotification(_ notification: Notification) {
        Task { @SessionActor in
            telemetryManager.captureBreadcrumb(
                severity: .info,
                category: .cameraSystem,
                message: "Camera services were reset",
                metadata: [
                    "state": .string("\(state)")
                ]
            )

            if !captureSession.isRunning {
                captureSession.startRunning()
            }

            if state == .running {
                telemetryManager.captureBreadcrumb(
                    severity: .info,
                    category: .cameraSystem,
                    message: "Camera recovering from reset"
                )

                await videoDevice.endCapturing(in: captureSession)
                await audioDevice.endCapturing(in: captureSession)

                do {
                    try await audioDevice.startCapturing()
                    try await videoDevice.startCapturing()

                    telemetryManager.captureBreadcrumb(
                        severity: .info,
                        category: .cameraSystem,
                        message: "Camera recovered from reset"
                    )
                } catch {
                    telemetryManager.captureError(error, name: .cameraFailedToRecoverFromReset)

                    await didReceiveError(error.localizedDescription)
                }
            }
        }
    }

    @MainActor
    @objc
    func didReceiveRouteChangeNotification(_ notification: Notification) {
        let reason = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt ?? 0

        telemetryManager.captureBreadcrumb(
            severity: .info,
            category: .cameraSystem,
            message: "Audio route changed",
            metadata: [
                "reason": .int(Int(reason)),
                "state": .string("\(state)"),
            ]
        )

        Task { @DeviceActor in
            if !audioDevice.isAvailable {
                audioDevice.endCapturing(in: captureSession)
            } else if !audioDevice.isReady {
                do {
                    try audioDevice.configure(in: captureSession)
                } catch {
                    telemetryManager.captureError(
                        error,
                        name: .audioRouteChangeFailed,
                        metadata: [
                            "reason": .int(Int(reason))
                        ]
                    )

                    await didReceiveError(error.localizedDescription)
                }
            }
        }
    }

    @MainActor
    @objc
    func didReceiveRuntimeErrorNotification(_ notification: Notification) {
        if let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError, state == .running {
            telemetryManager.captureError(
                error,
                name: .cameraRuntimeError,
                metadata: [
                    "errorCode": .int(error.code.rawValue),
                    "state": .string("\(state)"),
                ]
            )

            if [.sessionConfigurationChanged, .sessionNotRunning].contains(error.code) {
                Task { @SessionActor in
                    if !captureSession.isRunning {
                        captureSession.startRunning()
                    }
                }
            }
        }
    }

    @MainActor
    @objc
    func didReceiveSessionWasInterruptedNotification(_ notification: Notification) {
        let reason = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as? Int ?? 0

        telemetryManager.captureBreadcrumb(
            severity: .info,
            category: .cameraSystem,
            message: "Camera session interrupted",
            metadata: [
                "reason": .int(reason),
                "state": .string("\(state)"),
            ]
        )

        if state == .running {
            pauseSession()
        }
    }

    @MainActor
    @objc
    func didReceiveWillEnterForegroundNotification(_ notification: Notification) {
        Task { @SessionActor in
            if !captureSession.isRunning {
                captureSession.startRunning()
            }
        }
    }
}
