//
//  ARDrawerBuilder.swift
//  TruvideoSdkCamera
//
//  Created by Luis Francisco Piura Mejia on 17/6/24.
//

import ARKit
import MetalKit

final class ARRendererBuilder {

    private static let maxAnchorInstanceCount = 64
    private static let maxBuffersInFlight: Int = 3

    private static let textIndicesCount = 12
    private static let textVerticesCount = 8
    private static let textIndicesBufferSize = ((MemoryLayout<UInt16>.size * textIndicesCount) & ~0xFF) + 0x100
    private static let textVerticesBufferSize =
        ((MemoryLayout<MeasureTextVertex>.size * textVerticesCount) & ~0xFF) + 0x100

    private static let measureLineVerticesCount = 22
    private static let measureLineIndicesCount = 120
    private static let measureLineBufferSize =
        ((MemoryLayout<MeasureUniforms>.size * measureLineVerticesCount * maxAnchorInstanceCount) & ~0xFF) + 0x100
    private static let measureLineIndicesBufferSize =
        ((MemoryLayout<UInt16>.size * measureLineIndicesCount * maxAnchorInstanceCount) & ~0xFF) + 0x100

    private static let measureTextBufferSize =
        ((MemoryLayout<InstanceUniforms>.size * maxAnchorInstanceCount) & ~0xFF) + 0x100

    private static let measurePreviewBufferSize =
        ((MemoryLayout<InstanceUniforms>.size * maxAnchorInstanceCount) & ~0xFF) + 0x100

    private static let measureEdgeBufferSize =
        ((MemoryLayout<InstanceUniforms>.size * maxAnchorInstanceCount) & ~0xFF) + 0x100

    private static let targetBufferSize = ((MemoryLayout<InstanceUniforms>.size) & ~0xFF) + 0x100

    private static let modelsBufferSize =
        ((MemoryLayout<InstanceUniforms>.size * maxAnchorInstanceCount) & ~0xFF) + 0x100

    private static let sharedUniformsBufferSize = (MemoryLayout<SharedUniforms>.size & ~0xFF) + 0x100

    private static let cameraImageVertices: [Float] = [
        -1.0, -1.0, 0.0, 1.0,
        1.0, -1.0, 1.0, 1.0,
        -1.0, 1.0, 0.0, 0.0,
        1.0, 1.0, 1.0, 0.0,
    ]

