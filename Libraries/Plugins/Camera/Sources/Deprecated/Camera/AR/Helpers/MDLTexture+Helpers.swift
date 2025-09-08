//
//  MDLTexture+Helpers.swift
//  TruvideoSdkCamera
//
//  Created by Luis Francisco Piura Mejia on 17/6/24.
//

import MetalKit

extension MDLTexture {

    func convertToMTLTexture(device: MTLDevice) -> MTLTexture? {
        guard let cgImage = imageFromTexture()?.takeUnretainedValue() else {
            return nil
        }

        let textureDescriptor: MTLTextureDescriptor = .texture2DDescriptor(
            pixelFormat: .rgba8Unorm,
            width: cgImage.width,
            height: cgImage.height,
            mipmapped: false
        )
        let texture = device.makeTexture(descriptor: textureDescriptor)
        let region = MTLRegionMake2D(0, 0, cgImage.width, cgImage.height)
        guard let imageBytes = cgImage.dataProvider?.data else {
            return nil
        }
        texture?.replace(
            region: region,
            mipmapLevel: 0,
            withBytes: CFDataGetBytePtr(imageBytes),
            bytesPerRow: cgImage.bytesPerRow
        )
        return texture
    }

}
