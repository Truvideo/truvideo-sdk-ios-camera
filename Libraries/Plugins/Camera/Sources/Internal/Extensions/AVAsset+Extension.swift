//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation

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
    /// - Throws: UtilityError with `.MovieOutputProcessorErrorReason.failedToLoadAssetAttribute` kind
    ///           if the video track or transform cannot be loaded, including the underlying error.
    func isMirrored() async throws -> Bool {
        guard let videoTrack = try await load(.tracks).first(where: { $0.mediaType == .video }) else {
            return false
        }

        let preferredTransform = try await videoTrack.load(.preferredTransform)
        return preferredTransform.a == -1 || preferredTransform.d == -1
    }
}