    static func makeARRenderer(
        arSession: ARSession,
        device: MTLDevice,
        commandQueue: MTLCommandQueue,
        renderDestinationProvider: RenderDestinationProvider
    ) throws -> ARRenderer {
        let geometryVertexDescriptor = make3DObjectsVertexDescriptor()
        guard
            let sharedUniformsBuffer = createBuffer(
                device: device,
                label: "SharedUniformBuffer",
                size: sharedUniformsBufferSize,
                maxBufferCount: maxBuffersInFlight,
                options: .storageModeShared
            ),
            let capturedImageDepthState = makeDepthState(
                device: device,
                compareFunction: .always,
                isDepthEnabled: false
            ),
            let modelsDepthState = makeDepthState(device: device, compareFunction: .less, isDepthEnabled: true),
            let measureTextDrawer = makeMeasureTextDrawer(
                device: device,
                renderDestination: renderDestinationProvider,
                depthState: modelsDepthState
            ),
            let modelsDrawer = make3DModelsDrawer(
                device: device,
                renderDestination: renderDestinationProvider,
                geometryVertexDescriptor: geometryVertexDescriptor,
                depthState: modelsDepthState
            ),
            let cameraImageDrawer = makeCameraImageDrawer(
                device: device,
                renderDestination: renderDestinationProvider,
                depthState: capturedImageDepthState
            ),
            let targetDrawer = makeTargetDrawer(
                device: device,
                renderDestination: renderDestinationProvider,
                geometryVertexDescriptor: geometryVertexDescriptor,
                depthState: modelsDepthState
            ),
            let measureEdgesDrawer = makeMeasureEdgesDrawer(
                device: device,
                renderDestination: renderDestinationProvider,
                geometryVertexDescriptor: geometryVertexDescriptor,
                depthState: modelsDepthState
            ),
            let measurePreviewDrawer = makeMeasurePreviewDrawer(
                device: device,
                renderDestination: renderDestinationProvider,
                geometryVertexDescriptor: geometryVertexDescriptor,
                depthState: modelsDepthState
            ),
            let measureTextPreviewDrawer = makeMeasureTextPreviewDrawer(
                device: device,
                renderDestination: renderDestinationProvider,
                depthState: modelsDepthState
            ),
            let measureLineDrawer = makeMeasureLineDrawer(
                device: device,
                renderDestination: renderDestinationProvider,
                depthState: modelsDepthState
            )
        else {
            throw TruVideoError(kind: .failedToLoadAR)
        }
        let drawers = ARRendererDrawers(
            cameraImageDrawer: cameraImageDrawer,
            modelsDrawer: modelsDrawer,
            targetDrawer: targetDrawer,
            measureEdgesDrawer: measureEdgesDrawer,
            measurePreviewDrawer: measurePreviewDrawer,
            measureLinesDrawer: measureLineDrawer,
            measureTextDrawer: measureTextDrawer,
            measureTextPreviewDrawer: measureTextPreviewDrawer
        )
        return TruvideoARRenderer(
            maxBuffersInFlight: maxBuffersInFlight,
            maxAnchorInstanceCount: maxAnchorInstanceCount,
            session: arSession,
            cameraImageVertices: cameraImageVertices,
            metalComponents: ARRendererMetalComponents(
                device: device,
                commandQueue: commandQueue,
                geometryVertexDescriptor: geometryVertexDescriptor
            ),
            sharedUniformBuffer: OffsetBuffer(
                size: sharedUniformsBufferSize,
                metalBuffer: sharedUniformsBuffer,
                offset: 0
            ),
            renderDestination: renderDestinationProvider,
            drawers: drawers
        )
    }

    // MARK: - Private

    private static func createBuffer(
        device: MTLDevice,
        label: String,
        size: Int,
        maxBufferCount: Int,
        options: MTLResourceOptions = []
    ) -> MTLBuffer? {
        let buffer = device.makeBuffer(length: size * maxBufferCount, options: options)
        buffer?.label = label
        return buffer
    }

    private static func createPipeline(
        device: MTLDevice,
        name: String,
        vertexFunctionName: String,
        fragmentFunctionName: String,
        destinationProvider: RenderDestinationProvider,
        vertexDescriptor: MTLVertexDescriptor? = nil
    ) throws -> MTLRenderPipelineState {
        let defaultLibrary = try device.makeDefaultLibrary(bundle: Bundle(for: TruvideoARRenderer.self))
        let vertexFunction = defaultLibrary.makeFunction(name: vertexFunctionName)!
        let fragmentFunction = defaultLibrary.makeFunction(name: fragmentFunctionName)!
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.label = name
        pipelineStateDescriptor.rasterSampleCount = destinationProvider.sampleCount
        pipelineStateDescriptor.vertexFunction = vertexFunction
        pipelineStateDescriptor.fragmentFunction = fragmentFunction
        pipelineStateDescriptor.vertexDescriptor = vertexDescriptor
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = destinationProvider.colorPixelFormat
        pipelineStateDescriptor.depthAttachmentPixelFormat = destinationProvider.depthStencilPixelFormat
        pipelineStateDescriptor.stencilAttachmentPixelFormat = destinationProvider.depthStencilPixelFormat

        let colorAttachment = pipelineStateDescriptor.colorAttachments[0]
        colorAttachment?.isBlendingEnabled = true
        colorAttachment?.sourceRGBBlendFactor = .sourceAlpha
        colorAttachment?.destinationRGBBlendFactor = .oneMinusSourceAlpha
        colorAttachment?.sourceAlphaBlendFactor = .sourceAlpha
        colorAttachment?.destinationAlphaBlendFactor = .oneMinusSourceAlpha

        return try device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    }

