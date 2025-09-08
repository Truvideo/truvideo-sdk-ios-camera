//
//  Renderer.swift
//  MetalARRecorder
//
//  Created by Luis Francisco Piura Mejia on 25/3/24.
//

import ARKit
import Combine
import Foundation
import Metal
import MetalKit
import RealityKit
import UIKit
import simd

protocol RenderDestinationProvider: AnyObject {
    var currentRenderPassDescriptor: MTLRenderPassDescriptor? { get }
    var currentDrawable: CAMetalDrawable? { get }
    var colorPixelFormat: MTLPixelFormat { get set }
    var depthStencilPixelFormat: MTLPixelFormat { get set }
    var sampleCount: Int { get set }
}

typealias ARRendererFrameRenderHandler = (CVPixelBuffer) -> Void

/// Protocol used to render the AR camera image and 3D objects
/// To perform the drawing actions the renderer interacts with a list of drawers that performs specific drawing tasks
/// such as:
/// 1. Rendering the AR Camera image
/// 2. Rendering the marker elements
/// 3. Rendering the measure preview
/// 4. Rendering the measure text
/// 5. Rendering the measure edges and lines
protocol ARRenderer: AnyObject {
    /// Publisher that notifies when undo and clear actions are enabled
    var enableDeletionActions: AnyPublisher<Bool, Never> { get set }
    /// Publisher that notifies the renderer mode changes
    var mode: AnyPublisher<ARRendererMode, Never> { get set }
    /// Metal components used to perform metal tasks
    var metalComponents: ARRendererMetalComponents { get }
    /// The AR session used to get the camera frames
    var session: ARSession { get set }
    /// Flag to stop or resume the renderer operations
    var isRendering: Bool { get set }
    /// Destination that provides metal configurations such as pixel format and sample count
    var renderDestination: RenderDestinationProvider { get set }
    /// Handler that provides the processed frame
    var renderHandler: ARRendererFrameRenderHandler? { get set }
    /// Has existing active actions
    var hasActiveActions: Bool { get }

    /// Method used to update the image displayed by the ARRenderer, for our implementation
    /// this method is called 60 times per second by a Metal view, on every call the next tasks are performed:
    ///  1. Update the buffers passed to the metal shader
    ///  2. Update the shared uniforms which are projection matrices that will help to apply perspective to the 3D objects
    ///  3. Update every 3D element transform
    ///  4. Render the ARSession frame as an RGB frame that can be displayed in a 2D view
    func update()
    /// Method used to adapt the size of the metal view
    func drawRectResized(size: CGSize)
    /// Method used to add 3D elements to the AR camera based on the current ARRenderer mode
    func draw()
    /// Remove the last added 3D object or measure
    func undo()
    /// Remove all 3D objects
    func clear()
    /// Enable the ruler mode with a given measure unit
    func enableRulerMode(unit: ARRendererMeasureUnit)
    /// Enable markers mode
    func enablePinObjectsMode()
    /// This method disables the 3D objects adding feature and hides the pointer so the recording is easier to do
    func disableModes()
}

struct ARRendererMetalComponents {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let geometryVertexDescriptor: MTLVertexDescriptor
}

enum ARRendererMode: Equatable {
    case ruler(unit: ARRendererMeasureUnit)
    case pinObjects
    case none
}

enum ARRendererMeasureUnit: Equatable {
    case centimeters
    case inches
}

struct ARRendererDrawers {
    let cameraImageDrawer: ARDrawer
    let modelsDrawer: ARDrawer
    let targetDrawer: ARDrawer
    let measureEdgesDrawer: ARDrawer
    let measurePreviewDrawer: ARDrawer
    let measureLinesDrawer: ARDrawer
    let measureTextDrawer: ARDrawer
    let measureTextPreviewDrawer: ARDrawer

    func updateOffsets(sharedUniformBuffer: OffsetBuffer) {
        modelsDrawer.sharedUniformBuffer = sharedUniformBuffer.metalBuffer
        modelsDrawer.sharedUniformBufferOffset = sharedUniformBuffer.offset
        targetDrawer.sharedUniformBuffer = sharedUniformBuffer.metalBuffer
        targetDrawer.sharedUniformBufferOffset = sharedUniformBuffer.offset
        measureEdgesDrawer.sharedUniformBuffer = sharedUniformBuffer.metalBuffer
        measureEdgesDrawer.sharedUniformBufferOffset = sharedUniformBuffer.offset
        measurePreviewDrawer.sharedUniformBuffer = sharedUniformBuffer.metalBuffer
        measurePreviewDrawer.sharedUniformBufferOffset = sharedUniformBuffer.offset
        measureLinesDrawer.sharedUniformBuffer = sharedUniformBuffer.metalBuffer
        measureLinesDrawer.sharedUniformBufferOffset = sharedUniformBuffer.offset
        measureTextDrawer.sharedUniformBuffer = sharedUniformBuffer.metalBuffer
        measureTextDrawer.sharedUniformBufferOffset = sharedUniformBuffer.offset
        measureTextPreviewDrawer.sharedUniformBuffer = sharedUniformBuffer.metalBuffer
        measureTextPreviewDrawer.sharedUniformBufferOffset = sharedUniformBuffer.offset
    }
}

