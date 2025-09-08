//
//  CVPixelBuffer+Metal.swift
//  TruvideoSdkCamera
//
//  Created by Luis Francisco Piura Mejia on 14/6/24.
//

import MetalKit

extension CVPixelBuffer {

    func createTexture(
        pixelFormat: MTLPixelFormat,
        planeIndex: Int,
        textureCache: CVMetalTextureCache
    ) -> CVMetalTexture? {
        let width = CVPixelBufferGetWidthOfPlane(self, planeIndex)
        let height = CVPixelBufferGetHeightOfPlane(self, planeIndex)

        var texture: CVMetalTexture? = nil
        let status = CVMetalTextureCacheCreateTextureFromImage(
            nil,
            textureCache,
            self,
            nil,
            pixelFormat,
            width,
            height,
            planeIndex,
            &texture
        )

        if status != kCVReturnSuccess {
            texture = nil
        }

        return texture
    }

    private func createTexture(
        pixelFormat: MTLPixelFormat,
        textureCache: CVMetalTextureCache
    ) -> CVMetalTexture? {
        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)

        var texture: CVMetalTexture? = nil
        let status = CVMetalTextureCacheCreateTextureFromImage(
            nil,
            textureCache,
            self,
            nil,
            pixelFormat,
            width,
            height,
            0,
            &texture
        )

        if status != kCVReturnSuccess {
            texture = nil
        }

        return texture
    }

}
