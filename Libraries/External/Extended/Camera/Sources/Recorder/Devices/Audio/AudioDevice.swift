//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation
import Foundation
import Utilities

extension ErrorReason {
    /// A collection of error reasons related to the audio device operations.
    ///
    /// The `AudioDeviceErrorReason` struct provides a set of static constants representing various errors that can occur
    /// during interactions with the external devices.
    struct AudioDeviceErrorReason: Sendable {
        /// The capture input could not be added to the session.
        ///
        /// Typical causes:
        /// - The session preset/active format is incompatible with the input
        /// - `canAddInput(_:)` returned `false` (e.g., too many inputs)
        /// - Microphone permission not granted
        /// - Changes applied outside `beginConfiguration()/commitConfiguration()`
        static let cannotAddInput = ErrorReason(rawValue: "CANNOT_ADD_AUDIO_INPUT")

        /// The capture output could not be added to the session.
        ///
        /// Typical causes:
        /// - `canAddOutput(_:)` returned `false` for the current preset/format
        /// - Conflicting outputs or unsupported configuration
        /// - Output settings incompatible with the active device/format
        static let cannotAddOutput = ErrorReason(rawValue: "CANNOT_ADD_AUDIO_OUTPUT")

        /// No matching audio capture device was found.
        ///
        /// Typical causes:
        /// - No available microphone (hardware or permission constraints)
        /// - Running in an environment without audio input
        /// - Device temporarily unavailable or in use by another session
        static let captureDeviceNotFound = ErrorReason(rawValue: "CAPTURE_AUDIO_DEVICE_NOT_FOUND")

        /// The app is not authorized to use the microphone.
        ///
        /// Meaning:
        /// - Authorization status is `.denied` or `.restricted`
        static let notAuthorized = ErrorReason(rawValue: "AUDIO_DEVICE_NOT_AUTHORIZED")
    }
}

/// A configurable set of microphone capture and encoding parameters for the audio pipeline.
///
/// Centralizes choices that affect capture format (sample rate, channel count, format ID)
/// and encoder settings (bit rate). These values are used to build AVFoundation‑compatible
/// settings dictionaries for `AVAssetWriterInput` or similar consumers.
struct AudioDeviceConfiguration: Sendable {
    // MARK: - Properties

    /// Whether the capture session should automatically adjust the shared `AVAudioSession`.
    ///
    /// When `true` (default), `AVCaptureSession` may configure the app’s audio session
    /// to match capture requirements. Set to `false` if you manage `AVAudioSession`
    /// yourself (e.g., custom category/mode/route handling).
    var automaticallyConfiguresAudioSession = true

    /// Target encoder bit rate in bits per second (`AVEncoderBitRateKey`).
    ///
    /// Higher bit rates yield better quality at the cost of larger files and bandwidth.
    /// Common values range from 96_000 to 192_000 for AAC stereo voice/music.
    var bitRate = audioBitRateDefault

    /// Number of audio channels (`AVNumberOfChannelsKey`).
    ///
    /// When `nil`, it may be inferred from the provided `CMSampleBuffer` .
    /// Typical values: `1` (mono) or `2` (stereo).
    var channelsCount: Int?

    /// Audio format identifier (`AVFormatIDKey`).
    ///
    /// Defaults to `kAudioFormatMPEG4AAC` (AAC), which is widely supported and efficient.
    /// See Core Audio data types for alternatives (e.g., `kAudioFormatLinearPCM`).
    var format = kAudioFormatMPEG4AAC

    /// Preferred capture preset for the session.
    ///
    /// `.inputPriority` (default) allows device input configuration (sample rate/channel count)
    /// to take precedence over coarse session presets.
    let preset = AVCaptureSession.Preset.inputPriority

    /// Sample rate in hertz (`AVSampleRateKey`).
    ///
    /// When `nil`, it may be inferred from the provided `CMSampleBuffer`.
    /// Typical values: `44_100` or `48_000`.
    var sampleRate: Float64?