class TruvideoARRenderer: ARRenderer {

    private enum AssetSource {
        case localFile(name: String, extension: String)
        case primitive(mesh: MDLMesh)
    }

    private enum Action {
        case measure
        case pinObject
    }

    var session: ARSession
    let cameraImageVertices: [Float]
    let metalComponents: ARRendererMetalComponents
    var renderDestination: RenderDestinationProvider
    var renderHandler: ARRendererFrameRenderHandler?
    var isRendering = true

    // MARK: - Buffers

    private var sharedUniformBuffer: OffsetBuffer
    private let maxAnchorInstanceCount: Int
    private let maxBuffersInFlight: Int

    // MARK: - Drawers
    private let drawers: ARRendererDrawers

    // MARK: - Buffer offsets

    // MARK: - Buffer pointers
    private var sharedUniformBufferAddress: UnsafeMutableRawPointer?

    private var capturedImageTextureY: CVMetalTexture?
    private var capturedImageTextureCbCr: CVMetalTexture?
    private var capturedImageTextureRBG: CVMetalTexture?

    private lazy var inFlightSemaphore = DispatchSemaphore(value: maxBuffersInFlight)

    private var measures = [Measure]()

    // Captured image texture cache
    private var capturedImageTextureCache: CVMetalTextureCache?

    // Used to determine _uniformBufferStride each frame.
    //   This is the current frame number modulo kMaxBuffersInFlight
    private var uniformBufferIndex = 0

    private var firstMeasureAnchorTransform: matrix_float4x4?

    // The number of anchor instances to render
    private var anchorInstanceCount = 0

    // The current viewport size
    private var viewportSize = CGSize()

    // Flag for viewport size changes
    private var viewportSizeDidChange = false

    private var measureInProgress = false
    @Published private var _mode = ARRendererMode.pinObjects
    lazy var mode: AnyPublisher<ARRendererMode, Never> = {
        $_mode.eraseToAnyPublisher()
    }()
    @Published private var _enableDeletionActions = false
    lazy var enableDeletionActions: AnyPublisher<Bool, Never> = {
        $_enableDeletionActions.eraseToAnyPublisher()
    }()

    private var actions = [Action]()
    /// Has existing active actions
    var hasActiveActions: Bool { !actions.isEmpty }
    private var cachedMeasuresText = [String: MTLTexture]()

    // MARK: - Fallback mechanisms for reliability
    /// Stores the last successful focus icon position as backup when detection fails
    private var lastValidTargetTransform: matrix_float4x4?

    /// Counts consecutive raycast failures to limit fallback attempts
    private var consecutiveRaycastFailures = 0

    /// Maximum consecutive raycast failures before giving up on fallbacks
    private let maxConsecutiveFailures = 5

    /// Recent successful raycast distances for realistic virtual target placement
    private var recentRaycastDistances: [Float] = []

    /// Maximum distance history entries to keep in memory
    private let maxDistanceHistory = 10

    init(
        maxBuffersInFlight: Int,
        maxAnchorInstanceCount: Int,
        session: ARSession,
        cameraImageVertices: [Float],
        metalComponents: ARRendererMetalComponents,
        sharedUniformBuffer: OffsetBuffer,
        renderDestination: RenderDestinationProvider,
        drawers: ARRendererDrawers
    ) {
        self.maxBuffersInFlight = maxBuffersInFlight
        self.maxAnchorInstanceCount = maxAnchorInstanceCount
        self.session = session
        self.metalComponents = metalComponents
        self.sharedUniformBuffer = sharedUniformBuffer
        self.renderDestination = renderDestination
        self.drawers = drawers
        self.cameraImageVertices = cameraImageVertices

        // Create captured image texture cache
        var textureCache: CVMetalTextureCache?
        CVMetalTextureCacheCreate(nil, nil, metalComponents.device, nil, &textureCache)
        capturedImageTextureCache = textureCache
        loadAssets()
    }

    func drawRectResized(size: CGSize) {
        viewportSize = size
        viewportSizeDidChange = true
    }

