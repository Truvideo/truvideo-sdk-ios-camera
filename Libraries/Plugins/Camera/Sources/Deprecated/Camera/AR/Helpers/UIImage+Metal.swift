//
//  UIImage+Metal.swift
//  TruvideoSdkCamera
//
//  Created by Luis Francisco Piura Mejia on 14/6/24.
//

import UIKit

extension UIImage {

    func createTexture(device: MTLDevice) -> MTLTexture? {
        guard let cgImage = cgImage else {
            return nil
        }

        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .rgba8Unorm,
            width: cgImage.width,
            height: cgImage.height,
            mipmapped: false
        )
        textureDescriptor.usage = [.shaderRead, .shaderWrite]

        guard let texture = device.makeTexture(descriptor: textureDescriptor) else {
            return nil
        }

        let bytesPerRow = cgImage.bytesPerRow

        let bitsPerComponent = 8  // RGBA
        let bytesCount = cgImage.height * bytesPerRow
        var imageData = [UInt8](repeating: 0, count: bytesCount)

        guard
            let context = CGContext(
                data: &imageData,
                width: cgImage.width,
                height: cgImage.height,
                bitsPerComponent: bitsPerComponent,
                bytesPerRow: bytesPerRow,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            )
        else {
            return nil
        }

        context.translateBy(x: 0, y: CGFloat(cgImage.height))
        context.scaleBy(x: 1.0, y: -1.0)
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
        let region = MTLRegionMake2D(0, 0, cgImage.width, cgImage.height)
        texture.replace(region: region, mipmapLevel: 0, withBytes: &imageData, bytesPerRow: bytesPerRow)

        return texture
    }
}
