//
//  CameraPreview.swift
//
//  Created by TruVideo on 6/16/22.
//  Copyright © 2023 TruVideo. All rights reserved.
//

import AVFoundation
import SwiftUI

/// Shows the current frames captured by the `AVCaptureSession`
struct CameraPreview: UIViewRepresentable {

    /// The underlying `AVCaptureVideoPreviewLayer`
    let previewLayer: AVCaptureVideoPreviewLayer
    let onDelegateCreated: (CameraPreviewDelegate) -> Void

    /// Container view for the `AVCaptureVideoPreviewLayer`.
    class PlayerContainerView: UIView, CameraPreviewDelegate {
        /// The underlying `AVCaptureVideoPreviewLayer`
        private let previewLayer: AVCaptureVideoPreviewLayer

        private var previousFocusImage: UIImageView?

        // MARK: Initializers

        /// Creates a new instance of the `PlayerContainerView`.
        init(previewLayer: AVCaptureVideoPreviewLayer) {
            self.previewLayer = previewLayer
            super.init(frame: .zero)
            layer.addSublayer(previewLayer)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: Overriden methods

        override func layoutSubviews() {
            super.layoutSubviews()
            previewLayer.frame = frame
        }

        func addImageAt(_ tapPoint: CGPoint) {
            let imageView = UIImageView(image: TruVideoImage.tapToFocus)
            imageView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
            imageView.tintColor = .white
            imageView.alpha = 0.3
            imageView.center = tapPoint

            previousFocusImage?.removeFromSuperview()
            previousFocusImage = imageView
            addSubview(imageView)

            UIView.animate(
                withDuration: 1.0,
                animations: {
                    imageView.alpha = 1.0
                }
            ) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    imageView.removeFromSuperview()
                }
            }
        }
    }

    // MARK: UIViewRepresentable

    /// Creates the view object and configures its initial state.
    func makeUIView(context: Context) -> UIView {
        let playerContainerView = PlayerContainerView(previewLayer: previewLayer)
        playerContainerView.backgroundColor = .black

        onDelegateCreated(playerContainerView)

        return playerContainerView
    }

    /// Updates the state of the specified view with new information from
    /// SwiftUI.
    func updateUIView(_ uiView: UIView, context: Context) {}
}

protocol CameraPreviewDelegate: AnyObject {
    func addImageAt(_ tapPoint: CGPoint)
}
