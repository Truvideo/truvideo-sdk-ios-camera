//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit
internal import Utilities

/// A global actor that provides isolated execution context for movie output processing operations.
///
/// This global actor ensures thread-safe access to movie output processing by serializing
/// all operations that interact with movie output functionality. It provides a shared
/// execution context that can be used across the application to coordinate movie
/// processing tasks and prevent race conditions.
@globalActor
actor MovieOutputProcessorActor {
    /// The shared global actor instance used to isolate device operations.
    static let shared = MovieOutputProcessorActor()
}

/// A processor that handles movie output generation from audio and video sample buffers.
///
/// This class manages the creation and writing of movie files using AVAssetWriter,
/// processing incoming audio and video samples according to device configurations.
/// It handles the complete lifecycle of movie creation from initialization through
/// completion, including background task management, error handling, and resource cleanup.
///
/// The processor supports both audio and video streams, configurable output formats
/// (MOV/MP4), and provides a state machine to ensure proper operation flow. It's
/// designed to work with the DeviceOutputProcessor protocol for seamless integration
/// with camera and audio capture systems.
final class MovieOutputProcessor {
    // MARK: - Private Properties

    private let identifier = UUID()
    private var assets: [AVAsset] = []
    private var assetWriter: AVAssetWriter?
    private var audioInput: AVAssetWriterInput?
    private var backgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    private var clipFilenameCount = 1
    private var lastAudioTimestamp = CMTime.invalid
    private var lastVideoTimestamp = CMTime.invalid
    private var mediaProcessingOptions: MediaProcessingOptions = []
    private var pixelBufferAdapter: AVAssetWriterInputPixelBufferAdaptor?
    private var skippedAudioBuffers: [AudioSampleBuffer] = []
    private var startTimestamp = CMTime.invalid
    private var videoInput: AVAssetWriterInput?

    // MARK: - Properties

    /// The underliying error.
    private(set) var error: UtilityError?

    /// Output file type for the session.
    var fileType = FileType.mp4

    /// Output directory for the session.
    var outputDirectory = URL(fileURLWithPath: NSTemporaryDirectory())

    /// The current state of the processing operation, indicating its lifecycle phase.
    private(set) var state = State.initialized

    // MARK: - Published Properties

    /// The total duration of processed media, published for UI updates.
    ///
    /// This published property tracks the cumulative duration of all processed
    /// audio and video samples since the start of the current processing session.
    /// It automatically updates as new media samples are processed, providing
    /// real-time feedback on the current recording or processing progress.
    @Published private(set) var totalDuration = CMTime.invalid

    // MARK: - Computed Properties

    /// Whether the session has configured the audio
    private var hasConfiguredAudio: Bool {
        audioInput != nil
    }

    /// Whether the session has configured the video
    private var hasConfiguredVideo: Bool {
        videoInput != nil
    }

    // MARK: - Static Properties

    /// Returns the default metadata for an `AVAssetWriter`
    var metadata: [AVMutableMetadataItem] {
        let modelItem = AVMutableMetadataItem()
        modelItem.keySpace = AVMetadataKeySpace.common
        modelItem.key = AVMetadataKey.commonKeyModel as (NSCopying & NSObjectProtocol)
        modelItem.value = UIDevice.current.localizedModel as (NSCopying & NSObjectProtocol)

        let softwareItem = AVMutableMetadataItem()
        softwareItem.keySpace = AVMetadataKeySpace.common
        softwareItem.key = AVMetadataKey.commonKeySoftware as (NSCopying & NSObjectProtocol)
        softwareItem.value = truVideoMetadataTitle as (NSCopying & NSObjectProtocol)

        let artistItem = AVMutableMetadataItem()
        artistItem.keySpace = AVMetadataKeySpace.common
        artistItem.key = AVMetadataKey.commonKeyArtist as (NSCopying & NSObjectProtocol)
        artistItem.value = truVideoMetadataArtist as (NSCopying & NSObjectProtocol)

        let creationDateItem = AVMutableMetadataItem()
        creationDateItem.keySpace = .common
        creationDateItem.key = AVMetadataKey.commonKeyCreationDate as NSString
        creationDateItem.value = Date() as NSDate

        return [modelItem, softwareItem, artistItem, creationDateItem]
    }

