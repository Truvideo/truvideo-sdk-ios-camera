//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation
import SwiftUI

/// A SwiftUI-compatible view that displays a live camera preview using `AVCaptureVideoPreviewLayer`.
///
/// `RecorderVideoPreview` wraps the recorder's preview layer in a SwiftUI view, providing
/// a seamless integration between UIKit-based camera functionality and SwiftUI interfaces.
/// It handles app lifecycle events to properly manage the preview layer's visibility
/// and includes an overlay system for UI elements.
///
/// ## Usage
/// ```swift
/// struct CameraView: View {
///     @StateObject private var recorder = Recorder()
///
///     var body: some View {
///         RecorderVideoPreview(recorder: recorder)
///             .edgesIgnoringSafeArea(.all)
///     }
/// }
/// ```
struct RecorderVideoPreview: UIViewRepresentable {
    // MARK: - Private Properties

    private let recorder: Recorder

    // MARK: - Types

    /// Container view for the `AVCaptureVideoPreviewLayer`.
    class PlayerContainerView: UIView {
        // MARK: - Private Properties

        private var overlayView = UIView()
        private var propertyViewAnimator: UIViewPropertyAnimator?
        private let videoPreviewLayer: AVCaptureVideoPreviewLayer

        // MARK: - Initializers

        /// Creates a new container view with the specified recorder.
        ///
        /// The initializer sets up the preview layer, overlay view, and notification
        /// observers. It also sets itself as the recorder's delegate to receive
        /// state change notifications.
        ///
        /// - Parameter recorder: The recorder instance that provides the preview layer.
        init(recorder: Recorder) {
            self.videoPreviewLayer = recorder.previewLayer

            self.overlayView.alpha = 0
            self.overlayView.backgroundColor = .black

            super.init(frame: .zero)

            recorder.delegate = self

            layer.addSublayer(videoPreviewLayer)
            addSubview(overlayView)

            configureObservers()
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: Overriden methods

        override func layoutSubviews() {
            super.layoutSubviews()

            overlayView.frame = frame
            videoPreviewLayer.frame = frame
        }

        // MARK: - Notification methods

        @objc
        func didReceiveWillEnterForegroundNotification(_ notification: Notification) {
            layer.insertSublayer(videoPreviewLayer, at: 0)
        }

        @objc
        func didReceiveDidEnterBackgroundNotification(_ notification: Notification) {
            videoPreviewLayer.removeFromSuperlayer()
        }

        // MARK: - Private methods

        private func configureObservers() {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(didReceiveDidEnterBackgroundNotification(_:)),
                name: UIApplication.didEnterBackgroundNotification,
                object: nil
            )

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(didReceiveWillEnterForegroundNotification(_:)),
                name: UIApplication.willEnterForegroundNotification,
                object: nil
            )
        }

        private func startAnimating(to alpha: CGFloat, duration: TimeInterval) {
            propertyViewAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeOut) { [weak self] in
                self?.overlayView.alpha = alpha
            }

            propertyViewAnimator?.startAnimation()
        }
    }

    // MARK: - Initializer

    /// Creates a new video preview view with the specified recorder.
    ///
    /// - Parameter recorder: The recorder instance that provides the camera preview.
    init(recorder: Recorder) {
        self.recorder = recorder
    }

    // MARK: - UIViewRepresentable

    /// Creates the view object and configures its initial state.
    func makeUIView(context: Context) -> UIView {
        let playerContainerView = PlayerContainerView(recorder: recorder)
        playerContainerView.backgroundColor = .black

        return playerContainerView
    }

    /// Updates the state of the specified view with new information from
    /// SwiftUI.
    func updateUIView(_ uiView: UIView, context: Context) {}
}

extension RecorderVideoPreview.PlayerContainerView: RecorderDelegate {

    // MARK: - RecorderDelegate

    func recorderWillPause(_ recorder: Recorder) {
        startAnimating(to: 1, duration: 0.25)
    }

    func recorderDidResume(_ recorder: Recorder) {
        propertyViewAnimator?.stopAnimation(true)
        startAnimating(to: 0, duration: 0.5)
    }
}
