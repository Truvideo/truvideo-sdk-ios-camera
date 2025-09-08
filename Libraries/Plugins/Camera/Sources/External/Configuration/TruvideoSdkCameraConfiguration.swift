//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVKit
import Foundation
import UIKit

/// A configuration object that defines camera behavior and capture settings.
///
/// This class encapsulates all the settings needed to configure the camera
/// for media capture, including lens selection, flash behavior, image format,
/// resolution options, and capture mode limits. It provides a centralized
/// way to manage camera configuration and ensures consistent behavior
/// across different capture sessions.
///
/// The configuration supports both front and back camera lenses, multiple
/// resolution options, various flash modes, and flexible media capture
/// modes. All settings have sensible defaults to simplify common use cases
/// while still allowing fine-grained customization when needed.
///
/// This class is designed to be Objective-C compatible and can be easily
/// integrated into existing iOS applications.
@objcMembers
public class TruvideoSdkCameraConfiguration: NSObject {
    /// The flash mode setting for the camera.
    ///
    /// This property determines how the camera flash behaves during capture.
    /// Options include off, on, auto, and other flash modes depending on
    /// device capabilities and lighting conditions.
    public let flashMode: TruvideoSdkCameraFlashMode

    /// The image format for captured photos.
    ///
    /// This property specifies the file format used for saving captured
    /// images. Common formats include JPEG, PNG, and HEIC. The format
    /// affects file size, quality, and compatibility with different systems.
    public var imageFormat = TruvideoSdkCameraImageFormat.jpeg

    /// Indicates whether high-resolution photo capture is enabled.
    ///
    /// When enabled, the camera will capture photos at the highest
    /// available resolution for the selected camera lens. This may
    /// impact performance and file size but provides maximum image quality.
    public var isHighResolutionPhotoEnabled = false

    /// The camera lens to use for capture.
    ///
    /// This property specifies whether to use the front-facing or
    /// back-facing camera lens. The choice affects the perspective
    /// and capabilities available during capture.
    public let lensFacing: TruvideoSdkCameraLensFacing

    /// The media capture mode and limits.
    ///
    /// This property defines what types of media can be captured
    /// (pictures, videos, or both) and sets limits on the number
    /// of items and duration for each media type.
    public let mode: TruvideoSdkCameraMediaMode

    /// The directory path where captured media will be saved.
    ///
    /// This property specifies the file system location where
    /// captured pictures and videos will be stored. The path
    /// should be writable and accessible by the application.
    public let outputPath: String

    // MARK: - Initializer

    /// Creates a new camera configuration with specified settings.
    ///
    /// This initializer allows comprehensive configuration of the camera
    /// with all available settings. Most parameters have sensible defaults
    /// to simplify common use cases while still allowing full customization
    /// when needed.
    ///
    /// The resolution parameters support both arrays of available options
    /// and specific resolution selections, providing flexibility in how
    /// the camera handles resolution selection and fallbacks.
    ///
    /// - Parameters:
    ///   - backResolutions: Available resolution options for the back camera (default: empty array)
    ///   - flashMode: The flash mode setting (default: off)
    ///   - frontResolutions: Available resolution options for the front camera (default: empty array)
    ///   - imageFormat: The image format for captured photos (default: JPEG)
    ///   - lensFacing: The camera lens to use (default: back)
    ///   - mode: The media capture mode and limits (default: video and picture with unlimited counts)
    ///   - outputPath: The directory path for saved media (default: empty string)
    ///   - backResolution: Specific resolution for back camera (default: nil = auto-select)
    ///   - frontResolution: Specific resolution for front camera (default: nil = auto-select)
    public init(
        backResolution: TruvideoSdkCameraResolution? = nil,
        backResolutions: [TruvideoSdkCameraResolution] = [],
        flashMode: TruvideoSdkCameraFlashMode = .off,
        frontResolution: TruvideoSdkCameraResolution? = nil,
        frontResolutions: [TruvideoSdkCameraResolution] = [],
        imageFormat: TruvideoSdkCameraImageFormat = .jpeg,
        lensFacing: TruvideoSdkCameraLensFacing = .back,
        mode: TruvideoSdkCameraMediaMode = .videoAndPicture(),
        outputPath: String = ""
    ) {

        self.lensFacing = lensFacing
        self.flashMode = flashMode
        self.outputPath = outputPath
        self.mode = mode
        self.imageFormat = imageFormat
    }
}

