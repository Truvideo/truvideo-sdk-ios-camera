//
//  TruVideoPhoto.swift
//
//  Created by TruVideo on 6/14/22.
//  Copyright © 2023 TruVideo. All rights reserved.
//

import UIKit

/// Represents a single video photo record
struct TruVideoPhoto {
    /// Unique identifier of this `TruVideoPhoto`
    let id: UUID = .init()

    /// Created timestamp
    let createdAt: Double = Date().timeIntervalSince1970

    /// File path
    var filePath: String {
        url.path
    }

    /// Media Type
    let type: TruvideoSdkCameraMediaType = .photo

    /// Lens Facing
    let lensFacing: TruvideoSdkCameraLensFacing

    /// Orientation angle
    let orientation: TruvideoSdkCameraOrientation

    /// Media Type
    let resolution: TruvideoSdkCameraResolutionDeprecated

    /// Metadata key for setting the device orientation when the
    /// photo was taken
    static let DeviceOrientationKey = "DeviceOrientation"

    /// Cropped image
    var croppedImage: UIImage? {
        guard let croppedImageData = croppedImageData else {
            return nil
        }

        return .init(data: croppedImageData)
    }

    /// Raw data for the cropped image
    let croppedImageData: Data?

    /// UI Image from the raw data
    var image: UIImage? {
        guard let imageData = imageData else {
            return nil
        }

        return .init(data: imageData)
    }

    /// Raw data for the image
    let imageData: Data?

    /// Metadata dictionary from the provided sample buffer
    let metadata: [String: Any]

    let url: URL

    let captureImage: UIImage

    // MARK: Initializers

    /// Initialize a new clip instance.
    ///
    /// - Parameters:
    ///   - imageData: Raw data for the image
    ///   - croppedImageData: Raw data for the cropped image
    ///   - metadata: Metadata dictionary from the provided sample buffer
    init(
        imageData: Data,
        croppedImageData: Data,
        metadata: [String: Any],
        url: URL,
        lensFacing: TruvideoSdkCameraLensFacing,
        orientation: TruvideoSdkCameraOrientation,
        resolution: TruvideoSdkCameraResolutionDeprecated,
        captureImage: UIImage
    ) {
        self.imageData = imageData
        self.croppedImageData = croppedImageData
        self.metadata = metadata
        self.url = url
        self.lensFacing = lensFacing
        self.orientation = orientation
        self.resolution = resolution
        self.captureImage = captureImage
    }

    var mediaRepresentation: TruvideoSdkCameraMedia {
        TruvideoSdkCameraMedia(
            createdAt: createdAt,
            duration: 0,
            filePath: filePath,
            lensFacing: lensFacing,
            orientation: orientation,
            resolution: TruvideoSdkCameraResolution.from(resolution),
            type: type
        )
    }

}

extension TruVideoPhoto: Hashable {

    // MARK: Hashable

    /// Returns a Boolean value indicating whether two values are equal.
    static func == (lhs: TruVideoPhoto, rhs: TruVideoPhoto) -> Bool {
        lhs.croppedImageData == rhs.croppedImageData && lhs.imageData == rhs.imageData
    }

    /// Hashes the essential components of this value by feeding them into the
    /// given hasher.
    func hash(into hasher: inout Hasher) {
        croppedImageData.hash(into: &hasher)
        imageData.hash(into: &hasher)
    }
}

extension TruvideoSdkCameraResolution {
    static func from(_ resolution: TruvideoSdkCameraResolutionDeprecated) -> TruvideoSdkCameraResolution {
        switch (resolution.width, resolution.height) {
        case (640, 480):
            .sd640x480

        case (1920, 1080):
            .hd1920x1080

        default:
            .hd1280x720
        }
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
public class TruvideoSdkCameraResolutionDeprecated: NSObject, Codable {
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
