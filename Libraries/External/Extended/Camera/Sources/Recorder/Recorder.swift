//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit
import Utilities

extension ErrorReason {
    /// A collection of error reasons related to the recorder operations.
    ///
    /// The `RecorderErrorReason` struct provides a set of static constants representing various errors that can occur
    /// during interactions with the external devices.
    struct RecorderErrorReason: Sendable {
        /// Recording could not be started due to a configuration or runtime error.
        ///
        /// This error typically occurs when:
        /// - Device setup fails during `startCapturing`
        /// - Session configuration encounters an unrecoverable issue
        /// - Required permissions or hardware access is unavailable
        ///
        /// Check the underlying error for specific failure details.
        static let beginRecordingFailed = ErrorReason(rawValue: "BEGIN_RECORDING_FAILED")

        /// A recording session is already active and cannot be started.
        ///
        /// This error occurs when attempting to start recording while another
        /// recording session is already running. The existing session must be
        /// stopped before starting a new one.
        static let recordingInProgress = ErrorReason(rawValue: "RECORDING_IN_PROGRESS")
    }
}

/// A global actor that serializes access to capture-device operations.
///
/// Use this actor to ensure all capture session and device mutations occur on a single,
/// well-defined executor, preventing data races and reducing configuration hazards.
/// Conforming device types may isolate their APIs to `DeviceActor` to guarantee consistency.
@globalActor
actor DeviceActor {
    /// The shared global actor instance used to isolate device operations.
    static let shared = DeviceActor()
}

/// Represents the lifecycle state of a capture/recording component.
///
/// The state machine models a simple flow from initialization to running,
/// and then to either a finished or failed condition.
enum RecordingState: Sendable {
    /// The component encountered an error.
    case failed

    /// The component completed successfully and is no longer active.
    case finished

    /// The component has been created and configured but not started.
    ///
    /// From this state you can move to `running` to begin work, or to `failed`
    /// if setup detects an unrecoverable issue.
    case initialized

    /// The component is temporarily suspended but remains configured in the session.
    ///
    /// From this state you can resume to `running` or transition to `finished`
    /// if the component is no longer needed. The device remains connected
    /// to the session during this state.
    case paused

    /// The component is actively capturing or processing.
    case running

    // MARK: - Instance methods

    /// Indicates whether a transition from the current state to a new state is permitted.
    /// Any other transition is rejected to protect lifecycle invariants.
    ///
    /// - Parameter newState: The target state to evaluate.
    /// - Returns: `true` if the transition is allowed; otherwise, `false`.
    func canTransition(to newState: RecordingState) -> Bool {
        switch (self, newState) {
        case (.initialized, .failed),
            (.initialized, .running),
            (.failed, .running),
            (.failed, .initialized),
            (.finished, .running),
            (.paused, .finished),
            (.paused, .initialized),
            (.paused, .running),
            (.running, .failed),
            (.running, .finished),
            (.running, .paused):

            true

        default:
            false
        }
    }
}

/// A sendable abstraction for a capture device that can attach to and detach from a session.
///
/// Conforming types manage their own inputs/outputs and any device-specific configuration.
/// Implementations are typically isolated to `DeviceActor` to serialize access to the
/// underlying `AVCaptureSession` and `AVCaptureDevice`.
@DeviceActor
protocol Device: AnyObject, Sendable {
    /// Stops capture for this device and removes any installed inputs/outputs from the session.
    ///
    /// Implementations should safely detach inputs/outputs and perform any necessary cleanup.
    /// Prefer calling this while the session is inside a configuration block.
    ///
    /// - Parameter session: The `AVCaptureSession` from which to remove this device’s input/output.
    func endCapturing(in session: AVCaptureSession)

    /// Pauses capture for this device without removing it from the session.
    ///
    /// Implementations should temporarily stop processing or capturing data while maintaining
    /// the device's connection to the session. This allows for quick resumption of capture
    /// without the overhead of reconfiguring inputs/outputs.
    func pause()

    /// Resumes capture for this device after it has been paused.
    ///
    /// This method restarts data capture for a previously paused device. The device
    /// should return to the same state it was in before `pause()` was called.
    ///
    /// Implementations should:
    /// - Restart data processing
    /// - Resume any recording or streaming operations
    /// - Restore previous device settings if needed
    /// - Handle any state changes that occurred during the pause
    func resume()

    /// Resets the device to a clean state, clearing any corrupted internal state.
    ///
    /// This method should be called when the device needs to recover from errors or when
    /// performing a complete session reset. It clears any corrupted buffers, resets internal
    /// configuration, and prepares the device for a fresh start without attempting to finalize
    /// any recordings to avoid corruption.
    func reset()