    // MARK: - Types

    /// Represents supported video file formats for recording and export operations.
    ///
    /// This enum defines the video file types that are supported by the video
    /// recording system. It provides a type-safe way to specify file formats
    /// and maps them to their corresponding AVFoundation file types for use
    /// with AVAssetWriter and other video processing APIs.
    enum FileType: String, Sendable {
        /// Apple's preferred video format with high quality and iOS optimization.
        ///
        /// MOV files are the default format for iOS video recording and provide
        /// excellent quality, efficient compression, and optimal performance
        /// on Apple devices. This format is recommended for most iOS applications.
        case mov

        /// Widely compatible video format supported across multiple platforms.
        ///
        /// MP4 files offer broad compatibility with web browsers, media players,
        /// and other platforms. This format is useful when sharing videos or
        /// when cross-platform compatibility is required.
        case mp4

        // MARK: - Properties

        /// The corresponding AVFoundation file type for use with video APIs.
        ///
        /// This computed property maps the enum cases to their corresponding
        /// AVFileType values used by AVFoundation for video writing and export
        /// operations. It provides seamless integration with Apple's video
        /// processing frameworks.
        fileprivate var avFileType: AVFileType {
            switch self {
            case .mov:
                AVFileType.mov

            case .mp4:
                AVFileType.mp4
            }
        }
    }

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

        /// The operation has been temporarily suspended and is waiting to resume.
        ///
        /// This state indicates that the operation has been paused and is not actively
        /// processing data, but maintains its current configuration and can resume
        /// processing when requested. The operation preserves its current state,
        /// including any buffered data, configuration settings, and progress information.
        case paused

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
                (.paused, .finishing),
                (.paused, .writing),
                (.writing, .failed),
                (.writing, .finishing),
                (.writing, .paused):

                true

