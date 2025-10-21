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
struct VideoClip {
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

    /// The capture session preset used when recording this video clip.
    ///
    /// This property stores the `AVCaptureSession.Preset` that was active during
    /// the recording of this video clip. It preserves the resolution and quality
    /// settings that were used at the time of capture.
    let preset: AVCaptureSession.Preset

    /// The size of the video file in bytes.
    ///
    /// This property represents the total file size of the video clip on disk.
    /// It's useful for calculating storage usage, estimating upload times,
    /// and managing available storage space.
    let size: Int64

    /// The URL of the thumbnail image representing this video.
    ///
    /// This property provides a reference to a preview-sized image used for
    /// displaying the video in lists, grids, or galleries.
    let thumbnailURL: URL

    /// The file system location where the video clip is stored.
    ///
    /// This property provides the URL path to the video file, allowing the
    /// application to access, play, or process the video content. The URL
    /// can be used with AVPlayer, AVAsset, or other video processing APIs.
    let url: URL

    // MARK: - Initializer

    /// Creates a new video clip instance with the specified metadata and file location.
    ///
    /// This initializer creates a video clip object with all the necessary metadata
    /// including bit rate, duration, lens position, orientation, file size, and
    /// the URL where the video file is stored.
    ///
    /// - Parameters:
    ///   - duration: The duration of the video in seconds
    ///   - lensPosition: The camera lens position used for recording (front or back)
    ///   - orientation: The device orientation when the video was recorded
    ///   - preset: The capture session preset used when recording this video clip.
    ///   - size: The file size of the video in bytes
    ///   - thumbnailURL: The file URL of the thumbnail image representing the video
    ///   - url: The file URL where the video is stored
    init(
        duration: TimeInterval,
        lensPosition: AVCaptureDevice.Position,
        orientation: UIDeviceOrientation,
        preset: AVCaptureSession.Preset,
        size: Int64,
        thumbnailURL: URL,
        url: URL
    ) {
        self.duration = duration
        self.lensPosition = lensPosition
        self.orientation = orientation
        self.preset = preset
        self.size = size
        self.thumbnailURL = thumbnailURL
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
