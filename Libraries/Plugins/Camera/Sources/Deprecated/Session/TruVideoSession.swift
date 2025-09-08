//
//  CaptureMovieOutput.swift
//
//  Created by TruVideo on 6/14/22.
//  Copyright © 2023 TruVideo. All rights reserved.
//

import AVFoundation
import UIKit

extension Dictionary where Key == String {
    /// Returns true if the dictionary contains a valid settings
    /// for the video input
    fileprivate var hasValidVideoSettings: Bool {
        self[AVVideoCodecKey] != nil && self[AVVideoHeightKey] != nil && self[AVVideoWidthKey] != nil
    }
}

extension AVCaptureVideoOrientation {
    /// Returns the natural size for the current video orientation.
    fileprivate var naturalSize: CGSize {
        switch self {
        case .landscapeLeft, .landscapeRight:
            return .init(width: UIScreen.main.bounds.height, height: UIScreen.main.bounds.width)

        default: return UIScreen.main.bounds.size
        }
    }
}

extension AVMutableComposition {
    /// Creates a `AVMutableComposition` from the given clips.
    ///
    /// - Parameter clips: The recorded clips during the session.
    /// - Returns: A new instance of `AVMutableComposition`.
    fileprivate static func from(_ clips: [TruVideoClip]) -> AVMutableComposition {
        var audioTrack: AVMutableCompositionTrack?
        let mutableComposition = AVMutableComposition()
        var currentTime = mutableComposition.duration
        var videoTrack: AVMutableCompositionTrack?

        for clip in clips {
            let asset = clip.asset

            let audioAssetTracks = asset.tracks(withMediaType: .audio)
            var maxRange = CMTime.invalid
            let videoAssetTracks = asset.tracks(withMediaType: .video)
            var videoTime = currentTime

            for videoAssetTrack in videoAssetTracks {
                videoTrack = mutableComposition.addMutableTrack(
                    withMediaType: .video,
                    preferredTransform: videoAssetTrack.preferredTransform,
                    trackID: videoAssetTrack.trackID
                )

                videoTime = videoTrack?.append(videoAssetTrack, startTime: videoTime, range: maxRange) ?? videoTime
                maxRange = videoTime
            }

            var audioTime = currentTime

            for audioAssetTrack in audioAssetTracks {
                if audioTrack == nil {
                    audioTrack = mutableComposition.addMutableTrack(
                        withMediaType: .audio,
                        preferredTrackID: audioAssetTrack.trackID
                    )
                }

                audioTime = audioTrack?.append(audioAssetTrack, startTime: audioTime, range: maxRange) ?? audioTime
            }

            currentTime = mutableComposition.duration
        }

        return mutableComposition
    }

    /// Adds an empty track to a mutable composition.
    ///
    /// - Parameters:
    ///    - mediaType: The media type of the new track.
    ///    - preferredTransform: The preferred transformation of the visual media data for display purposes.
    /// - Returns: A new instance of the `AVMutableCompositionTrack`
    fileprivate func addMutableTrack(
        withMediaType mediaType: AVMediaType,
        preferredTransform: CGAffineTransform = .identity,
        trackID: CMPersistentTrackID
    ) -> AVMutableCompositionTrack? {

        let tracks = tracks(withMediaType: mediaType)
        guard let track = tracks.first else {
            let track = addMutableTrack(withMediaType: mediaType, preferredTrackID: trackID)
            track?.preferredTransform = preferredTransform
            return track
        }

        return track
    }
}

extension AVMutableCompositionTrack {
    /// Appends a new track to the composition
    ///
    /// - Parameters:
    ///    - track: The `AVAssetTrack` to append into the composition
    ///    - startTime: The initial time where the asset is going to be added
    ///    - range: Time Range
    /// - Returns: The total time of the asset
    fileprivate func append(_ track: AVAssetTrack, startTime: CMTime, range: CMTime) -> CMTime {
        let timeRange = track.timeRange
        let startTime = startTime + timeRange.start

        if timeRange.duration > .zero {
            do {
                try insertTimeRange(timeRange, of: track, at: startTime)
            } catch {
                print("[TruVideoSession]: ⚠️ Could not add the track \(track)")
            }

            return startTime + timeRange.duration
        }

        return startTime
    }
}

