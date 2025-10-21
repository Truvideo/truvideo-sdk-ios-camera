//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation
import Foundation

/// A configurable set of microphone capture and encoding parameters for the audio pipeline.
///
/// Centralizes choices that affect capture format (sample rate, channel count, format ID)
/// and encoder settings (bit rate). These values are used to build AVFoundation‑compatible
/// settings dictionaries for `AVAssetWriterInput` or similar consumers.
final class AudioDeviceConfiguration {
    // MARK: - Properties

    /// Whether the capture session should automatically adjust the shared `AVAudioSession`.
    ///
    /// When `true` (default), `AVCaptureSession` may configure the app’s audio session
    /// to match capture requirements. Set to `false` if you manage `AVAudioSession`
    /// yourself (e.g., custom category/mode/route handling).
    var automaticallyConfiguresAudioSession = true

    /// Target encoder bit rate in bits per second (`AVEncoderBitRateKey`).
    ///
    /// Higher bit rates yield better quality at the cost of larger files and bandwidth.
    /// Common values range from 96_000 to 192_000 for AAC stereo voice/music.
    var bitRate = audioBitRateDefault

    /// Number of audio channels (`AVNumberOfChannelsKey`).
    ///
    /// When `nil`, it may be inferred from the provided `CMSampleBuffer` .
    /// Typical values: `1` (mono) or `2` (stereo).
    var channelsCount: Int?

    /// Audio format identifier (`AVFormatIDKey`).
    ///
    /// Defaults to `kAudioFormatMPEG4AAC` (AAC), which is widely supported and efficient.
    /// See Core Audio data types for alternatives (e.g., `kAudioFormatLinearPCM`).
    var format = kAudioFormatMPEG4AAC

    /// Preferred capture preset for the session.
    ///
    /// `.inputPriority` (default) allows device input configuration (sample rate/channel count)
    /// to take precedence over coarse session presets.
    let preset = AVCaptureSession.Preset.inputPriority

    /// Sample rate in hertz (`AVSampleRateKey`).
    ///
    /// When `nil`, it may be inferred from the provided `CMSampleBuffer`.
    /// Typical values: `44_100` or `48_000`.
    var sampleRate: Float64?

    // MARK: - Static Properties

    /// Default encoder bit rate (128 kbps).
    static let audioBitRateDefault = 128_000

    /// Default number of channels (stereo).
    static let audioChannelsCountDefault = 2

    /// Default sample rate (44.1 kHz).
    static let audioSampleRateDefault: Float64 = 44_100

    // MARK: - Instance methods

    /// Builds an AVFoundation‑compatible audio settings dictionary.
    ///
    /// This method assembles a dictionary suitable for `AVAssetWriterInput` (mediaType `.audio`)
    /// or other AVFoundation consumers. If `sampleRate` and `channelsCount` are not set, it will
    /// attempt to infer them from the provided `sampleBuffer`’s format description. Channel layout
    /// data is included when available.
    ///
    /// - Parameter sampleBuffer: Optional `CMSampleBuffer` used to infer `sampleRate`, `channelsCount`, and channel
    /// layout.
    /// - Returns: A dictionary keyed by `AV*` audio constants . Returns `nil` only if insufficient information is
    /// available (rare).
    func makeSettingsDictionary(sampleBuffer: CMSampleBuffer? = nil) -> [String: Any] {
        var config: [String: Any] = [AVEncoderBitRateKey: bitRate]

        if /// Sample buffer
            let sampleBuffer,

            /// Sample format description.
            let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) {
            if let streamBasicDescription = CMAudioFormatDescriptionGetStreamBasicDescription(formatDescription),
               sampleRate == nil, channelsCount == nil {
                sampleRate = streamBasicDescription.pointee.mSampleRate
                channelsCount = Int(streamBasicDescription.pointee.mChannelsPerFrame)
            }

            var layoutSize = 0

            if let layoutPtr = CMAudioFormatDescriptionGetChannelLayout(formatDescription, sizeOut: &layoutSize) {
                config[AVChannelLayoutKey] = layoutSize > 0 ? Data(bytes: layoutPtr, count: layoutSize) : Data()
            }
        }

        config[AVSampleRateKey] = (sampleRate ?? AudioDeviceConfiguration.audioSampleRateDefault)
        config[AVNumberOfChannelsKey] = (channelsCount ?? AudioDeviceConfiguration.audioChannelsCountDefault)
        config[AVFormatIDKey] = format

        return config
    }
}
