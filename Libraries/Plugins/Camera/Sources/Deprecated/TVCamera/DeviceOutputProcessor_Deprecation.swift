//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit

/// A lightweight wrapper that couples an audio `CMSampleBuffer` with its timing information.
///
/// The AudioSampleBuffer struct provides a convenient way to access audio sample data
/// along with its associated timing metadata. This wrapper encapsulates the duration,
/// presentation timestamp, and underlying sample buffer, making it easier to work with
/// audio timing for synchronization, ordering, and writer session management. The struct
/// is designed to be lightweight and efficient, storing only references to avoid
/// unnecessary data copying while providing easy access to commonly needed timing
/// information.
struct AudioSampleBufferDeprecation {
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

/// A lightweight wrapper that couples a video `CMSampleBuffer` with its presentation timestamp.
///
/// Use this type to pass samples through processing pipelines with an explicit, immutable
/// timestamp, avoiding repeated queries to the buffer’s timing info. The underlying buffer
/// is not copied; this struct only stores a reference.
struct VideoSampleBufferDeprecation {
    /// The nominal frame duration for the capture source.
    ///
    /// Typically the inverse of the target FPS (e.g., 1/24, 1/30). Used to pace processing,
    /// compute scaled frame durations, and maintain continuous timestamps. For variable‑frame‑rate
    /// streams this is a baseline reference and individual samples may deviate.
    let minFrameDuration: CMTime

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

    /// Returns an image buffer that contains the media data.
    var imageBuffer: CVImageBuffer? {
        CMSampleBufferGetImageBuffer(sampleBuffer)
    }
}

/// Protocol defining the interface for processing audio output buffers.
///
/// The AudioOutputProcessor protocol provides a standardized way to handle audio sample buffers
/// with configurable audio processing parameters. Implementers can apply various audio effects,
/// filters, or transformations to incoming audio data before it is output or further processed.
/// This protocol is designed to be flexible and extensible, allowing for different audio processing
/// strategies while maintaining a consistent interface.
protocol AudioOutputProcessorDeprecation {
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
    func processAudio(buffer: AudioSampleBufferDeprecation, with configuration: TruAudioConfiguration)
}

/// A contract for components that consume video samples with access
/// to the active capture/encode configuration.
///
/// Conforming types are reference types to enable stable identity Implementations should
/// keep per‑frame work lightweight and offload heavy tasks to background queues to avoid
/// blocking the capture pipeline. The provided configuration is a read‑only snapshot of the
/// current device/encoding preferences and must not be mutated by processors.
protocol VideoOutputProcessorDeprecation {
    /// Processes a single video sample using the provided configuration.
    ///
    /// Use the configuration to guide transformations (e.g., scaling, color space,
    /// orientation/transform, target bitrate hints) while relying on the sample’s
    /// timing for ordering. This method is expected to run on the component’s serialization context
    ///
    /// - Parameters:
    ///   - buffer: The video sample to process.
    ///   - configuration: A snapshot of capture/encoding preferences to inform processing.
    func processVideo(buffer: VideoSampleBufferDeprecation, with configuration: TruVideoConfiguration)
}

/// Type alias combining audio and video output processing capabilities.
///
/// The DeviceOutputProcessor type alias creates a unified interface that combines both
/// AudioOutputProcessor and VideoOutputProcessor protocols. This allows implementers to
/// provide coordinated processing of both audio and video streams through a single interface,
/// enabling synchronized media processing operations and unified lifecycle management.
typealias DeviceOutputProcessorDeprecation = AudioOutputProcessorDeprecation & VideoOutputProcessorDeprecation

/// Global actor that provides thread-safe isolation for movie output processing operations.
///
/// The MovieOutputProcessorActor ensures that all movie output processing operations
/// are executed on a single, dedicated thread, preventing race conditions and data
/// corruption when multiple parts of the system attempt to access or modify the
/// processor's state simultaneously. This actor is particularly important for
/// coordinating audio and video processing operations that must remain synchronized.
final class MovieOutputProcessorDeprecation: DeviceOutputProcessorDeprecation {
    // MARK: - Private Properties

    private let identifier = UUID()
    private var assetWriter: AVAssetWriter?
    private var audioInput: AVAssetWriterInput?
    private var backgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    private var clipFilenameCount = 0
    private var lastAudioTimestamp = CMTime.invalid
    private var lastVideoTimestamp = CMTime.invalid
    private var mediaProcessingOptions: MediaProcessingOptions = []
    private var pauseStartTime = CMTime.invalid
    private var pixelBufferAdapter: AVAssetWriterInputPixelBufferAdaptor?
    private var skippedAudioBuffers: [AudioSampleBufferDeprecation] = []
    private var startTimestamp = CMTime.invalid
    private var videoInput: AVAssetWriterInput?