extension AVMutableVideoComposition {
    /// Creates a `AVMutableVideoComposition` from the given clips.
    ///
    /// - Parameters:
    ///    - clips: The recorded clips during the session.
    ///    - preset: AVAssetExportSession preset name for export.
    /// - Returns: A new instance of `AVMutableVideoComposition`.
    fileprivate static func from(
        _ clips: [TruVideoClip],
        usingPreset preset: AVCaptureSession.Preset
    ) async throws -> AVMutableVideoComposition {
        var currentTime = CMTime.zero
        var layerInstructions: [AVVideoCompositionLayerInstruction] = []
        let mainInstruction = AVMutableVideoCompositionInstruction()
        let mutableVideoComposition = AVMutableVideoComposition()
        var targetSize = CGSize.zero

        mutableVideoComposition.frameDuration = .init(value: 1, timescale: 24)

        for (index, clip) in clips.enumerated() {
            let asset = clip.asset

            let videoAssetTracks = asset.tracks(withMediaType: .video)

            for videoAssetTrack in videoAssetTracks {
                let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoAssetTrack)

                if index == 0 {
                    instruction.setOpacity(0, at: CMTimeAdd(currentTime, asset.duration))
                }
                let videoSize = try await videoAssetTrack.load(.naturalSize)
                instruction.setTransform(.identity, at: .zero)
                layerInstructions.append(instruction)
                if videoSize.width > targetSize.width {
                    targetSize = videoSize
                }
            }

            currentTime = CMTimeAdd(currentTime, asset.duration)
        }
        mutableVideoComposition.renderSize = targetSize
        mainInstruction.timeRange = .init(start: .zero, duration: currentTime)
        mainInstruction.layerInstructions = layerInstructions
        mutableVideoComposition.instructions = [mainInstruction]

        return mutableVideoComposition
    }
}

extension FileManager {
    /// Removes the file at the destination `url`
    ///
    /// - Parameter url: The url where the file is located
    func removeFile(at url: URL) {
        guard fileExists(atPath: url.path) else { return }

        do {
            try removeItem(atPath: url.path)
        } catch {
            print("[TruVideoSession]: ⚠️ Could not remove file at path \(url)")
        }
    }
}

extension TruVideoRecorder {
    /// Returns the default metadata for an `AVAssetWriter`
    class var assetWriterMetadata: [AVMutableMetadataItem] {
        let modelItem = AVMutableMetadataItem()
        modelItem.keySpace = AVMetadataKeySpace.common
        modelItem.key = AVMetadataKey.commonKeyModel as (NSCopying & NSObjectProtocol)
        modelItem.value = UIDevice.current.localizedModel as (NSCopying & NSObjectProtocol)

        let softwareItem = AVMutableMetadataItem()
        softwareItem.keySpace = AVMetadataKeySpace.common
        softwareItem.key = AVMetadataKey.commonKeySoftware as (NSCopying & NSObjectProtocol)
        softwareItem.value = TruVideoMetadataTitle as (NSCopying & NSObjectProtocol)

        let artistItem = AVMutableMetadataItem()
        artistItem.keySpace = AVMetadataKeySpace.common
        artistItem.key = AVMetadataKey.commonKeyArtist as (NSCopying & NSObjectProtocol)
        artistItem.value = TruVideoMetadataArtist as (NSCopying & NSObjectProtocol)

        let creationDateItem = AVMutableMetadataItem()
        creationDateItem.keySpace = .common
        creationDateItem.key = AVMetadataKey.commonKeyCreationDate as NSString
        creationDateItem.value = Date() as NSDate

        return [modelItem, softwareItem, artistItem, creationDateItem]
    }
}

/// Represents all the errors that can be thrown
/// during a capture session
enum TruVideoSessionError: Error {
    /// canAddOutput threw an error in.
    /// when adding the audio input.
    case cannotAddAudioInput

    /// `canAddOutput` threw an error in
    /// when adding the video input.
    case cannotAddVideoInput

    /// `beginNewClip` threw an error in.
    case cannotBeginANewClip
}

/// Implements the complete file recording interface declared for writing media data to QuickTime/MP4 movie files.
class TruVideoSession {
    /// Instance of AVAssetWriter configured to write to a file in a specified container format.
    private var assetWriter: AVAssetWriter?