    func update() {
        // Wait to ensure only kMaxBuffersInFlight are getting processed by any stage in the Metal
        //   pipeline (App, Metal, Drivers, GPU, etc)
        guard isRendering, session.currentFrame != nil else { return }
        let _ = inFlightSemaphore.wait(timeout: DispatchTime.distantFuture)

        // Create a new command buffer for each renderpass to the current drawable
        if let commandBuffer = metalComponents.commandQueue.makeCommandBuffer() {
            commandBuffer.label = "MyCommand"

            // Add completion handler which signal _inFlightSemaphore when Metal and the GPU has fully
            //   finished processing the commands we're encoding this frame.  This indicates when the
            //   dynamic buffers, that we're writing to this frame, will no longer be needed by Metal
            //   and the GPU.
            // Retain our CVMetalTextures for the duration of the rendering cycle. The MTLTextures
            //   we use from the CVMetalTextures are not valid unless their parent CVMetalTextures
            //   are retained. Since we may release our CVMetalTexture ivars during the rendering
            //   cycle, we must retain them separately here.
            var textures = [capturedImageTextureY, capturedImageTextureCbCr]
            commandBuffer.addCompletedHandler { [weak self] commandBuffer in
                if let strongSelf = self {
                    strongSelf.inFlightSemaphore.signal()
                }
                textures.removeAll()
            }

            drawers.targetDrawer.removeInstanceAnchors(from: session)
            updateBufferStates()
            addTargetAnchor()
            if let targetAnchorTransform = drawers.targetDrawer.instanceAnchors.first?.transform {
                addMeasurePreviewAnchors(anchorTransform: targetAnchorTransform)
            }
            updateGameState()

            if let renderHandler,
                let renderPassDescriptor = renderDestination.currentRenderPassDescriptor,
                let currentDrawable = renderDestination.currentDrawable,
                let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
            {
                renderEncoder.label = "MyRenderEncoder"
                let cameraTextures =
                    textures
                    .compactMap { $0 }
                    .compactMap { CVMetalTextureGetTexture($0) }
                if cameraTextures.count == 2 {
                    drawers.cameraImageDrawer.draw(
                        renderEncoder: renderEncoder,
                        textures: cameraTextures,
                        vertexCount: 4
                    )
                }
                drawers.modelsDrawer.draw(renderEncoder: renderEncoder)
                drawers.targetDrawer.draw(renderEncoder: renderEncoder)
                drawers.measureEdgesDrawer.draw(renderEncoder: renderEncoder)
                drawers.measurePreviewDrawer.draw(renderEncoder: renderEncoder)
                drawers.measureTextPreviewDrawer.draw(
                    renderEncoder: renderEncoder,
                    indicesCount: drawers.measureTextPreviewDrawer.indicesBuffer?.elementsCount ?? 0,
                    instancesCount: 1
                )
                if !measures.isEmpty {
                    drawers.measureLinesDrawer.draw(
                        renderEncoder: renderEncoder,
                        indicesCount: measures.count * (drawers.measureLinesDrawer.indicesBuffer?.elementsCount ?? 0)
                    )
                    drawers.measureTextDrawer.draw(
                        renderEncoder: renderEncoder,
                        indicesCount: drawers.measureTextDrawer.indicesBuffer?.elementsCount ?? 0,
                        instancesCount: measures.count
                    )
                }

                // We're done encoding commands
                renderEncoder.endEncoding()

                // Schedule a present once the framebuffer is complete using the current drawable
                commandBuffer.present(currentDrawable)
                if let buffer = currentDrawable.texture.createPixelBuffer() {
                    renderHandler(buffer)
                }
            }

            // Finalize rendering here & push the command buffer to the GPU
            commandBuffer.commit()
        }
    }

    func undo() {
        guard !measureInProgress else {
            removeInProgressMeasure()
            enableDeletionActionsIfNeeded()
            return
        }
        guard !actions.isEmpty else { return }
        guard let lastAction = actions.popLast() else { return }
        switch lastAction {
        case .measure:
            measures.removeLast()
            drawers.measureTextDrawer.instanceAnchors.removeLast()
            drawers.measureTextDrawer.modelTextures.removeLast()
            drawers.measureEdgesDrawer.instanceAnchors.removeLast()
            drawers.measureEdgesDrawer.instanceAnchors.removeLast()
        case .pinObject:
            drawers.modelsDrawer.instanceAnchors.removeLast()
        }
        enableDeletionActionsIfNeeded()
    }

    func clear() {
        measureInProgress = false
        firstMeasureAnchorTransform = nil
        measures.removeAll()
        drawers.measureTextDrawer.removeInstanceAnchors(from: session)
        drawers.measureTextDrawer.modelTextures.removeAll()
        drawers.measureEdgesDrawer.removeInstanceAnchors(from: session)
        drawers.modelsDrawer.removeInstanceAnchors(from: session)
        actions.removeAll()
        enableDeletionActionsIfNeeded()
    }

    func enableRulerMode(unit: ARRendererMeasureUnit) {
        if measureInProgress {
            removeInProgressMeasure()
        }
        _mode = .ruler(unit: unit)
        enableDeletionActionsIfNeeded()
    }

    func enablePinObjectsMode() {
        _mode = .pinObjects
        enableDeletionActionsIfNeeded()
    }

    func disableModes() {
        _mode = .none
        enableDeletionActionsIfNeeded()
    }

    func draw() {
        switch _mode {
        case .ruler:
            addMeasureAnchor()
        case .pinObjects:
            add3DModelAnchor()
        default:
            break
        }
        enableDeletionActionsIfNeeded()
    }

    // MARK: - Private

