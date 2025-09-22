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

/// A delegate protocol for handling movie output processing events and completion notifications.
///
/// The `MovieOutputProcessorDelegate` protocol defines the interface for receiving notifications
/// about movie processing operations, particularly when the maximum recording duration has been
/// reached. This protocol enables the delegate to respond to processing events and handle the
/// results appropriately, whether successful or failed.
///
/// The protocol is designed to work with the `MovieOutputProcessor` class, which handles
/// the recording of video and audio streams. When the processor reaches the configured
/// maximum duration limit, it automatically stops recording and notifies the delegate
/// with the completed video clip or any errors that occurred during processing.
///
/// ## Usage Example
///
/// ```swift
/// class CameraViewController: MovieOutputProcessorDelegate {
///     func movieOutputProcessor(_ output: MovieOutputProcessor, didReachMaxDuration result: Result<VideoClip, Error>) {
///         switch result {
///         case .success(let videoClip):
///             // Handle successful video clip creation
///             print("Video clip created: \(videoClip.url)")
///
///         case .failure(let error):
///             // Handle processing error
///             print("Error creating video clip: \(error.localizedDescription)")
///         }
///     }
/// }
/// ```
protocol MovieOutputProcessorDelegate: AnyObject {
    /// Notifies the delegate when the movie output processor reaches the maximum recording duration.
    ///
    /// This method is called when the `MovieOutputProcessor` has reached its configured
    /// maximum recording duration and has completed processing the current video segment.
    /// The processor automatically stops recording and finalizes the video clip before
    /// calling this delegate method.
    ///
    /// The result parameter contains either a successfully created `VideoClip` object
    /// with metadata about the recorded video, or an `Error` if the processing failed.
    /// The delegate should handle both cases appropriately, such as updating the UI
    /// or managing the application's state.
    ///
    /// - Parameters:
    ///   - output: The movie output processor that reached the maximum duration
    ///   - result: A result containing either a `VideoClip` on success or an `Error` on failure
    func movieOutputProcessor(_ output: MovieOutputProcessor, didReachMaxDuration result: Result<VideoClip, Error>)
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
    private var assetsURLs: [URL] = []
    private var assetWriter: AVAssetWriter?
    private var audioInput: AVAssetWriterInput?
    private var backgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    private var clipFilenameCount = 1
    private var currentClipDuration = CMTime.zero
    private var firstVideoSampleBuffer: VideoSampleBuffer?
    private let mediaComposer: MediaComposer
    private var pixelBufferAdapter: AVAssetWriterInputPixelBufferAdaptor?
    private var skippedAudioBuffers: [AudioSampleBuffer] = []
    private var startTimestamp = CMTime.invalid
    private var videoConfiguration = VideoDeviceConfiguration()
    private var videoInput: AVAssetWriterInput?

    // MARK: - Properties

    /// The delegate object that receives movie output processing events and notifications.
    ///
    /// This property holds a weak reference to an object that conforms to the
    /// `MovieOutputProcessorDelegate` protocol. The delegate is notified when
    /// important events occur during movie processing, particularly when the
    /// maximum recording duration is reached and processing completes.
    weak var delegate: MovieOutputProcessorDelegate?

    /// The underliying error.
    private(set) var error: UtilityError?

    /// Output file type for the session.
    var fileType = FileType.mp4

    /// The maximum duration in seconds for each video recording.
    var maxRecordingDuration: TimeInterval = 5 * 24 * 60 * 60

    /// Output directory for the session.
    var outputDirectory = URL(fileURLWithPath: NSTemporaryDirectory())

    /// The current state of the processing operation, indicating its lifecycle phase.
    private(set) var state = State.initialized

    // MARK: - Published Properties

    /// The total recording duration of processed media, published for UI updates.
    ///
    /// This published property tracks the cumulative duration of all processed
    /// audio and video samples since the start of the current processing session.
    /// It automatically updates as new media samples are processed, providing
    /// real-time feedback on the current recording or processing progress.
    @Published private(set) var recordingDuration = CMTime.invalid

