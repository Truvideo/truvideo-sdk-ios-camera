//
//  UIInterfaceOrientationMask+title.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 3/26/25.
//

import UIKit

extension UIInterfaceOrientationMask {
    var title: String {
        switch self {
        case .portrait:
            return "PORTRAIT"
        case .portraitUpsideDown:
            return "PORTRAIT-UPSIDE-DOWN"
        case .landscapeLeft:
            return "LANDSCAPE-LEFT"
        case .landscapeRight:
            return "LANDSCAPE-RIGHT"
        default:
            return "UNKNOWN"
        }
    }

    var deviceOrientation: UIDeviceOrientation {
        switch self {
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        case .portraitUpsideDown:
            return .portraitUpsideDown
        default:
            return .portrait
        }
    }
}