    /// Configures and starts capture for this device on the given session.
    ///
    /// Implementations typically validate authorization, resolve an `AVCaptureDevice`,
    /// install an `AVCaptureDeviceInput` and any required outputs, and update connection
    /// settings as needed. Prefer calling this while the session is inside a configuration block.
    ///
    /// - Parameter session: The `AVCaptureSession` to which inputs/outputs will be added.
    /// - Throws: An error if authorization is missing, if no suitable device is found, or if inputs/outputs cannot be added to the session due to incompatibility.
    func startCapturing(in session: AVCaptureSession) throws
}

/// A global actor that serializes recorder orchestration and session mutations.
///
/// Use this actor to ensure all `AVCaptureSession`/device lifecycle changes, recorder state
/// transitions, and related coordination occur on a single, well‑defined executor. Annotate
/// the recorder and its mutating APIs with `@RecorderActor` to avoid data races and
/// transient configuration hazards when working with AVFoundation.
@globalActor
actor RecorderActor {
    /// The shared global actor instance used to isolate device operations.
    static let shared = RecorderActor()
}

/// A recorder that manages capture devices and coordinates recording sessions.
///
/// The `Recorder` class provides a high-level interface for managing multiple capture devices
/// (audio, video, etc.) within a single `AVCaptureSession`. It handles device lifecycle,
/// session configuration, and provides a preview layer for displaying camera output.
///
/// Key features:
/// - Supports multiple devices of different types (audio, video)
/// - Manages session presets and quality settings
/// - Provides a preview layer for UI integration
/// - Handles app lifecycle and session interruption events
/// - Thread-safe operations through actor isolation
///
/// Usage:
/// ```swift
/// let recorder = Recorder()
/// recorder.add(videoDevice)
/// recorder.add(audioDevice)
/// try await recorder.beginRecording()
/// ```
final class Recorder {
    // MARK: - Private Properties

    private var captureSession: AVCaptureSession?
    private var devices: [ObjectIdentifier: any Device] = [:]
    private var sessionWasRunning = false

    // MARK: - Properties

    /// The video preview layer that displays the camera feed in the UI.
    let previewLayer = AVCaptureVideoPreviewLayer()

    /// The current lifecycle state of the recorder.
    private(set) var state = RecordingState.initialized

    // MARK: - Initializer

