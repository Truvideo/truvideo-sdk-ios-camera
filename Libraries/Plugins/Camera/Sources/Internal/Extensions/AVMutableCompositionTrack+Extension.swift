//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation

extension AVMutableCompositionTrack {
    /// Appends an asset track to the current composition track at a specified time.
    ///
    /// This method adds the content of an AVAssetTrack to the current composition track,
    /// starting at the specified time position. The method calculates the correct
    /// insertion time by adding the track's start time offset to the provided start time,
    /// ensuring proper alignment with the track's original timing.
    ///
    /// The method only performs the insertion if the track has a valid duration greater
    /// than zero, preventing attempts to insert empty or invalid time ranges. This
    /// provides a safe way to append track content without causing composition errors.
    ///
    /// The appended track maintains its original timing characteristics and is inserted
    /// seamlessly into the composition track, allowing for proper sequential playback
    /// of concatenated media content.
    ///
    /// - Parameters:
    ///   - track: The AVAssetTrack to be appended to the composition track
    ///   - startTime: The time position in the composition where the track should be inserted
    /// - Throws: An error if the time range insertion fails or if the track is invalid
    func append(_ track: AVAssetTrack, at startTime: CMTime) throws {
        let timeRange = track.timeRange
        let startTime = startTime + timeRange.start

        if timeRange.duration > .zero {
            try insertTimeRange(timeRange, of: track, at: startTime)
        }
    }
}