    /// Configuration to use when recording audio frames
    private var audioConfiguration: TruAudioConfiguration?

    /// Defines an interface for appending either new media samples for the audio recording
    private var audioInput: AVAssetWriterInput?

    /// Queue for the audio session operation
    private let audioQueue: DispatchQueue

    /// The identifier for the current background task.
    private var backgroundTaskIdentifier: UIBackgroundTaskIdentifier = .invalid

    /// The number of clips recorded
    private var clipFilenameCount = 0

    /// Timestamp of the last audio frame received
    private var lastAudioTimestamp: CMTime = .invalid

    /// Timestamp of the last video frame received
    private var lastVideoTimestamp: CMTime = .invalid

    /// The current interface for appending video samples packaged as CVPixelBuffer objects to a single AVAssetWriterInput object
    private var pixelBufferAdapter: AVAssetWriterInputPixelBufferAdaptor?

    /// Queue for a session operations
    private let queue: DispatchQueue

    /// Keeps track of the skipped the audio buffers
    private var skippedAudioBuffers: [CMSampleBuffer] = []

    /// Starting time stamp when a new clip is being recorded
    private var startTimestamp: CMTime = .invalid

    /// Time offset between the clip and the paused frames
    private var timeOffset: CMTime = .zero

    /// Configuration to use when recording video frames
    private var videoConfiguration: TruVideoConfiguration?

    /// Defines an interface for appending either new media samples for the video recording
    private var videoInput: AVAssetWriterInput?

    /// The list of the recorded clips
    private(set) var clips: [TruVideoClip] = []

    /// Whether the clip is being recorded with audio
    private(set) var currentClipHasAudio = false

    /// Whether the clip is being recorded with video
    private(set) var currentClipHasVideo = false

    /// Output file type for a session, see AVMediaFormat.h for supported types.
    var fileType: AVFileType = .mp4

    /// Whether the session is recording a clip
    private(set) var hasStartedRecording = false

    /// Unique identifier for the session
    let identifier = UUID()

    /// `AVAsset` of the session.
    var asset: AVAsset? {
        if clips.count == 1 {
            return clips.first?.asset
        }

        return AVMutableComposition.from(clips)
    }

    /// Whether the session has configured the audio
    var hasConfiguredAudio: Bool {
        audioInput != nil
    }

    /// Whether the session has configured the video
    var hasConfiguredVideo: Bool {
        videoInput != nil
    }

    /// Checks if the session's asset writer is ready for data.
    var isReady: Bool {
        assetWriter != nil
    }

    /// Output directory for the session.
    var outputDirectory = URL(fileURLWithPath: NSTemporaryDirectory())

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

    /// Duration of a session, the sum of all recorded clips.
    @Published
    private(set) var totalDuration: CMTime = .invalid

    private let TruVideoSessionAudioQueueIdentifier = "org.TruVideo.session.audioQueue"
    private let TruVideoSessionQueueIdentifier = "org.TruVideo.sessionQueue"
    private let TruVideoSessionQueueSpecificKey = DispatchSpecificKey<()>()

    // MARK: Initializers

    /// Creates a new instance of the `TruVideoSession`
    ///
    /// - Parameters:
    ///    - queue: The worker queue for the `AVAssetWriter`
    init(queue: DispatchQueue? = nil) {
        self.audioQueue = DispatchQueue(label: TruVideoSessionAudioQueueIdentifier)
        self.queue = queue ?? DispatchQueue(label: TruVideoSessionQueueIdentifier)
        self.queue.setSpecific(key: TruVideoSessionQueueSpecificKey, value: ())

        configureObservers()
    }

    // MARK: Instance methods

    var currentVideoRecordingIsPaused = false
    private var currentVideoRecordingPauseStart: CMTime = .zero
    private var currentVideoRecordingPauseInterval: CMTime = .zero

    func handlePauseVideoRecording() {
        if currentVideoRecordingIsPaused {
            Logger.addLog(event: .resumeRecording, eventMessage: .resumeRecording)
            let pauseEnd = CMTime(seconds: Date().timeIntervalSince1970, preferredTimescale: 1000)
            currentVideoRecordingPauseInterval =
                currentVideoRecordingPauseInterval + (pauseEnd - currentVideoRecordingPauseStart)
        } else {
            Logger.addLog(event: .pauseRecording, eventMessage: .pauseRecording)
            currentVideoRecordingPauseStart = CMTime(seconds: Date().timeIntervalSince1970, preferredTimescale: 1000)
        }
        currentVideoRecordingIsPaused.toggle()
    }

