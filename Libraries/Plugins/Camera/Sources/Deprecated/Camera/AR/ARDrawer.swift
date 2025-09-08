//
//  ARDrawer.swift
//  TruvideoSdkCamera
//
//  Created by Luis Francisco Piura Mejia on 6/6/24.
//

import ARKit
import MetalKit

/// Protocol used to interact with the metal shaders in order to perform drawing actions
protocol ARDrawer: AnyObject {
    /// Buffer used to store the 4x4 matrices to render an element
    var instancesBuffer: OffsetBuffer? { get }
    /// Buffer used to store the indices to render an element
    var indicesBuffer: OffsetBuffer? { get }
    /// Buffer used to store the vertices to render an element
    var verticesBuffer: OffsetBuffer? { get }

    /// Metal buffer used to store the shared uniforms
    var sharedUniformBuffer: MTLBuffer? { get set }
    /// Shared uniforms metal buffer offset
    var sharedUniformBufferOffset: Int { get set }
    /// Array to store the rendered AR anchors
    var instanceAnchors: [ARAnchor] { get set }
    /// Metal textures used to render images in 3D space such as measure texts
    var modelTextures: [MTLTexture] { get set }
    /// Mesh of an 3D element, containing its vertices and its textures coordinates
    var modelMeshes: [MTKMesh] { get set }

    /// Update the position of a given instances buffer
    func updateInstanceBufferState(bufferIndex: Int)
    /// Update the position of a given indices buffer
    func updateIndicesBufferState(bufferIndex: Int)
    /// Get and index address direction
    func getIndex(at position: Int) -> UnsafeMutablePointer<UInt16>?
    /// Get a vertex address direction
    func getVertex() -> UnsafeMutablePointer<Float>?
    /// Method used to render in metal shaders without any additional parameters
    func draw(renderEncoder: MTLRenderCommandEncoder)
    /// Method used to render in metal shaders using the number of indices
    func draw(renderEncoder: MTLRenderCommandEncoder, indicesCount: Int)
    /// Method used to render in metal shaders  using the number of indices and instances
    func draw(renderEncoder: MTLRenderCommandEncoder, indicesCount: Int, instancesCount: Int)
    /// Method used to render in metal shaders using textures and vertices count
    func draw(renderEncoder: MTLRenderCommandEncoder, textures: [MTLTexture], vertexCount: Int)
    /// Method used to remove a given 3D object from the metal shader
    func removeInstanceAnchors(from: ARSession)
}

final class TruvideoARDrawer: ARDrawer {

    var sharedUniformBuffer: MTLBuffer?
    var sharedUniformBufferOffset = 0
    var instanceAnchors = [ARAnchor]()
    var modelTextures = [MTLTexture]()
    var modelMeshes = [MTKMesh]()

    private let drawerName: String
    private let device: MTLDevice

    private(set) var instancesBuffer: OffsetBuffer?
    private(set) var indicesBuffer: OffsetBuffer?
    private(set) var verticesBuffer: OffsetBuffer?
    private let depthState: MTLDepthStencilState
    private let pipelineState: MTLRenderPipelineState

    init(
        drawerName: String,
        device: MTLDevice,
        instancesBuffer: OffsetBuffer?,
        indicesBuffer: OffsetBuffer? = nil,
        verticesBuffer: OffsetBuffer? = nil,
        pipelineState: MTLRenderPipelineState,
        depthState: MTLDepthStencilState
    ) {
        self.drawerName = drawerName
        self.device = device
        self.depthState = depthState
        self.indicesBuffer = indicesBuffer
        self.verticesBuffer = verticesBuffer
        self.instancesBuffer = instancesBuffer
        self.pipelineState = pipelineState
    }

    func updateInstanceBufferState(bufferIndex: Int) {
        let offset = instancesBuffer?.size ?? 0 * bufferIndex
        instancesBuffer?.offset = offset
        let newAddress = instancesBuffer?.metalBuffer?.contents().advanced(by: offset)
        instancesBuffer?.currentAddress = newAddress
    }

    func updateIndicesBufferState(bufferIndex: Int) {
        let offset = indicesBuffer?.size ?? 0 * bufferIndex
        indicesBuffer?.offset = offset
        let newAddress = indicesBuffer?.metalBuffer?.contents().advanced(by: offset)
        indicesBuffer?.currentAddress = newAddress
    }

    func getIndex(at position: Int) -> UnsafeMutablePointer<UInt16>? {
        indicesBuffer?.currentAddress?.assumingMemoryBound(
            to: UInt16.self
        ).advanced(by: position)
    }

    func getVertex() -> UnsafeMutablePointer<Float>? {
        verticesBuffer?.metalBuffer?.contents().assumingMemoryBound(to: Float.self)
    }

    func draw(renderEncoder: MTLRenderCommandEncoder) {
        guard
            instanceAnchors.count > 0
        else {
            return
        }

        prepare(
            renderEncoder: renderEncoder,
            groupName: drawerName,
            pipelineState: pipelineState,
            depthState: depthState
        )

        // Set any buffers fed into our render pipeline
        renderEncoder.setVertexBuffer(
            instancesBuffer?.metalBuffer,
            offset: instancesBuffer?.offset ?? 0,
            index: Int(kBufferIndexInstanceUniforms.rawValue)
        )
        renderEncoder.setVertexBuffer(
            sharedUniformBuffer,
            offset: sharedUniformBufferOffset,
            index: Int(kBufferIndexSharedUniforms.rawValue)
        )
        if let texture = modelTextures.first {
            renderEncoder.setFragmentTexture(texture, index: 0)
        }

        drawMesh(meshes: modelMeshes, renderEncoder: renderEncoder, instanceCount: instanceAnchors.count)
        renderEncoder.popDebugGroup()
    }

