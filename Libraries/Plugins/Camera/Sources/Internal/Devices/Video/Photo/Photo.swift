//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit

/// A model representing a captured photo with metadata and lazy-loaded image data.
///
/// This class encapsulates a photo captured by the camera system, storing both
/// the file location and associated metadata such as creation time, format,
/// orientation, and lens position. The actual image data is loaded lazily to
/// optimize memory usage and performance.
///
/// The photo provides access to the underlying image through a lazy property
/// that loads the image data from the file URL when first accessed, making it
/// efficient for displaying thumbnails or full-size images as needed.
struct Photo {
    /// The timestamp when the photo was captured.
    ///
    /// This value represents the time interval since the Unix epoch (January 1, 1970)
    /// when the photo was taken. It's used for sorting, filtering, and displaying
    /// photos in chronological order.
    let createdAt: TimeInterval

    /// The file format of the captured photo.
    ///
    /// This property specifies the image format used for the photo, such as JPEG,
    /// PNG, or other supported formats. It's used for proper image processing
    /// and display.
    let format: FileFormat

    /// The camera lens position used for capture.
    ///
    /// This property specifies which camera lens was used to capture the photo,
    /// such as front-facing or back-facing camera. It's useful for determining
    /// the photo's context and applying appropriate processing.
    let lensPosition: AVCaptureDevice.Position

    /// The device orientation when the photo was captured.
    ///
    /// This value indicates how the device was oriented when the photo was taken,
    /// which is important for proper image display and rotation handling.
    let orientation: UIDeviceOrientation

    /// The capture session preset used when recording this video clip.
    ///
    /// This property stores the `AVCaptureSession.Preset` that was active during
    /// the recording of this video clip. It preserves the resolution and quality
    /// settings that were used at the time of capture, which is important for:
    let preset: AVCaptureSession.Preset

    /// The URL of the thumbnail image representing this photo.
    ///
    /// This property provides a reference to a preview-sized image used for
    /// displaying the photo in lists, grids, or galleries. The thumbnail is
    /// optimized for quick loading and reduced memory usage compared to
    /// loading the full-resolution photo.
    let thumbnailURL: URL

    /// The file URL where the photo is stored.
    ///
    /// This property provides the location of the photo file on the device's
    /// file system. It's used for loading the image data and managing file
    /// operations.
    let url: URL

    // MARK: - Initializer

    /// Creates a new photo instance with the specified metadata and file location.
    ///
    /// - Parameters:
    ///   - url: The file URL where the full-resolution photo is stored
    ///   - thumbnailURL: The file URL of the thumbnail image representing the photo
    ///   - format: The file format of the captured photo
    ///   - lensPosition: The camera lens position used for capture
    ///   - orientation: The device orientation when the photo was captured
    ///   - preset: The capture session preset used when recording this video clip.
    ///   - createdAt: The timestamp when the photo was captured (defaults to current time)
    init(
        url: URL,
        thumbnailURL: URL,
        format: FileFormat,
        lensPosition: AVCaptureDevice.Position,
        orientation: UIDeviceOrientation,
        preset: AVCaptureSession.Preset,
        createdAt: TimeInterval = Date().timeIntervalSince1970
    ) {
        self.createdAt = createdAt
        self.format = format
        self.lensPosition = lensPosition
        self.orientation = orientation
        self.preset = preset
        self.thumbnailURL = thumbnailURL
        self.url = url
    }
}

extension Photo: Equatable {
    // MARK: - Hashable

    /// Returns a Boolean value indicating whether two values are equal.
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        lhs.url == rhs.url
    }
}
