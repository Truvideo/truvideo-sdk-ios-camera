//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation
import Foundation
internal import Utilities

/// A lightweight wrapper that couples an audio `CMSampleBuffer` with its timing information.
///
/// The AudioSampleBuffer struct provides a convenient way to access audio sample data
/// along with its associated timing metadata. This wrapper encapsulates the duration,
/// presentation timestamp, and underlying sample buffer, making it easier to work with
/// audio timing for synchronization, ordering, and writer session management. The struct
/// is designed to be lightweight and efficient, storing only references to avoid
/// unnecessary data copying while providing easy access to commonly needed timing
/// information.
struct AudioSampleBuffer {
    /// The sample’s duration timestamp.
    ///
    /// Use this for ordering, synchronization with audio, and writer session timing.
    let duration: CMTime

    /// The underlying captured/decoded media sample.
    ///
    /// Contains the pixel data and timing/format metadata for this frame.
    /// The buffer is not owned or retained beyond normal ARC semantics.
    let sampleBuffer: CMSampleBuffer

    /// The sample’s presentation timestamp.
    ///
    /// Use this for ordering, synchronization with audio, and writer session timing.
    let timestamp: CMTime

    // MARK: - Computed Properties

    /// Returns the format description of the samples in a sample buffer.
    var formatDescription: CMFormatDescription? {
        CMSampleBufferGetFormatDescription(sampleBuffer)
    }
}

/// Protocol defining the interface for processing audio output buffers.
///
/// The AudioOutputProcessor protocol provides a standardized way to handle audio sample buffers
/// with configurable audio processing parameters. Implementers can apply various audio effects,
/// filters, or transformations to incoming audio data before it is output or further processed.
/// This protocol is designed to be flexible and extensible, allowing for different audio processing
/// strategies while maintaining a consistent interface.
protocol AudioOutputProcessor: AnyObject {
    /// Processes an audio sample buffer using the specified configuration.
    ///
    /// This method takes a sample buffer containing raw audio data and applies audio processing
    /// according to the provided configuration. The processing may include effects like equalization,
    /// compression, noise reduction, or other audio transformations. The method should handle
    /// different audio formats and sample rates as specified in the configuration.
    ///
    /// - Parameters:
    ///   - buffer: The audio sample buffer to be processed. This buffer contains the raw audio
    ///             data in the format specified by the buffer's audio format description.
    ///   - configuration: The audio configuration object that defines how the audio should be processed.
    func process(_ buffer: AudioSampleBuffer, with configuration: AudioDeviceConfiguration)
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
    private var processors: [ObjectIdentifier: any AudioOutputProcessor] = [:]
    private let queue = DispatchQueue(label: "com.audio.device.queue")

    // MARK: - Properties

    /// Holds options such as desired sample rate, channel count, audio format, and encoder bit rate
    /// that guide how the audio pipeline is configured. This instance is created with sensible
    /// defaults and may be updated by higher‑level APIs before building `AVAssetWriterInput`
    /// output settings or stream‑upload parameters. Exposed as `nonisolated` for read‑only access
    /// without hopping onto `DeviceActor`.
    let configuration = AudioDeviceConfiguration()

    /// Indicates whether the audio device is ready for capture operations.
    ///
    /// This property tracks the initialization state of the audio device, determining
    /// whether it has been properly configured and is ready to perform audio capture
    /// operations.
    private(set) var isReady = false

    /// The current lifecycle state of the audio device.
    ///
    /// Starts as `.initialized` and transitions through `running`, `finished`, or `failed`
    /// according to the component’s workflow. See `State` for the allowed transitions
    /// enforced by the state machine.
    private(set) var state = RecordingState.initialized

    // MARK: - Computed Properties

    /// The current authorization status for audio capture permissions.
    ///
    /// This computed property returns the current authorization status for audio capture
    /// permissions from the system. It provides a convenient way to check whether the app
    /// has permission to access the device's microphone for audio recording and processing.
    var authorizationStatus: AVAuthorizationStatus {
        AVCaptureDevice.authorizationStatus(for: .audio)
    }

