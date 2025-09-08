//
//  TruvideoSdkCameraResolution.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 2/21/24.
//

import AVFoundation

enum ResolutionType {
    case front
    case back
}

@objc public class TruvideoSdkCameraResolution: NSObject, Comparable, Encodable {
    @objc public let width: Int32
    @objc public let height: Int32
    let highResolutionPhotoWidth: Int32
    let highResolutionPhotoHeight: Int32

    var supportsHighResolutionPhotos: Bool {
        width != highResolutionPhotoWidth
    }

    public init(
        width: Int32,
        height: Int32,
        highResolutionPhotoWidth: Int32 = .zero,
        highResolutionPhotoHeight: Int32 = .zero
    ) {
        self.width = width
        self.height = height
        self.highResolutionPhotoWidth = highResolutionPhotoWidth
        self.highResolutionPhotoHeight = highResolutionPhotoHeight
    }

    public static func == (lhs: TruvideoSdkCameraResolution, rhs: TruvideoSdkCameraResolution) -> Bool {
        lhs.width == rhs.width && lhs.height == rhs.height
            && lhs.highResolutionPhotoWidth == rhs.highResolutionPhotoWidth
            && lhs.highResolutionPhotoHeight == rhs.highResolutionPhotoHeight
    }

    public static func < (lhs: TruvideoSdkCameraResolution, rhs: TruvideoSdkCameraResolution) -> Bool {
        guard lhs.width == rhs.width else {
            return lhs.width > rhs.width
        }

        guard lhs.height == rhs.height else {
            return lhs.height > rhs.height
        }

        guard lhs.highResolutionPhotoWidth == rhs.highResolutionPhotoWidth else {
            return lhs.highResolutionPhotoWidth > rhs.highResolutionPhotoWidth
        }

        return lhs.highResolutionPhotoHeight > rhs.highResolutionPhotoHeight
    }

    public required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.width = try container.decode(Int32.self, forKey: .width)
        self.height = try container.decode(Int32.self, forKey: .height)
        self.highResolutionPhotoWidth =
            try container.decodeIfPresent(Int32.self, forKey: .highResolutionPhotoWidth) ?? self.width
        self.highResolutionPhotoHeight =
            try container.decodeIfPresent(Int32.self, forKey: .highResolutionPhotoHeight) ?? self.height
    }

    private enum CodingKeys: String, CodingKey {
        case width
        case height
        case highResolutionPhotoWidth
        case highResolutionPhotoHeight
    }

    public static let defaultResolution: TruvideoSdkCameraResolution = .init(
        width: 1280,
        height: 720,
        highResolutionPhotoWidth: 1280,
        highResolutionPhotoHeight: 720
    )
}

class TruvideoSdkCameraResolutionFormat: TruvideoSdkCameraResolution {
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
        super.init(
            width: width,
            height: height,
            highResolutionPhotoWidth: highResolutionPhotoWidth ?? width,
            highResolutionPhotoHeight: highResolutionPhotoHeight ?? height
        )
    }

    public required init(from decoder: any Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }

    static var defaultResolutionFormat: TruvideoSdkCameraResolutionFormat {
        .init(
            width: 1280,
            height: 720,
            highResolutionPhotoWidth: 1280,
            highResolutionPhotoHeight: 720,
            type: .back,
            format: nil
        )
    }
}

extension Array where Element: TruvideoSdkCameraResolutionFormat {
    func filterStandardResolutions() -> [Element] {
        var filteredResolutions = [Element]()
        for element in self {
            switch (element.width, element.height) {
            case (640, 480):  // SD
                filteredResolutions.append(element)
            case (1280, 720):  // HD
                filteredResolutions.append(element)
            case (1920, 1080):  // FULL HD
                filteredResolutions.append(element)
            default:
                continue  // No standard
            }
        }

        return filteredResolutions
    }
}
