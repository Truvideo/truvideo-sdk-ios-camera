//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation
import UIKit

extension AVAsset {
    /// Determines whether the video content is mirrored based on its transform matrix.
    ///
    /// This function analyzes the video track's preferred transform to determine
    /// if the video content has been mirrored horizontally or vertically. It loads
    /// the video track and its transform matrix asynchronously, then examines the
    /// transform coefficients to detect mirroring transformations.
    ///
    /// The function checks for horizontal mirroring (transform.a == -1) or vertical
    /// mirroring (transform.d == -1) in the video's preferred transform matrix.
    /// This is commonly used to detect if a video was recorded with a front-facing
    /// camera, which typically applies mirroring to match user expectations.
    ///
    /// - Returns: `true` if the video is mirrored.
    /// - Throws: UtilityError if the video track or transform cannot be loaded.
    func isMirrored() async throws -> Bool {
        guard let preferredTransform = try await preferredTransform() else {
            return false
        }

        return preferredTransform.a == -1 || preferredTransform.d == -1
    }

    /// Generates a snapshot image from the video at the specified time.
    ///
    /// This method creates a `UIImage` from the video asset at the requested time
    /// using an `AVAssetImageGenerator`. The generator applies the preferred track
    /// transform to ensure the image is correctly oriented based on the video's
    /// capture orientation..
    ///
    /// - Parameters:
    ///    - requestedTime: The time at which the image of the asset is to be created.
    ///    - actualTime: A pointer to a CMTime to receive the time at which the image was actually generated.
    func snapshot(at requestedTime: CMTime, actualTime: UnsafeMutablePointer<CMTime>?) throws -> UIImage? {
        let imageGenerator = AVAssetImageGenerator(asset: self)
        imageGenerator.appliesPreferredTrackTransform = true

        let cgImage = try imageGenerator.copyCGImage(at: requestedTime, actualTime: actualTime)
        return UIImage(cgImage: cgImage)
    }

    /// Determines the device orientation from the video track's preferred transform.
    ///
    /// This method analyzes the video track's preferred transform matrix to determine
    /// the device orientation when the video was captured. It loads the video track
    /// asynchronously and examines the transform matrix values to map them to the
    /// corresponding device orientation.
    ///
    /// - Returns: The `UIDeviceOrientation` corresponding to the video's capture orientation
    /// - Throws: An error if the video track or transform cannot be loaded
    func orientation() async throws -> UIDeviceOrientation {
        guard let preferredTransform = try await preferredTransform() else {
            return .portrait
        }

        switch (preferredTransform.a, preferredTransform.b, preferredTransform.c, preferredTransform.d) {
        case (1, 0, 0, 1):
            return .landscapeRight

        case (-1, 0, 0, -1):
            return .landscapeLeft

        case (0, -1, 1, 0):
            return .portraitUpsideDown

        default:
            return .portrait
        }
    }

    /// Retrieves the preferred transform matrix from the video track.
    ///
    /// This method loads the video track from the asset and returns its preferred
    /// transform matrix, which contains information about the video's orientation
    /// and any transformations applied during capture. The transform matrix is
    /// used to determine how the video should be displayed and oriented.
    ///
    /// - Returns: The `CGAffineTransform` matrix from the video track, or `nil` if no video track exists
    /// - Throws: An error if the video track or transform cannot be loaded
    func preferredTransform() async throws -> CGAffineTransform? {
        let videoTrack = try await load(.tracks).first { $0.mediaType == .video }

        return try await videoTrack?.load(.preferredTransform)
    }
}
