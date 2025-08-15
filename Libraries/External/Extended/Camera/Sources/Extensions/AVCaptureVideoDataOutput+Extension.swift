//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation
import Foundation

extension AVCaptureVideoDataOutput {
    /// Creates a preconfigured `AVCaptureVideoDataOutput` optimized for real-time camera capture.
    ///
    /// This method selects the best available pixel format supported by the current device:
    /// it prefers 4:2:0 bi-planar full-range (`kCVPixelFormatType_420YpCbCr8BiPlanarFullRange`),
    /// then falls back to 4:2:0 bi-planar video-range (`kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange`),
    /// and finally to 32-bit BGRA (`kCVPixelFormatType_32BGRA`) if neither YUV format is available.
    /// It also sets `alwaysDiscardsLateVideoFrames` to `false` to preserve frame continuity under load.
    /// Callers must set a sample buffer delegate and provide an appropriate serial dispatch queue.
    static func createDefault() -> AVCaptureVideoDataOutput {
        let captureVideoDataOutput = AVCaptureVideoDataOutput()
        let pixelFormatKey = String(kCVPixelBufferPixelFormatTypeKey)
        var settings = [String(kCVPixelBufferPixelFormatTypeKey): Int(kCVPixelFormatType_32BGRA)]

        for formatType in captureVideoDataOutput.availableVideoPixelFormatTypes {
            if formatType == Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
                settings[pixelFormatKey] = Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
            }

            if formatType == Int(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) && settings[pixelFormatKey] == nil {
                settings[pixelFormatKey] = Int(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)
            }
        }

        captureVideoDataOutput.alwaysDiscardsLateVideoFrames = false
        captureVideoDataOutput.videoSettings = settings

        return captureVideoDataOutput
    }
}