    // MARK: - Properties

    /// The list of the recorded clips
    private(set) var clips: [TruVideoClip] = []

    /// Output file type for a session, see AVMediaFormat.h for supported types.
    var fileType = AVFileType.mp4

    /// The current state of the processing operation, indicating its lifecycle phase.
    ///
    /// This property tracks the current state of the processing operation, from initialization
    /// through completion. The state can only be modified internally by the class itself,
    /// ensuring that state transitions follow the defined state machine rules and preventing
    /// external code from accidentally corrupting the operation's lifecycle. The state
    /// property is used to coordinate audio and video processing operations, manage resource
    /// allocation, and ensure proper cleanup procedures are followed.
    private(set) var state = State.initialized

    /// Output directory for the session.
    var outputDirectory = URL(fileURLWithPath: NSTemporaryDirectory())

    /// Duration of a session, the sum of all recorded clips.
    @Published
    private(set) var totalDuration = CMTime.invalid

    // MARK: - Computed Properties

    /// Whether the session has configured the audio
    private var hasConfiguredAudio: Bool {
        audioInput != nil
    }

    /// Whether the session has configured the video
    private var hasConfiguredVideo: Bool {
        videoInput != nil
    }

    /// The underliying error.
    private(set) var error: TruVideoError?

    /// Video output transform for display
    var transform: CGAffineTransform? {
        get {
            videoInput?.transform
        }

        set {
            guard let newValue = newValue else {
                return
            }

            videoInput?.transform = newValue
        }
    }

    // MARK: - Types

    /// Option set defining media processing configuration options for audio and video streams.
    ///
    /// The MediaProcessingOptions struct provides a type-safe way to configure which media streams
    /// should be processed during media operations. This option set allows developers to specify
    /// whether to process audio, video, or both streams, enabling flexible configuration of media
    /// processing pipelines. The options can be combined using set operations to create complex
    /// processing configurations while maintaining clear and readable code.
    struct MediaProcessingOptions: OptionSet {
        // MARK: - Properties

        /// The raw integer value representing the option set's bit flags.
        ///
        /// This property stores the underlying bit pattern that represents the combination
        /// of selected options. Each bit position corresponds to a specific media processing
        /// option, allowing efficient bitwise operations for option combination and checking.
        let rawValue: Int

        // MARK: - Static Properties

        /// Option to process audio streams during media operations.
        ///
        /// When this option is selected, audio processing will be enabled for the media
        /// operation. This includes audio capture, processing, encoding, and output
        /// generation. Audio processing can be combined with video processing or used
        /// independently for audio-only operations.
        static let audio = MediaProcessingOptions(rawValue: 1 << 0)

        /// Option to process video streams during media operations.
        ///
        /// When this option is selected, video processing will be enabled for the media
        /// operation. This includes video capture, processing, encoding, and output
        /// generation. Video processing can be combined with audio processing or used
        /// independently for video-only operations.
        static let video = MediaProcessingOptions(rawValue: 1 << 1)
    }

    /// Enumeration representing the lifecycle states of a processing or recording operation.
    ///
    /// The State enum defines the various stages that a processing operation can be in, from
    /// initialization through completion. Each state represents a specific point in the operation's
    /// lifecycle, and the enum provides methods to validate state transitions to ensure proper
    /// lifecycle management and prevent invalid state changes that could lead to data corruption
    /// or inconsistent behavior.
    enum State {
        /// The initial state after creation, ready to begin processing.
        ///
        /// In this state, the operation has been initialized with all necessary resources
        /// and configuration, but processing has not yet begun. This is the starting point
        /// for all valid operation lifecycles.
        case initialized

        /// The operation has encountered an error and cannot continue.
        ///
        /// This state indicates that a critical error has occurred during processing,
        /// such as device failures, configuration errors, or resource unavailability.
        /// The operation cannot recover from this state and must be reinitialized.
        case failed

        /// The operation is in the process of completing and finalizing its output.
        ///
        /// This state indicates that the operation has completed its main processing tasks
        /// and is now performing finalization operations such as writing final data,
        /// closing output files, releasing resources, and preparing for completion.
        /// The operation is transitioning from active processing to a completed state
        /// and should not receive new input data during this phase.
        case finishing

        /// The operation has completed successfully and all resources have been released.
        ///
        /// This is the final state for a successful operation. All processing has been
        /// completed, output has been finalized, and resources have been properly cleaned up.
        /// No further processing can occur from this state.
        case finished