    // MARK: - Static Properties

    /// Default encoder bit rate (128 kbps).
    static let audioBitRateDefault: Int = 128_000

    /// Default number of channels (stereo).
    static let audioChannelsCountDefault = 2

    /// Default sample rate (44.1 kHz).
    static let audioSampleRateDefault: Float64 = 44_100

    // MARK: - Instance methods

    /// Builds an AVFoundation‑compatible audio settings dictionary.
    ///
    /// This method assembles a dictionary suitable for `AVAssetWriterInput` (mediaType `.audio`)
    /// or other AVFoundation consumers. If `sampleRate` and `channelsCount` are not set, it will
    /// attempt to infer them from the provided `sampleBuffer`’s format description. Channel layout
    /// data is included when available.
    ///
    /// - Parameter sampleBuffer: Optional `CMSampleBuffer` used to infer `sampleRate`, `channelsCount`, and channel layout.
    /// - Returns: A dictionary keyed by `AV*` audio constants . Returns `nil` only if insufficient information is available (rare).
    fileprivate mutating func makeSettingsDictionary(sampleBuffer: CMSampleBuffer? = nil) -> [String: Any] {
        var config: [String: Any] = [AVEncoderBitRateKey: bitRate]

        if /// Sample buffer
        let sampleBuffer,

            /// Sample format description.
            let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer)
        {

            if let streamBasicDescription = CMAudioFormatDescriptionGetStreamBasicDescription(formatDescription),
                sampleRate == nil, channelsCount == nil
            {

                sampleRate = streamBasicDescription.pointee.mSampleRate
                channelsCount = Int(streamBasicDescription.pointee.mChannelsPerFrame)
            }

            var layoutSize = 0

            if let layoutPtr = CMAudioFormatDescriptionGetChannelLayout(formatDescription, sizeOut: &layoutSize) {
                config[AVChannelLayoutKey] = layoutSize > 0 ? Data(bytes: layoutPtr, count: layoutSize) : Data()
            }
        }

        config[AVSampleRateKey] = (sampleRate ?? AudioDeviceConfiguration.audioSampleRateDefault)
        config[AVNumberOfChannelsKey] = (channelsCount ?? AudioDeviceConfiguration.audioChannelsCountDefault)
        config[AVFormatIDKey] = format

        return config
    }
}

/// A concrete audio capture device that configures inputs/outputs and manages lifecycle.
///
/// This class owns the active `AVCaptureDeviceInput` for audio and an `AVCaptureAudioDataOutput`.
/// It validates authorization, attaches/detaches inputs and outputs to a provided `AVCaptureSession`,
/// and tracks a simple lifecycle state machine.
final class AudioDevice: NSObject, Device {
    // MARK: - Private Properties

    private var captureAudioDataOutput: AVCaptureAudioDataOutput?
    private var captureDeviceInput: AVCaptureDeviceInput?
    private var captureSession: AVCaptureSession?
    private let queue = DispatchQueue(label: "com.audio.device.queue")

    // MARK: - Properties

    /// Holds options such as desired sample rate, channel count, audio format, and encoder bit rate
    /// that guide how the audio pipeline is configured. This instance is created with sensible
    /// defaults and may be updated by higher‑level APIs before building `AVAssetWriterInput`
    /// output settings or stream‑upload parameters. Exposed as `nonisolated` for read‑only access
    /// without hopping onto `DeviceActor`.
    let configuration = AudioDeviceConfiguration()

    /// The current lifecycle state of the audio device.
    ///
    /// Starts as `.initialized` and transitions through `running`, `finished`, or `failed`
    /// according to the component’s workflow. See `State` for the allowed transitions
    /// enforced by the state machine.
    private(set) var state = RecordingState.initialized

    // MARK: - Computed Properties

