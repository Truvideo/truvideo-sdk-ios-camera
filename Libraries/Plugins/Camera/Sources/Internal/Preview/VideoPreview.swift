//
// Copyright © 2025 TruVideo. All rights reserved.
//

import AVFoundation
import SwiftUI
internal import Utilities

/// A SwiftUI-compatible view that displays a live camera preview using `AVCaptureVideoPreviewLayer`.
///
/// `VideoPreview` wraps the recorder's preview layer in a SwiftUI view, providing
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
struct VideoPreview: UIViewRepresentable {
    // MARK: - Private Properties

    private let previewLayer: AVCaptureVideoPreviewLayer

    // MARK: - Types

    /// Container view for the `AVCaptureVideoPreviewLayer`.
    class PlayerContainerView: UIView {
        // MARK: - Private Properties

        private let aspectRatio: CGFloat = 16 / 9
        private let blurView: UIVisualEffectView
        private var blurViewPropertyAnimator: UIViewPropertyAnimator?
        private var overlayView = UIView()
        private var overlayViewPropertyAnimator: UIViewPropertyAnimator?
        private var previewLayer: AVCaptureVideoPreviewLayer

        // MARK: - Initializers

        /// Creates a new container view with the specified layer.
        ///
        /// The initializer sets up the preview layer, overlay view, and notification
        /// observers. It also sets itself as the recorder's delegate to receive
        /// state change notifications.
        ///
        /// - Parameter previewLayer: The preview layer instance that provides video.
        init(previewLayer: AVCaptureVideoPreviewLayer) {
            let blurEffect = UIBlurEffect(style: .systemThinMaterialDark)

            self.previewLayer = previewLayer
            self.previewLayer.videoGravity = .resizeAspect

            self.blurView = UIVisualEffectView(effect: blurEffect)
            self.blurView.alpha = 0

            self.overlayView.alpha = 0
            self.overlayView.backgroundColor = .black

            super.init(frame: .zero)

            layer.addSublayer(previewLayer)

            configureConstraints()
            configureDeviceObservers()
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
            previewLayer.frame = frame
        }

        deinit {
            NotificationCenter.default.removeObserver(self)
        }

        // MARK: - Notification methods

        @objc
        func didReceiveDidBecomeActiveNotification(_ notification: Notification) {
            if let overlayViewPropertyAnimator {
                overlayViewPropertyAnimator.stopAnimation(true)
            }

            overlayViewPropertyAnimator = overlayView.animate(\.alpha, to: 0, duration: 0.25)
        }

        @objc
        func didReceiveDeviceDidChangePosition(_ notification: Notification) {
            let position = notification.userInfo?[VideoDevice.newPosition] as? AVCaptureDevice.Position
            let milliseconds: TimeInterval = position == .back ? 900 : 600

            Task.delayed(milliseconds: milliseconds) { @MainActor in
                blurView.animate(\.alpha, to: 0, duration: 0.5)
            }
        }

        @objc
        func didReceiveDeviceWillChangePosition(_ notification: Notification) {
            blurView.animate(\.alpha, to: 1, duration: 0.25)
                .addCompletion { [weak self] _ in
                    let position = notification.userInfo?[VideoDevice.devicePosition] as? AVCaptureDevice.Position
                    self?.flip(from: position ?? .back)
                }
        }

        @objc
        func didReceiveDidEnterBackgroundNotification(_ notification: Notification) {
            previewLayer.removeFromSuperlayer()
        }

        @objc
        func didReceiveWillEnterForegroundNotification(_ notification: Notification) {
            layer.insertSublayer(previewLayer, at: 0)
            overlayView.alpha = 1
            overlayView.animate(\.alpha, to: 0, duration: 0.25, delay: 0.8)
        }

        @objc
        func didReceiveWillResignActiveNotification(_ notification: Notification) {
            overlayViewPropertyAnimator = overlayView.animate(\.alpha, to: 1, duration: 0.25, delay: 1)
        }

        // MARK: - Private methods

        private func configureConstraints() {
            blurView.translatesAutoresizingMaskIntoConstraints = false

            addSubview(overlayView)
            addSubview(blurView)

            NSLayoutConstraint.activate([
                blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
                blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
                blurView.topAnchor.constraint(equalTo: topAnchor),
                blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            ])
        }

        private func configureDeviceObservers() {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(didReceiveDeviceDidChangePosition(_:)),
                name: VideoDevice.deviceDidChangePosition,
                object: nil
            )

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(didReceiveDeviceWillChangePosition(_:)),
                name: VideoDevice.deviceWillChangePosition,
                object: nil
            )
        }

        private func configureObservers() {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(didReceiveDidBecomeActiveNotification(_:)),
                name: UIApplication.didBecomeActiveNotification,
                object: nil
            )

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

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(didReceiveWillResignActiveNotification(_:)),
                name: UIApplication.willResignActiveNotification,
                object: nil
            )
        }
    }

    // MARK: - Initializer

    /// Creates a new video preview view with the specified layer.
    ///
    /// - Parameter previewLayer: The preview layer instance that provides video.
    init(previewLayer: AVCaptureVideoPreviewLayer) {
        self.previewLayer = previewLayer
    }

    // MARK: - UIViewRepresentable

    func makeUIView(context: Context) -> UIView {
        let playerContainerView = PlayerContainerView(previewLayer: previewLayer)
        playerContainerView.backgroundColor = .black

        return playerContainerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

extension UIView {
    /// Animates a specific property of the view to a target value over a specified duration.
    ///
    /// This generic function creates a property animator that smoothly transitions any
    /// writable property of the view to a new value. The function uses key path
    /// syntax to provide type-safe access to view properties, allowing you to
    /// animate properties like alpha, transform, backgroundColor, or any other
    /// UIView property that conforms to the Value type.
    ///
    /// - Parameters:
    ///   - key: A writable key path that identifies the specific property to animate.
    ///   - to: The target value that the property should animate to.
    ///   - duration: The duration of the animation in seconds.
    ///   - delay: The amount of time (in seconds) to wait before starting the animation.
    /// - Returns: A `UIViewPropertyAnimator` instance that controls the animation.
    @MainActor
    @discardableResult
    fileprivate func animate<Value>(
        _ key: WritableKeyPath<UIView, Value>,
        to value: Value,
        duration: TimeInterval,
        delay: TimeInterval = 0
    ) -> UIViewPropertyAnimator {

        let propertyViewAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeOut) { [weak self] in
            if var self {
                self[keyPath: key] = value
            }
        }

        propertyViewAnimator.startAnimation(afterDelay: delay)
        return propertyViewAnimator
    }

    /// Flips the camera view with an appropriate transition animation based on the current device position.
    ///
    /// This function performs a smooth flip transition animation when switching between front and back cameras.
    /// The transition direction is automatically determined based on the current camera position to provide
    /// a natural visual flow - flipping from right when switching from back camera, and from left when
    /// switching from front camera.
    ///
    /// - Parameter position: The current camera position that determines the flip transition direction.
    @MainActor
    fileprivate func flip(from position: AVCaptureDevice.Position) {
        let transition = position == .back ? AnimationOptions.transitionFlipFromRight : .transitionFlipFromLeft

        UIView.transition(
            with: self,
            duration: 0.25,
            options: [transition, .curveEaseInOut],
            animations: nil
        )
    }
}