/// An enumeration representing the camera lens orientation.
///
/// This enum defines the two possible camera lens orientations available
/// on iOS devices. It supports both Objective-C integration and JSON
/// serialization through Codable conformance, making it suitable for
/// cross-platform communication and persistent storage.
///
/// The enum uses string raw values for better readability and compatibility
/// with external systems, while maintaining type safety through the
/// RawRepresentable protocol. The string values are uppercase to follow
/// common API conventions.
@objc
public enum TruvideoSdkCameraLensFacing: Int, Codable, RawRepresentable {
    /// The back-facing camera lens.
    ///
    /// This case represents the primary camera lens located on the back
    /// of the device. The back camera typically has higher resolution
    /// and better image quality compared to the front camera, making
    /// it ideal for most photography and video capture scenarios.
    case back

    /// The front-facing camera lens.
    ///
    /// This case represents the camera lens located on the front of the
    /// device, typically used for selfies and video calls. The front
    /// camera is designed for close-up shots and face detection features.
    case front

    /// The raw type that can be used to represent all values of the conforming type.
    public typealias RawValue = String

    // MARK: - Computed Properties

    /// The corresponding value of the raw type.
    ///
    /// This property returns the string representation of the enum case.
    /// The raw values are uppercase strings that follow common API naming
    /// conventions and provide clear, human-readable representations.
    ///
    /// - Returns: The string raw value for the current enum case
    public var rawValue: RawValue {
        switch self {
        case .back:
            "BACK"

        case .front:
            "FRONT"
        }
    }

    // MARK: - Initializers

    /// Creates a lens position instance from an `AVCaptureDevice.Position`.
    ///
    /// This initializer converts an `AVCaptureDevice.Position` to the corresponding
    /// lens position value, mapping both `.back` and `.unspecified` positions to the
    /// back camera. It provides a safe conversion with a default fallback for unknown
    /// position values.
    ///
    /// - Parameter position: The `AVCaptureDevice.Position` to convert from
    init(position: AVCaptureDevice.Position) {
        switch position {
        case .back, .unspecified:
            self = .back

        case .front:
            self = .front

        @unknown default:
            self = .back
        }
    }

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer supports JSON deserialization by decoding the
    /// string raw value and converting it to the appropriate enum case.
    /// If the decoded string doesn't match any valid raw value, a
    /// DecodingError is thrown to indicate data corruption.
    ///
    /// - Parameter decoder: The decoder to read data from
    /// - Throws: DecodingError.dataCorrupted if the raw value is invalid
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)

        guard let lensFacing = TruvideoSdkCameraLensFacing(rawValue: rawValue) else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Invalid raw value for TruvideoSdkCameraLensFacing"
                )
            )
        }

        self = lensFacing
    }

    /// Creates a new instance with the specified raw value.
    ///
    /// This failable initializer creates an enum case from a string raw value.
    /// It returns nil if the provided string doesn't match any valid
    /// enum case, providing safe conversion from external string data.
    ///
    /// - Parameter rawValue: The string raw value to convert
    /// - Returns: The corresponding enum case, or nil if the raw value is invalid
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "BACK":
            self = .back

        case "FRONT":
            self = .front

        default:
            return nil
        }
    }

    // MARK: - Codable

    /// Encodes this value into the given encoder.
    ///
    /// This method supports JSON serialization by encoding the string
    /// raw value of the enum case. The encoded value can be used for
    /// storage, transmission, or cross-platform communication.
    ///
    /// - Parameter encoder: The encoder to write data to
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()

        try container.encode(rawValue)
    }
}

/// An enumeration representing the camera flash mode settings.
///
/// This enum defines the available flash modes for camera capture, providing
/// control over whether the camera flash is active during photo or video
/// capture. It supports both Objective-C integration and JSON serialization
/// through Codable conformance, making it suitable for configuration storage
/// and cross-platform communication.
///
/// The enum uses string raw values for better readability and API consistency,
/// with uppercase values following common naming conventions. The flash mode
/// setting affects the lighting conditions during capture and can significantly
/// impact image quality in low-light environments.
@objc
public enum TruvideoSdkCameraFlashMode: Int, Codable, RawRepresentable {
    /// Flash is disabled during capture.
    ///
    /// This case represents the flash being turned off, which is useful
    /// for natural lighting conditions or when additional lighting is
    /// not desired. This mode is often preferred for outdoor photography
    /// or when capturing subjects at a distance.
    case off