            default:
                false
            }
        }
    }

    // MARK: - Initializer

    init() {
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

    deinit {
        NotificationCenter.default.removeObserver(self)
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
    /// - Throws: A `TruVideoError` if something fails.
    @MovieOutputProcessorActor
    func endProcessing() async throws(UtilityError) -> VideoClip {
        guard let error else {
            if let assetWriter, state.canTransition(to: .finishing) {
                state = .finishing

                await assetWriter.finishWriting()

                if assetWriter.status == .failed {
                    throw UtilityError(
                        kind: .MovieOutputProcessorErrorReason.endProcessingFailed,
                        underlyingError: assetWriter.error
                    )
                }

                let outputURL = assetWriter.outputURL

                destroyWriter()

                do {
                    let asset = AVAsset(url: outputURL)
                    let bitRate = videoInput?.outputSettings?[AVVideoAverageBitRateKey] as? Int
                    let clip = try await VideoClip(
                        bitRate: bitRate ?? VideoDeviceConfiguration.defaultVideoBitRate,
                        devicePosition: asset.isMirrored() ? .front : .back,
                        duration: asset.load(.duration).seconds,
                        size: FileManager.default.attributesOfItem(atPath: outputURL.path)[.size] as? Int64 ?? 0,
                        url: outputURL
                    )

                    startTimestamp = .invalid
                    totalDuration = .zero
                    state = .finished

                    return clip
                } catch {
                    throw UtilityError(
                        kind: .MovieOutputProcessorErrorReason.endProcessingFailed,
                        underlyingError: error
                    )
                }
            } else {
                throw UtilityError(
                    kind: .MovieOutputProcessorErrorReason.endProcessingFailed,
                    failureReason: "Cannot end processing: assetWriter is nil or state transition not allowed"
                )
            }
        }

        throw error
    }

    /// Pauses the movie output processing and finalizes the current video segment.
    ///
    /// This function safely pauses the video recording process by finishing the current
    /// writing session and creating a final video asset. It performs state validation,
    /// asset writer finalization, error checking, and asset management in a coordinated manner.
    @MovieOutputProcessorActor
    func pause() async throws(UtilityError) {
        if let assetWriter, state.canTransition(to: .paused) {
            state = .paused

            await assetWriter.finishWriting()

            if assetWriter.status == .failed {
                throw UtilityError(
                    kind: .MovieOutputProcessorErrorReason.cannotPauseProcessor,
                    underlyingError: assetWriter.error
                )
            }

            let asset = AVAsset(url: assetWriter.outputURL)

            destroyWriter()

            assets.append(asset)
        }
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

    // MARK: - Notification methods

    @objc
    func didReceiveDidEnterBackgroundNotification(_ notification: Notification) {
        endBackgroundTaskIfNeeded()
        backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTaskIfNeeded()
        }
    }

    @objc
    func didReceiveWillEnterForegroundNotification(_ notification: Notification) {
        endBackgroundTaskIfNeeded()
    }

    // MARK: - Private methods

    private func appendAudio(buffer: AudioSampleBuffer) {
        let buffers = skippedAudioBuffers + [buffer]
        var failedBuffers: [AudioSampleBuffer] = []

        skippedAudioBuffers = []

        if let audioInput, audioInput.isReadyForMoreMediaData {
            for buffer in buffers {
                if audioInput.append(buffer.sampleBuffer) {
                    let currentBufferTimestamp = buffer.duration + buffer.timestamp

                    lastAudioTimestamp = currentBufferTimestamp
                    mediaProcessingOptions.insert(.audio)

                    if !mediaProcessingOptions.contains(.video) {
                        totalDuration = currentBufferTimestamp - startTimestamp
                    }
                } else {
                    failedBuffers.append(buffer)
                }
            }
        }

        skippedAudioBuffers = failedBuffers
    }

    private func appendVideo(buffer: VideoSampleBuffer) {
        if /// The active video input.
        let videoInput,

            /// The prixel buffer adapter.
            let pixelBufferAdapter, videoInput.isReadyForMoreMediaData
        {

            /// Current buffer to process.
            if let bufferToProcess = buffer.imageBuffer,

                /// Whether the current timespamp is valid for processing.
                buffer.timestamp.isValid,

                /// Whether the buffer can be appened to the adapter.
                pixelBufferAdapter.append(bufferToProcess, withPresentationTime: buffer.timestamp)
            {

                lastVideoTimestamp = buffer.timestamp
                totalDuration = buffer.timestamp - startTimestamp

                mediaProcessingOptions.insert(.video)
            }
        }
    }

    private func configureAudioInput(with buffer: AudioSampleBuffer, configuration: AudioDeviceConfiguration) {
        if audioInput == nil {
            let audioInput = AVAssetWriterInput(
                mediaType: .audio,
                outputSettings: configuration.makeSettingsDictionary(),
                sourceFormatHint: buffer.formatDescription
            )

            audioInput.expectsMediaDataInRealTime = true

            self.audioInput = audioInput
        }
    }

    private func configureVideoInput(with buffer: VideoSampleBuffer, configuration: VideoDeviceConfiguration) {
        if videoInput == nil {
            let settings = configuration.makeSettingsDictionary(sampleBuffer: buffer.sampleBuffer)
            var pixelBufferAttibutes: [String: Any] = [
                String(kCVPixelBufferPixelFormatTypeKey): Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
            ]

            if let format = buffer.formatDescription {
                let dimensions = CMVideoFormatDescriptionGetDimensions(format)

                pixelBufferAttibutes[String(kCVPixelBufferHeightKey)] = dimensions.height
                pixelBufferAttibutes[String(kCVPixelBufferWidthKey)] = dimensions.width
            } else if /// The video height dimension.
            let height = settings?[String(kCVPixelBufferHeightKey)],

                /// The video width dimension.
                let width = settings?[String(kCVPixelBufferWidthKey)]
            {

                pixelBufferAttibutes[String(kCVPixelBufferHeightKey)] = height
                pixelBufferAttibutes[String(kCVPixelBufferWidthKey)] = width
            } else {
                error = UtilityError(
                    kind: .MovieOutputProcessorErrorReason.videoOutputConfigurationFailed,
                    failureReason: "Missing format description or dimensions from sample buffer"
                )
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

    private func destroyWriter() {
        assetWriter = nil
        audioInput = nil
        videoInput = nil
    }

    private func endBackgroundTaskIfNeeded() {
        if backgroundTaskIdentifier != UIBackgroundTaskIdentifier.invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
            backgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
        }
    }

    private func nextOutputURL() -> URL {
        let filename = "\(identifier)-TV-clip.\(clipFilenameCount).\(fileType.rawValue)"
        defer { clipFilenameCount += 1 }

        return outputDirectory.appendingPathComponent(filename)
    }

    private func startSessionIfNecessary(at timestamp: CMTime) {
        if assetWriter == nil, hasConfiguredAudio, hasConfiguredVideo {
            do {
                assetWriter = try AVAssetWriter(url: nextOutputURL(), fileType: fileType.avFileType)
            } catch {
                self.state = .failed
                self.error = UtilityError(
                    kind: .MovieOutputProcessorErrorReason.cannotCreateWriter,
                    underlyingError: error
                )
            }

            if let assetWriter {
                assetWriter.metadata = metadata
                assetWriter.shouldOptimizeForNetworkUse = true

                if let audioInput, assetWriter.canAdd(audioInput) {
                    assetWriter.add(audioInput)
                } else {
                    state = .failed
                    error = UtilityError(
                        kind: .MovieOutputProcessorErrorReason.cannotAddAudioInput,
                        failureReason: "Writer encountered an error adding the audio input"
                    )
                }

                if let videoInput, assetWriter.canAdd(videoInput) {
                    assetWriter.add(videoInput)
                } else {
                    state = .failed
                    error = UtilityError(
                        kind: .MovieOutputProcessorErrorReason.cannotAddAudioInput,
                        failureReason: "Writer encountered an error adding the video input"
                    )
                }

                if error == nil {
                    assetWriter.startWriting()
                    assetWriter.startSession(atSourceTime: timestamp)

                    startTimestamp = timestamp
                }
            }
        }
    }
}

extension MovieOutputProcessor: DeviceOutputProcessor {

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
    func process(_ buffer: AudioSampleBuffer, with configuration: AudioDeviceConfiguration) {
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
    func process(_ buffer: VideoSampleBuffer, with configuration: VideoDeviceConfiguration) {
        if state == .writing {
            Task { @MovieOutputProcessorActor in
                configureVideoInput(with: buffer, configuration: configuration)
                startSessionIfNecessary(at: buffer.timestamp)
                appendVideo(buffer: buffer)
            }
        }
    }
}

extension FileManager {
    /// Retrieves the file size of an item at the specified path.
    ///
    /// This function attempts to get the file size of an item located at the given path
    /// by accessing the file system attributes. It returns the size in bytes as an Int64
    /// value, which is useful for calculating storage usage, estimating upload times,
    /// or managing file storage requirements.
    ///
    /// The function uses FileManager to access file attributes and specifically looks
    /// for the file size attribute. If the size attribute is not available or cannot
    /// be cast to Int64, it returns 0 as a fallback value.
    ///
    /// - Parameter path: The file system path to the item whose size should be retrieved.
    /// - Returns: The size of the item in bytes as an Int64 value, or 0 if the size cannot be determined.
    /// - Throws: An error if the file attributes cannot be accessed, including the underlying file system error.
    fileprivate func sizeOfItem(at path: String) throws -> Int64 {
        let attributes = try FileManager.default.attributesOfItem(atPath: path)

        return attributes[.size] as? Int64 ?? 0
    }
}