    /// Indicates whether the audio device is currently available for capture operations.
    ///
    /// This computed property determines if the audio device can be used for recording
    /// by checking whether another app is currently using the microphone or if the
    /// system has silenced secondary audio. It provides real-time availability status
    /// that helps prevent conflicts and ensures proper audio capture behavior.
    var isAvailable: Bool {
        !AVAudioSession.sharedInstance().secondaryAudioShouldBeSilencedHint
    }

    // MARK: - Initializer

    /// Creates a new instance of the `AudioDevice`.
    nonisolated override init() {}

    // MARK: - Device

    /// Configures the device for use with the specified capture session.
    ///
    /// This function sets up the device with the necessary configuration to work with the given
    /// AVCaptureSession. It handles device initialization, format selection, and session integration
    /// to ensure the device is ready for capture operations.
    ///
    /// - Parameter session: The AVCaptureSession to configure the device with.
    /// - Throws: UtilityError if the device configuration fails or cannot be completed.
    @DeviceActor
    func configure(in session: AVCaptureSession) throws(UtilityError) {
        guard AVCaptureDevice.authorizationStatus(for: .audio) == .authorized else {
            throw UtilityError(
                kind: .AudioDeviceErrorReason.notAuthorized,
                failureReason: "This app doesn’t have permission to use the audio device."
            )
        }

        do {
            session.beginUpdates()

            defer { session.endUpdates() }

            captureDeviceInput = try session.addDeviceInput()
            captureAudioDataOutput = try session.addDeviceOutput()

            captureAudioDataOutput?.setSampleBufferDelegate(self, queue: queue)

            captureSession = session
            isReady = true
        } catch {
            destroyDevice()
            state = .failed
            throw error
        }
    }

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
        if state.canTransition(to: .running) {
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
    func startCapturing() throws(UtilityError) {
        if state.canTransition(to: .running) {
            guard isReady else {
                state = .failed
                throw UtilityError(
                    kind: .AudioDeviceErrorReason.needsConfiguration,
                    failureReason: "Device needs to be configured."
                )
            }

            state = .running
        }
    }

    // MARK: - Instance methods

    /// Registers a processor by its reference identity.
    ///
    /// Stores the processor in the internal registry keyed by `ObjectIdentifier(processor)`,
    /// ensuring one entry per instance. Adding the same instance again replaces the existing entry.
    /// Requires `AudioOutputProcessor` to be class‑bound so it has stable reference identity.
    ///
    /// - Parameter processor: The processor instance to register.
    @DeviceActor
    func add(_ processor: any AudioOutputProcessor) {
        processors[ObjectIdentifier(processor)] = processor
    }

    /// Requests microphone (audio) permission from the user.
    ///
    /// Presents the system authorization dialog if the status is `.notDetermined`.
    @discardableResult
    func requestAccess() async -> Bool {
        await AVCaptureDevice.requestAccess(for: .audio)
    }

    /// Unregisters a processor by its reference identity.
    ///
    /// Removes the entry keyed by `ObjectIdentifier(processor)`. If no matching instance
    /// is registered, this is a no‑op. Identity is based on the processor’s object reference,
    /// not value equality.
    ///
    /// - Parameter processor: The processor instance to remove.
    @DeviceActor
    func remove(_ processor: any AudioOutputProcessor) {
        processors.removeValue(forKey: ObjectIdentifier(processor))
    }

    // MARK: - Private methods

    private func destroyDevice() {
        if let captureSession {
            captureSession.beginUpdates()

            defer { captureSession.endUpdates() }

            if let captureAudioDataOutput {
                captureAudioDataOutput.setSampleBufferDelegate(nil, queue: nil)
                captureSession.removeOutput(captureAudioDataOutput)

                self.captureAudioDataOutput = nil
            }

            if let captureDeviceInput {
                captureSession.removeInput(captureDeviceInput)

                self.captureDeviceInput = nil
            }

            isReady = false
        }
    }
}

extension AudioDevice: AVCaptureAudioDataOutputSampleBufferDelegate {

    // MARK: - AVCaptureAudioDataOutputSampleBufferDelegate

    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {

        if state == .running {
            let sampleBuffer = AudioSampleBuffer(
                duration: CMSampleBufferGetDuration(sampleBuffer),
                sampleBuffer: sampleBuffer,
                timestamp: CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            )

            Task {
                let processors = Array(processors.values)
                processors.forEach { $0.process(sampleBuffer, with: configuration) }
            }
        }
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
