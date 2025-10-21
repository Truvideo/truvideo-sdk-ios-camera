//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

extension TruvideoSdkCameraMediaMode {
    /// Creates a mode configured for capturing both videos and pictures with separate limits.
    ///
    /// This Objective-C wrapper method provides the same functionality as the Swift `videoAndPicture`
    /// method but accepts NSNumber parameters for better Objective-C compatibility.
    ///
    /// - Warning: This method is deprecated. Use `videoAndPicture(videoCount:pictureCount:videoDuration:)` instead.
    ///
    /// - Parameters:
    ///   - videoCount: Maximum number of videos (nil = unlimited)
    ///   - pictureCount: Maximum number of pictures (nil = unlimited)
    ///   - videoDuration: Maximum duration per video in seconds (nil = unlimited)
    /// - Returns: A media mode configured for mixed media capture with separate limits
    @available(*, deprecated, message: "Use videoAndPicture(videoCount:pictureCount:videoDuration:) instead")
    @objc
    public static func NSVideoAndPicture(
        videoCount: NSNumber? = nil,
        pictureCount: NSNumber? = nil,
        videoDuration: NSNumber? = nil
    ) -> TruvideoSdkCameraMediaMode {
        TruvideoSdkCameraMediaMode.videoAndPicture(
            videoCount: videoCount?.intValue ?? Int.max,
            pictureCount: pictureCount?.intValue ?? Int.max,
            videoDuration: videoDuration?.intValue ?? Int.max
        )
    }

    /// Creates a mode configured for capturing a single video.
    ///
    /// This Objective-C wrapper method provides the same functionality as the Swift `singleVideo`
    /// method but accepts NSNumber parameters for better Objective-C compatibility.
    ///
    /// - Warning: This method is deprecated. Use `singleVideo(videoDuration:)` instead.
    ///
    /// - Parameter videoDuration: Maximum video duration in seconds (nil = unlimited)
    /// - Returns: A media mode configured for single video capture
    @available(*, deprecated, message: "Use singleVideo(videoDuration:) instead")
    @objc
    public static func NSSingleVideo(videoDuration: NSNumber? = nil) -> TruvideoSdkCameraMediaMode {
        TruvideoSdkCameraMediaMode.singleVideo(videoDuration: videoDuration?.intValue ?? Int.max)
    }

    /// Creates a mode configured for capturing a single picture.
    ///
    /// This Objective-C wrapper method provides the same functionality as the Swift `singlePicture`
    /// method for better Objective-C compatibility.
    ///
    /// - Warning: This method is deprecated. Use `singlePicture()` instead.
    ///
    /// - Returns: A media mode configured for single picture capture
    @available(*, deprecated, message: "Use singlePicture() instead")
    @objc
    public static func NSSinglePicture() -> TruvideoSdkCameraMediaMode {
        TruvideoSdkCameraMediaMode.singlePicture()
    }

    /// Creates a mode configured for capturing either a single video or picture.
    ///
    /// This Objective-C wrapper method provides the same functionality as the Swift `singleVideoOrPicture`
    /// method but accepts NSNumber parameters for better Objective-C compatibility.
    ///
    /// - Warning: This method is deprecated. Use `singleVideoOrPicture(videoDuration:)` instead.
    ///
    /// - Parameter videoDuration: Maximum video duration in seconds (nil = unlimited)
    /// - Returns: A media mode configured for single video or picture capture
    @available(*, deprecated, message: "Use singleVideoOrPicture(videoDuration:) instead")
    @objc
    public static func NSSingleVideoOrPicture(videoDuration: NSNumber? = nil) -> TruvideoSdkCameraMediaMode {
        TruvideoSdkCameraMediaMode.singleVideoOrPicture(videoDuration: videoDuration?.intValue ?? Int.max)
    }

    /// Creates a mode configured for capturing multiple videos.
    ///
    /// This Objective-C wrapper method provides the same functionality as the Swift `video`
    /// method but accepts NSNumber parameters for better Objective-C compatibility.
    ///
    /// - Warning: This method is deprecated. Use `video(videoCount:videoDuration:)` instead.
    ///
    /// - Parameters:
    ///   - videoCount: Maximum number of videos (nil = unlimited)
    ///   - videoDuration: Maximum duration per video in seconds (nil = unlimited)
    /// - Returns: A media mode configured for multiple video capture
    @available(*, deprecated, message: "Use video(videoCount:videoDuration:) instead")
    @objc
    public static func NSVideo(
        videoCount: NSNumber? = nil,
        videoDuration: NSNumber? = nil
    ) -> TruvideoSdkCameraMediaMode {
        TruvideoSdkCameraMediaMode.video(
            videoCount: videoCount?.intValue ?? Int.max,
            videoDuration: videoDuration?.intValue ?? Int.max
        )
    }

    /// Creates a mode configured for capturing multiple pictures.
    ///
    /// This Objective-C wrapper method provides the same functionality as the Swift `picture`
    /// method but accepts NSNumber parameters for better Objective-C compatibility.
    ///
    /// - Warning: This method is deprecated. Use `picture(pictureCount:)` instead.
    ///
    /// - Parameter pictureCount: Maximum number of pictures (nil = unlimited)
    /// - Returns: A media mode configured for picture capture
    @available(*, deprecated, message: "Use picture(pictureCount:) instead")
    @objc
    public static func NSPicture(pictureCount: NSNumber? = nil) -> TruvideoSdkCameraMediaMode {
        TruvideoSdkCameraMediaMode.picture(pictureCount: pictureCount?.intValue ?? Int.max)
    }

    /// Creates a mode configured for capturing both videos and pictures with a total limit.
    ///
    /// This Objective-C wrapper method provides the same functionality as the Swift `videoAndPicture`
    /// method with total media count limit but accepts NSNumber parameters for better Objective-C compatibility.
    ///
    /// - Warning: This method is deprecated. Use `videoAndPicture(mediaCount:videoDuration:)` instead.
    ///
    /// - Parameters:
    ///   - mediaCount: Maximum total media items (nil = unlimited)
    ///   - videoDuration: Maximum duration per video in seconds (nil = unlimited)
    /// - Returns: A media mode configured for mixed media capture with total limit
    @available(*, deprecated, message: "Use videoAndPicture(mediaCount:videoDuration:) instead")
    @objc
    public static func NSVideoAndPicture(
        mediaCount: NSNumber? = nil,
        videoDuration: NSNumber? = nil
    ) -> TruvideoSdkCameraMediaMode {
        TruvideoSdkCameraMediaMode.videoAndPicture(
            mediaCount: mediaCount?.intValue ?? Int.max,
            videoDuration: videoDuration?.intValue ?? Int.max
        )
    }
}