        /// The operation is actively processing or recording data.
        ///
        /// This is the active processing state where the operation is consuming input,
        /// performing transformations, and producing output. This state consumes the most
        /// resources and represents the core operational phase.
        case writing

        // MARK: - Instance methods

        /// Indicates whether a transition from the current state to a new state is permitted.
        /// Any other transition is rejected to protect lifecycle invariants.
        ///
        /// - Parameter newState: The target state to evaluate.
        /// - Returns: `true` if the transition is allowed; otherwise, `false`.
        func canTransition(to newState: State) -> Bool {
            switch (self, newState) {
            case (.initialized, .failed),
                (.initialized, .writing),
                (.failed, .writing),
                (.finished, .writing),
                (.finishing, .failed),
                (.finishing, .finished),
                (.writing, .failed),
                (.writing, .finishing):

                true

            default:
                false
            }
        }
    }

    // MARK: - DeviceOutputProcessor

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
    func processAudio(buffer: AudioSampleBufferDeprecation, with configuration: TruAudioConfiguration) {
        if state == .writing {
            Task { @MovieOutputProcessorActor in
                configureAudioInput(with: buffer, configuration: configuration)
                startSessionIfNecessary(at: buffer.timestamp)
                appendAudio(buffer: buffer)
            }
        }
    }

    /// Processes a single video sample using the provided configuration.
    ///
    /// Use the configuration to guide transformations (e.g., scaling, color space,
    /// orientation/transform, target bitrate hints) while relying on the sample’s
    /// timing for ordering. This method is expected to run on the component’s serialization context
    ///
    /// - Parameters:
    ///   - buffer: The video sample to process.
    ///   - configuration: A snapshot of capture/encoding preferences to inform processing.
    func processVideo(buffer: VideoSampleBufferDeprecation, with configuration: TruVideoConfiguration) {
        if state == .writing {
            Task { @MovieOutputProcessorActor in
                configureVideoInput(with: buffer, configuration: configuration)
                startSessionIfNecessary(at: buffer.timestamp)
                appendVideo(buffer: buffer)
            }
        }
    }

    // MARK: - Instance methods

    /// Ends the movie processing operation and returns the output file URL.
    ///
    /// This method gracefully terminates the movie processing operation, finalizes the output file,
    /// and cleans up all associated resources. It ensures that the asset writer properly finishes
    /// writing, validates the final status, and resets all internal state variables. The method
    /// follows the state machine rules to ensure only valid transitions occur during shutdown.
    ///
    /// - Returns: The URL of the successfully completed output movie file. This URL points to
    ///            the final video file that has been completely written and finalized.
    ///
    /// - Throws: A `TruVideoError` if something fails.
    @MovieOutputProcessorActor
    func endProcessing() async throws(TruVideoError) -> URL {
        guard let error else {
            if let assetWriter, state.canTransition(to: .finishing) {
                state = .finishing

                await assetWriter.finishWriting()

                if assetWriter.status == .failed {
                    throw TruVideoError(kind: .unknown)
                }

                let outputURL = assetWriter.outputURL
                self.assetWriter = nil

                audioInput = nil
                videoInput = nil
                startTimestamp = .invalid
                totalDuration = .zero
                state = .finished

                return outputURL
            } else {
                throw TruVideoError(kind: .unknown)
            }
        }

        throw error
    }

    /// Starts or resumes the movie processing operation.
    ///
    /// This method initiates or resumes the movie processing operation by transitioning the state
    /// to writing. The start operation only succeeds if the current state allows transition to
    /// writing according to the state machine rules.
    @MovieOutputProcessorActor
    func startProcessing() {
        if state.canTransition(to: .writing) {
            state = .writing
        }
    }

    // MARK: - Private methods

    private func appendAudio(buffer: AudioSampleBufferDeprecation) {
        let buffers = skippedAudioBuffers + [buffer]
        var failedBuffers: [AudioSampleBufferDeprecation] = []

        skippedAudioBuffers = []

        if let audioInput, audioInput.isReadyForMoreMediaData {
            for buffer in buffers {
                let lastTimestamp = buffer.duration + buffer.timestamp

                if audioInput.append(buffer.sampleBuffer) {
                    lastAudioTimestamp = lastTimestamp
                    mediaProcessingOptions.insert(.audio)

                    if !mediaProcessingOptions.contains(.video) {
                        totalDuration = lastTimestamp - startTimestamp
                    }
                } else {
                    failedBuffers.append(buffer)
                }
            }
        }

        skippedAudioBuffers = failedBuffers
    }

