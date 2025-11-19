//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// A configuration class that defines the media capture limits and constraints for the camera.
///
/// This class provides a unified way to configure how many pictures and videos can be captured,
/// along with duration limits for video recordings. It supports various capture modes including
/// single media capture, multiple media capture, and mixed media capture scenarios.
///
/// The class uses a flexible approach where maxMediaCount represents the total limit across
/// all media types, while individual limits (maxPictureCount, maxVideoCount) provide specific
/// constraints for each media type. When both total and specific limits are set, the more
/// restrictive limit takes precedence.
///
/// All factory methods provide sensible defaults and can be used to quickly create common
/// capture configurations without needing to understand the underlying limit calculations.
///
/// ## Examples
///
/// ```swift
/// // Single picture capture
/// let singlePictureMode = TruvideoSdkCameraMediaMode.singlePicture()
///
/// // Multiple pictures with limit
/// let pictureMode = TruvideoSdkCameraMediaMode.picture(pictureCount: 5)
///
/// // Single video with 30-second limit
/// let singleVideoMode = TruvideoSdkCameraMediaMode.singleVideo(videoDuration: 30)
///
/// // Multiple videos with limits
/// let videoMode = TruvideoSdkCameraMediaMode.video(videoCount: 3, videoDuration: 60)
///
/// // Mixed media with separate limits
/// let mixedMode = TruvideoSdkCameraMediaMode.videoAndPicture(
///     videoCount: 2,
///     pictureCount: 5,
///     videoDuration: 45
/// )
///
/// // Mixed media with total limit only
/// let totalLimitMode = TruvideoSdkCameraMediaMode.videoAndPicture(
///     mediaCount: 10,
///     videoDuration: 30
/// )
///
/// // Custom configuration
/// let customMode = TruvideoSdkCameraMediaMode(
///     maxMediaCount: 15,
///     maxPictureCount: 8,
///     maxVideoCount: 7,
///     maxVideoDuration: 60
/// )
/// ```
@objcMembers
public final class TruvideoSdkCameraMediaMode: NSObject {
    /// The maximum total number of media items (pictures + videos) that can be captured.
    /// When set to 0, no total limit is enforced.
    let maxMediaCount: Int

    /// The maximum number of pictures that can be captured.
    /// When set to 0, picture capture is disabled.
    let maxPictureCount: Int

    /// The maximum number of videos that can be captured.
    /// When set to 0, video capture is disabled.
    let maxVideoCount: Int

    /// The maximum duration in seconds for each video recording.
    /// When set to 0, video recording is disabled.
    let maxVideoDuration: TimeInterval

    // MARK: - Static Properties

    /// Maximum number of pictures (photos/images) allowed per user/action.
    /// Use together with `maxMediaCount`, which caps the total across all media types.
    static let maxPictureCount = 10_000

    /// Maximum total number of media items (pictures + videos) allowed.
    /// This global cap is enforced in addition to the per-type limits.
    static let maxMediaCount = 10_000

    /// Maximum number of videos allowed per user/action.
    /// Use together with `maxMediaCount`, which caps the total across all media types.
    static let maxVideoCount = 10_000

    /// Maximum allowed duration for a single video, in seconds (equals 5 days).
    static let maxVideoDurationAllowed: TimeInterval = 5 * 24 * 60 * 60

    // MARK: - Public Static methods

    /// Creates a mode configured for capturing multiple pictures.
    ///
    /// This mode allows unlimited picture capture by default, but can be constrained
    /// to a specific count. Video capture is disabled in this mode.
    ///
    /// - Parameter pictureCount: Maximum number of pictures (default: unlimited)
    /// - Returns: A media mode configured for picture capture
    public static func picture(pictureCount: Int? = nil) -> TruvideoSdkCameraMediaMode {
        TruvideoSdkCameraMediaMode(
            maxMediaCount: pictureCount ?? maxPictureCount,
            maxPictureCount: pictureCount ?? maxPictureCount
        )
    }

    /// Creates a mode configured for capturing a single picture.
    ///
    /// This mode allows exactly one picture to be captured. Video capture is disabled.
    /// This is useful for simple photo capture scenarios.
    ///
    /// - Returns: A media mode configured for single picture capture
    public static func singlePicture() -> TruvideoSdkCameraMediaMode {
        TruvideoSdkCameraMediaMode(maxMediaCount: 1, maxPictureCount: 1)
    }

    /// Creates a mode configured for capturing a single video.
    ///
    /// This mode allows exactly one video to be captured with an optional duration limit.
    /// Picture capture is disabled in this mode.
    ///
    /// - Parameter videoDuration: Maximum video duration in seconds (default: unlimited)
    /// - Returns: A media mode configured for single video capture
    public static func singleVideo(videoDuration: Int? = nil) -> TruvideoSdkCameraMediaMode {
        TruvideoSdkCameraMediaMode(
            maxMediaCount: 1,
            maxVideoCount: 1,
            maxVideoDuration: videoDuration.map(TimeInterval.init) ?? maxVideoDurationAllowed
        )
    }