    private static func makeInstancesBuffer(
        device: MTLDevice,
        label: String,
        size: Int,
        maxBufferCount: Int
    ) -> MTLBuffer? {
        createBuffer(
            device: device,
            label: label,
            size: size,
            maxBufferCount: maxBufferCount,
            options: .storageModeShared
        )
    }

    private static func makeDepthState(
        device: MTLDevice,
        compareFunction: MTLCompareFunction,
        isDepthEnabled: Bool
    ) -> MTLDepthStencilState? {
        let depthStateDescriptor = MTLDepthStencilDescriptor()
        depthStateDescriptor.depthCompareFunction = compareFunction
        depthStateDescriptor.isDepthWriteEnabled = isDepthEnabled
        return device.makeDepthStencilState(descriptor: depthStateDescriptor)
    }

    private static func makeMeasureTextDrawer(
        device: MTLDevice,
        renderDestination: RenderDestinationProvider,
        depthState: MTLDepthStencilState
    ) -> ARDrawer? {
        guard
            let pipelineState = try? createPipeline(
                device: device,
                name: "MeasureTextDrawerPipeline",
                vertexFunctionName: "anchorGeometryMeasureTextTransform",
                fragmentFunctionName: "anchorGeometryMeasureTextLightning",
                destinationProvider: renderDestination
            )
        else {
            return nil
        }
        let verticesBuffer = device.makeBuffer(
            bytes: getTextVertices(size: CGSize(width: 100, height: 50)),
            length: textVerticesBufferSize,
            options: .storageModeShared
        )
        let indicesBuffer = device.makeBuffer(
            bytes: getTextVerticesIndices(),
            length: textIndicesBufferSize,
            options: .storageModeShared
        )
        let instancesBuffer = makeInstancesBuffer(
            device: device,
            label: "TextDrawerBuffer",
            size: measureTextBufferSize,
            maxBufferCount: maxBuffersInFlight
        )
        return TruvideoARDrawer(
            drawerName: "MeasureTextDrawer",
            device: device,
            instancesBuffer: OffsetBuffer(
                size: measureTextBufferSize,
                metalBuffer: instancesBuffer
            ),
            indicesBuffer: OffsetBuffer(
                size: textIndicesBufferSize,
                elementsCount: textIndicesCount,
                metalBuffer: indicesBuffer
            ),
            verticesBuffer: OffsetBuffer(
                size: textVerticesBufferSize,
                metalBuffer: verticesBuffer
            ),
            pipelineState: pipelineState,
            depthState: depthState
        )
    }

    private static func make3DModelsDrawer(
        device: MTLDevice,
        renderDestination: RenderDestinationProvider,
        geometryVertexDescriptor: MTLVertexDescriptor,
        depthState: MTLDepthStencilState
    ) -> ARDrawer? {
        guard
            let pipelineState = try? createPipeline(
                device: device,
                name: "ModelsDrawerPipeline",
                vertexFunctionName: "anchorGeometryVertexTransform",
                fragmentFunctionName: "anchorGeometryFragmentLighting",
                destinationProvider: renderDestination,
                vertexDescriptor: geometryVertexDescriptor
            )
        else {
            return nil
        }
        let instancesBuffer = makeInstancesBuffer(
            device: device,
            label: "ModelsDrawerBuffer",
            size: modelsBufferSize,
            maxBufferCount: maxBuffersInFlight
        )
        return TruvideoARDrawer(
            drawerName: "ModelsDrawer",
            device: device,
            instancesBuffer: OffsetBuffer(
                size: modelsBufferSize,
                metalBuffer: instancesBuffer
            ),
            pipelineState: pipelineState,
            depthState: depthState
        )
    }

