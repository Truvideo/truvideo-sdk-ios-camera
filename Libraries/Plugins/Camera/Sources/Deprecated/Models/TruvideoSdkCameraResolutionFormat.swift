//
//  TruvideoSdkCameraResolutionFormat.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 2/21/24.
//

import AVFoundation

enum ResolutionType {
    case front
    case back
}

class TruvideoSdkCameraResolutionFormat: TruvideoSdkCameraResolutionDeprecated, Comparable {
    let type: ResolutionType
    let format: AVCaptureDevice.Format?

    var bitRate: Int {
        switch (width, height) {
        case (640, 480):  // SD
            return 1_000_000  // 1MB
        case (1280, 720):  // HD
            return 2_500_000  // 2.5MB
        case (1920, 1080):  // FULL HD
            return 4_000_000  // 4MB
        case (3840, 2160):  // UHD
            return 8_000_000  // 8MB
        default:  // Default
            return 2_000_000  // 2MB
        }
    }

    var aspectRatio: CGFloat {
        CGFloat(width) / CGFloat(height)
    }

    init(
        width: Int32,
        height: Int32,
        highResolutionPhotoWidth: Int32? = nil,
        highResolutionPhotoHeight: Int32? = nil,
        type: ResolutionType,
        format: AVCaptureDevice.Format?
    ) {
        self.type = type
        self.format = format
        super.init(width: width, height: height)
    }

    public required init(from decoder: any Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }

    static var defaultResolutionFormat: TruvideoSdkCameraResolutionFormat {
        TruvideoSdkCameraResolutionFormat(
            width: 1280,
            height: 720,
            highResolutionPhotoWidth: 1280,
            highResolutionPhotoHeight: 720,
            type: .back,
            format: nil
        )
    }

    public static func == (lhs: TruvideoSdkCameraResolutionFormat, rhs: TruvideoSdkCameraResolutionFormat) -> Bool {
        lhs.width == rhs.width && lhs.height == rhs.height
    }

    public static func < (lhs: TruvideoSdkCameraResolutionFormat, rhs: TruvideoSdkCameraResolutionFormat) -> Bool {
        guard lhs.width == rhs.width else {
            return lhs.width > rhs.width
        }

        guard lhs.height == rhs.height else {
            return lhs.height > rhs.height
        }

        return false
    }
}