    private func loadAssets() {
        let metalAllocator = MTKMeshBufferAllocator(device: metalComponents.device)
        drawers.modelsDrawer.modelMeshes = loadAsset(
            assetSource: .localFile(name: "arrow", extension: "usdz"),
            metalAllocator: metalAllocator,
            loadTexture: true
        )
        drawers.targetDrawer.modelMeshes = loadAsset(
            assetSource: .localFile(name: "pointer", extension: "obj"),
            metalAllocator: metalAllocator,
            loadTexture: false
        )
        drawers.measureEdgesDrawer.modelMeshes = loadAsset(
            assetSource: .primitive(
                mesh: MDLMesh(
                    sphereWithExtent: vector3(0.0075, 0.0075, 0.0075),
                    segments: vector2(30, 30),
                    inwardNormals: false,
                    geometryType: .triangles,
                    allocator: metalAllocator
                )
            ),
            metalAllocator: metalAllocator,
            loadTexture: false
        )
        drawers.measurePreviewDrawer.modelMeshes = loadAsset(
            assetSource: .primitive(
                mesh: MDLMesh(
                    sphereWithExtent: vector3(0.25, 0.25, 0.25),
                    segments: vector2(30, 30),
                    inwardNormals: false,
                    geometryType: .triangles,
                    allocator: metalAllocator
                )
            ),
            metalAllocator: metalAllocator,
            loadTexture: false
        )
    }

    private func enableDeletionActionsIfNeeded() {
        _enableDeletionActions = measureInProgress || !actions.isEmpty
    }

    private func add3DModelAnchor() {
        if let worldTransform = raycastFromScreenCenter()?.worldTransform {
            let anchorTransform = worldTransform
            // Add a new anchor to the session
            let anchor = ARAnchor(transform: anchorTransform)
            drawers.modelsDrawer.instanceAnchors.append(anchor)
            session.add(anchor: anchor)
            actions.append(.pinObject)
        }
    }

    private func addMeasureAnchor() {
        if let worldTransform = raycastFromScreenCenter()?.worldTransform {
            let anchorTransform = worldTransform
            // Add a new anchor to the session
            let anchor = ARAnchor(transform: anchorTransform)
            drawers.measureEdgesDrawer.instanceAnchors.append(anchor)
            session.add(anchor: anchor)
            completeMeasureIfNeeded(endingMeasureAnchor: anchor)
        }
    }

    private func removeInProgressMeasure() {
        measureInProgress = false
        firstMeasureAnchorTransform = nil
        drawers.measureEdgesDrawer.instanceAnchors.removeLast()
    }

    private func completeMeasureIfNeeded(endingMeasureAnchor: ARAnchor) {
        if measureInProgress {
            if let firstMeasureAnchorTransform {
                let measureEndTransform =
                    drawers.targetDrawer.instanceAnchors.first?.transform ?? endingMeasureAnchor.transform
                let measure = Measure(
                    origin: firstMeasureAnchorTransform,
                    end: measureEndTransform
                )
                measures.append(measure)
                addMeasureTextAnchor(measure: measure)
                actions.append(.measure)
            }
            firstMeasureAnchorTransform = nil
        }
        measureInProgress.toggle()
    }

    private func addMeasureTextAnchor(measure: Measure) {
        let measureText = getMeasureText(origin: measure.origin, end: measure.end)
        if let cachedTexture = cachedMeasuresText[measureText] {
            drawers.measureTextDrawer.modelTextures.append(cachedTexture)
        } else {
            generateTextTexture(measureText: measureText).map {
                cachedMeasuresText[measureText] = $0
                drawers.measureTextDrawer.modelTextures.append($0)
            }
        }

        let measureTextTransform = measure.origin.interpolate(
            with: measure.end,
            steps: 3
        )
        let textureTransform = measureTextTransform[1]
        let textAnchor = ARAnchor(transform: textureTransform)
        drawers.measureTextDrawer.instanceAnchors.append(textAnchor)
        session.add(anchor: textAnchor)
    }

    private func addMeasureTextPreviewAnchor(origin: matrix_float4x4, end: matrix_float4x4) {
        let measureText = getMeasureText(origin: origin, end: end)
        if let cachedTexture = cachedMeasuresText[measureText] {
            drawers.measureTextPreviewDrawer.modelTextures = [cachedTexture]
        } else {
            generateTextTexture(measureText: measureText).map {
                cachedMeasuresText[measureText] = $0
                drawers.measureTextPreviewDrawer.modelTextures = [$0]
            }
        }
        let textAnchor = ARAnchor(transform: end)
        drawers.measureTextPreviewDrawer.instanceAnchors.append(textAnchor)
        session.add(anchor: textAnchor)
    }

    private func raycastFromScreenCenter() -> ARRaycastResult? {
        guard let currentFrame = session.currentFrame else { return nil }
        let raycastOriginPoint = CGPoint(x: 0.5, y: 0.5)
        let raycastQuery = currentFrame.raycastQuery(
            from: raycastOriginPoint,
            allowing: .estimatedPlane,
            alignment: .any
        )
        return session.raycast(raycastQuery).first
    }

