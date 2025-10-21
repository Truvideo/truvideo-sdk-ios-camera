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

    /// The preset of the captured media.
    public let preset: TruvideoSdkCameraPreset

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
        case preset
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
            preset: TruvideoSdkCameraPreset.from(clip.preset),
            resolution: .init(width: Int32(clip.preset.size.width), height: Int32(clip.preset.size.height)),
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
            preset: TruvideoSdkCameraPreset.from(photo.preset),
            resolution: .init(width: Int32(photo.preset.size.width), height: Int32(photo.preset.size.height)),
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
    ///   - preset: The preset of the captured media
    ///   - resolution: The resolution of the captured media
    ///   - type: The type of media that was captured
    public init(
        id: UUID = UUID(),
        createdAt: TimeInterval,
        duration: TimeInterval,
        filePath: String,
        lensFacing: TruvideoSdkCameraLensFacing,
        orientation: TruvideoSdkCameraOrientation,
        preset: TruvideoSdkCameraPreset,
        resolution: TruvideoSdkCameraResolution,
        type: TruvideoSdkCameraMediaType
    ) {
        self.id = id
        self.createdAt = createdAt
        self.duration = duration
        self.filePath = filePath
        self.lensFacing = lensFacing
        self.orientation = orientation
        self.preset = preset
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
        self.preset = try container.decode(TruvideoSdkCameraPreset.self, forKey: .preset)
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
        try container.encode(preset, forKey: .preset)
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
public enum TruvideoSdkCameraOrientation: Int, Codable, RawRepresentable {
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

    // MARK: - Encodable

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

/// Represents a camera resolution with width and height dimensions.
///
/// `TruvideoSdkCameraResolution` defines a camera resolution using integer width and height values.
/// This class provides a simple way to represent video capture resolutions and supports
/// JSON encoding for configuration storage and API communication.
///
/// ## Usage
///
/// ```swift
/// // Create a 1920x1080 resolution
/// let fullHD = TruvideoSdkCameraResolution(width: 1920, height: 1080)
///
/// // Create a 1280x720 resolution
/// let hd = TruvideoSdkCameraResolution(width: 1280, height: 720)
///
/// // Access resolution dimensions
/// print("Width: \(fullHD.width), Height: \(fullHD.height)")
/// ```
///
/// ## Common Resolutions
///
/// Standard video resolutions include:
/// - **4K**: 3840×2160 (Ultra High Definition)
/// - **1080p**: 1920×1080 (Full High Definition)
/// - **720p**: 1280×720 (High Definition)
/// - **480p**: 854×480 (Standard Definition)
/// - **360p**: 640×360 (Low Definition)
///
/// ## JSON Encoding
///
/// The class supports JSON encoding for API communication:
///
/// ```swift
/// let resolution = TruvideoSdkCameraResolution(width: 1920, height: 1080)
/// let encoder = JSONEncoder()
/// let data = try encoder.encode(resolution)
/// // Result: {"width": 1920, "height": 1080}
/// ```
///
/// ## Objective-C Compatibility
///
/// The class is marked with `@objcMembers` for full Objective-C interoperability,
/// allowing seamless integration with existing Objective-C codebases.
///
/// ## Thread Safety
///
/// This class is thread-safe and can be used concurrently across multiple threads.
/// All properties are immutable once initialized.
///
/// - Note: This class is deprecated. Use `AVCaptureSession.Preset` for resolution handling.
/// - Important: Width and height values are stored as `Int32` for API compatibility.
@objcMembers
public class TruvideoSdkCameraResolution: NSObject, Codable {
    /// The height of the camera resolution in pixels.
    ///
    /// This property represents the vertical dimension of the video capture resolution.
    /// It's stored as an `Int32` for API compatibility and JSON encoding support.
    public let height: Int32

    /// The width of the camera resolution in pixels.
    ///
    /// This property represents the horizontal dimension of the video capture resolution.
    /// It's stored as an `Int32` for API compatibility and JSON encoding support.
    public let width: Int32

    // MARK: - Types

    /// Allowable keys for JSON encoding and decoding.
    enum CodingKeys: String, CodingKey {
        case height
        case width
    }

    // MARK: - Initializers

    /// Creates a new camera resolution with the specified width and height.
    ///
    /// This initializer creates a resolution object with the given dimensions.
    /// Both width and height must be positive values representing pixel dimensions.
    ///
    /// - Parameters:
    ///   - width: The horizontal dimension in pixels
    ///   - height: The vertical dimension in pixels
    public init(width: Int32, height: Int32) {
        self.height = height
        self.width = width
    }

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.height = try container.decode(Int32.self, forKey: .height)
        self.width = try container.decode(Int32.self, forKey: .width)
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
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(height, forKey: .height)
        try container.encode(width, forKey: .width)
    }
}
