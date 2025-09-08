//
//  MediaCounterViewModel.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 4/1/25.
//

import SwiftUI

protocol MediaCounterProtocol: AnyObject {
    func updateVideoCounter(increment: Int)

    func updatePictureCounter(increment: Int)

    func addPreview(_ previewImage: UIImage)

    func removePreview()
}

class MediaCounterViewModel: ObservableObject, MediaCounterProtocol {
    // - MARK: Class name
    let className = String(describing: MediaCounterViewModel.self)

    @Published var mediaCount: Int = 0
    @Published var videoCount: Int = 0
    @Published var pictureCount: Int = 0

    @Published var hasContent: Bool = false

    @Published var previewImage: UIImage = TruVideoImage.blackImage

    @Published var frameSize: CGSize?
    @Published var triggerUpdate = false

    private(set) var maxMediaCount: Int?
    private(set) var maxVideoCount: Int?
    private(set) var maxPictureCount: Int?
    private let mode: TruvideoSdkCameraMediaMode

    private(set) var isOneModeOnly: Bool

    init(mode: TruvideoSdkCameraMediaMode) {
        self.mode = mode
        self.maxMediaCount = mode.maxMediaCount
        self.maxVideoCount = mode.maxVideoCount
        self.maxPictureCount = mode.maxPictureCount
        self.isOneModeOnly = mode.isOneModeOnly

        hasContent = checkIfHasContent()
    }

    func updateVideoCounter(increment: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            frameSize = nil
            videoCount += increment
            mediaCount += increment
            triggerUpdate.toggle()
            hasContent = checkIfHasContent()
            dprint(className, "update video counter: \(self.mediaCount) - \(self.videoCount)")
        }
    }

    func updatePictureCounter(increment: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            frameSize = nil
            pictureCount += increment
            mediaCount += increment
            triggerUpdate.toggle()
            hasContent = checkIfHasContent()
            dprint(className, "update picture counter: \(self.mediaCount) - \(self.pictureCount)")
        }
    }

    func addPreview(_ previewImage: UIImage) {
        DispatchQueue.main.async { [weak self] in
            self?.previewImage = previewImage
        }
    }

    func removePreview() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            dprint(className, "remove preview with media: \(self.mediaCount)")
            guard self.mediaCount == 0 else { return }
            self.previewImage = TruVideoImage.blackImage
        }
    }

    private func checkIfHasContent() -> Bool {
        if mediaCount > 0 || videoCount > 0 || pictureCount > 0 {
            return true
        }

        return false
        /* switch mode {
        case .videoAndPicture(let videoCount, let pictureCount, _):
            if let videoCount = videoCount, videoCount > 0 {
                return true
            } else if let pictureCount = pictureCount, pictureCount > 0 {
                return true
            } else {
                return false
            }
        case .media(let mediaCount, _):
            if let mediaCount = mediaCount, mediaCount > 0 {
                return true
            } else {
                return false
            }
        case .video(let videoCount, _):
            if let videoCount = videoCount, videoCount > 0 {
                return true
            } else {
                return false
            }
        case .picture(let pictureCount):
            if let pictureCount = pictureCount, pictureCount > 0 {
                return true
            } else {
                return false
            }
        case .singleVideo(_), .singlePicture, .singleVideoOrPicture(_):
            return true
        }*/
    }
}
