//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// Represents a media item that can be either a video clip or a photo.
///
/// This enum provides a unified way to handle different types of media content
/// within the gallery system. It encapsulates both video clips and photos
/// while providing common properties like creation timestamp that can be
/// accessed regardless of the media type.
enum Media: Equatable {
    /// A video clip containing recorded video content.
    ///
    /// This case represents a video recording with associated metadata
    /// such as duration, file path, and recording settings. The associated
    /// value contains the complete video clip information needed for
    /// playback, editing, and display operations.
    case clip(VideoClip)

    /// A photo containing captured image content.
    ///
    /// This case represents a captured image with associated metadata
    /// such as file path, format, and capture settings. The associated
    /// value contains the complete photo information needed for
    /// display, editing, and sharing operations.
    case photo(Photo)

    // MARK: - Computed Properties

    /// The timestamp when this media item was created.
    ///
    /// This computed property extracts the creation timestamp from either
    /// a video clip or photo, providing a unified way to access the
    /// creation time regardless of the media type.
    var createdAt: TimeInterval {
        switch self {
        case let .clip(videoClip):
            videoClip.createdAt

        case let .photo(photo):
            photo.createdAt
        }
    }

    /// The URL of the thumbnail image representing this media item.
    ///
    /// This computed property provides a preview image location for the
    /// media, whether it is a video clip or photo. For videos, it usually
    /// points to a generated still image that represents the clip.
    /// For photos, it points to the image itself or a downscaled preview.
    ///
    /// - Returns: A `URL` pointing to the thumbnail image for this media item
    var thumbnailURL: URL {
        switch self {
        case let .clip(clip):
            clip.thumbnailURL

        case let .photo(photo):
            photo.thumbnailURL
        }
    }

    /// The file URL of the underlying media content.
    ///
    /// This computed property provides direct access to the stored file
    /// associated with this media item. For video clips, it points to the
    /// video file; for photos, it points to the image file.
    ///
    /// - Returns: A `URL` pointing to the underlying media file
    var url: URL {
        switch self {
        case let .clip(clip):
            clip.url

        case let .photo(photo):
            photo.url
        }
    }

    /// Indicates whether this media item is a video clip.
    ///
    /// This computed property provides a convenient way to check if the media
    /// item represents a video clip without needing to use pattern matching
    /// in switch statements. It returns true for video clips and false for
    /// photos, enabling boolean-based conditional logic for media type checking.
    ///
    /// - Returns: True if the media item is a video clip, false otherwise
    var isClip: Bool {
        switch self {
        case .clip:
            true

        case .photo:
            false
        }
    }

    /// Indicates whether this media item is a photo.
    ///
    /// This computed property provides a convenient way to check if the media
    /// item represents a photo without needing to use pattern matching in
    /// switch statements. It returns true for photos and false for video
    /// clips, enabling boolean-based conditional logic for media type checking.
    ///
    /// - Returns: True if the media item is a photo, false otherwise
    var isPhoto: Bool {
        switch self {
        case .clip:
            false

        case .photo:
            true
        }
    }
}