    private func appendVideo(buffer: VideoSampleBufferDeprecation) {
        if /// The active video input.
        let videoInput,

            /// The prixel buffer adapter.
            let pixelBufferAdapter, videoInput.isReadyForMoreMediaData
        {

            /// Current buffer to process.
            if let bufferToProcess = buffer.imageBuffer,

                /// Whether the current timespamp is valid for processing.
                buffer.sampleBuffer.presentationTimeStamp.isValid,

                pixelBufferAdapter.append(
                    bufferToProcess,
                    withPresentationTime: buffer.sampleBuffer.presentationTimeStamp
                )
            {

                lastVideoTimestamp = buffer.timestamp
                totalDuration = CMTimeSubtract(
                    buffer.sampleBuffer.presentationTimeStamp + buffer.minFrameDuration,
                    startTimestamp
                )

                mediaProcessingOptions.insert(.video)
            }
        }
    }

    private func configureAudioInput(with buffer: AudioSampleBufferDeprecation, configuration: TruAudioConfiguration) {
        if audioInput == nil {
            let audioInput = AVAssetWriterInput(
                mediaType: .audio,
                outputSettings: configuration.avcaptureSettingsDictionary(),
                sourceFormatHint: buffer.formatDescription
            )

            audioInput.expectsMediaDataInRealTime = true

            self.audioInput = audioInput
        }
    }

    private func configureVideoInput(with buffer: VideoSampleBufferDeprecation, configuration: TruVideoConfiguration) {
        if videoInput == nil {
            let settings = configuration.avcaptureSettingsDictionary(sampleBuffer: buffer.sampleBuffer)
            var pixelBufferAttibutes: [String: Any] = [
                String(kCVPixelBufferPixelFormatTypeKey): Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
            ]

            if let format = buffer.formatDescription {
                let dimensions = CMVideoFormatDescriptionGetDimensions(format)

                pixelBufferAttibutes[String(kCVPixelBufferHeightKey)] = dimensions.height
                pixelBufferAttibutes[String(kCVPixelBufferWidthKey)] = dimensions.width
            } else if /// The video configuration.
            let settings,

                /// The video height dimension.
                let height = settings[String(kCVPixelBufferHeightKey)],

                /// The video width dimension.
                let width = settings[String(kCVPixelBufferWidthKey)]
            {

                pixelBufferAttibutes[String(kCVPixelBufferHeightKey)] = height
                pixelBufferAttibutes[String(kCVPixelBufferWidthKey)] = width
            } else {
                print("[TruVideoSession]: 🛑 failed to configure video output")
                error = TruVideoError(kind: .unknown)
                videoInput = nil
            }

            videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: settings)

            if let videoInput {
                videoInput.expectsMediaDataInRealTime = true
                videoInput.transform = configuration.transform

                pixelBufferAdapter = AVAssetWriterInputPixelBufferAdaptor(
                    assetWriterInput: videoInput,
                    sourcePixelBufferAttributes: pixelBufferAttibutes
                )
            }
        }
    }

    private func generateNextOutputURL() -> URL {
        let filename = "\(identifier)-TV-clip.\(clipFilenameCount).mp4"

        clipFilenameCount += 1
        return outputDirectory.appendingPathComponent(filename)
    }

    private func startSessionIfNecessary(at timestamp: CMTime) {
        guard assetWriter == nil, hasConfiguredAudio, hasConfiguredVideo else {
            return
        }

        do {
            assetWriter = try AVAssetWriter(url: generateNextOutputURL(), fileType: fileType)
        } catch {
            self.error = TruVideoError(kind: .unknown)
            self.state = .failed
            print("[TruVideoSession]: 🛑 cannot create the writer")
        }

        if let assetWriter {
            assetWriter.metadata = TruVideoRecorder.assetWriterMetadata
            assetWriter.shouldOptimizeForNetworkUse = true

            if let audioInput {
                if assetWriter.canAdd(audioInput) {
                    assetWriter.add(audioInput)
                } else {
                    print("[TruVideoSession]: 🛑 writer encountered an error adding the audio input")
                    error = TruVideoError(kind: .unknown)
                    state = .failed
                }
            }

            if let videoInput {
                if assetWriter.canAdd(videoInput) {
                    assetWriter.add(videoInput)
                } else {
                    print("[TruVideoSession]: 🛑 writer encountered an adding the video input")
                    error = TruVideoError(kind: .unknown)
                    state = .failed
                }
            }

            if error == nil {
                assetWriter.startWriting()
                assetWriter.startSession(atSourceTime: timestamp)

                startTimestamp = timestamp
            }
        }
    }
}
