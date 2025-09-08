//
// Created by TruVideo on 3/6/23.
// Copyright © 2023 TruVideo. All rights reserved.
//

import Foundation

/// Represents a camera device available on the system.
///
/// `TruvideoSdkCameraDevice` provides details about a specific camera, including its **ID, lens direction, supported resolutions, flash availability, and sensor orientation**.
///
/// ## Example Usage
///
/// ```swift
/// let backCamera = TruvideoSdkCameraDevice(
///     id: "com.truvideo.backcamera",
///     lensFacing: .back,
///     resolutions: [TruvideoSdkCameraResolution(width: 1920, height: 1080)],
///     withFlash: true,
///     isTapToFocusEnabled: true,
///     sensorOrientation: 90
/// )
/// ```
@objc public class TruvideoSdkCameraDevice: NSObject, Encodable {
    /// The unique identifier of the camera device.
    @objc public let id: String

    /// The lens direction of the camera.
    ///
    /// Specifies whether the camera is **front-facing** or **back-facing**.
    @objc public let lensFacing: TruvideoSdkCameraLensFacing

    /// The list of supported resolutions for this camera device.
    ///
    /// Each resolution represents a width-height pair that defines the camera's image capture capabilities.
    @objc public let resolutions: [TruvideoSdkCameraResolution]

    /// Indicates whether the camera device has a built-in flash.
    @objc public let withFlash: Bool

    /// Indicates whether the camera supports tap-to-focus functionality.
    @objc public let isTapToFocusEnabled: Bool

    /// The sensor orientation of the camera, in degrees.
    ///
    /// Represents the natural orientation of the camera sensor relative to the device's display.
    @objc public let sensorOrientation: Int

    /// Initializes a new `TruvideoSdkCameraDevice` instance.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the camera.
    ///   - lensFacing: The lens direction (`.front` or `.back`).
    ///   - resolutions: A list of supported resolutions.
    ///   - withFlash: Indicates if the camera has a built-in flash.
    ///   - isTapToFocusEnabled: Determines if the camera supports tap-to-focus.
    ///   - sensorOrientation: The orientation of the camera sensor.
    init(
        id: String,
        lensFacing: TruvideoSdkCameraLensFacing,
        resolutions: [TruvideoSdkCameraResolution],
        withFlash: Bool,
        isTapToFocusEnabled: Bool,
        sensorOrientation: Int
    ) {

        self.id = id
        self.lensFacing = lensFacing
        self.resolutions = resolutions
        self.withFlash = withFlash
        self.isTapToFocusEnabled = isTapToFocusEnabled
        self.sensorOrientation = sensorOrientation
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        switch lensFacing {
        case .back:
            try container.encode("BACK", forKey: .lensFacing)
        case .front:
            try container.encode("FRONT", forKey: .lensFacing)
        }
        try container.encode(resolutions, forKey: .resolutions)
        try container.encode(withFlash, forKey: .withFlash)
        try container.encode(isTapToFocusEnabled, forKey: .isTapToFocusEnabled)
        try container.encode(sensorOrientation, forKey: .sensorOrientation)
    }

    /// Defines the keys used for encoding.
    private enum CodingKeys: String, CodingKey {
        case id
        case lensFacing
        case resolutions
        case withFlash
        case isTapToFocusEnabled
        case sensorOrientation
    }
}

/// Provides detailed information about available camera devices.
///
/// `TruvideoSdkCameraInformation` contains references to the **front-facing** and **back-facing** cameras available on the device.
///
/// ## Example Usage
///
/// ```swift
/// let cameraInfo = TruvideoSdkCameraInformation(frontCamera: frontDevice, backCamera: backDevice)
/// print("Front Camera ID: \(cameraInfo.frontCamera?.id ?? "N/A")")
/// ```
@objc public class TruvideoSdkCameraInformation: NSObject, Encodable {

    /// The front-facing camera device, if available.
    @objc public let frontCamera: TruvideoSdkCameraDevice?

    /// The back-facing camera device, if available.
    @objc public let backCamera: TruvideoSdkCameraDevice?

    /// Initializes a new `TruvideoSdkCameraInformation` instance.
    ///
    /// - Parameters:
    ///   - frontCamera: The front-facing camera device.
    ///   - backCamera: The back-facing camera device.
    init(frontCamera: TruvideoSdkCameraDevice?, backCamera: TruvideoSdkCameraDevice?) {
        self.frontCamera = frontCamera
        self.backCamera = backCamera
    }
}
