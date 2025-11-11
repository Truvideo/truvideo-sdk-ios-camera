//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation
import AVKit
import Foundation
import UIKit
internal import Utilities

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
    /// The selected resolution for the back-facing camera.
    ///
    /// This property determines the default capture resolution when using
    /// the back camera. It should correspond to one of the values available
    /// in `backResolutions`.
    public let backResolution: TruvideoSdkCameraResolution

    /// The list of available resolution presets for the back-facing camera.
    ///
    /// This array contains all supported resolution options for the device’s
    /// back camera. Use this to populate selection menus or validate a chosen preset.
    public let backResolutions: [TruvideoSdkCameraResolution]

    /// The flash mode setting for the camera.
    ///
    /// This property determines how the camera flash behaves during capture.
    /// Options include off, on, auto, and other flash modes depending on
    /// device capabilities and lighting conditions.
    public let flashMode: TruvideoSdkCameraFlashMode

    /// The selected resolution for the front-facing camera.
    ///
    /// This property determines the default capture resolution when using
    /// the front camera. It should correspond to one of the values available
    /// in `frontResolutions`.
    public let frontResolution: TruvideoSdkCameraResolution

    /// The list of available resolution presets for the front-facing camera.
    ///
    /// This array contains all supported resolution options for the device’s
    /// front camera. Use this to populate selection menus or validate a chosen preset.
    public let frontResolutions: [TruvideoSdkCameraResolution]

    /// The image format for captured photos.
    ///
    /// This property specifies the file format used for saving captured
    /// images. Common formats include JPEG, PNG, and HEIC. The format
    /// affects file size, quality, and compatibility with different systems.
    public let imageFormat: TruvideoSdkCameraImageFormat

    /// Indicates whether high-resolution photo capture is enabled.
    ///
    /// When enabled, the camera will capture photos at the highest
    /// available resolution for the selected camera lens. This may
    /// impact performance and file size but provides maximum image quality.
    public let isHighResolutionPhotoEnabled = false

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

    /// The interface orientation for the camera experience.
    ///
    /// This property determines the preferred screen orientation
    /// during the camera session (for example, portrait or landscape).
    /// It controls how the camera preview and interface are displayed
    /// to match the intended capture orientation.
    ///
    /// When set to a specific orientation (such as `.landscapeLeft`),
    /// the camera interface will attempt to lock to that mode.
    /// If set to `.all`, the camera supports all device orientations
    /// and adapts automatically based on the user's device rotation.
    public let orientation: TruvideoSdkCameraOrientation?

    /// The directory path where captured media will be saved.
    ///
    /// This property specifies the file system location where
    /// captured pictures and videos will be stored. The path
    /// should be writable and accessible by the application.
    public let outputPath: String

    // MARK: - Initializer

    /// Creates a new camera configuration with essential settings.
    ///
    /// This initializer provides a simplified way to configure the camera with the most
    /// commonly used settings. It offers sensible defaults for all parameters while still
    /// allowing customization when needed. This is the recommended initializer for most
    /// use cases as it focuses on the core camera functionality without the complexity
    /// of resolution-specific configurations.
    ///
    /// ## Usage Examples
    ///
    /// ```swift
    /// // Basic configuration with defaults
    /// let config = TruvideoSdkCameraConfiguration()
    ///
    /// // Custom flash and lens settings
    /// let config = TruvideoSdkCameraConfiguration(
    ///     flashMode: .auto,
    ///     lensFacing: .front
    /// )
    ///
    /// // Photo-only mode with specific format
    /// let config = TruvideoSdkCameraConfiguration(
    ///     imageFormat: .heic,
    ///     mode: .pictureOnly(maxCount: 10)
    /// )
    ///
    /// // Video-only mode with custom output path
    /// let config = TruvideoSdkCameraConfiguration(
    ///     mode: .videoOnly(maxDuration: 60),
    ///     outputPath: "/Documents/Videos"
    /// )
    /// ```
    ///
    /// ## Parameter Details
    ///
    /// - **Flash Mode**: Controls camera flash behavior during capture
    /// - **Image Format**: Determines the file format for captured photos
    /// - **Lens Facing**: Specifies which camera (front or back) to use
    /// - **Media Mode**: Defines what can be captured and any limits
    /// - **Output Path**: Sets where captured media will be saved
    ///
    /// - Parameters:
    ///   - backResolution: The default capture resolution for the back-facing camera.
    ///   - backResolutions: The list of available resolution presets for the back-facing camera.
    ///   - flashMode: The flash mode setting for photo capture (default: `.off`)
    ///   - frontResolution: The default capture resolution for the front-facing camera.
    ///   - frontResolutions: The list of available resolution presets for the front-facing camera.
    ///   - imageFormat: The file format for captured images (default: `.jpeg`)
    ///   - lensFacing: The camera lens to use for capture (default: `.back`)
    ///   - mode: The media capture mode and limits (default: `.videoAndPicture()`)
    ///   - orientation: The interface orientation for the camera experience.
    ///   - outputPath: The directory path for saved media (default: `""`)
    public init(
        backResolution: TruvideoSdkCameraResolution = .hd1280x720,
        backResolutions: [TruvideoSdkCameraResolution] = TruvideoSdkCameraResolution.allCases,
        flashMode: TruvideoSdkCameraFlashMode = .off,
        frontResolution: TruvideoSdkCameraResolution = .hd1280x720,
        frontResolutions: [TruvideoSdkCameraResolution] = TruvideoSdkCameraResolution.allCases,
        imageFormat: TruvideoSdkCameraImageFormat = .jpeg,
        lensFacing: TruvideoSdkCameraLensFacing = .back,
        mode: TruvideoSdkCameraMediaMode = .videoAndPicture(),
        orientation: TruvideoSdkCameraOrientation? = nil,
        outputPath: String = ""
    ) {
        self.backResolution = backResolution
        self.backResolutions = backResolutions
        self.flashMode = flashMode
        self.frontResolution = frontResolution
        self.frontResolutions = frontResolutions
        self.imageFormat = imageFormat
        self.lensFacing = lensFacing
        self.mode = mode
        self.orientation = orientation
        self.outputPath = outputPath
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

    /// The raw type that can be used to represent all values of the conforming type.
    public typealias RawValue = String

    // MARK: - Computed Properties

    /// Converts the SDK-defined camera orientation to the equivalent
    /// `UIDeviceOrientation` value used by the system.
    ///
    /// This property provides a convenient way to align the camera’s
    /// configuration orientation (`TruvideoSdkCameraOrientation`)
    /// with the physical orientation of the device reported by `UIDevice`.
    /// It is especially useful when applying orientation-dependent logic,
    /// such as adjusting the camera preview or synchronizing rotation
    /// with hardware sensors.
    var deviceOrientation: UIDeviceOrientation {
        switch self {
        case .landscapeLeft:
            .landscapeLeft

        case .landscapeRight:
            .landscapeRight

        case .portrait:
            .portrait
        }
    }

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

/// Represents video quality presets for camera recording with predefined resolutions and aspect ratios.
///
/// `TruvideoSdkCameraPreset` defines the available video recording quality levels supported by the
/// TruVideo SDK camera functionality. Each preset corresponds to a specific resolution and provides
/// direct mapping to AVFoundation's capture session presets for seamless integration with
/// `AVCaptureSession` configuration.
///
/// ## Supported Presets
///
/// The class provides three predefined video quality options:
/// - **Standard Definition** (`.sd640x480`): 640×480 resolution with 4:3 aspect ratio
/// - **High Definition** (`.hd1280x720`): 1280×720 resolution with 16:9 aspect ratio
/// - **Full High Definition** (`.hd1920x1080`): 1920×1080 resolution with 16:9 aspect ratio
///
/// ## Usage
///
/// ```swift
/// // Create a preset instance
/// let preset = TruvideoSdkCameraPreset.hd1920x1080
///
/// // Configure capture session
/// captureSession.sessionPreset = preset.preset
///
/// // Check available presets
/// for preset in TruvideoSdkCameraPreset.allCases {
///     print("Available: \(preset.rawValue)")
/// }
/// ```
///
/// ## Protocol Conformance
///
/// - `RawRepresentable`: Provides string-based raw value representation
/// - `CaseIterable`: Enables iteration over all available presets
/// - `Encodable`: Supports JSON serialization for configuration storage
/// - `Hashable`: Enables use in collections and dictionary keys
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
/// - Note: The default fallback preset is `.hd1280x720` when invalid raw values are provided.
/// - Important: Always validate preset compatibility using `canSetSessionPreset(_:)` before applying to capture
/// sessions.
@objcMembers
public final class TruvideoSdkCameraResolution: RawRepresentable, CaseIterable, Codable, Hashable {
    // MARK: - Properties

    /// The raw type that can be used to represent all values of the conforming
    /// type.
    public let rawValue: String

    // MARK: - Computed Properties

    /// Maps the camera preset to its corresponding `AVCaptureSession.Preset` value.
    ///
    /// This computed property provides a bridge between the custom `TruvideoSdkCameraPreset`
    /// types and the native `AVCaptureSession.Preset` values required by AVFoundation.
    /// It ensures that each custom preset is correctly mapped to the appropriate
    /// capture session configuration for video recording.
    ///
    /// ## Mapping Details
    ///
    /// The property maps custom presets to AVFoundation presets as follows:
    /// - `.sd640x480` → `.vga640x480` (640×480, 4:3 aspect ratio)
    /// - `.hd1920x1080` → `.hd1920x1080` (1920×1080, 16:9 aspect ratio)
    /// - `.hd1280x720` → `.hd1280x720` (1280×720, 16:9 aspect ratio, default)
    ///
    /// ## Usage
    ///
    /// This property is typically used when configuring an `AVCaptureSession` to
    /// set the appropriate session preset based on the selected video quality:
    ///
    /// ```swift
    /// let cameraPreset = TruvideoSdkCameraPreset.hd1920x1080
    /// captureSession.sessionPreset = cameraPreset.preset
    /// ```
    var preset: AVCaptureSession.Preset {
        switch self {
        case .sd640x480:
            .vga640x480

        case .hd1920x1080:
            .hd1920x1080

        default:
            .hd1280x720
        }
    }

    // MARK: - Static Properties

    /// All available preset types.
    public static let allCases: [TruvideoSdkCameraResolution] = [.sd640x480, .hd1280x720, .hd1920x1080]

    /// Standard Definition video preset with 640x480 resolution.
    ///
    /// This preset provides the lowest quality option with 4:3 aspect ratio,
    /// suitable for basic recording or when storage space is limited.
    public static let sd640x480 = TruvideoSdkCameraResolution(rawValue: "sd640x480")

    /// High Definition video preset with 1280x720 resolution.
    ///
    /// This preset offers a good balance between quality and file size,
    /// providing HD quality with 16:9 aspect ratio.
    public static let hd1280x720 = TruvideoSdkCameraResolution(rawValue: "hd1280x720")

    /// Full High Definition video preset with 1920x1080 resolution.
    ///
    /// This preset provides the highest quality option with full HD resolution
    /// and 16:9 aspect ratio, ideal for high-quality video recording.
    public static let hd1920x1080 = TruvideoSdkCameraResolution(rawValue: "hd1920x1080")

    // MARK: - Types

    /// Allowable keys for the model
    enum CodingKeys: String, CodingKey {
        case rawValue
    }

    // MARK: - Static Properties

    /// Converts an `AVCaptureSession.Preset` to its corresponding `TruvideoSdkCameraPreset`.
    ///
    /// This static method provides a bridge from native AVFoundation presets to the custom
    /// `TruvideoSdkCameraPreset` types used by the TruVideo SDK. It ensures proper mapping
    /// between the two preset systems and handles unsupported presets with a sensible default.
    ///
    /// - Parameter preset: The `AVCaptureSession.Preset` to convert
    /// - Returns: The corresponding `TruvideoSdkCameraPreset`, or `.hd1280x720` as default
    static func from(_ preset: AVCaptureSession.Preset) -> TruvideoSdkCameraResolution {
        switch preset {
        case .vga640x480:
            .sd640x480

        case .hd1920x1080:
            .hd1920x1080

        default:
            .hd1280x720
        }
    }

    // MARK: - Initializers

    /// Creates a new preset type with the specified raw value.
    ///
    /// - Parameter rawValue: The string value of the preset.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.rawValue = try container.decode(String.self, forKey: .rawValue)
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