    // MARK: - Private Computed Properties

    /// Whether the session has configured the audio
    private var hasConfiguredAudio: Bool {
        audioInput != nil
    }

    /// Whether the session has configured the video
    private var hasConfiguredVideo: Bool {
        videoInput != nil
    }

    /// The maximum duration in `CMTime` for each video recording.
    private var maxDuration: CMTime {
        CMTime(seconds: maxRecordingDuration, preferredTimescale: 600)
    }

    /// Returns the default metadata for an `AVAssetWriter`
    private var metadata: [AVMutableMetadataItem] {
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

    /// Creates a new instance with a media composer and sets up background/foreground notifications.
    ///
    /// This initializer configures the instance with a media composer for handling
    /// media processing operations and registers for application lifecycle notifications
    /// to manage background and foreground state changes. The notifications are used
    /// to pause, resume, or clean up operations when the app transitions between
    /// background and foreground states.
    ///
    /// - Parameter composer: The media composer to use for processing operations (defaults to FFMPEGVideoComposer)
    init(mediaComposer: MediaComposer = FFMPEGVideoComposer()) {
        self.mediaComposer = mediaComposer

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
            if state.canTransition(to: .finishing) {
                state = .finishing

                if let assetWriter {
                    await assetWriter.finishWriting()

                    if assetWriter.status == .failed {
                        state = .failed
                        throw UtilityError(
                            kind: .MovieOutputProcessorErrorReason.endProcessingFailed,
                            underlyingError: assetWriter.error
                        )
                    }

                    assetsURLs.append(assetWriter.outputURL)
                    destroySession()
                }

                do {
                    let clip = try await exportClip()

                    assetsURLs.removeAll()
                    currentClipDuration = .zero
                    firstVideoSampleBuffer = nil
                    recordingDuration = .zero
                    state = .finished

                    return clip
                } catch {
                    state = .failed
                    throw UtilityError(
                        kind: .MovieOutputProcessorErrorReason.endProcessingFailed,
                        underlyingError: error
                    )
                }
            } else {
                throw UtilityError(
                    kind: .MovieOutputProcessorErrorReason.endProcessingFailed,
                    failureReason: "Cannot end processing: state transition not allowed"
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
        if state.canTransition(to: .paused) {
            state = .paused

            if let assetWriter, assetWriter.status == .writing {
                await assetWriter.finishWriting()

                if assetWriter.status == .failed {
                    throw UtilityError(
                        kind: .MovieOutputProcessorErrorReason.pauseFailed,
                        underlyingError: assetWriter.error
                    )
                }

                currentClipDuration = CMTimeAdd(currentClipDuration, recordingDuration - currentClipDuration)

                destroySession()

                assetsURLs.append(assetWriter.outputURL)
            }
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
            recordingDuration = currentClipDuration
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
        guard let assetWriter, assetWriter.status == .writing, buffer.timestamp.isValid else {
            return
        }

        let buffers = skippedAudioBuffers + [buffer]
        var failedBuffers: [AudioSampleBuffer] = []

        skippedAudioBuffers = []

        for buffer in buffers {
            if /// The current audio input.
            let audioInput,

                /// The adjusted audio buffer.
                let adjustedBuffer = buffer.sampleBuffer.offset(by: buffer.timestamp, duration: buffer.duration),

                /// A value that indicates whether the input is ready to accept media data.
                audioInput.isReadyForMoreMediaData
            {

                if !audioInput.append(adjustedBuffer) {
                    failedBuffers.append(buffer)
                }
            } else {
                failedBuffers.append(buffer)
            }
        }

        skippedAudioBuffers = failedBuffers
    }

    private func appendVideo(buffer: VideoSampleBuffer) {
        guard let assetWriter, assetWriter.status == .writing, buffer.timestamp.isValid else {
            return
        }

        let currentDuration = CMTimeAdd(currentClipDuration, buffer.timestamp - startTimestamp)

        recordingDuration = min(currentDuration, maxDuration)

        guard recordingDuration < maxDuration else {
            Task {
                do {
                    let clip = try await endProcessing()

                    delegate?.movieOutputProcessor(self, didReachMaxDuration: .success(clip))
                } catch {
                    delegate?.movieOutputProcessor(self, didReachMaxDuration: .failure(error))
                }
            }

            return
        }

        if /// The active video input.
        let videoInput,

            /// The prixel buffer adapter.
            let pixelBufferAdapter,

            /// Current buffer to process.
            let bufferToProcess = buffer.imageBuffer, videoInput.isReadyForMoreMediaData
        {

            pixelBufferAdapter.append(bufferToProcess, withPresentationTime: buffer.timestamp - startTimestamp)

            if firstVideoSampleBuffer == nil {
                firstVideoSampleBuffer = buffer
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
            videoConfiguration = configuration

            if let videoInput {
                videoInput.expectsMediaDataInRealTime = true
                videoInput.transform = buffer.preferredTransform

                videoConfiguration = configuration
                pixelBufferAdapter = AVAssetWriterInputPixelBufferAdaptor(
                    assetWriterInput: videoInput,
                    sourcePixelBufferAttributes: pixelBufferAttibutes
                )
            }
        }
    }

    private func destroySession() {
        startTimestamp = CMTime.zero

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

    private func exportAsset() async throws -> AVURLAsset {
        guard !assetsURLs.isEmpty else {
            throw UtilityError(
                kind: .MovieOutputProcessorErrorReason.cannotExportAsset,
                failureReason: "Cannot export asset: No asset URLs provided."
            )
        }

        if assetsURLs.count == 1 {
            return AVURLAsset(url: assetsURLs[0])
        }

        let outputURL = nextOutputURL()

        try await mediaComposer.compose(assetsURLs, into: outputURL)

        return AVURLAsset(url: outputURL)
    }

    private func exportClip() async throws -> VideoClip {
        guard let firstVideoSampleBuffer else {
            throw UtilityError(kind: .unknown, failureReason: "Unable to create thumbnail of the video.")
        }

        let asset = try await exportAsset()
        let thumbnail = try asset.snapshot(at: CMTime(seconds: 1, preferredTimescale: 1), actualTime: nil)
        let thumbnailURL = asset.url
            .deletingPathExtension()
            .appendingPathExtension("_thumb.\(videoConfiguration.imageFormat.rawValue)")

        guard let data = thumbnail?.data(with: videoConfiguration.imageFormat) else {
            throw UtilityError(kind: .unknown, failureReason: "Unable to create thumbnail of the video.")
        }

        try data.write(to: thumbnailURL, options: .atomic)

        return try await VideoClip(
            bitRate: firstVideoSampleBuffer.bitRate,
            duration: asset.load(.duration).seconds,
            lensPosition: firstVideoSampleBuffer.isMirrored ? .front : .back,
            orientation: UIDeviceOrientation(from: firstVideoSampleBuffer.orientation),
            size: FileManager.default.sizeOfItem(at: asset.url.path),
            thumbnailURL: thumbnailURL,
            url: asset.url
        )
    }

    private func nextOutputURL() -> URL {
        let filename = "\(identifier)-TV-clip.\(clipFilenameCount).\(fileType.rawValue)"
        clipFilenameCount += 1

        return outputDirectory.appendingPathComponent(filename)
    }

    private func startSessionIfNecessary(at timestamp: CMTime) {
        if assetWriter == nil, hasConfiguredAudio, hasConfiguredVideo, timestamp.isValid {
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
                    assetWriter.startSession(atSourceTime: .zero)

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
        Task { @MovieOutputProcessorActor in
            if state == .writing {
                configureAudioInput(with: buffer, configuration: configuration)
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
        Task { @MovieOutputProcessorActor in
            if state == .writing {
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