    func getVideoFrameTimestamp() -> CMTime? {
        if currentVideoRecordingIsPaused {
            return nil
        }
        return CMTime(seconds: Date().timeIntervalSince1970, preferredTimescale: 1000)
            - currentVideoRecordingPauseInterval
    }

    /// Append video sample buffer frames to a session for recording.
    ///
    /// - Parameters:
    ///   - sampleBuffer: Sample buffer input to be appended, unless an image buffer is also provided
    ///   - minFrameDuration: Current active minimum frame duration
    /// - Returns: A boolean indicating whether the `sampleBuffer` was recorded
    @discardableResult
    func appendVideoBuffer(_ buffer: CVPixelBuffer) -> Bool {
        guard let timestamp = getVideoFrameTimestamp() else {
            return false
        }
        startSessionIfNecessary(at: .zero, startTimestamp: timestamp)

        guard assetWriter?.status == .writing else {
            return false
        }

        let offsetBufferTimestamp = timestamp - startTimestamp
        if let videoInput = videoInput,
            let pixelBufferAdapter = pixelBufferAdapter,
            videoInput.isReadyForMoreMediaData,
            pixelBufferAdapter.append(buffer, withPresentationTime: offsetBufferTimestamp)
        {
            currentClipHasVideo = true
            lastVideoTimestamp = timestamp
            totalDuration = timestamp - startTimestamp
            return true
        }

        return false
    }

    /// Append audio sample buffer frames to a session for recording.
    ///
    /// - Parameters:
    ///   - sampleBuffer: Sample buffer input to be appended, unless an image buffer is also provided
    /// - Returns: A boolean indicating whether the `sampleBuffer` was recorded
    @discardableResult
    func appendAudioBuffer(_ sampleBuffer: CMSampleBuffer) -> Bool {
        if currentVideoRecordingIsPaused {
            return false
        }

        let buffers = skippedAudioBuffers + [sampleBuffer]
        var failedBuffers: [CMSampleBuffer] = []
        var hasFailed = false

        skippedAudioBuffers = []

        for buffer in buffers {
            let duration = CMSampleBufferGetDuration(sampleBuffer)
            let presentationTimestamp = CMSampleBufferGetPresentationTimeStamp(buffer)
            startSessionIfNecessary(at: .zero, startTimestamp: presentationTimestamp)
            if let adjustedBuffer = buffer.offset(by: presentationTimestamp, duration: duration) {
                let lastTimestamp = CMTimeAdd(presentationTimestamp, duration)

                if let audioInput = audioInput,
                    audioInput.isReadyForMoreMediaData, audioInput.append(adjustedBuffer)
                {

                    lastVideoTimestamp = lastTimestamp
                    currentClipHasAudio = true

                    if !currentClipHasVideo {
                        totalDuration = lastTimestamp - startTimestamp - currentVideoRecordingPauseInterval
                    }
                } else {
                    hasFailed = true
                    failedBuffers.append(buffer)
                }
            }
        }

        skippedAudioBuffers = failedBuffers
        return !hasFailed
    }

    /// Starts a new clip
    ///
    /// - Throws: An error if the clip cannot be created.
    func beginNewClip() throws {
        guard self.assetWriter == nil else {
            print("[TruVideoSession]: ⚠️ Clip has already been created.")
            return
        }

        do {
            assetWriter = try AVAssetWriter(url: generateNextOutputURL(), fileType: fileType)

            if let assetWriter = assetWriter {
                assetWriter.metadata = TruVideoRecorder.assetWriterMetadata
                assetWriter.shouldOptimizeForNetworkUse = true

                if let audioInput = audioInput {
                    if assetWriter.canAdd(audioInput) {
                        assetWriter.add(audioInput)
                    } else {
                        print("[TruVideoSession]: 🛑 writer encountered an adding the audio input")
                        throw TruVideoSessionError.cannotAddAudioInput
                    }
                }

                if let videoInput = videoInput {
                    if assetWriter.canAdd(videoInput) {
                        assetWriter.add(videoInput)
                    } else {
                        print("[TruVideoSession]: 🛑 writer encountered an adding the video input")
                        throw TruVideoSessionError.cannotAddVideoInput
                    }
                }

                if assetWriter.startWriting() {
                    hasStartedRecording = true
                    startTimestamp = .invalid
                    timeOffset = .zero
                    currentVideoRecordingPauseStart = .zero
                    currentVideoRecordingPauseInterval = .zero
                    currentVideoRecordingIsPaused = false
                } else {
                    print("[TruVideoSession]: 🛑 writer encountered an error \(String(describing: assetWriter.error))")
                    self.assetWriter = nil
                    throw TruVideoSessionError.cannotBeginANewClip
                }
            }
        } catch {
            throw TruVideoSessionError.cannotBeginANewClip
        }
    }

