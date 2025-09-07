//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation
import UIKit

/// Represents a video clip with metadata about its recording characteristics.
///
/// This struct encapsulates essential information about a recorded video clip,
/// including the camera position used for recording, duration, frame rate,
/// device orientation during recording, file size, and the location of the
/// video file. This information is useful for video processing, playback,
/// and organizing video collections.
///
/// The struct provides a convenient way to access video metadata without
/// needing to load the entire video file or parse complex format descriptions.
final class VideoClip {
    /// The frame rate at which the video was recorded, measured in frames per second.
    ///
    /// This property indicates how smooth the video playback will be. Higher
    /// frame rates provide smoother motion, while lower frame
    /// rates may be more suitable for cinematic content.
    let bitRate: Int

    /// The timestamp when this object was created.
    let createdAt: TimeInterval = Date().timeIntervalSince1970

    /// The duration of the video clip in seconds.
    ///
    /// This property represents the total playback time of the video clip.
    /// It's useful for calculating video length, determining storage requirements,
    /// and providing duration information in user interfaces.
    let duration: TimeInterval

    /// The camera lens position used for capture.
    ///
    /// This property specifies which camera lens was used to capture the photo,
    /// such as front-facing or back-facing camera. It's useful for determining
    /// the photo's context and applying appropriate processing.
    let lensPosition: AVCaptureDevice.Position

    /// The device orientation when the video was captured.
    ///
    /// This value indicates how the device was oriented when the video was recorded,
    /// which is important for proper video display and rotation handling.
    let orientation: UIDeviceOrientation

    /// The size of the video file in bytes.
    ///
    /// This property represents the total file size of the video clip on disk.
    /// It's useful for calculating storage usage, estimating upload times,
    /// and managing available storage space.
    let size: Int64

    /// The file system location where the video clip is stored.
    ///
    /// This property provides the URL path to the video file, allowing the
    /// application to access, play, or process the video content. The URL
    /// can be used with AVPlayer, AVAsset, or other video processing APIs.
    let url: URL

    // MARK: - Lazy Properties

    /// A lazy-loaded thumbnail image from the beginning of the video.
    ///
    /// This property generates a thumbnail image from the first frame of the video
    /// using the video's URL. The thumbnail is created lazily to optimize performance
    /// and memory usage, only generating the image when first accessed.
    lazy var thumbnail: UIImage? = {
        let asset = AVAsset(url: url)

        return try? asset.snapshot(at: CMTime(seconds: 1, preferredTimescale: 1), actualTime: nil)
    }()

    // MARK: - Initializer

    /// Creates a new video clip instance with the specified metadata and file location.
    ///
    /// This initializer creates a video clip object with all the necessary metadata
    /// including bit rate, duration, lens position, orientation, file size, and
    /// the URL where the video file is stored.
    ///
    /// - Parameters:
    ///   - bitRate: The bit rate of the video in bits per second
    ///   - duration: The duration of the video in seconds
    ///   - lensPosition: The camera lens position used for recording (front or back)
    ///   - orientation: The device orientation when the video was recorded
    ///   - size: The file size of the video in bytes
    ///   - url: The file URL where the video is stored
    init(
        bitRate: Int,
        duration: TimeInterval,
        lensPosition: AVCaptureDevice.Position,
        orientation: UIDeviceOrientation,
        size: Int64,
        url: URL
    ) {

        self.bitRate = bitRate
        self.duration = duration
        self.lensPosition = lensPosition
        self.orientation = orientation
        self.size = size
        self.url = url
    }
}

extension VideoClip: Hashable {

    // MARK: - Equatable

    /// Returns a Boolean value indicating whether two type-erased hashable
    /// instances wrap the same value.
    static func == (lhs: VideoClip, rhs: VideoClip) -> Bool {
        lhs.url == rhs.url
    }

    /// Hashes the essential components of this value by feeding them into the
    /// given hasher.
    ///
    /// - Parameter hasher: The hasher to use when combining the components
    ///   of this instance.
    func hash(into hasher: inout Hasher) {
        url.hash(into: &hasher)
    }
}
