//
//  CVPixelBuffer+Rotation.swift
//  TruvideoSdkCamera
//
//  Created by Luis Francisco Piura Mejia on 23/8/24.
//

import CoreImage
import Foundation

extension CVPixelBuffer {

    func rotate(orientation: CGImagePropertyOrientation, swapDimensions: Bool) -> CVPixelBuffer? {
        let coreImageContext = CIContext(options: nil)
        var newPixelBuffer: CVPixelBuffer?
        let error = CVPixelBufferCreate(
            kCFAllocatorDefault,
            swapDimensions ? CVPixelBufferGetWidth(self) : CVPixelBufferGetHeight(self),
            swapDimensions ? CVPixelBufferGetHeight(self) : CVPixelBufferGetWidth(self),
            kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
            nil,
            &newPixelBuffer
        )
        guard
            error == kCVReturnSuccess,
            let buffer = newPixelBuffer
        else {
            return nil
        }
        let ciImage = CIImage(cvPixelBuffer: self).oriented(orientation)
        coreImageContext.render(ciImage, to: buffer)
        return buffer
    }
}