    /// Prepares a session for recording audio.
    ///
    /// - Parameters:
    ///   - settings: AVFoundation audio settings dictionary
    ///   - configuration: Audio configuration for audio output
    ///   - formatDescription: sample buffer format description
    /// - Returns: True when setup completes successfully
    @discardableResult
    func configureAudio(
        with settings: [String: Any]?,
        configuration: TruAudioConfiguration,
        formatDescription: CMFormatDescription
    ) -> Bool {

        audioInput = AVAssetWriterInput(
            mediaType: .audio,
            outputSettings: settings,
            sourceFormatHint: formatDescription
        )

        if let audioInput = audioInput {
            audioInput.expectsMediaDataInRealTime = true
            audioConfiguration = configuration
        }

        return hasConfiguredAudio
    }

    /// Prepares a session for recording video.
    ///
    /// - Parameters:
    ///   - settings: AVFoundation video settings dictionary
    ///   - configuration: Video configuration for video output
    ///   - formatDescription: sample buffer format description
    /// - Returns: True when setup completes successfully
    @discardableResult
    func configureVideo(
        with settings: [String: Any]?,
        configuration: TruVideoConfiguration,
        formatDescription: CMFormatDescription? = nil
    ) -> Bool {

        if let formatDescription = formatDescription {
            videoInput = AVAssetWriterInput(
                mediaType: .video,
                outputSettings: settings,
                sourceFormatHint: formatDescription
            )
        } else if let settings = settings, settings.hasValidVideoSettings == true {
            videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
        } else {
            print("[TruVideoSession]: 🛑 failed to configure video output")
            videoInput = nil
            return false
        }

        if let videoInput = videoInput {
            videoInput.expectsMediaDataInRealTime = true
            videoInput.transform = configuration.transform
            videoConfiguration = configuration

            var pixelBufferAttibutes: [String: Any] = [
                String(kCVPixelBufferPixelFormatTypeKey): Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
            ]

            if let formatDescription = formatDescription {
                let videoDimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)
                pixelBufferAttibutes[String(kCVPixelBufferHeightKey)] =
                    configuration.swapDimensions ? videoDimensions.width : videoDimensions.height
                pixelBufferAttibutes[String(kCVPixelBufferWidthKey)] =
                    configuration.swapDimensions ? videoDimensions.height : videoDimensions.width
            } else if /// Video height
            let height = settings?[String(kCVPixelBufferHeightKey)],

                /// Video width
                let width = settings?[String(kCVPixelBufferWidthKey)]
            {

                pixelBufferAttibutes[String(kCVPixelBufferHeightKey)] = configuration.swapDimensions ? width : height
                pixelBufferAttibutes[String(kCVPixelBufferWidthKey)] = configuration.swapDimensions ? height : width
            }

            pixelBufferAdapter = AVAssetWriterInputPixelBufferAdaptor(
                assetWriterInput: videoInput,
                sourcePixelBufferAttributes: pixelBufferAttibutes
            )
        }

