//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation
import Foundation

/// A lightweight wrapper that couples a video `CMSampleBuffer` with its presentation timestamp.
///
/// Use this type to pass samples through processing pipelines with an explicit, immutable
/// timestamp, avoiding repeated queries to the buffer’s timing info. The underlying buffer
/// is not copied; this struct only stores a reference.
struct VideoSampleBuffer {
    // MARK: - Properties

    /// The average video bit rate (bits per second).
    let bitRate: Int

    /// Indicates whether the video frame should be horizontally mirrored when displayed.
    ///
    /// This property determines if the video frame needs to be flipped horizontally
    /// to appear correctly oriented to the user. It's typically set to `true` for
    /// front-facing camera captures to provide a natural mirror-like experience,
    /// where users see themselves as they would in a mirror rather than flipped.
    let isMirrored: Bool

    /// The nominal frame duration for the capture source.
    ///
    /// Typically the inverse of the target FPS (e.g., 1/24, 1/30). Used to pace processing,
    /// compute scaled frame durations, and maintain continuous timestamps. For variable‑frame‑rate
    /// streams this is a baseline reference and individual samples may deviate.
    let minFrameDuration: CMTime

    /// The video orientation indicating how the captured frame should be rotated for display.
    ///
    /// This property specifies the orientation of the video frame as captured by the
    /// camera system. It indicates how the frame should be rotated to appear correctly
    /// oriented when displayed to the user, taking into account the device's physical
    /// orientation during capture.
    let orientation: AVCaptureVideoOrientation

    /// The underlying captured/decoded media sample.
    ///
    /// Contains the pixel data and timing/format metadata for this frame.
    /// The buffer is not owned or retained beyond normal ARC semantics.
    let sampleBuffer: CMSampleBuffer

    // MARK: - Computed Properties

    /// Returns the format description of the samples in a sample buffer.
    var formatDescription: CMFormatDescription? {
        CMSampleBufferGetFormatDescription(sampleBuffer)
    }

    /// Returns an image buffer that contains the media data.
    var imageBuffer: CVImageBuffer? {
        CMSampleBufferGetImageBuffer(sampleBuffer)
    }

    /// The sample’s presentation timestamp.
    ///
    /// Use this for ordering, synchronization with audio, and writer session timing.
    var timestamp: CMTime {
        sampleBuffer.presentationTimeStamp
    }

    /// The preferred affine transform for displaying the video frame in its correct orientation.
    ///
    /// This computed property calculates the appropriate transformation matrix needed to display
    /// the video frame in its intended orientation. It combines rotation based on the capture
    /// orientation with horizontal mirroring if the frame should be flipped. The transform
    /// is designed to be applied to the video layer or view to ensure proper display orientation
    /// regardless of device rotation or camera position.
    ///
    /// The transform handles all standard video orientations:
    /// - Portrait: 90° clockwise rotation
    /// - Portrait upside down: 90° counter-clockwise rotation
    /// - Landscape left: 180° rotation
    /// - Landscape right: No rotation (identity transform)
    ///
    /// If the frame is mirrored (typically for front-facing camera), the transform is
    /// additionally scaled horizontally by -1 to flip the image.
    var preferredTransform: CGAffineTransform {
        switch orientation {
        case .landscapeRight:
            isMirrored ? CGAffineTransform(rotationAngle: .pi) : .identity

        case .landscapeLeft:
            isMirrored ? .identity : CGAffineTransform(rotationAngle: .pi)

        case .portrait:
            CGAffineTransform(rotationAngle: .pi / 2)

        case .portraitUpsideDown:
            CGAffineTransform(rotationAngle: -.pi / 2)

        @unknown default:
            .identity
        }
    }

    // MARK: - Initializer

    /// Creates a new video sample buffer with the specified orientation, mirroring, frame duration, and sample data.
    ///
    /// This initializer creates a lightweight wrapper around a `CMSampleBuffer` that includes
    /// additional metadata about the video frame's orientation and mirroring state. The sample
    /// buffer is not copied or retained beyond normal ARC semantics, making this struct efficient
    /// for passing video samples through processing pipelines.
    ///
    /// - Parameters:
    ///   - bitRate: The average video bit rate in bits per second, used for encoding
    ///     configuration and quality control. This value typically comes from the
    ///     video device configuration and affects the final video quality and file size.
    ///   - isMirrored: Whether the video frame should be horizontally mirrored when displayed.
    ///     This is typically true for front-facing camera captures to provide a natural
    ///     mirror-like experience for users.
    ///   - orientation: The video orientation of the captured frame, indicating how the image
    ///     should be rotated for display (e.g., portrait, landscape left/right, upside down).
    ///   - minFrameDuration: The minimum frame duration for the capture source, typically
    ///     the inverse of the target FPS (e.g., 1/24, 1/30). Used for pacing processing and
    ///     maintaining continuous timestamps in variable-frame-rate streams.
    ///   - sampleBuffer: The underlying captured or decoded media sample containing the pixel
    ///     data and timing/format metadata for this frame.
    init(
        bitRate: Int,
        isMirrored: Bool,
        orientation: AVCaptureVideoOrientation,
        minFrameDuration: CMTime,
        sampleBuffer: CMSampleBuffer
    ) {
        self.bitRate = bitRate
        self.orientation = orientation
        self.isMirrored = isMirrored
        self.minFrameDuration = minFrameDuration
        self.sampleBuffer = sampleBuffer
    }
}

/// A class‑bound contract for components that consume video samples with access
/// to the active capture/encode configuration.
///
/// Conforming types are reference types to enable stable identity Implementations should
/// keep per‑frame work lightweight and offload heavy tasks to background queues to avoid
/// blocking the capture pipeline. The provided configuration is a read‑only snapshot of the
/// current device/encoding preferences and must not be mutated by processors.
protocol VideoOutputProcessor: AnyObject {
    /// Processes a single video sample using the provided configuration.
    ///
    /// Use the configuration to guide transformations (e.g., scaling, color space,
    /// orientation/transform, target bitrate hints) while relying on the sample’s
    /// timing for ordering. This method is expected to run on the component’s serialization context
    ///
    /// - Parameters:
    ///   - buffer: The video sample to process.
    ///   - configuration: A snapshot of capture/encoding preferences to inform processing.
    func process(_ buffer: VideoSampleBuffer, with configuration: VideoDeviceConfiguration)
}
