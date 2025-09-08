//
//  TruvideoSdkARCameraConfiguration.swift
//  TruvideoSdkCamera
//
//  Created by Luis Francisco Piura Mejia on 21/8/24.
//

import Foundation

/// A configuration object for setting up the AR Camera in `TruvideoSdkCamera`.
///
/// `TruvideoSdkARCameraConfiguration` allows you to customize the AR Camera’s behavior, including flash settings, capture mode,
/// and camera orientation.
///
/// ## Example Usage
///
/// ```swift
/// let arConfig = TruvideoSdkARCameraConfiguration(
///     flashMode: .auto,
///     mode: .videoAndPicture(videoMaxCount: 3, pictureMaxCount: 5, durationLimit: 15),
///     orientation: .portrait
/// )
/// ```
///
/// This configuration can be passed to `presentTruvideoSdkARCameraView` to launch the AR Camera with the specified settings.
///
/// ## See Also
/// - ``TruvideoSdkCameraFlashMode``
/// - ``TruvideoSdkCameraMediaMode``
/// - ``TruvideoSdkCameraOrientation``
@objc public class TruvideoSdkARCameraConfiguration: NSObject {

    /// The flash mode setting for the AR Camera.
    ///
    /// Determines whether the flash is on, off, or set to auto mode.
    @objc public let flashMode: TruvideoSdkCameraFlashMode

    /// The media capture mode for the AR Camera.
    ///
    /// Defines whether the camera captures photos, videos, or both.
    @objc public let mode: TruvideoSdkCameraMediaMode

    /// The camera orientation used when capturing AR content.
    ///
    /// Determines whether the camera operates in portrait or landscape mode.
    @objc public let orientation: TruvideoSdkCameraOrientation

    /// Creates a new instance of `TruvideoSdkARCameraConfiguration` with customizable settings.
    ///
    /// - Parameters:
    ///   - flashMode: The desired flash setting (default: `.off`).
    ///   - mode: The media capture mode (default: `.videoAndPicture()`).
    ///   - orientation: The camera's orientation (default: device's current orientation).
    public init(
        flashMode: TruvideoSdkCameraFlashMode = .off,
        mode: TruvideoSdkCameraMediaMode = .videoAndPicture(),
        orientation: TruvideoSdkCameraOrientation? = nil
    ) {
        self.flashMode = flashMode
        self.mode = mode
        self.orientation = orientation ?? .portrait
    }

    /// Instantiates a new `TruvideoSdkARCameraConfiguration` using static method syntax.
    ///
    /// This provides a convenient way to create configurations without directly initializing an instance.
    ///
    /// - Parameters:
    ///   - flashMode: The desired flash setting (default: `.off`).
    ///   - orientation: The camera's orientation.
    ///   - mode: The media capture mode (default: `.videoAndPicture()`).
    /// - Returns: A new `TruvideoSdkARCameraConfiguration` instance.
    @objc public static func instantiate(
        with flashMode: TruvideoSdkCameraFlashMode = .off,
        orientation: TruvideoSdkCameraOrientation,
        mode: TruvideoSdkCameraMediaMode = .videoAndPicture()
    ) -> TruvideoSdkARCameraConfiguration {
        .init(flashMode: flashMode, mode: mode, orientation: orientation)
    }
}