        return hasConfiguredVideo
    }

    /// Starts a new clip
    ///
    /// - Throws: An error if the clip cannot be created.
    @discardableResult
    func finishClip() async throws -> TruVideoClip? {
        hasStartedRecording = false

        return try await withUnsafeThrowingContinuation { continuation in
            if let assetWriter = self.assetWriter {
                if !self.currentClipHasAudio && !self.currentClipHasVideo {
                    assetWriter.cancelWriting()

                    FileManager.default.removeFile(at: assetWriter.outputURL)
                    self.destroyAssetWriter()
                    continuation.resume(returning: nil)
                } else {
                    assetWriter.finishWriting {
                        defer {
                            self.destroyAssetWriter()
                            self.destroyAssetWriter()
                            self.endBackgroundTaskIfNeeded()
                        }

                        guard let error = assetWriter.error else {
                            let clip = TruVideoClip(url: assetWriter.outputURL)

                            self.clips.append(clip)
                            continuation.resume(returning: clip)

                            return
                        }

                        continuation.resume(throwing: error)
                    }
                }
            } else {
                endBackgroundTaskIfNeeded()
                continuation.resume(returning: nil)
            }
        }
    }

    /// Merges all existing recorded clips in the session and exports to a file.
    ///
    /// - Parameter preset: AVAssetExportSession preset name for export.
    /// - Returns: The url of the exported file.
    func mergeClips(usingPreset preset: AVCaptureSession.Preset) async throws -> URL {
        let outputURL = generateNextOutputURL()
        guard
            !clips.isEmpty,
            let exportAsset = asset,
            let exportSession = AVAssetExportSession(asset: exportAsset, presetName: preset.exportPreset)
        else {
            self.endBackgroundTaskIfNeeded()
            throw TruVideoError(kind: .unknown)
        }

        if clips.count == 1 {
            print("[TruVideoSession]: ⚠️ a merge was requested for a single clip, use lastClipUrl instead")
        }

        FileManager.default.removeFile(at: outputURL)

        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.outputURL = outputURL
        exportSession.outputFileType = fileType
        exportSession.videoComposition = try await AVMutableVideoComposition.from(clips, usingPreset: preset)

        await exportSession.export()

        return outputURL
    }

    /// Finalizes the recording of a clip.
    func reset() {
        executeSync { [weak self] in
            guard let self else { return }
            self.audioConfiguration = nil
            self.audioInput = nil
            self.pixelBufferAdapter = nil
            self.skippedAudioBuffers = []
            self.videoInput = nil
            self.videoConfiguration = nil
        }
    }

    // MARK: Notification methods

    @objc
    private func didReceiveDidEnterBackgroundNotification(_ notification: Notification) {
        endBackgroundTaskIfNeeded()
        backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask()
    }

    @objc
    private func didReceiveWillEnterForegroundNotification(_ notification: Notification) {
        endBackgroundTaskIfNeeded()
    }

    // MARK: Private methods

    private func configureObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveDidEnterBackgroundNotification),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveWillEnterForegroundNotification),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    private func destroyAssetWriter() {
        assetWriter = nil
        currentClipHasAudio = false
        currentClipHasVideo = false
        hasStartedRecording = false
        startTimestamp = .invalid
        timeOffset = .zero
        totalDuration = .zero
        currentVideoRecordingPauseStart = .zero
        currentVideoRecordingPauseInterval = .zero
        currentVideoRecordingIsPaused = false
    }

    private func endBackgroundTaskIfNeeded() {
        guard backgroundTaskIdentifier != .invalid else { return }

        UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
        backgroundTaskIdentifier = .invalid
    }

    private func executeSync(_ closure: @escaping () -> Void) {
        if DispatchQueue.getSpecific(key: TruVideoSessionQueueSpecificKey) != nil {
            closure()
        } else {
            queue.sync(execute: closure)
        }
    }

    private func generateNextOutputURL() -> URL {
        let filename = "\(identifier.uuidString)-TV-clip.\(clipFilenameCount).mp4"
        let nextOutputURL = outputDirectory.appendingPathComponent(filename)

        clipFilenameCount += 1
        FileManager.default.removeFile(at: nextOutputURL)
        return nextOutputURL
    }

    private func startSessionIfNecessary(at sessionStart: CMTime, startTimestamp: CMTime) {
        guard !self.startTimestamp.isValid && sessionStart.isValid else { return }

        self.startTimestamp = startTimestamp
        assetWriter?.startSession(atSourceTime: sessionStart)
    }

    func deleteClips() {
        for clip in clips {
            do {
                try FileManager.default.removeItem(at: clip.url)
            } catch {
                print("[TruVideoSession]: 🛑 failed to delete clip at: \(clip.url)")
            }
        }
    }
}