    private func createVirtualTarget(from cameraTransform: matrix_float4x4) -> matrix_float4x4 {
        let targetDistance: Float
        if !recentRaycastDistances.isEmpty {
            let averageDistance = recentRaycastDistances.reduce(0, +) / Float(recentRaycastDistances.count)
            targetDistance = max(0.3, min(3.0, averageDistance))
        } else {
            targetDistance = 1.2
        }

        // Place target at calculated distance in front of camera
        let forwardDirection = -cameraTransform.columns.2  // Camera looks down negative Z
        let targetPosition = cameraTransform.columns.3 + (simd_normalize(forwardDirection) * targetDistance)

        var targetTransform = matrix_identity_float4x4
        targetTransform.columns.3 = targetPosition
        return targetTransform
    }

    private func raycastWithFallbackSettings() -> ARRaycastResult? {
        guard let currentFrame = session.currentFrame else { return nil }

        let raycastOriginPoint = CGPoint(x: 0.5, y: 0.5)

        // Try with existing plane geometry
        let raycastQuery = currentFrame.raycastQuery(
            from: raycastOriginPoint,
            allowing: .existingPlaneGeometry,
            alignment: .any
        )

        return session.raycast(raycastQuery).first
    }

    private func addTargetAnchor() {
        guard _mode != .none else {
            return
        }

        drawers.measurePreviewDrawer.removeInstanceAnchors(from: session)
        drawers.measureTextPreviewDrawer.removeInstanceAnchors(from: session)

        if let worldTransform = getReliableTargetTransform() {
            let anchorTransform = worldTransform.scaled(by: getConsistentScale(for: worldTransform))
            let anchor = ARAnchor(transform: anchorTransform)

            if measureInProgress && firstMeasureAnchorTransform == nil {
                firstMeasureAnchorTransform = anchorTransform
            }

            drawers.targetDrawer.instanceAnchors.append(anchor)
            session.add(anchor: anchor)

            lastValidTargetTransform = worldTransform
            consecutiveRaycastFailures = 0
        } else {
            consecutiveRaycastFailures += 1

            if consecutiveRaycastFailures <= maxConsecutiveFailures,
                let fallbackTransform = lastValidTargetTransform
            {
                let anchorTransform = fallbackTransform.scaled(by: getConsistentScale(for: fallbackTransform))
                let anchor = ARAnchor(transform: anchorTransform)

                drawers.targetDrawer.instanceAnchors.append(anchor)
                session.add(anchor: anchor)
            }
        }
    }

    // Calculate consistent scale based on distance to maintain visual size
    private func getConsistentScale(for targetTransform: matrix_float4x4) -> Float {
        guard let cameraTransform = session.currentFrame?.camera.transform else {
            return 0.05
        }

        let distance = simd_distance(cameraTransform.columns.3, targetTransform.columns.3)

        let baseScale: Float = 0.05
        let baseDistance: Float = 1.0

        return baseScale * (distance / baseDistance)
    }

    private func getReliableTargetTransform() -> matrix_float4x4? {
        // 1. Try normal raycast
        if let result = raycastFromScreenCenter() {
            updateDistanceHistory(from: result.worldTransform)
            return result.worldTransform
        }

        // 2. Fallback - Try with more permissive raycast settings
        if let result = raycastWithFallbackSettings() {
            updateDistanceHistory(from: result.worldTransform)
            return result.worldTransform
        }

        // 3. Second fallback - Create virtual target based on camera position with smart distance
        if let cameraTransform = session.currentFrame?.camera.transform {
            return createVirtualTarget(from: cameraTransform)
        }

        return nil
    }

    private func updateDistanceHistory(from targetTransform: matrix_float4x4) {
        guard let cameraTransform = session.currentFrame?.camera.transform else { return }

        let distance = simd_distance(cameraTransform.columns.3, targetTransform.columns.3)
        recentRaycastDistances.append(distance)

        if recentRaycastDistances.count > maxDistanceHistory {
            recentRaycastDistances.removeFirst()
        }
    }

    private func addMeasurePreviewAnchors(anchorTransform: matrix_float4x4) {
        if let firstMeasureAnchorTransform {
            let distance = firstMeasureAnchorTransform.distanceTo(matrix: anchorTransform)
            let steps = Int(distance / 0.05)
            let previewAnchors = firstMeasureAnchorTransform.interpolate(
                with: anchorTransform,
                steps: steps > maxAnchorInstanceCount ? maxAnchorInstanceCount : steps
            ).dropFirst()
            previewAnchors.forEach {
                let previewAnchor = ARAnchor(transform: $0)
                drawers.measurePreviewDrawer.instanceAnchors.append(previewAnchor)
                session.add(anchor: previewAnchor)
            }
            if distance >= 3 / 100 {
                addMeasureTextPreviewAnchor(origin: firstMeasureAnchorTransform, end: anchorTransform)
            }
        }
    }

    private func generateTextTexture(measureText: String) -> MTLTexture? {
        guard let measureTextViewImage = UILabel.make(with: measureText).toImage() else {
            return nil
        }
        return measureTextViewImage.createTexture(device: metalComponents.device)
    }

