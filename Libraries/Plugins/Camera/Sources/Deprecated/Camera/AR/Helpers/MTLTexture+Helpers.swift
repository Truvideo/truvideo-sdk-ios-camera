//
//  MTLTexture+Helpers.swift
//  TruvideoSdkCamera
//
//  Created by Luis Francisco Piura Mejia on 14/6/24.
//

import MetalKit

extension MTLTexture {

    func createPixelBuffer() -> CVPixelBuffer? {
        let pixelBufferAttributes: [String: Any] = [
            kCVPixelBufferMetalCompatibilityKey as String: true,
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey as String: width,
            kCVPixelBufferHeightKey as String: height,
            kCVPixelBufferBytesPerRowAlignmentKey as String: 64,
        ]

        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32BGRA,
            pixelBufferAttributes as CFDictionary,
            &pixelBuffer
        )

        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            print("Failed to create pixel buffer")
            return nil
        }

        CVPixelBufferLockBaseAddress(buffer, .readOnly)

        guard let baseAddress = CVPixelBufferGetBaseAddress(buffer) else {
            CVPixelBufferUnlockBaseAddress(buffer, .readOnly)
            return nil
        }

        let bytesPerRow = CVPixelBufferGetBytesPerRow(buffer)
        let region = MTLRegionMake2D(0, 0, width, height)

        getBytes(baseAddress, bytesPerRow: bytesPerRow, from: region, mipmapLevel: 0)
        CVPixelBufferUnlockBaseAddress(buffer, .readOnly)

        return buffer
    }

}
