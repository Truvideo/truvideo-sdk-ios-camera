//
//  ToastType.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 3/26/25.
//

import Foundation

enum ToastType {
    case none
    case maxVideoCountReached
    case maxPictureCountReached
    case maxVideoDurationReached

    var message: String {
        switch self {
        case .maxPictureCountReached:
            return "You have reached the maximum number of pictures for this session."
        case .maxVideoCountReached:
            return "You have reached the maximum number of videos for this session."
        case .maxVideoDurationReached:
            return "Maximum video duration reached."
        case .none:
            return ""
        }
    }
}