    /// Creates a mode configured for capturing either a single video or picture.
    ///
    /// This mode allows exactly one media item to be captured, either a video or picture.
    /// The user can choose which type to capture, but only one item total is allowed.
    ///
    /// - Parameter videoDuration: Maximum video duration in seconds (default: unlimited)
    /// - Returns: A media mode configured for single video or picture capture
    public static func singleVideoOrPicture(videoDuration: Int? = nil) -> TruvideoSdkCameraMediaMode {
        TruvideoSdkCameraMediaMode(
            maxMediaCount: 1,
            maxVideoDuration: videoDuration.map(TimeInterval.init) ?? maxVideoDurationAllowed
        )
    }

    /// Creates a mode configured for capturing multiple videos.
    ///
    /// This mode allows unlimited video capture by default, but can be constrained
    /// to a specific count. Picture capture is disabled in this mode.
    ///
    /// - Parameters:
    ///   - videoCount: Maximum number of videos (default: unlimited)
    ///   - videoDuration: Maximum duration per video in seconds (default: unlimited)
    /// - Returns: A media mode configured for multiple video capture
    public static func video(videoCount: Int? = nil, videoDuration: Int? = nil) -> TruvideoSdkCameraMediaMode {
        TruvideoSdkCameraMediaMode(
            maxMediaCount: videoCount ?? maxVideoCount,
            maxVideoCount: videoCount ?? maxVideoCount,
            maxVideoDuration: videoDuration.map(TimeInterval.init) ?? maxVideoDurationAllowed
        )
    }

    /// Creates a mode configured for capturing both videos and pictures with separate limits.
    ///
    /// This mode allows both video and picture capture with independent limits for each type.
    /// The total media count is calculated as the sum of picture and video limits.
    ///
    /// - Parameters:
    ///   - videoCount: Maximum number of videos (default: unlimited)
    ///   - pictureCount: Maximum number of pictures (default: unlimited)
    ///   - videoDuration: Maximum duration per video in seconds (default: unlimited)
    /// - Returns: A media mode configured for mixed media capture with separate limits
    public static func videoAndPicture(
        videoCount: Int? = nil,
        pictureCount: Int? = nil,
        videoDuration: Int? = nil
    ) -> TruvideoSdkCameraMediaMode {
        TruvideoSdkCameraMediaMode(
            maxMediaCount: (pictureCount ?? maxPictureCount) + (videoCount ?? maxVideoCount),
            maxPictureCount: pictureCount ?? maxPictureCount,
            maxVideoCount: videoCount ?? maxVideoCount,
            maxVideoDuration: videoDuration.map(TimeInterval.init) ?? maxVideoDurationAllowed
        )
    }

    /// Creates a mode configured for capturing both videos and pictures with a total limit.
    ///
    /// This mode allows both video and picture capture but enforces a total media count limit.
    /// Individual media type limits are set to unlimited, allowing flexible distribution
    /// of the total limit between pictures and videos.
    ///
    /// - Parameters:
    ///   - mediaCount: Maximum total media items (default: unlimited)
    ///   - videoDuration: Maximum duration per video in seconds (default: unlimited)
    /// - Returns: A media mode configured for mixed media capture with total limit
    public static func videoAndPicture(
        mediaCount: Int? = nil,
        videoDuration: Int? = nil
    ) -> TruvideoSdkCameraMediaMode {
        TruvideoSdkCameraMediaMode(
            maxMediaCount: mediaCount ?? maxMediaCount,
            maxPictureCount: 0,
            maxVideoCount: 0,
            maxVideoDuration: videoDuration.map(TimeInterval.init) ?? maxVideoDurationAllowed
        )
    }

    // MARK: - Initializer

    /// Creates a new camera media mode with specified capture limits.
    ///
    /// This initializer allows fine-grained control over media capture limits.
    /// The maxMediaCount parameter sets the overall limit, while individual
    /// media type limits can be set independently. When both total and specific
    /// limits are provided, the more restrictive limit will be enforced.
    ///
    /// - Parameters:
    ///   - maxMediaCount: Maximum total media items (0 = no limit)
    ///   - maxPictureCount: Maximum pictures (0 = disabled, default: 0)
    ///   - maxVideoCount: Maximum videos (0 = disabled, default: 0)
    ///   - maxVideoDuration: Maximum video duration in seconds (0 = disabled, default: 0)
    init(maxMediaCount: Int, maxPictureCount: Int = 0, maxVideoCount: Int = 0, maxVideoDuration: TimeInterval = 0) {
        self.maxMediaCount = maxMediaCount
        self.maxPictureCount = maxPictureCount
        self.maxVideoCount = maxVideoCount
        self.maxVideoDuration = maxVideoDuration
    }
}
