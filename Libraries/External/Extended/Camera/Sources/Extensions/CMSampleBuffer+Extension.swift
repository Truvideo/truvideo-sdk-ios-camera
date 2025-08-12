//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation

extension CMSampleBuffer {
    /// Returns a copy of the sample buffer with its timestamps offset by the given time.
    ///
    /// Extracts the buffer’s timing entries, subtracts `time` from both the decode and presentation
    /// timestamps for each sample, and optionally overrides each sample’s `duration`. The underlying
    /// media data and format description are preserved; only timing metadata is changed. If timing
    /// information cannot be read, `nil` is returned.
    ///
    /// - Parameters:
    ///   - time: The offset to subtract from each sample’s decode and presentation timestamps.
    ///   - duration: An optional duration to assign to each sample. When `nil`, existing durations are preserved.
    /// - Returns: A new `CMSampleBuffer` with adjusted timing, or `nil` if timing adjustment fails.
    func offset(by time: CMTime, duration: CMTime? = nil) -> CMSampleBuffer? {
        var itemCount: CMItemCount = 0
        var status = CMSampleBufferGetSampleTimingInfoArray(
            self,
            entryCount: 0,
            arrayToFill: nil,
            entriesNeededOut: &itemCount
        )

        guard status == 0 else { return nil }

        var timingInfo = [CMSampleTimingInfo](
            repeating: CMSampleTimingInfo(
                duration: CMTimeMake(value: 0, timescale: 0),
                presentationTimeStamp: CMTimeMake(value: 0, timescale: 0),
                decodeTimeStamp: CMTimeMake(value: 0, timescale: 0)
            ),
            count: itemCount
        )

        status = CMSampleBufferGetSampleTimingInfoArray(
            self,
            entryCount: itemCount,
            arrayToFill: &timingInfo,
            entriesNeededOut: &itemCount
        )

        guard status == 0 else { return nil }

        for index in 0 ..< itemCount {
            timingInfo[index].decodeTimeStamp = CMTimeSubtract(timingInfo[index].decodeTimeStamp, time)
            timingInfo[index].presentationTimeStamp = CMTimeSubtract(timingInfo[index].presentationTimeStamp, time)

            if let duration {
                timingInfo[index].duration = duration
            }
        }

        var sampleBufferOffset: CMSampleBuffer?
        CMSampleBufferCreateCopyWithNewTiming(
            allocator: kCFAllocatorDefault,
            sampleBuffer: self,
            sampleTimingEntryCount: itemCount,
            sampleTimingArray: &timingInfo,
            sampleBufferOut: &sampleBufferOffset
        )

        return sampleBufferOffset
    }
}