    private static func makeTargetDrawer(
        device: MTLDevice,
        renderDestination: RenderDestinationProvider,
        geometryVertexDescriptor: MTLVertexDescriptor,
        depthState: MTLDepthStencilState
    ) -> ARDrawer? {
        guard
            let pipelineState = try? createPipeline(
                device: device,
                name: "TargetDrawerPipeline",
                vertexFunctionName: "anchorGeometryVertexTransform",
                fragmentFunctionName: "targetAnchorGeometryFragmentLighting",
                destinationProvider: renderDestination,
                vertexDescriptor: geometryVertexDescriptor
            )
        else {
            return nil
        }
        let instancesBuffer = makeInstancesBuffer(
            device: device,
            label: "TargetDrawerBuffer",
            size: targetBufferSize,
            maxBufferCount: maxBuffersInFlight
        )
        return TruvideoARDrawer(
            drawerName: "TargetDrawer",
            device: device,
            instancesBuffer: OffsetBuffer(
                size: targetBufferSize,
                metalBuffer: instancesBuffer
            ),
            pipelineState: pipelineState,
            depthState: depthState
        )
    }

    private static func makeMeasureEdgesDrawer(
        device: MTLDevice,
        renderDestination: RenderDestinationProvider,
        geometryVertexDescriptor: MTLVertexDescriptor,
        depthState: MTLDepthStencilState
    ) -> ARDrawer? {
        guard
            let pipelineState = try? createPipeline(
                device: device,
                name: "MeasureEdgesDrawerPipeline",
                vertexFunctionName: "anchorGeometryVertexTransform",
                fragmentFunctionName: "measureAnchorGeometryFragmentLighting",
                destinationProvider: renderDestination,
                vertexDescriptor: geometryVertexDescriptor
            )
        else {
            return nil
        }
        let instancesBuffer = makeInstancesBuffer(
            device: device,
            label: "MeasureEdgesDrawerBuffer",
            size: measureEdgeBufferSize,
            maxBufferCount: maxBuffersInFlight
        )
        return TruvideoARDrawer(
            drawerName: "MeasureEdgesDrawer",
            device: device,
            instancesBuffer: OffsetBuffer(
                size: measureEdgeBufferSize,
                metalBuffer: instancesBuffer
            ),
            pipelineState: pipelineState,
            depthState: depthState
        )
    }

    private static func makeMeasurePreviewDrawer(
        device: MTLDevice,
        renderDestination: RenderDestinationProvider,
        geometryVertexDescriptor: MTLVertexDescriptor,
        depthState: MTLDepthStencilState
    ) -> ARDrawer? {
        guard
            let pipelineState = try? createPipeline(
                device: device,
                name: "MeasurePreviewDrawerPipeline",
                vertexFunctionName: "anchorGeometryVertexTransform",
                fragmentFunctionName: "measurePreviewGeometryFragmentLighting",
                destinationProvider: renderDestination,
                vertexDescriptor: geometryVertexDescriptor
            )
        else {
            return nil
        }
        let instancesBuffer = makeInstancesBuffer(
            device: device,
            label: "MeasurePreviewDrawerBuffer",
            size: measurePreviewBufferSize,
            maxBufferCount: maxBuffersInFlight
        )
        return TruvideoARDrawer(
            drawerName: "MeasurePreviewDrawer",
            device: device,
            instancesBuffer: OffsetBuffer(
                size: measurePreviewBufferSize,
                metalBuffer: instancesBuffer
            ),
            pipelineState: pipelineState,
            depthState: depthState
        )
    }

