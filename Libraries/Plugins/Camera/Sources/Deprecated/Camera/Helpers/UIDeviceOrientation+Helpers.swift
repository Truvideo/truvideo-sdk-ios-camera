//
//  UIDeviceOrientation+Helpers.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 7/10/24.
//

import CoreImage
import Foundation
import SwiftUI

extension UIDeviceOrientation {
    /// Returns the rotation angle for the current `UIDeviceOrientation`.
    var angle: Angle? {
        switch self {
        case .landscapeLeft: return Angle.degrees(90)
        case .landscapeRight: return Angle.degrees(-90)
        case .portrait: return Angle.degrees(0)
        case .portraitUpsideDown: return Angle.degrees(180)
        default: return nil
        }
    }

    var transform: CGAffineTransform {
        switch self {
        case .landscapeLeft: return .identity.rotated(by: .pi / -2)
        case .landscapeRight: return .identity.rotated(by: .pi / 2)
        case .portrait: return .identity
        case .portraitUpsideDown: return .identity.rotated(by: .pi)
        default: return .identity
        }
    }

    var imageOrientation: CGImagePropertyOrientation {
        switch self {
        case .landscapeLeft: return .left
        case .landscapeRight: return .right
        case .portrait: return .up
        case .portraitUpsideDown: return .up
        default: return .up
        }
    }

    var swapDimensionsForVideo: Bool {
        switch self {
        case .landscapeLeft, .landscapeRight: return true
        default: return false
        }
    }

    var swapDimensionsForPhoto: Bool {
        !swapDimensionsForVideo
    }

    var interfaceOrientationMask: UIInterfaceOrientationMask {
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