    /// Indicates whether the app is authorized to access the audio capture.
    ///
    /// Evaluates the current authorization status for `.audio` and returns `true` only when
    /// the status is `.authorized`. Use this to gate microphone-dependent features.
    ///
    /// - Returns: `true` if audio capture is authorized; otherwise, `false`.
    var isAuthorized: Bool {
        AVCaptureDevice.authorizationStatus(for: .audio) == .authorized
    }

    // MARK: - Initializer

    /// Creates a new instance of the `AudioDevice`.
    nonisolated override init() {}

    // MARK: - Device

    /// Stops capture for this device and removes any installed inputs/outputs from the session.
    ///
    /// Implementations should safely detach inputs/outputs and perform any necessary cleanup.
    /// Prefer calling this while the session is inside a configuration block.
    ///
    /// - Parameter session: The `AVCaptureSession` from which to remove this device’s input/output.
    @DeviceActor
    func endCapturing(in session: AVCaptureSession) {
        if state.canTransition(to: .finished) {
            destroyDevice()
            state = .finished
        }
    }

    /// Pauses capture for this device without removing it from the session.
    ///
    /// Implementations should temporarily stop processing or capturing data while maintaining
    /// the device's connection to the session. This allows for quick resumption of capture
    /// without the overhead of reconfiguring inputs/outputs.
    @DeviceActor
    func pause() {
        if state.canTransition(to: .paused) {
            state = .paused
        }
    }

    /// Resets the device to a clean state, clearing any corrupted internal state.
    ///
    /// This method should be called when the device needs to recover from errors or when
    /// performing a complete session reset. It clears any corrupted buffers, resets internal
    /// configuration, and prepares the device for a fresh start without attempting to finalize
    /// any recordings to avoid corruption.
    @DeviceActor
    func reset() {
        if state.canTransition(to: .initialized) {
            destroyDevice()
            state = .initialized
        }
    }

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
    @DeviceActor
    func resume() {
        if state.canTransition(to: .paused) {
            state = .running
        }
    }

    /// Configures and starts capture for this device on the given session.
    ///
    /// Implementations typically validate authorization, resolve an `AVCaptureDevice`,
    /// install an `AVCaptureDeviceInput` and any required outputs, and update connection
    /// settings as needed. Prefer calling this while the session is inside a configuration block.
    ///
    /// - Parameter session: The `AVCaptureSession` to which inputs/outputs will be added.
    /// - Throws: An error if authorization is missing, if no suitable device is found, or if inputs/outputs cannot be added to the session due to incompatibility.
    @DeviceActor
    func startCapturing(in session: AVCaptureSession) throws {
        if state.canTransition(to: .running) {
            do {
                guard AVCaptureDevice.authorizationStatus(for: .audio) == .authorized else {
                    throw UtilityError(
                        kind: .AudioDeviceErrorReason.notAuthorized,
                        failureReason: "This app doesn’t have permission to use the audio device."
                    )
                }

                session.beginConfiguration()

                defer { session.commitConfiguration() }

                captureDeviceInput = try session.addDeviceInput()
                captureAudioDataOutput = try session.addDeviceOutput()
                
                captureAudioDataOutput?.setSampleBufferDelegate(self, queue: queue)

                captureSession = session
                state = .running
            } catch {
                if let captureDeviceInput {
                    session.removeInput(captureDeviceInput)
                }

                state = .failed
                throw error
            }
        }
    }

    // MARK: - Instance methods

    /// Requests microphone (audio) permission from the user.
    ///
    /// Presents the system authorization dialog if the status is `.notDetermined`.
    @discardableResult
    func requestAccess() async -> Bool {
        await AVCaptureDevice.requestAccess(for: .audio)
    }

    // MARK: - Private methods

