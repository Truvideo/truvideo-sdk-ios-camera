//
//  TruVideoClip.swift
//
//  Created by TruVideo on 6/14/22.
//  Copyright © 2023 TruVideo. All rights reserved.
//

import AVFoundation
import UIKit

/// Represents a single video clip record
class TruVideoClip {
    /// Unique identifier of this `TruVideoClip`
    let id: UUID = .init()

    /// Cached size in `KB`.
    private var cachedSize: Int64?

    /// Created timestamp
    let createdAt: Double = Date().timeIntervalSince1970

    /// File path
    var filePath: String {
        url.path
    }

    /// Media Type
    let type: TruvideoSdkCameraMediaType = .clip

    /// Lens Facing
    var lensFacing: TruvideoSdkCameraLensFacing = .back

    /// Orientation angle
    var orientation: TruvideoSdkCameraOrientation = .portrait

    /// Media Type
    var resolution: TruvideoSdkCameraResolution {
        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            return TruvideoSdkCameraResolution(width: 0, height: 0)
        }

        /// Note: This resolution is being affected by the AR Camera, looks like at this date the AR Camera is not roating the layer
        /// producing videos always with the portrait size, this extra validation allows us to know if the video was recorded in the correct
        /// orientation.
        let isPortrait =
            [.portrait, .portraitReverse].contains(orientation)
            && [.portrait, .portraitUpsideDown].contains(videoOrientation)

        return TruvideoSdkCameraResolution(
            width: isPortrait ? Int32(videoTrack.naturalSize.width) : Int32(videoTrack.naturalSize.height),
            height: isPortrait ? Int32(videoTrack.naturalSize.height) : Int32(videoTrack.naturalSize.width)
        )
    }

    /// Underliying `AVAsset`
    lazy var asset: AVAsset = {
        AVAsset(url: url)
    }()

    /// Duration of the clip, otherwise invalid.
    var duration: CMTime {
        asset.duration
    }

    var formattedTime: String {
        let totalSeconds = CMTimeGetSeconds(duration)
        let hours = Int(totalSeconds / 3600)
        let minutes = Int((totalSeconds.truncatingRemainder(dividingBy: 3600)) / 60)
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        let timeString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        return timeString
    }

    /// True, if the clip's file exists
    var fileExists: Bool {
        FileManager.default.fileExists(atPath: url.path)
    }

    /// Frame rate at which the asset was recorded.
    var frameRate: Float {
        if let videoTrack = asset.tracks(withMediaType: .video).first {
            return videoTrack.nominalFrameRate
        }

        return 0
    }

    /// Image for the last frame of the clip.
    private(set) lazy var firstFrameImage: UIImage? = {
        try? asset.createImage(at: duration, actualTime: nil)
    }()

    /// The `AVCaptureVideoOrientation` of the clip
    private(set) lazy var videoOrientation: AVCaptureVideoOrientation? = asset.orientation

    /// The size in `KB` of the clip
    private(set) lazy var size: Int64? = {
        guard cachedSize == nil else {
            return cachedSize
        }

        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            return attributes[.size] as? Int64
        } catch {
            print("[TruVideoSession]: ⚠️ Unable to get size of the clip error: \(error)")
            return nil
        }
    }()

    /// If it doesn't already exist, generates a thumbnail image of the clip.
    private(set) lazy var thumbnailImage: UIImage? = {
        try? asset.createImage(at: duration, actualTime: nil)
    }()

    /// URL of the clip
    let url: URL

    // MARK: Initializers

    /// Initialize a new clip instance.
    ///
    /// - Parameter url: URL and filename of the specified media asset
    init(url: URL, lastFrameImage: UIImage? = nil) {
        self.url = url
        self.firstFrameImage = lastFrameImage
    }

    func toMediaRepresentation() async -> TruvideoSdkCameraMedia {
        let duration = await duration()

        return TruvideoSdkCameraMedia(
            createdAt: createdAt,
            duration: duration.seconds * 1_000,
            filePath: filePath,
            lensFacing: lensFacing,
            orientation: orientation,
            resolution: resolution,
            type: type
        )
    }

    private func duration() async -> CMTime {
        do {
            return try await asset.load(.duration)
        } catch {
            return .zero
        }
    }
}

extension TruVideoClip: Hashable {

    // MARK: Equatable

    static func == (lhs: TruVideoClip, rhs: TruVideoClip) -> Bool {
        lhs.url == rhs.url
    }

    func hash(into hasher: inout Hasher) {
        url.hash(into: &hasher)
    }
}
