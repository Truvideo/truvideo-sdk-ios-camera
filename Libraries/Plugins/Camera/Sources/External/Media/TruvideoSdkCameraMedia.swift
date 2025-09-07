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
public final class TruvideoSdkCameraMedia: NSObject, Encodable, Identifiable {
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
        case .clip(let clip):
            from(clip)

        case .photo(let photo):
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
            duration: clip.duration,
            filePath: clip.url.path,
            lensFacing: TruvideoSdkCameraLensFacing(position: clip.lensPosition),
            orientation: TruvideoSdkCameraOrientation(orientation: clip.orientation),
            resolution: .init(width: 0, height: 0),
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
            resolution: .init(width: 0, height: 0),
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

/// An enumeration representing camera orientation states.
///
/// This enum defines the four possible camera orientations that correspond
/// to device orientation states. It provides a bridge between device
/// orientation detection and camera interface orientation requirements,
/// supporting both portrait and landscape orientations in all directions.
///
/// The enum uses string raw values for better readability and API consistency,
/// with underscore-separated uppercase values following common naming
/// conventions. It includes utility properties for converting between
/// different orientation representations and retrieving current device state.
@objc
public enum TruvideoSdkCameraOrientation: Int, Encodable, RawRepresentable {
    /// Upright portrait mode.
    ///
    /// This case represents the standard portrait orientation where the device
    /// is held vertically with the top of the device pointing upward. This is
    /// the most common orientation for mobile photography and video capture.
    case portrait

    /// Landscape mode with the device rotated left.
    ///
    /// This case represents landscape orientation where the device is rotated
    /// 90 degrees counterclockwise from portrait. The left edge of the device
    /// becomes the top edge in this orientation.
    case landscapeLeft

    /// Landscape mode with the device rotated right.
    ///
    /// This case represents landscape orientation where the device is rotated
    /// 90 degrees clockwise from portrait. The right edge of the device
    /// becomes the top edge in this orientation.
    case landscapeRight

    /// Upside-down portrait mode.
    ///
    /// This case represents portrait orientation where the device is rotated
    /// 180 degrees from the standard portrait position. The bottom of the
    /// device becomes the top in this orientation.
    case portraitReverse

    /// The raw type that can be used to represent all values of the conforming type.
    public typealias RawValue = String

    // MARK: - Computed Properties

    /// The corresponding value of the raw type.
    ///
    /// This property returns the string representation of the orientation
    /// enum case. The raw values use underscore-separated uppercase strings
    /// that provide clear, human-readable representations suitable for
    /// API communication and configuration storage.
    ///
    /// - Returns: The string raw value for the current orientation case
    public var rawValue: RawValue {
        switch self {
        case .portrait:
            "PORTRAIT"

        case .landscapeLeft:
            "LANDSCAPE_LEFT"

        case .landscapeRight:
            "LANDSCAPE_RIGHT"

        case .portraitReverse:
            "PORTRAIT_REVERSE"
        }
    }

    // MARK: - Initializers

    /// Creates an orientation instance from a `UIDeviceOrientation`.
    ///
    /// This initializer converts a `UIDeviceOrientation` to the corresponding
    /// orientation value, mapping the device orientation to the appropriate
    /// orientation representation. It handles all standard orientations with
    /// a default fallback for unknown orientation values.
    ///
    /// - Parameter orientation: The `UIDeviceOrientation` to convert from
    init(orientation: UIDeviceOrientation) {
        switch orientation {
        case .landscapeLeft:
            self = .landscapeLeft

        case .landscapeRight:
            self = .landscapeRight

        case .portrait:
            self = .portrait

        case .portraitUpsideDown:
            self = .portraitReverse

        default:
            self = .portrait
        }
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
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)

        guard let cameraOrientation = TruvideoSdkCameraOrientation(rawValue: rawValue) else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Invalid raw value for TruvideoSdkCameraOrientation"
                )
            )
        }

        self = cameraOrientation
    }

    /// Creates a new instance with the specified raw value.
    ///
    /// This failable initializer creates an orientation enum case from a string
    /// raw value. It provides safe conversion from external string data by
    /// returning nil for invalid raw values, ensuring type safety.
    ///
    /// - Parameter rawValue: The string raw value to convert
    /// - Returns: The corresponding enum case, or nil if the raw value is invalid
    public init?(rawValue: RawValue) {
        switch rawValue.uppercased() {
        case "PORTRAIT":
            self = .portrait

        case "LANDSCAPE_LEFT":
            self = .landscapeLeft

        case "LANDSCAPE_RIGHT":
            self = .landscapeRight

        case "PORTRAIT_REVERSE":
            self = .portraitReverse

        default:
            return nil
        }
    }

    // MARK: - Encoder

    /// Encodes this value into the given encoder.
    ///
    /// This method supports JSON serialization by encoding the string raw
    /// value of the orientation enum case. The encoded value can be used
    /// for configuration storage, API communication, or cross-platform
    /// data exchange.
    ///
    /// - Parameter encoder: The encoder to write data to
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()

        try container.encode(rawValue)
    }
}