    private static func makeMeasureTextPreviewDrawer(
        device: MTLDevice,
        renderDestination: RenderDestinationProvider,
        depthState: MTLDepthStencilState
    ) -> ARDrawer? {
        guard
            let pipelineState = try? createPipeline(
                device: device,
                name: "MeasureTextPreviewDrawerPipeline",
                vertexFunctionName: "anchorGeometryMeasureTextTransform",
                fragmentFunctionName: "anchorGeometryMeasureTextLightning",
                destinationProvider: renderDestination
            )
        else {
            return nil
        }
        let verticesBuffer = device.makeBuffer(
            bytes: getTextVertices(size: CGSize(width: 100, height: 50), transparent: true),
            length: textVerticesBufferSize,
            options: .storageModeShared
        )
        let indicesBuffer = device.makeBuffer(
            bytes: getTextVerticesIndices(),
            length: textIndicesBufferSize,
            options: .storageModeShared
        )
        let instancesBuffer = makeInstancesBuffer(
            device: device,
            label: "MeasureTextPreviewDrawerBuffer",
            size: measureTextBufferSize,
            maxBufferCount: maxBuffersInFlight
        )
        return TruvideoARDrawer(
            drawerName: "MeasureTextPreviewDrawer",
            device: device,
            instancesBuffer: OffsetBuffer(
                size: measureTextBufferSize,
                metalBuffer: instancesBuffer
            ),
            indicesBuffer: OffsetBuffer(
                size: textIndicesBufferSize,
                elementsCount: textIndicesCount,
                metalBuffer: indicesBuffer
            ),
            verticesBuffer: OffsetBuffer(
                size: textVerticesBufferSize,
                metalBuffer: verticesBuffer
            ),
            pipelineState: pipelineState,
            depthState: depthState
        )
    }

    private static func makeMeasureLineDrawer(
        device: MTLDevice,
        renderDestination: RenderDestinationProvider,
        depthState: MTLDepthStencilState
    ) -> ARDrawer? {
        guard
            let pipelineState = try? createPipeline(
                device: device,
                name: "MeasureLinesDrawerPipeline",
                vertexFunctionName: "measureLineGeometryVertexTransform",
                fragmentFunctionName: "measureLineGeometryFragmentLightning",
                destinationProvider: renderDestination
            )
        else {
            return nil
        }
        let indicesBuffer = createBuffer(
            device: device,
            label: "MeasureLineVerticesBuffer",
            size: measureLineIndicesBufferSize,
            maxBufferCount: maxBuffersInFlight
        )
        let instancesBuffer = makeInstancesBuffer(
            device: device,
            label: "MeasureLinesDrawerBuffer",
            size: measureLineBufferSize,
            maxBufferCount: maxBuffersInFlight
        )
        return TruvideoARDrawer(
            drawerName: "MeasureLinesDrawer",
            device: device,
            instancesBuffer: OffsetBuffer(
                size: measureLineBufferSize,
                metalBuffer: instancesBuffer
            ),
            indicesBuffer: OffsetBuffer(
                size: measureLineIndicesBufferSize,
                elementsCount: measureLineIndicesCount,
                metalBuffer: indicesBuffer
            ),
            pipelineState: pipelineState,
            depthState: depthState
        )
    }

    private static func makeCameraImageDrawer(
        device: MTLDevice,
        renderDestination: RenderDestinationProvider,
        depthState: MTLDepthStencilState
    ) -> ARDrawer? {
        let imagePlaneVertexDataCount = cameraImageVertices.count * MemoryLayout<Float>.size
        let verticesBuffer = device.makeBuffer(
            bytes: cameraImageVertices,
            length: imagePlaneVertexDataCount,
            options: []
        )

        let imagePlaneVertexDescriptor = MTLVertexDescriptor()

        // Positions.
        imagePlaneVertexDescriptor.attributes[0].format = .float2
        imagePlaneVertexDescriptor.attributes[0].offset = 0
        imagePlaneVertexDescriptor.attributes[0].bufferIndex = Int(kBufferIndexMeshPositions.rawValue)

        // Texture coordinates.
        imagePlaneVertexDescriptor.attributes[1].format = .float2
        imagePlaneVertexDescriptor.attributes[1].offset = 8
        imagePlaneVertexDescriptor.attributes[1].bufferIndex = Int(kBufferIndexMeshPositions.rawValue)

        // Buffer Layout
        imagePlaneVertexDescriptor.layouts[0].stride = 16
        imagePlaneVertexDescriptor.layouts[0].stepRate = 1
        imagePlaneVertexDescriptor.layouts[0].stepFunction = .perVertex

        guard
            let pipelineState = try? createPipeline(
                device: device,
                name: "CameraImageDrawerPipeline",
                vertexFunctionName: "capturedImageVertexTransform",
                fragmentFunctionName: "capturedImageFragmentShader",
                destinationProvider: renderDestination,
                vertexDescriptor: imagePlaneVertexDescriptor
            )
        else {
            return nil
        }
        return TruvideoARDrawer(
            drawerName: "CameraImageDrawer",
            device: device,
            instancesBuffer: nil,
            verticesBuffer: OffsetBuffer(
                size: imagePlaneVertexDataCount,
                metalBuffer: verticesBuffer
            ),
            pipelineState: pipelineState,
            depthState: depthState
        )
    }

