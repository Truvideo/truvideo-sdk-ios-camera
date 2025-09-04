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
    /// The frame rate at which the video was recorded, measured in frames per second.
    ///
    /// This property indicates how smooth the video playback will be. Higher
    /// frame rates provide smoother motion, while lower frame
    /// rates may be more suitable for cinematic content.
    let bitRate: Int

    /// The timestamp when this object was created.
    let createdAt: TimeInterval = Date().timeIntervalSince1970

    /// The camera position used to record this video clip.
    ///
    /// This property indicates whether the video was recorded using the front
    /// camera (`.front`) or back camera (`.back`). This information is useful
    /// for determining video mirroring, applying appropriate filters, or
    /// organizing videos by camera source.
    let devicePosition: AVCaptureDevice.Position

    /// The duration of the video clip in seconds.
    ///
    /// This property represents the total playback time of the video clip.
    /// It's useful for calculating video length, determining storage requirements,
    /// and providing duration information in user interfaces.
    let duration: TimeInterval

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
}

extension VideoClip: Hashable {

    // MARK: - Equatable

    static func == (lhs: VideoClip, rhs: VideoClip) -> Bool {
        lhs.url == rhs.url
    }

    func hash(into hasher: inout Hasher) {
        url.hash(into: &hasher)
    }
}