    private func destroyDevice() {
        if let captureSession {
            captureSession.beginConfiguration()

            defer { captureSession.commitConfiguration() }

            if let captureAudioDataOutput {
                captureAudioDataOutput.setSampleBufferDelegate(nil, queue: nil)
                captureSession.removeOutput(captureAudioDataOutput)

                self.captureAudioDataOutput = nil
            }

            if let captureDeviceInput {
                captureSession.removeInput(captureDeviceInput)

                self.captureDeviceInput = nil
            }
        }
    }
}

extension AudioDevice: AVCaptureAudioDataOutputSampleBufferDelegate {

    // MARK: - AVCaptureAudioDataOutputSampleBufferDelegate

    nonisolated func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {

    }
}

extension AVCaptureSession {
    /// Creates and adds an audio device input to the capture session.
    ///
    /// This function sets up audio capture by discovering the default audio device (microphone),
    /// removing any existing audio input to prevent configuration conflicts, and adding the
    /// new audio device input to the capture session. The function performs comprehensive
    /// validation and error handling to ensure reliable audio input setup, including
    /// device availability checks and session compatibility validation.
    ///
    /// - Returns: An `AVCaptureDeviceInput` instance that has been successfully created and added to the
    ///            capture session for audio capture.
    ///
    /// - Throws: A `UtilityError` with specific audio device error reasons:
    ///           - `.AudioDeviceErrorReason.captureDeviceNotFound` if no audio capture
    ///             device is available on the current device, typically indicating
    ///             the device lacks a microphone or audio capture capability
    ///           - `.AudioDeviceErrorReason.cannotAddInput` if the audio device input
    ///             cannot be added to the session, including underlying system errors
    ///             that prevented input creation or session integration
    fileprivate func addDeviceInput() throws(UtilityError) -> AVCaptureDeviceInput {
        guard let captureDevice = AVCaptureDevice.default(for: .audio) else {
            throw UtilityError(
                kind: .AudioDeviceErrorReason.captureDeviceNotFound,
                failureReason: "No audio capture device was found. Ensure this device has a microphone available."
            )
        }

        if let currentCaptureDeviceInput = captureDeviceInput(for: .audio) {
            removeInput(currentCaptureDeviceInput)
        }

        let captureDeviceInput: AVCaptureDeviceInput

        do {
            captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
        } catch {
            throw UtilityError(kind: .AudioDeviceErrorReason.cannotAddInput, underlyingError: error)
        }
        
        guard canAddInput(captureDeviceInput) else {
            throw UtilityError(
                kind: .AudioDeviceErrorReason.cannotAddInput,
                failureReason: "Unable to add \(captureDeviceInput.debugDescription) to the session"
            )
        }

        addInput(captureDeviceInput)

        return captureDeviceInput
    }
    
    /// Creates and adds an audio data output to the capture session.
    ///
    /// This function sets up audio data output by creating a new `AVCaptureAudioDataOutput`
    /// instance and adding it to the current capture session. The function performs
    /// validation to ensure the audio output can be successfully added to the session
    /// before attempting the addition. If the output cannot be added, the function
    /// throws an appropriate error with detailed failure information for debugging
    /// and error handling purposes.
    ///
    /// - Returns: An `AVCaptureAudioDataOutput` instance that has been successfully
    ///            added to the capture session and is ready for audio data processing.
    ///
    /// - Throws: A `UtilityError` with `.AudioDeviceErrorReason.cannotAddOutput` kind
    ///           if the audio data output cannot be added to the session, including
    ///           a detailed failure reason that provides debugging information about
    ///           why the output addition failed.
    fileprivate func addDeviceOutput() throws(UtilityError) -> AVCaptureAudioDataOutput {
        let captureAudioDataOutput = AVCaptureAudioDataOutput()

        guard canAddOutput(captureAudioDataOutput) else {
            throw UtilityError(
                kind: .AudioDeviceErrorReason.cannotAddOutput,
                failureReason: "Unable to add \(captureAudioDataOutput.debugDescription) to the session"
            )
        }

        addOutput(captureAudioDataOutput)
        
        return captureAudioDataOutput
    }
}