    private static func make3DObjectsVertexDescriptor() -> MTLVertexDescriptor {
        // Create a vertex descriptor for our Metal pipeline. Specifies the layout of vertices the
        //   pipeline should expect. The layout below keeps attributes used to calculate vertex shader
        //   output position separate (world position, skinning, tweening weights) separate from other
        //   attributes (texture coordinates, normals).  This generally maximizes pipeline efficiency
        let geometryVertexDescriptor = MTLVertexDescriptor()
        // Positions.
        geometryVertexDescriptor.attributes[0].format = .float3
        geometryVertexDescriptor.attributes[0].offset = 0
        geometryVertexDescriptor.attributes[0].bufferIndex = Int(kBufferIndexMeshPositions.rawValue)

        // Texture coordinates.
        geometryVertexDescriptor.attributes[1].format = .float2
        geometryVertexDescriptor.attributes[1].offset = 0
        geometryVertexDescriptor.attributes[1].bufferIndex = Int(kBufferIndexMeshGenerics.rawValue)

        // Normals.
        geometryVertexDescriptor.attributes[2].format = .half3
        geometryVertexDescriptor.attributes[2].offset = 8
        geometryVertexDescriptor.attributes[2].bufferIndex = Int(kBufferIndexMeshGenerics.rawValue)

        // Position Buffer Layout
        geometryVertexDescriptor.layouts[0].stride = 12
        geometryVertexDescriptor.layouts[0].stepRate = 1
        geometryVertexDescriptor.layouts[0].stepFunction = .perVertex

        // Generic Attribute Buffer Layout
        geometryVertexDescriptor.layouts[1].stride = 16
        geometryVertexDescriptor.layouts[1].stepRate = 1
        geometryVertexDescriptor.layouts[1].stepFunction = .perVertex

        return geometryVertexDescriptor
    }

    private static func getTextVertices(size: CGSize, transparent: Bool = false) -> [MeasureTextVertex] {
        let width = Float(size.width / size.height)
        let height: Float = 1.0

        return [
            MeasureTextVertex(
                position: .init(-width / 2, height / 2, 0),
                texture: .init(0, 1),
                inverTexture: true,
                transparent: transparent
            ),
            MeasureTextVertex(
                position: .init(-width / 2, -height / 2, 0),
                texture: .init(0, 0),
                inverTexture: true,
                transparent: transparent
            ),
            MeasureTextVertex(
                position: .init(width / 2, -height / 2, 0),
                texture: .init(1, 0),
                inverTexture: true,
                transparent: transparent
            ),
            MeasureTextVertex(
                position: .init(width / 2, height / 2, 0),
                texture: .init(1, 1),
                inverTexture: true,
                transparent: transparent
            ),
            MeasureTextVertex(
                position: .init(-width / 2, height / 2, 0),
                texture: .init(0, 1),
                inverTexture: false,
                transparent: transparent
            ),
            MeasureTextVertex(
                position: .init(-width / 2, -height / 2, 0),
                texture: .init(0, 0),
                inverTexture: false,
                transparent: transparent
            ),
            MeasureTextVertex(
                position: .init(width / 2, -height / 2, 0),
                texture: .init(1, 0),
                inverTexture: false,
                transparent: transparent
            ),
            MeasureTextVertex(
                position: .init(width / 2, height / 2, 0),
                texture: .init(1, 1),
                inverTexture: false,
                transparent: transparent
            ),
        ]
    }

    private static func getTextVerticesIndices() -> [UInt16] {
        [
            0, 1, 2,
            2, 3, 0,
            4, 3, 6,
            6, 5, 4,
        ]
    }

}