    // swiftlint:disable identifier_name
    /// Flash is enabled during capture.
    ///
    /// This case represents the flash being turned on, which provides
    /// additional lighting during capture. This mode is useful for
    /// low-light conditions, indoor photography, or when additional
    /// illumination is needed to properly expose the subject.
    case on
    // swiftlint:enable identifier_name

    /// The raw type that can be used to represent all values of the conforming type.
    public typealias RawValue = String

    // MARK: - Computed Properties

    /// The corresponding raw string value for the flash mode.
    ///
    /// - Returns: `"OFF"` for `.off` and `"ON"` for `.on`.
    public var rawValue: RawValue {
        switch self {
        case .off:
            "OFF"

        case .on:
            "ON"
        }
    }

    /// Converts the flash mode to the corresponding `AVCaptureDevice.FlashMode`.
    ///
    /// This computed property maps the current flash mode value to the equivalent
    /// `AVCaptureDevice.FlashMode` used by the camera system. It handles the
    /// conversion between the custom flash mode enumeration and the system's
    /// flash mode representation.
    var value: AVCaptureDevice.FlashMode {
        switch self {
        case .off:
            .off

        case .on:
            .on
        }
    }

    // MARK: - Initializers

    /// Creates a new `TruvideoSdkCameraFlashMode` instance with the specified raw value.
    ///
    /// - Parameter rawValue: The raw string value (`"OFF"` or `"ON"`) to initialize the flash mode.
    /// - Returns: A matching `TruvideoSdkCameraFlashMode` value if the raw value is valid, otherwise `nil`.
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "OFF":
            self = .off

        case "ON":
            self = .on

        default:
            return nil
        }
    }

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// - Parameter decoder: The decoder to read data from.
    /// - Throws: `DecodingError.dataCorrupted` if the raw value does not match a valid flash mode.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)

        guard let flashMode = TruvideoSdkCameraFlashMode(rawValue: rawValue) else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Invalid raw value for TruvideoSdkCameraFlashMode"
                )
            )
        }

        self = flashMode
    }

    // MARK: - Codable

    /// Encodes this flash mode into the given encoder.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()

        try container.encode(rawValue)
    }
}

/// An enumeration representing supported image formats for camera capture.
///
/// This enum defines the available image formats that can be used for
/// photo capture in the camera system. It provides a type-safe way to
/// specify image format preferences and ensures compatibility with
/// different use cases and quality requirements.
///
/// The enum uses string raw values for better readability and API
/// consistency, with uppercase values following common naming conventions.
/// Each format has distinct characteristics regarding compression,
/// quality, file size, and feature support.
@objc
public enum TruvideoSdkCameraImageFormat: Int, RawRepresentable {
    /// JPEG image format.
    ///
    /// Produces a **compressed image** with lossy compression,
    /// resulting in smaller file sizes while maintaining reasonable quality.
    case jpeg

    /// PNG image format.
    ///
    /// Produces a **lossless compressed image** with higher file size
    /// but exact preservation of quality, including transparency.
    case png

    /// The raw type that can be used to represent all values of the conforming type.
    public typealias RawValue = String

    // MARK: - Computed Properties

    /// The corresponding raw string value for the image format.
    ///
    /// - Returns: `"JPEG"` for `.jpeg` and `"PNG"` for `.png`.
    public var rawValue: RawValue {
        switch self {
        case .jpeg:
            "JPEG"

        case .png:
            "PNG"
        }
    }

    /// Converts the image format to the corresponding `FileFormat`.
    ///
    /// This computed property maps the current image format value to the equivalent
    /// `FileFormat` used by the file system. It handles the conversion between
    /// the custom image format enumeration and the system's file format
    /// representation.
    var value: FileFormat {
        switch self {
        case .jpeg:
            .jpeg

        case .png:
            .png
        }
    }

    // MARK: - Initializer

    /// Creates a new `TruvideoSdkCameraImageFormat` instance from the given raw value.
    ///
    /// - Parameter rawValue: The raw string value (`"JPEG"` or `"PNG"`) to initialize the format.
    /// - Returns: A matching `TruvideoSdkCameraImageFormat` value if the raw value is valid, otherwise `nil`.
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "JPEG":
            self = .jpeg

        case "PNG":
            self = .png

        default:
            return nil
        }
    }
}
