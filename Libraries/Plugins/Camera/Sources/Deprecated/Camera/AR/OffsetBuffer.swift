//
//  OffsetBuffer.swift
//  TruvideoSdkCamera
//
//  Created by Luis Francisco Piura Mejia on 1/7/24.
//

import MetalKit

struct OffsetBuffer {
    var size: Int = 0
    var elementsCount = 0
    var metalBuffer: MTLBuffer?
    var offset: Int = 0
    var currentAddress: UnsafeMutableRawPointer?
}