    func draw(renderEncoder: MTLRenderCommandEncoder, indicesCount: Int) {
        guard
            let indicesBuffer,
            let indicesMetalBuffer = indicesBuffer.metalBuffer
        else {
            return
        }
        prepare(
            renderEncoder: renderEncoder,
            groupName: drawerName,
            pipelineState: pipelineState,
            depthState: depthState
        )
        renderEncoder.setVertexBuffer(
            instancesBuffer?.metalBuffer,
            offset: instancesBuffer?.offset ?? 0,
            index: Int(kBufferIndexInstanceUniforms.rawValue)
        )
        renderEncoder.setVertexBuffer(
            sharedUniformBuffer,
            offset: sharedUniformBufferOffset,
            index: Int(kBufferIndexSharedUniforms.rawValue)
        )
        renderEncoder.drawIndexedPrimitives(
            type: .triangle,
            indexCount: indicesCount,
            indexType: .uint16,
            indexBuffer: indicesMetalBuffer,
            indexBufferOffset: indicesBuffer.offset
        )

        renderEncoder.popDebugGroup()
    }

    func draw(renderEncoder: MTLRenderCommandEncoder, indicesCount: Int, instancesCount: Int) {
        guard
            let indicesBuffer,
            let indicesMetalBuffer = indicesBuffer.metalBuffer,
            instanceAnchors.count > 0
        else {
            return
        }
        prepare(
            renderEncoder: renderEncoder,
            groupName: drawerName,
            pipelineState: pipelineState,
            depthState: depthState
        )

        // Set any buffers fed into our render pipeline
        renderEncoder.setVertexBuffer(
            instancesBuffer?.metalBuffer,
            offset: instancesBuffer?.offset ?? 0,
            index: Int(kBufferIndexInstanceUniforms.rawValue)
        )
        renderEncoder.setVertexBuffer(
            verticesBuffer?.metalBuffer,
            offset: verticesBuffer?.offset ?? 0,
            index: Int(kBufferIndexInstanceVertices.rawValue)
        )
        renderEncoder.setVertexBuffer(
            sharedUniformBuffer,
            offset: sharedUniformBufferOffset,
            index: Int(kBufferIndexSharedUniforms.rawValue)
        )
        for (index, texture) in modelTextures.enumerated() {
            renderEncoder.setFragmentTexture(texture, index: index)
        }

        // Set mesh's vertex buffers
        renderEncoder.drawIndexedPrimitives(
            type: .triangle,
            indexCount: indicesCount,
            indexType: .uint16,
            indexBuffer: indicesMetalBuffer,
            indexBufferOffset: indicesBuffer.offset,
            instanceCount: instancesCount
        )

        renderEncoder.popDebugGroup()
    }

    func draw(renderEncoder: MTLRenderCommandEncoder, textures: [MTLTexture], vertexCount: Int) {
        // Push a debug group allowing us to identify render commands in the GPU Frame Capture tool
        renderEncoder.pushDebugGroup(drawerName)

        // Set render command encoder state
        renderEncoder.setCullMode(.none)
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setDepthStencilState(depthState)

        // Set mesh's vertex buffers
        renderEncoder.setVertexBuffer(
            verticesBuffer?.metalBuffer,
            offset: verticesBuffer?.offset ?? 0,
            index: Int(kBufferIndexMeshPositions.rawValue)
        )

        // Set any textures read/sampled from our render pipeline
        for (index, texture) in textures.enumerated() {
            renderEncoder.setFragmentTexture(texture, index: index)
        }

        // Draw each submesh of our mesh
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: vertexCount)
        renderEncoder.popDebugGroup()
    }

    func removeInstanceAnchors(from session: ARSession) {
        instanceAnchors.forEach { session.remove(anchor: $0) }
        instanceAnchors.removeAll()
    }

    private func prepare(
        renderEncoder: MTLRenderCommandEncoder,
        groupName: String,
        pipelineState: MTLRenderPipelineState,
        depthState: MTLDepthStencilState
    ) {
        // Push a debug group allowing us to identify render commands in the GPU Frame Capture tool
        renderEncoder.pushDebugGroup(groupName)

        // Set render command encoder state
        renderEncoder.setCullMode(.back)
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setDepthStencilState(depthState)

        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.sAddressMode = .clampToEdge
        samplerDescriptor.tAddressMode = .clampToEdge

        // Create a sampler state
        let samplerState = device.makeSamplerState(descriptor: samplerDescriptor)!

        // Assume renderEncoder is a valid MTLRenderCommandEncoder
        renderEncoder.setFragmentSamplerState(samplerState, index: 0)
    }

    private func drawMesh(meshes: [MTKMesh], renderEncoder: MTLRenderCommandEncoder, instanceCount: Int) {
        for modelMesh in meshes {
            for bufferIndex in 0 ..< modelMesh.vertexBuffers.count {
                let vertexBuffer = modelMesh.vertexBuffers[bufferIndex]
                renderEncoder.setVertexBuffer(vertexBuffer.buffer, offset: vertexBuffer.offset, index: bufferIndex)
            }
            // Draw each submesh of our mesh
            for submesh in modelMesh.submeshes {
                renderEncoder.drawIndexedPrimitives(
                    type: submesh.primitiveType,
                    indexCount: submesh.indexCount,
                    indexType: submesh.indexType,
                    indexBuffer: submesh.indexBuffer.buffer,
                    indexBufferOffset: submesh.indexBuffer.offset,
                    instanceCount: instanceCount
                )
            }
        }
    }
}
