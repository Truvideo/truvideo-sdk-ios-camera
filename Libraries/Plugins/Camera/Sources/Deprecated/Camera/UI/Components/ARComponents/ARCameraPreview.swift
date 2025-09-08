//
//  ARCameraPreview.swift
//  TruvideoSdkCamera
//
//  Created by Luis Francisco Piura Mejia on 17/4/24.
//

import ARKit
import Foundation
import MetalKit
import SwiftUI

struct ARCameraPreview: UIViewRepresentable {

    let renderer: ARRenderer
    let renderHandler: ARRendererFrameRenderHandler

    // MARK: UIViewRepresentable

    /// Creates the view object and configures its initial state.
    func makeUIView(context: Context) -> UIView {
        guard let mtkView = renderer.renderDestination as? MTKView else {
            return UIView()
        }
        let view = MetalView(mtkView: mtkView)
        view.mtkView.delegate = context.coordinator
        renderer.renderHandler = renderHandler
        view.mtkView.device = renderer.metalComponents.device
        context.coordinator.arRenderer = renderer
        return view
    }

    /// Updates the state of the specified view with new information from
    /// SwiftUI.
    func updateUIView(_ uiView: UIView, context: Context) {
        if let metalView = uiView as? MetalView {
            renderer.drawRectResized(size: metalView.mtkView.bounds.size)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator: NSObject, MTKViewDelegate {

        weak var arRenderer: ARRenderer?

        // Called whenever view changes orientation or layout is changed
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            arRenderer?.drawRectResized(size: size)
        }

        // Called whenever the view needs to render
        func draw(in view: MTKView) {
            arRenderer?.update()
        }
    }

    final class MetalView: UIView {

        let mtkView: MTKView

        init(mtkView: MTKView) {
            self.mtkView = mtkView
            super.init(frame: .zero)
        }

        required init?(coder: NSCoder) {
            fatalError("Not implemented")
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            mtkView.frame = frame
            let metalSubview = subviews.first { $0 as? MTKView != nil }
            guard metalSubview == nil else { return }
            addSubview(mtkView)
        }
    }
}

extension MTKView: RenderDestinationProvider {}