    /// Creates a new recorder instance with default configuration.
    init() {
        self.previewLayer.videoGravity = .resizeAspectFill

        configureObservers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Instance methods

    /// Registers a capture device in the recorder by its reference identity.
    ///
    /// Stores the device in the internal registry keyed by `ObjectIdentifier(device)`, ensuring
    /// a single entry per instance. Adding the same instance again replaces the existing entry.
    /// Devices are later coordinated for start/stop operations.
    ///
    /// - Parameter device: The device instance to register.
    @RecorderActor
    func add(_ device: any Device) {
        devices[ObjectIdentifier(device)] = device
    }

    /// Starts a new capture session and transitions the recorder to `.running`.
    ///
    /// Creates an `AVCaptureSession`, applies the configured `preset` (throwing if unsupported),
    /// asks each registered device to start capturing on that session, starts the session, binds it
    /// to `previewLayer.session`, and updates `state` to `.running`.
    ///
    /// If a session is already active, the call fails early. On any failure while configuring the
    /// session or starting devices, `state` is set to `.failed` and an error is thrown.
    ///
    /// - Throws:
    ///   - `UtilityError(kind: .RecorderErrorReason.recordingInProgress)` if a session is already active.
    ///   - `UtilityError(kind: .RecorderErrorReason.beginRecordingFailed, underlyingError:)` for any other startup failure.
    @RecorderActor
    func beginRecording() async throws {
        guard captureSession == nil else {
            throw UtilityError(
                kind: .RecorderErrorReason.recordingInProgress,
                failureReason: "A recording is already in progress. Stop the session before starting a new one."
            )
        }

        if state.canTransition(to: .running) {
            let captureSession = AVCaptureSession()
            
            if captureSession.canSetSessionPreset(.hd4K3840x2160) {
                captureSession.sessionPreset = .hd4K3840x2160
            }

            do {
                try await startCapturing(in: captureSession)

                captureSession.startRunning()

                await MainActor.run {
                    previewLayer.session = captureSession
                }

                self.captureSession = captureSession
                self.state = .running
            } catch {
                await endCapturing(in: captureSession)

                state = .failed
                throw UtilityError(kind: .RecorderErrorReason.beginRecordingFailed, underlyingError: error)
            }
        }
    }

    /// Ends recording by stopping all registered devices and the capture session.
    ///
    /// If the recorder can transition to `.finished`, this method:
    /// 1) Asks each registered device to end capturing on the active `AVCaptureSession`
    /// 2) Stops the session (`stopRunning()`), and
    /// 3) Updates internal state and clears the session reference
    @RecorderActor
    func endRecording() async {
        if let captureSession, state.canTransition(to: .finished) {
            await endCapturing(in: captureSession)

            captureSession.stopRunning()

            self.state = .finished
            self.captureSession = nil
        }
    }

    /// Unregisters a capture device by its reference identity.
    ///
    /// Removes the device from the internal registry. If the device is not registered, this is a no‑op.
    /// The removal releases the registry’s strong reference to the device.
    ///
    /// - Parameter device: The device instance to remove.
    @RecorderActor
    func remove(_ device: any Device) {
        devices.removeValue(forKey: ObjectIdentifier(device))
    }

    // MARK: - Notification methods

    @objc
    func didReceiveBecomeActiveNotification(_ notification: Notification) {
        Task {
            if sessionWasRunning {
                await resumeSession()
            }
        }
    }

    @objc
    func didReceiveDeviceOrientationDidChangeNotification(_ notification: Notification) {
        if
            /// The new device orientation.
            let videoOrientation = AVCaptureVideoOrientation(rawValue: UIDevice.current.orientation.rawValue),
            
            /// The allowable device orientations.
            [.landscapeLeft, .landscapeRight, .portrait].contains(videoOrientation) {
            
            previewLayer.connection?.videoOrientation = videoOrientation
        }
    }

    @objc
    func didReceiveMediaServicesWereResetNotification(_ notification: Notification) {
        Task {
            await receivedMediaServicesWereResetNotification()
        }
    }

    @objc
    func didReceiveSessionInterruptionEnded(_ notification: Notification) {
        Task {
            if sessionWasRunning {
                await resumeSession()
            }
        }
    }

    @objc
    func didReceiveRuntimeErrorNotification(_ notification: Notification) {
        Task {
            if let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError {
                await receivedRuntimeError(error)
            }
        }
    }

    @objc
    func didReceiveSessionWasInterruptedNotification(_ notification: Notification) {
        Task {
            if sessionWasRunning {
                await resumeSession()
            }
        }
    }

    @objc
    func didReceiveWillResignActiveNotification(_ notification: Notification) {
        Task {
            sessionWasRunning = state == .running
            await pauseSession()
        }
    }

    // MARK: - Private methods

    private func configureObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveBecomeActiveNotification(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveDeviceOrientationDidChangeNotification(_:)),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveMediaServicesWereResetNotification(_:)),
            name: AVAudioSession.mediaServicesWereResetNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveSessionInterruptionEnded(_:)),
            name: AVCaptureSession.interruptionEndedNotification,
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

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveWillResignActiveNotification(_:)),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }

    @RecorderActor
    private func endCapturing(in captureSession: AVCaptureSession) async {
        let devices = devices.values

        for device in devices {
            await device.endCapturing(in: captureSession)
        }
    }

    @RecorderActor
    private func pauseSession() async {
        if state.canTransition(to: .paused) {
            let devices = Array(devices.values)

            for device in devices {
                await device.pause()
            }

            captureSession?.stopRunning()
            state = .paused
        }
    }

    @RecorderActor
    private func resumeSession() async {
        if state.canTransition(to: .running) {
            let devices = Array(devices.values)

            for device in devices {
                await device.resume()
            }

            captureSession?.startRunning()
            state = .running
        }
    }

    @RecorderActor
    private func receivedMediaServicesWereResetNotification() async {
        if let captureSession, state == .running, !captureSession.isRunning {
            do {
                let devices = Array(devices.values)

                for device in devices {
                    await device.pause()
                    await device.reset()
                }

                captureSession.startRunning()
                try await startCapturing(in: captureSession)
            } catch {
                state = .failed
            }
        }
    }

    @RecorderActor
    private func receivedRuntimeError(_ error: AVError) async {
        switch error.code {
        case .sessionConfigurationChanged where state == .running,
            .sessionNotRunning where state == .running:

            if let captureSession, !captureSession.isRunning {
                captureSession.startRunning()
            }

        default:
            break
        }
    }

    @RecorderActor
    private func receivedSessionWasInterrupted(_ reason: AVCaptureSession.InterruptionReason) async {
        switch reason {
        case .audioDeviceInUseByAnotherClient,
            .videoDeviceInUseByAnotherClient,
            .videoDeviceNotAvailableDueToSystemPressure,
            .videoDeviceNotAvailableWithMultipleForegroundApps:

            await pauseSession()

        default:
            break
        }
    }

    @RecorderActor
    private func startCapturing(in session: AVCaptureSession) async throws {
        let devices = Array(devices.values)

        for device in devices {
            try await device.startCapturing(in: session)
        }
    }
}
