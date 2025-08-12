//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit
/*
actor SessionWriter {
    // MARK: - Private Properties

    private var assetWriter: AVAssetWriter?
    private var audioWriterInput: AVAssetWriterInput?
    private var clipFilenameCount = 0
    private var hasStartedRecording = false
    private var pixelBufferAdapter: AVAssetWriterInputPixelBufferAdaptor?
    private var skippedAudioBuffers: [CMSampleBuffer] = []
    private var startTimestamp = CMTime.invalid
    private let taskManaging: TaskManaging
    private var timeOffset = CMTime.zero
    private var videoWriterInput: AVAssetWriterInput?

    // MARK: - Properties

    /// The list of the recorded clips
    private(set) var clips: [TruVideoClip] = []

    /// Whether the clip is being recorded with audio
    private(set) var currentClipHasAudio = false

    /// Whether the clip is being recorded with video
    private(set) var currentClipHasVideo = false

    /// Output file type for a session, see AVMediaFormat.h for supported types.
    var fileType: AVFileType = .mp4

    // MARK: - Published Properties

    /// Duration of a session, the sum of all recorded clips.
    @Published private(set) var totalDuration = CMTime.invalid

    // MARK: - Computed Properties

    /// `AVAsset` of the session.
    var asset: AVAsset? {
        if clips.count == 1 {
            return clips.first?.asset
        }

        return AVMutableComposition.from(clips)
    }

    /// Whether the session has configured the audio
    var hasConfiguredAudio: Bool {
        audioWriterInput != nil
    }

    /// Whether the session has configured the video
    var hasConfiguredVideo: Bool {
        videoWriterInput != nil
    }

    // MARK: - Initializer

    init(taskManaging: TaskManaging = BackgroundTaskManaging()) {
        self.taskManaging = taskManaging

        configureObservers()
    }

    // MARK: - Instance methods

    /// Append audio sample buffer frames to a session for recording.
    ///
    /// - Parameters:
    ///   - sampleBuffer: Sample buffer input to be appended, unless an image buffer is also provided
    /// - Returns: A boolean indicating whether the `sampleBuffer` was recorded
    @discardableResult
    func appendAudioBuffer(_ sampleBuffer: CMSampleBuffer) -> Bool {
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

                if
                    /// The audio writer input.
                    let audioWriterInput,

                    /// Indicates the readiness of the input to accept more media data.
                    audioWriterInput.isReadyForMoreMediaData,

                    /// Appends samples to the receiver.
                    audioWriterInput.append(adjustedBuffer) {

                    currentClipHasAudio = true

                    if !currentClipHasVideo {
                        totalDuration = lastTimestamp - startTimestamp
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

    /// Append video sample buffer frames to a session for recording.
    ///
    /// - Parameters:
    ///   - sampleBuffer: Sample buffer input to be appended, unless an image buffer is also provided
    ///   - minFrameDuration: Current active minimum frame duration
    /// - Returns: A boolean indicating whether the `sampleBuffer` was recorded
    @discardableResult
    func appendVideoBuffer(
        _ buffer: CVPixelBuffer,
        timestamp: TimeInterval,
        timescale: Float64?,
        minFrameDuration: CMTime
    ) -> Bool {

        let timestamp = CMTime(seconds: timestamp, preferredTimescale: minFrameDuration.timescale)

        startSessionIfNecessary(at: .zero, startTimestamp: timestamp)

        guard assetWriter?.status == .writing else {
            return false
        }

        var frameDuration = minFrameDuration
        let offsetBufferTimestamp = timestamp - timeOffset

        if let timescale, timescale != 1 {
            let scaledDuration = CMTimeMultiplyByFloat64(minFrameDuration, multiplier: timescale)

            if scaledDuration.value > 0 {
                timeOffset = CMTimeAdd(timeOffset, minFrameDuration - scaledDuration)
            }

            frameDuration = scaledDuration
        }

        if
            /// The video writer input.
            let videoWriterInput,

            /// The pixel buffer adapter.
            let pixelBufferAdapter,

            /// Indicates the readiness of the input to accept more media data.
            videoWriterInput.isReadyForMoreMediaData,

            /// Appends a pixel buffer to the receiver.
            pixelBufferAdapter.append(buffer, withPresentationTime: offsetBufferTimestamp) {

            currentClipHasVideo = true
            totalDuration = CMTimeAdd(offsetBufferTimestamp, frameDuration) - startTimestamp
            return true
        }

        return false
    }

    func beginNewClip() throws {
        guard assetWriter == nil else {
            print("[TruVideoSession]: ⚠️ Clip has already been created.")
            return
        }

        do {
            assetWriter = try AVAssetWriter(url: generateNextOutputURL(), fileType: fileType)

            if let assetWriter = assetWriter {
                assetWriter.metadata = await makeAssetMetadata()
                assetWriter.shouldOptimizeForNetworkUse = true

                if let audioWriterInput {
                    if assetWriter.canAdd(audioWriterInput) {
                        assetWriter.add(audioWriterInput)
                    } else {
                        print("[TruVideoSession]: 🛑 writer encountered an adding the audio input")
                        throw TruVideoSessionError.cannotAddAudioInput
                    }
                }

                if let videoWriterInput, assetWriter.canAdd(videoWriterInput) {
                    if assetWriter.canAdd(videoWriterInput) {
                        assetWriter.add(videoWriterInput)
                    } else {
                        print("[TruVideoSession]: 🛑 writer encountered an adding the video input")
                        throw TruVideoSessionError.cannotAddVideoInput
                    }
                }

                if assetWriter.startWriting() {
                    hasStartedRecording = true
                    startTimestamp = .invalid
                    timeOffset = .zero
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
    ///   - formatDescription: sample buffer format description
    /// - Returns: True when setup completes successfully
    @discardableResult
    func configureAudio(with settings: [String: Any]?, formatDescription: CMFormatDescription) -> Bool {
        audioWriterInput = AVAssetWriterInput(
            mediaType: .audio,
            outputSettings: settings,
            sourceFormatHint: formatDescription
        )

        audioWriterInput?.expectsMediaDataInRealTime = true

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
        configuration: VideoConfiguration,
        formatDescription: CMFormatDescription? = nil
    ) -> Bool {

        if let formatDescription = formatDescription {
            videoWriterInput = AVAssetWriterInput(
                mediaType: .video,
                outputSettings: settings,
                sourceFormatHint: formatDescription
            )
        } else if let settings = settings, settings.hasValidVideoSettings == true {
            videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
        } else {
            print("[TruVideoSession]: 🛑 failed to configure video output")
            videoWriterInput = nil
            return false
        }

        if let videoWriterInput {
            videoWriterInput.expectsMediaDataInRealTime = true
            videoWriterInput.transform = configuration.transform

            var pixelBufferAttibutes: [String: Any] = [
                String(kCVPixelBufferPixelFormatTypeKey): Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
            ]

            if let formatDescription = formatDescription {
                let videoDimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)

                pixelBufferAttibutes[String(kCVPixelBufferHeightKey)] = videoDimensions.height
                pixelBufferAttibutes[String(kCVPixelBufferWidthKey)] = videoDimensions.width
            } else if
                /// Video height
                let height = settings?[String(kCVPixelBufferHeightKey)],

                /// Video width
                let width = settings?[String(kCVPixelBufferWidthKey)] {

                pixelBufferAttibutes[String(kCVPixelBufferHeightKey)] = height
                pixelBufferAttibutes[String(kCVPixelBufferWidthKey)] = width
            }

            pixelBufferAdapter = AVAssetWriterInputPixelBufferAdaptor(
                assetWriterInput: videoWriterInput,
                sourcePixelBufferAttributes: pixelBufferAttibutes
            )
        }

        return hasConfiguredVideo
    }

    // MARK: - Notification methods

    @objc
    nonisolated private func didReceiveDidEnterBackgroundNotification(_ notification: Notification) async {
        await taskManaging.beginBackgroundTask()
    }

    @objc
    nonisolated private func didReceiveWillEnterForegroundNotification(_ notification: Notification) async {
        await taskManaging.endBackgroundTask()
    }

    // MARK: - Private methods

    nonisolated private func configureObservers() {
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

    private func destroyAssetWriter() {
        assetWriter = nil
        currentClipHasAudio = false
        currentClipHasVideo = false
        hasStartedRecording = false
        startTimestamp = .invalid
        timeOffset = .zero
        totalDuration = .zero
    }

    private func makeAssetMetadata() async -> [AVMutableMetadataItem] {
        let modelItem = AVMutableMetadataItem()
        modelItem.keySpace = AVMetadataKeySpace.common
        modelItem.key = AVMetadataKey.commonKeyModel as (NSCopying & NSObjectProtocol)
        modelItem.value = await UIDevice.current.localizedModel as (NSCopying & NSObjectProtocol)

        let softwareItem = AVMutableMetadataItem()
        softwareItem.keySpace = AVMetadataKeySpace.common
        softwareItem.key = AVMetadataKey.commonKeySoftware as (NSCopying & NSObjectProtocol)
        softwareItem.value = "TruVideo" as (NSCopying & NSObjectProtocol)

        let artistItem = AVMutableMetadataItem()
        artistItem.keySpace = AVMetadataKeySpace.common
        artistItem.key = AVMetadataKey.commonKeyArtist as (NSCopying & NSObjectProtocol)
        artistItem.value = "https://truvideo.com/" as (NSCopying & NSObjectProtocol)

        let creationDateItem = AVMutableMetadataItem()
        creationDateItem.keySpace = .common
        creationDateItem.key = AVMetadataKey.commonKeyCreationDate as NSString
        creationDateItem.value = Date() as NSDate

        return [modelItem, softwareItem, artistItem, creationDateItem]
    }

    private func startSessionIfNecessary(at sessionStart: CMTime, startTimestamp: CMTime) {
        if !self.startTimestamp.isValid && sessionStart.isValid {
            self.startTimestamp = startTimestamp
            assetWriter?.startSession(atSourceTime: sessionStart)
        }
    }
}

private extension Dictionary where Key == String {
    /// Returns true if the dictionary contains a valid settings
    /// for the video input
    var hasValidVideoSettings: Bool {
        self[AVVideoCodecKey] != nil && self[AVVideoHeightKey] != nil && self[AVVideoWidthKey] != nil
    }
}
*/
