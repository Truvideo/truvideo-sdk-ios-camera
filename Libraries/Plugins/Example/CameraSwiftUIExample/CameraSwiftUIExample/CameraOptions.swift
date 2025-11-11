//
// Copyright © 2025 TruVideo. All rights reserved.
//

import TruvideoSdkCamera

struct CameraOptions {
    var lens: TruvideoSdkCameraLensFacing = .back
    var flash: TruvideoSdkCameraFlashMode = .off
    var imageFormat: TruvideoSdkCameraImageFormat = .jpeg
    var mediaMode: MediaMode = .videoAndPicture
    var mediaLimit: MediaLimit = .unlimited
    var pictureLimit = 1
    var videoLimit = 1
    var videoDuration: Double = 60

    enum MediaMode: String, CaseIterable, Identifiable {
        case photoOnly
        case videoOnly
        case videoAndPicture

        var id: String { rawValue }
    }

    enum MediaLimit: String, CaseIterable, Identifiable {
        case single
        case limited
        case unlimited

        var id: String { rawValue }
    }

    var configuration: TruvideoSdkCameraConfiguration {
        TruvideoSdkCameraConfiguration(
            flashMode: flash,
            imageFormat: imageFormat,
            lensFacing: lens,
            mode: makeMediaMode(),
            outputPath: ""
        )
    }

    private func makeMediaMode() -> TruvideoSdkCameraMediaMode {
        switch mediaMode {
        case .photoOnly:
            switch mediaLimit {
            case .single:
                .singlePicture()

            case .limited:
                .picture(pictureCount: max(1, pictureLimit))

            case .unlimited:
                .picture()
            }

        case .videoOnly:
            switch mediaLimit {
            case .single:
                .singleVideo(videoDuration: Int(videoDuration))

            case .limited:
                .video(videoCount: max(1, videoLimit), videoDuration: Int(videoDuration))

            case .unlimited:
                .video(videoDuration: Int(videoDuration))
            }

        case .videoAndPicture:
            switch mediaLimit {
            case .single:
                .singleVideoOrPicture(videoDuration: Int(videoDuration))

            case .limited:
                .videoAndPicture(
                    videoCount: max(1, videoLimit),
                    pictureCount: max(1, pictureLimit),
                    videoDuration: Int(videoDuration)
                )

            case .unlimited:
                .videoAndPicture(mediaCount: nil, videoDuration: Int(videoDuration))
            }
        }
    }
}
