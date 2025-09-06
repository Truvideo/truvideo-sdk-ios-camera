//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation

extension AVMutableVideoComposition {
    /// Creates a mutable video composition by layering multiple AVAssets sequentially.
    ///
    /// This static function combines multiple AVAssets into a single AVMutableVideoComposition
    /// by creating layer instructions for each video track. The function processes each asset
    /// sequentially, creating composition layer instructions that define how each video
    /// track should be rendered and positioned in time.
    ///
    /// The composition uses a 24fps frame rate and automatically calculates the target
    /// render size based on the largest video dimensions (by area) among all assets.
    /// Each video track is positioned at its respective time offset, with the last asset
    /// fading out at the end of its duration to create a smooth transition.
    ///
    /// The function creates a single main instruction that spans the entire duration
    /// of all assets combined, with layer instructions for each video track positioned
    /// at their appropriate time positions. This allows for proper sequential playback
    /// of multiple video assets in a single composition.
    ///
    /// - Parameter assets: An array of AVAssets to be combined into a video composition
    /// - Returns: An AVMutableVideoComposition with layered video tracks
    /// - Throws: An error if track loading or composition creation fails
    static func from(_ assets: [AVAsset]) async throws -> AVMutableVideoComposition {
        var currentTime = CMTime.zero
        var layerInstructions: [AVVideoCompositionLayerInstruction] = []
        let mainInstruction = AVMutableVideoCompositionInstruction()
        let mutableVideoComposition = AVMutableVideoComposition()
        var targetSize = CGSize.zero

        mutableVideoComposition.frameDuration = CMTime(value: 1, timescale: 30)

        for (index, asset) in assets.enumerated() {
            let videoAssetTracks = try await asset.loadTracks(withMediaType: .video)

            for assetTrack in videoAssetTracks {
                let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: assetTrack)
                let preferredTransform = try await assetTrack.load(.preferredTransform)
                let videoSize = try await assetTrack.load(.naturalSize).applying(preferredTransform)

                if index == assets.count - 1 {
                    instruction.setOpacity(0, at: currentTime + asset.duration)
                }

                instruction.setTransform(preferredTransform, at: currentTime)
                layerInstructions.append(instruction)

                targetSize.height = max(targetSize.height, videoSize.height)
                targetSize.width = max(targetSize.width, videoSize.width)
            }

            currentTime = CMTimeAdd(currentTime, asset.duration)
        }

        mainInstruction.layerInstructions = layerInstructions
        mainInstruction.timeRange = CMTimeRange(start: .zero, duration: currentTime)

        mutableVideoComposition.instructions = [mainInstruction]
        mutableVideoComposition.renderSize = targetSize

        return mutableVideoComposition
    }
}
