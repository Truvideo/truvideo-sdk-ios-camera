//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

/// A result object containing the media items captured by the camera.
///
/// This class represents the outcome of a camera capture session, containing
/// all the media items (pictures and videos) that were successfully captured.
/// The result is designed to be easily serializable and can be encoded for
/// storage or transmission purposes.
///
/// The media array contains all captured items in the order they were captured,
/// allowing for chronological playback or processing. Each media item includes
/// its type, file path, metadata, and any associated properties.
@objcMembers
public final class TruvideoSdkCameraResult: NSObject, Encodable {
    /// The collection of media items captured during the camera session.
    ///
    /// This array contains all successfully captured pictures and videos,
    /// ordered chronologically by capture time. Each media item includes
    /// the file path, type information, and associated metadata.
    public let media: [TruvideoSdkCameraMedia]

    // MARK: - Initializer

    /// Creates a new camera result with the captured media items.
    ///
    /// This initializer creates a result object that encapsulates all
    /// the media captured during a camera session. The media array
    /// should contain all successfully captured items in chronological order.
    ///
    /// - Parameter media: An array of captured media items
    init(media: [TruvideoSdkCameraMedia]) {
        self.media = media
    }
}