    private func getMeasureText(origin: matrix_float4x4, end: matrix_float4x4) -> String {
        if _mode == .ruler(unit: .centimeters) {
            return origin.distanceInCentimeters(to: end)
        } else {
            return origin.distanceInInches(to: end)
        }
    }

    private func loadAsset(
        assetSource: AssetSource,
        metalAllocator: MTKMeshBufferAllocator,
        loadTexture: Bool
    ) -> [MTKMesh] {
        let bundle = Bundle(for: TruvideoARRenderer.self)
        // Create a Model IO vertexDescriptor so that we format/layout our model IO mesh vertices to
        //   fit our Metal render pipeline's vertex descriptor layout
        let vertexDescriptor = MTKModelIOVertexDescriptorFromMetal(metalComponents.geometryVertexDescriptor)

        let vertexPositionAttribute = vertexDescriptor.attributes[Int(kVertexAttributePosition.rawValue)]
        (vertexPositionAttribute as? MDLVertexAttribute)?.name = MDLVertexAttributePosition

        let textureCoordinateAttribute = vertexDescriptor.attributes[Int(kVertexAttributeTexcoord.rawValue)]
        (textureCoordinateAttribute as? MDLVertexAttribute)?.name = MDLVertexAttributeTextureCoordinate

        let vertexNormalAttribute = vertexDescriptor.attributes[Int(kVertexAttributeNormal.rawValue)]
        (vertexNormalAttribute as? MDLVertexAttribute)?.name = MDLVertexAttributeNormal

        // Use ModelIO to create a box mesh as our object
        var meshes = [MDLMesh]()
        switch assetSource {
        case let .localFile(assetName, assetExtension):
            guard
                let assetURL = bundle.url(forResource: assetName, withExtension: assetExtension)
            else {
                fatalError()
            }
            let asset = MDLAsset(
                url: assetURL,
                vertexDescriptor: vertexDescriptor,
                bufferAllocator: metalAllocator
            )
            if loadTexture {
                asset.loadTextures()
            }
            meshes = asset.childObjects(of: MDLMesh.self) as! [MDLMesh]

            if loadTexture {
                for mesh in meshes {
                    if !drawers.modelsDrawer.modelTextures.isEmpty {
                        continue
                    }
                    mesh.submeshes?.forEach {
                        if let mdlSubmesh = $0 as? MDLSubmesh,
                            let material = mdlSubmesh.material
                        {
                            // Check if the material has a texture
                            if let property = material.property(with: .baseColor),
                                property.type == .texture,
                                let mdlTexture = property.textureSamplerValue?.texture,
                                let texture = mdlTexture.convertToMTLTexture(
                                    device: metalComponents.device
                                )
                            {
                                drawers.modelsDrawer.modelTextures.append(texture)
                            }
                        }
                    }
                }
            }
        case let .primitive(mesh):
            meshes = [mesh]
        }
        // Perform the format/relayout of mesh vertices by setting the new vertex descriptor in our
        //   Model IO mesh
        for mesh in meshes {
            mesh.vertexDescriptor = vertexDescriptor
        }
        return meshes.map { try! MTKMesh(mesh: $0, device: metalComponents.device) }
    }

    private func updateBufferStates() {
        // Update the location(s) to which we'll write to in our dynamically changing Metal buffers for
        //   the current frame (i.e. update our slot in the ring buffer used for the current frame)

        uniformBufferIndex = (uniformBufferIndex + 1) % maxBuffersInFlight

        sharedUniformBuffer.offset = sharedUniformBuffer.size * uniformBufferIndex
        drawers.modelsDrawer.updateInstanceBufferState(bufferIndex: uniformBufferIndex)
        drawers.targetDrawer.updateInstanceBufferState(bufferIndex: uniformBufferIndex)
        drawers.measureEdgesDrawer.updateInstanceBufferState(bufferIndex: uniformBufferIndex)
        drawers.measurePreviewDrawer.updateInstanceBufferState(bufferIndex: uniformBufferIndex)
        drawers.measureLinesDrawer.updateInstanceBufferState(bufferIndex: uniformBufferIndex)
        drawers.measureLinesDrawer.updateIndicesBufferState(bufferIndex: uniformBufferIndex)
        drawers.measureTextDrawer.updateInstanceBufferState(bufferIndex: uniformBufferIndex)
        drawers.measureTextPreviewDrawer.updateInstanceBufferState(bufferIndex: uniformBufferIndex)

        sharedUniformBufferAddress = sharedUniformBuffer.metalBuffer?.contents().advanced(
            by: sharedUniformBuffer.offset
        )
    }

    private func updateGameState() {
        // Update any game state

        guard let currentFrame = session.currentFrame, let capturedImageTextureCache else {
            return
        }

        updateSharedUniforms(frame: currentFrame)
        updateTargetAnchors()
        updateMeasureAnchors()
        updateMeasureLinesAnchors()
        updateMeasurePreviewAnchors()
        updatePreviewTextAnchor(frame: currentFrame)
        updateAnchors(frame: currentFrame)
        updateCapturedImageTextures(frame: currentFrame, capturedImageTextureCache: capturedImageTextureCache)
        updateMeasureTextAnchors(frame: currentFrame)

        if viewportSizeDidChange {
            viewportSizeDidChange = false

            updateImagePlane(frame: currentFrame)
        }
    }

