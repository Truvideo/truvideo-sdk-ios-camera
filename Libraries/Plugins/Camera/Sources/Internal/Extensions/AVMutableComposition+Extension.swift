//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation

extension AVMutableComposition {
    /// Creates a mutable composition by concatenating multiple AVAssets.
    ///
    /// This static function combines multiple AVAssets into a single AVMutableComposition
    /// by concatenating their video and audio tracks sequentially. The function creates
    /// one video track and one audio track in the composition, then appends each asset's
    /// content to these tracks in the order they appear in the input array.
    ///
    /// The function maintains the original timing and transform properties of each asset
    /// while creating a seamless concatenated result. Video tracks preserve their
    /// preferred transform (orientation, scaling, etc.) from the first asset, while
    /// audio tracks are appended without modification.
    ///
    /// Each asset's content is added at the current time position, which is incremented
    /// by the duration of each asset to ensure proper sequential playback without overlap.
    ///
    /// - Parameter assets: An array of AVAssets to be concatenated into a single composition
    /// - Returns: An AVMutableComposition containing all assets concatenated sequentially
    /// - Throws: An error if track loading or appending operations fail
    static func from(_ assets: [AVAsset]) async throws -> AVMutableComposition {
        var currentTime = CMTime.zero
        let mutableComposition = AVMutableComposition()
        var audioTrack: AVMutableCompositionTrack?
        var videoTrack: AVMutableCompositionTrack?

        for asset in assets {
            let audioAssetTracks = try await asset.loadTracks(withMediaType: .audio)
            let videoAssetTracks = try await asset.loadTracks(withMediaType: .video)

            for assetTrack in videoAssetTracks {
                if videoTrack == nil {
                    videoTrack = mutableComposition.addMutableTrack(
                        withMediaType: .video,
                        preferredTrackID: kCMPersistentTrackID_Invalid
                    )

                    videoTrack?.preferredTransform = try await assetTrack.load(.preferredTransform)
                }

                try videoTrack?.append(assetTrack, at: currentTime)
            }

            for assetTrack in audioAssetTracks {
                if audioTrack == nil {
                    audioTrack = mutableComposition.addMutableTrack(
                        withMediaType: .audio,
                        preferredTrackID: kCMPersistentTrackID_Invalid
                    )
                }

                try audioTrack?.append(assetTrack, at: currentTime)
            }

            currentTime = CMTimeAdd(currentTime, asset.duration)
        }

        return mutableComposition
    }
}
