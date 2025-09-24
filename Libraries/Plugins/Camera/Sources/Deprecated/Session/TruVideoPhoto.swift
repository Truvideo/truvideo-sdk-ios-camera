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
    let resolution: TruvideoSdkCameraResolution

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
        resolution: TruvideoSdkCameraResolution,
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
            preset: .hd1280x720,
            resolution: resolution,
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