    // MARK: - Update 3D elements transforms

    private func updateSharedUniforms(frame: ARFrame) {
        // Update the shared uniforms of the frame
        guard let uniforms = sharedUniformBufferAddress?.assumingMemoryBound(to: SharedUniforms.self) else {
            return
        }

        uniforms.pointee.viewMatrix = frame.camera.viewMatrix(for: .portrait)
        uniforms.pointee.projectionMatrix = frame.camera.projectionMatrix(
            for: .portrait,
            viewportSize: viewportSize,
            zNear: 0.001,
            zFar: 1000
        )

        // Set up lighting for the scene using the ambient intensity if provided
        var ambientIntensity: Float = 1.0

        if let lightEstimate = frame.lightEstimate {
            ambientIntensity = Float(lightEstimate.ambientIntensity) / 1000.0
        }

        let ambientLightColor: vector_float3 = vector3(0.5, 0.5, 0.5)
        uniforms.pointee.ambientLightColor = ambientLightColor * ambientIntensity

        var directionalLightDirection: vector_float3 = vector3(0.0, 0.0, -1.0)
        directionalLightDirection = simd_normalize(directionalLightDirection)
        uniforms.pointee.directionalLightDirection = directionalLightDirection

        let directionalLightColor: vector_float3 = vector3(0.6, 0.6, 0.6)
        uniforms.pointee.directionalLightColor = directionalLightColor * ambientIntensity

        uniforms.pointee.materialShininess = 30

        drawers.updateOffsets(sharedUniformBuffer: sharedUniformBuffer)
    }

    private func updateAnchors(frame: ARFrame) {
        // Update the anchor uniform buffer with transforms of the current frame's anchors
        let anchors = drawers.modelsDrawer.instanceAnchors
        anchorInstanceCount = min(anchors.count, maxAnchorInstanceCount)
        var anchorOffset: Int = 0
        if anchorInstanceCount == maxAnchorInstanceCount {
            anchorOffset = max(anchors.count - maxAnchorInstanceCount, 0)
        }

        for index in 0 ..< anchorInstanceCount {
            let anchor = anchors[index + anchorOffset]

            // Flip Z axis to convert geometry from right handed to left handed
            var coordinateSpaceTransform = matrix_identity_float4x4
            coordinateSpaceTransform.columns.2.z = -1.0
            let rotationAngle: Float = .pi / 2
            let modelMatrix = simd_mul(anchor.transform, coordinateSpaceTransform)
            let anchorUniforms = getInstance(drawer: drawers.modelsDrawer, at: index, for: InstanceUniforms.self)
            anchorUniforms?.pointee.modelMatrix =
                modelMatrix
                .face(at: frame.camera.transform)
                .scaled(by: 0.01)
                .rotateOverZAxis(rotationAngle: rotationAngle)
                .rotateOverXAxis(rotationAngle: rotationAngle)
                .translatedBy(x: -6)

        }
    }

    private func updateTargetAnchors() {
        // Update the anchor uniform buffer with transforms of the current frame's anchors
        if let targetAnchor = drawers.targetDrawer.instanceAnchors.first {
            // Flip Z axis to convert geometry from right handed to left handed
            var coordinateSpaceTransform = matrix_identity_float4x4
            coordinateSpaceTransform.columns.2.z = -1.0

            let modelMatrix = simd_mul(targetAnchor.transform, coordinateSpaceTransform)
            let anchorUniforms = getInstance(drawer: drawers.targetDrawer, at: 0, for: InstanceUniforms.self)
            anchorUniforms?.pointee.modelMatrix = modelMatrix
        }
    }

    private func updateMeasureAnchors() {
        drawers.measureEdgesDrawer.instanceAnchors.enumerated().forEach { index, anchor in
            // Flip Z axis to convert geometry from right handed to left handed
            var coordinateSpaceTransform = matrix_identity_float4x4
            coordinateSpaceTransform.columns.2.z = -1.0

            let modelMatrix = simd_mul(anchor.transform, coordinateSpaceTransform)
            let anchorUniforms = getInstance(drawer: drawers.measureEdgesDrawer, at: index, for: InstanceUniforms.self)
            anchorUniforms?.pointee.modelMatrix = modelMatrix
        }
    }

    private func updateMeasurePreviewAnchors() {
        drawers.measurePreviewDrawer.instanceAnchors.enumerated().forEach { index, anchor in
            // Flip Z axis to convert geometry from right handed to left handed
            var coordinateSpaceTransform = matrix_identity_float4x4
            coordinateSpaceTransform.columns.2.z = -1.0

            let modelMatrix = simd_mul(anchor.transform, coordinateSpaceTransform)
            let anchorUniforms = getInstance(
                drawer: drawers.measurePreviewDrawer,
                at: index,
                for: InstanceUniforms.self
            )
            anchorUniforms?.pointee.modelMatrix = modelMatrix
        }
    }

