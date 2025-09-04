//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation

/// An enumeration representing the different media types supported by the Truvideo SDK camera.
///
/// `TruvideoSdkCameraMediaType` conforms to `Codable` and `RawRepresentable`, allowing it to be
/// encoded and decoded from JSON. The raw values are stored as `String` representations.
@objc
public enum TruvideoSdkCameraMediaType: Int, Codable, RawRepresentable {
    /// The media type representing a recorded video clip.
    case clip

    /// The media type representing a captured photo.
    case photo

    /// The raw type that can be used to represent all values of the conforming type.
    public typealias RawValue = String

    // MARK: - Computed Properties

    /// The string representation of each media type.
    public var rawValue: RawValue {
        switch self {
        case .clip:
            "CLIP"

        case .photo:
            "PHOTO"
        }
    }

    // MARK: - Initializers

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// - Parameter decoder: The decoder to read data from.
    /// - Throws: `DecodingError.dataCorrupted` if the raw value does not match any known cases.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)

        guard let mediaType = TruvideoSdkCameraMediaType(rawValue: rawValue) else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Invalid raw value for TruvideoSdkCameraMediaType"
                )
            )
        }

        self = mediaType
    }

    /// Creates a new instance with the specified raw value.
    ///
    /// - Parameter rawValue: The raw string value representing the media type.
    /// - Returns: An optional `TruvideoSdkCameraMediaType` if the raw value matches a known case, otherwise `nil`.
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "CLIP":
            self = .clip

        case "PHOTO":
            self = .photo

        default:
            return nil
        }
    }

    // MARK: - Encoding

    /// Encodes this value into the given encoder.
    ///
    /// - Parameter encoder: The encoder to write data to.
    /// - Throws: An encoding error if encoding fails.
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()

        try container.encode(rawValue)
    }
}
