//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import UIKit

/// A model representing a captured media item from the camera.
///
/// This class encapsulates all the metadata and properties of a captured
/// media item, including pictures and videos. It provides comprehensive
/// information about the capture session, including timing, device
/// orientation, camera settings, and file location.
///
/// Each media item includes a unique identifier, creation timestamp,
/// file path for access, and detailed capture metadata such as
/// camera lens, orientation, resolution, and media type.
@objcMembers
public final class TruvideoSdkCameraMedia: NSObject, Codable, Identifiable {
    /// A unique identifier for the media item.
    public let id: UUID

    /// The timestamp when the media was captured.
    public let createdAt: TimeInterval

    /// The duration of the media item in seconds.
    public let duration: TimeInterval

    /// The file system path where the media is stored.
    public let filePath: String

    /// The camera lens used to capture the media.
    public let lensFacing: TruvideoSdkCameraLensFacing

    /// The device orientation when the media was captured.
    public let orientation: TruvideoSdkCameraOrientation

    /// The resolution of the captured media.
    public let resolution: TruvideoSdkCameraResolution

    /// The type of media that was captured.
    public let type: TruvideoSdkCameraMediaType

    // MARK: - CodingKeys

    /// Allowable keys for the model.
    private enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case filePath
        case type
        case lensFacing
        case orientation
        case resolution
        case duration
    }

    // MARK: - Static methods

    /// Creates a `TruvideoSdkCameraMedia` instance from a `Media` object.
    ///
    /// This method converts a `Media` instance into the corresponding `TruvideoSdkCameraMedia`
    /// format used by the TruVideo SDK. It handles both photo and video clip media types by
    /// delegating to the appropriate conversion method based on the media's associated value.
    ///
    /// - Parameter media: The `Media` object to convert from
    /// - Returns: A `TruvideoSdkCameraMedia` instance with the media's data
    static func from(_ media: Media) -> TruvideoSdkCameraMedia {
        switch media {
        case let .clip(clip):
            from(clip)

        case let .photo(photo):
            from(photo)
        }
    }

    /// Creates a `TruvideoSdkCameraMedia` instance from a `VideoClip` object.
    ///
    /// This method converts a `VideoClip` instance into the corresponding `TruvideoSdkCameraMedia`
    /// format used by the TruVideo SDK. It maps the video clip's metadata including creation time,
    /// duration, lens position, orientation, and file path to the SDK's media representation.
    ///
    /// - Parameter clip: The `VideoClip` object to convert from
    /// - Returns: A `TruvideoSdkCameraMedia` instance with the video clip's data
    static func from(_ clip: VideoClip) -> TruvideoSdkCameraMedia {
        TruvideoSdkCameraMedia(
            createdAt: clip.createdAt,
            duration: clip.duration * 1_000,
            filePath: clip.url.path,
            lensFacing: TruvideoSdkCameraLensFacing(position: clip.lensPosition),
            orientation: TruvideoSdkCameraOrientation(orientation: clip.orientation),
            resolution: TruvideoSdkCameraResolution.from(clip.preset),
            type: .clip
        )
    }

    /// Creates a `TruvideoSdkCameraMedia` instance from a `Photo` object.
    ///
    /// This method converts a `Photo` instance into the corresponding `TruvideoSdkCameraMedia`
    /// format used by the TruVideo SDK. It maps the photo's metadata including creation time,
    /// lens position, orientation, and file path to the SDK's media representation.
    ///
    /// - Parameter photo: The `Photo` object to convert from
    /// - Returns: A `TruvideoSdkCameraMedia` instance with the photo's data
    static func from(_ photo: Photo) -> TruvideoSdkCameraMedia {
        TruvideoSdkCameraMedia(
            createdAt: photo.createdAt,
            duration: 0,
            filePath: photo.url.path,
            lensFacing: TruvideoSdkCameraLensFacing(position: photo.lensPosition),
            orientation: TruvideoSdkCameraOrientation(orientation: photo.orientation),
            resolution: TruvideoSdkCameraResolution.from(photo.preset),
            type: .photo
        )
    }

    // MARK: - Initializer

    /// Creates a new media item with all required properties.
    ///
    /// This initializer creates a complete media item with all
    /// necessary metadata and properties. All parameters are required
    /// to ensure the media item has complete information for proper
    /// handling and display throughout the application.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the media item
    ///   - createdAt: The timestamp when the media was captured
    ///   - duration: The duration of the media in seconds
    ///   - filePath: The file system path where the media is stored
    ///   - lensFacing: The camera lens used for capture
    ///   - orientation: The device orientation during capture
    ///   - resolution: The resolution of the captured media
    ///   - type: The type of media that was captured
    public init(
        id: UUID = UUID(),
        createdAt: TimeInterval,
        duration: TimeInterval,
        filePath: String,
        lensFacing: TruvideoSdkCameraLensFacing,
        orientation: TruvideoSdkCameraOrientation,
        resolution: TruvideoSdkCameraResolution,
        type: TruvideoSdkCameraMediaType
    ) {
        self.id = id
        self.createdAt = createdAt
        self.duration = duration
        self.filePath = filePath
        self.lensFacing = lensFacing
        self.orientation = orientation
        self.resolution = resolution
        self.type = type
    }

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer supports JSON deserialization by decoding the string
    /// raw value and converting it to the appropriate orientation enum case.
    /// If the decoded string doesn't match any valid raw value, a DecodingError
    /// is thrown to indicate data corruption.
    ///
    /// - Parameter decoder: The decoder to read data from
    /// - Throws: DecodingError.dataCorrupted if the raw value is invalid
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(UUID.self, forKey: .id)
        self.createdAt = try container.decode(TimeInterval.self, forKey: .createdAt)
        self.duration = try container.decode(TimeInterval.self, forKey: .duration)
        self.filePath = try container.decode(String.self, forKey: .filePath)
        self.lensFacing = try container.decode(TruvideoSdkCameraLensFacing.self, forKey: .lensFacing)
        self.orientation = try container.decode(TruvideoSdkCameraOrientation.self, forKey: .orientation)
        self.resolution = try container.decode(TruvideoSdkCameraResolution.self, forKey: .resolution)
        self.type = try container.decode(TruvideoSdkCameraMediaType.self, forKey: .type)
    }

    // MARK: - Encoding

    /// Encodes this media instance into the given encoder.
    ///
    /// - Parameter encoder: The encoder to write data to.
    /// - Throws: An encoding error if encoding fails.
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(duration, forKey: .duration)
        try container.encode(filePath, forKey: .filePath)
        try container.encode(lensFacing, forKey: .lensFacing)
        try container.encode(orientation, forKey: .orientation)
        try container.encode(resolution, forKey: .resolution)
        try container.encode(type, forKey: .type)
    }
}