    private func updateMeasureLinesAnchors() {
        let radius: Float = 0.0025
        let segments = 10

        var indicesPattern = [UInt16]()
        var indices = [UInt16]()

        // Update the vertex buffer
        var vertices = [SIMD4<Float>]()
        for measure in measures {
            if indicesPattern.isEmpty {
                indicesPattern = measure.getMeasureLineIndices(segments: segments)
            }
            indices.append(
                contentsOf: indicesPattern.map({
                    $0 + UInt16(vertices.count)
                })
            )
            vertices.append(contentsOf: measure.getMeasureLineVertices(radius: radius, segments: segments))
        }

        vertices.enumerated().forEach { index, vertex in
            let anchorUniforms = getInstance(drawer: drawers.measureLinesDrawer, at: index, for: MeasureUniforms.self)
            anchorUniforms?.pointee.position = vertex
        }
        indices.enumerated().forEach { index, value in
            let anchorUniforms = drawers.measureLinesDrawer.getIndex(at: index)
            anchorUniforms?.pointee = value
        }
    }

    private func updateMeasureTextAnchors(frame: ARFrame) {
        drawers.measureTextDrawer.instanceAnchors.enumerated().forEach { index, anchor in
            // Flip Z axis to convert geometry from right handed to left handed
            var coordinateSpaceTransform = matrix_identity_float4x4
            coordinateSpaceTransform.columns.2.z = -1.0
            let modelMatrix = simd_mul(anchor.transform, coordinateSpaceTransform)
            let anchorUniforms = getInstance(drawer: drawers.measureTextDrawer, at: index, for: InstanceUniforms.self)
            guard let measure = getMeasure(at: index) else { return }
            let measureStart = measure.origin
            let measureEnd = measure.end
            anchorUniforms?.pointee.modelMatrix =
                modelMatrix
                .face(at: frame.camera.transform)
                .scaled(by: 0.02)
                .centerBetween(
                    matrix1: measureStart,
                    matrix2: measureEnd
                )
                .translatedBy(y: 0.8, z: -0.5)
        }
    }

    private func updatePreviewTextAnchor(frame: ARFrame) {
        drawers.measureTextPreviewDrawer.instanceAnchors.enumerated().forEach { index, anchor in
            // Flip Z axis to convert geometry from right handed to left handed
            var coordinateSpaceTransform = matrix_identity_float4x4
            coordinateSpaceTransform.columns.2.z = -1.0
            let modelMatrix = simd_mul(anchor.transform, coordinateSpaceTransform)
            let anchorUniforms = getInstance(
                drawer: drawers.measureTextPreviewDrawer,
                at: index,
                for: InstanceUniforms.self
            )
            anchorUniforms?.pointee.modelMatrix =
                modelMatrix
                .face(at: frame.camera.transform)
                .scaled(by: 0.02)
                .translatedBy(y: 1, z: -1)
        }
    }

    private func getMeasure(at index: Int) -> Measure? {
        guard index < measures.count else { return nil }
        return measures[index]
    }

    private func updateCapturedImageTextures(frame: ARFrame, capturedImageTextureCache: CVMetalTextureCache) {
        // Create two textures (Y and CbCr) from the provided frame's captured image
        let pixelBuffer = frame.capturedImage

        if CVPixelBufferGetPlaneCount(pixelBuffer) < 2 {
            return
        }

        capturedImageTextureY = pixelBuffer.createTexture(
            pixelFormat: .r8Unorm,
            planeIndex: 0,
            textureCache: capturedImageTextureCache
        )
        capturedImageTextureCbCr = pixelBuffer.createTexture(
            pixelFormat: .rg8Unorm,
            planeIndex: 1,
            textureCache: capturedImageTextureCache
        )
    }

    private func updateImagePlane(frame: ARFrame) {
        // Update the texture coordinates of our image plane to aspect fill the viewport
        let displayToCameraTransform = frame.displayTransform(
            for: .portrait,
            viewportSize: viewportSize
        ).inverted()

        let vertexData = drawers.cameraImageDrawer.getVertex()
        for index in 0 ... 3 {
            let textureCoordIndex = 4 * index + 2
            let textureCoord = CGPoint(
                x: CGFloat(cameraImageVertices[textureCoordIndex]),
                y: CGFloat(cameraImageVertices[textureCoordIndex + 1])
            )
            let transformedCoord = textureCoord.applying(displayToCameraTransform)
            vertexData?[textureCoordIndex] = Float(transformedCoord.x)
            vertexData?[textureCoordIndex + 1] = Float(transformedCoord.y)
        }
    }

    func getInstance<T>(drawer: ARDrawer, at index: Int, for type: T.Type) -> UnsafeMutablePointer<T>? {
        drawer.instancesBuffer?.currentAddress?.assumingMemoryBound(
            to: T.self
        ).advanced(by: index)
    }
}
