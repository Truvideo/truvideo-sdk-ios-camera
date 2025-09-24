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
///         VideoPreview(recorder: recorder)
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
        private var focusIndicatorView = FocusIndicatorView()
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
            let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)

            self.previewLayer = previewLayer
            self.previewLayer.videoGravity = .resizeAspectFill

            self.blurView = UIVisualEffectView(effect: blurEffect)
            self.blurView.alpha = 0

            super.init(frame: .zero)

            self.focusIndicatorView.frame.size = CGSize(width: 80, height: 80)
            self.focusIndicatorView.alpha = 0

            self.overlayView.alpha = 0
            self.overlayView.backgroundColor = .black

            clipsToBounds = true
            layer.addSublayer(previewLayer)

            addSubview(focusIndicatorView)

            configureConstraints()
            configureDeviceObservers()
            configureObservers()
            configureSessionObservers()
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: Overridden methods

        override func layoutSubviews() {
            super.layoutSubviews()

            overlayView.frame = bounds
            previewLayer.frame = bounds
        }

        deinit {
            NotificationCenter.default.removeObserver(self)
        }

        // MARK: - Notification methods

        @MainActor
        @objc
        func didReceiveDidBecomeActiveNotification(_ notification: Notification) {
            if let overlayViewPropertyAnimator {
                overlayViewPropertyAnimator.stopAnimation(true)
            }

            overlayViewPropertyAnimator = overlayView.animate(\.alpha, to: 0, duration: 0.25)
        }

        @MainActor
        @objc
        func didReceiveDeviceDidChangeFocusPoint(_ notification: Notification) {
            if let focusPoint = notification.userInfo?[VideoDevice.newFocusPoint] as? CGPoint {
                let layerPoint = previewLayer.layerPointConverted(fromCaptureDevicePoint: focusPoint)
                let newCenter = layer.convert(layerPoint, from: previewLayer)

                guard newCenter.x.isFinite, newCenter.y.isFinite else {
                    return
                }

                if focusIndicatorView.center != newCenter {
                    focusIndicatorView.alpha = 0
                    focusIndicatorView.center = layer.convert(layerPoint, from: previewLayer)
                    focusIndicatorView.show()
                    focusIndicatorView.fade(to: 0, delay: 2)
                } else {
                    focusIndicatorView.fade(to: 0.4)
                }
            }
        }

        @MainActor
        @objc
        func didReceiveDeviceWillChangeFocusPoint(_ notification: Notification) {
            if let focusPoint = notification.userInfo?[VideoDevice.newFocusPoint] as? CGPoint {
                let layerPoint = previewLayer.layerPointConverted(fromCaptureDevicePoint: focusPoint)
                let newCenter = layer.convert(layerPoint, from: previewLayer)

                guard newCenter.x.isFinite, newCenter.y.isFinite else {
                    return
                }

                focusIndicatorView.center = layer.convert(layerPoint, from: previewLayer)
                focusIndicatorView.show()
            }
        }

        @MainActor
        @objc
        func didReceiveDeviceWillChangePosition(_ notification: Notification) {
            if let position = notification.userInfo?[VideoDevice.devicePosition] as? AVCaptureDevice.Position {
                flip(from: position)
            }
        }

        @MainActor
        @objc
        func didReceiveDidEnterBackgroundNotification(_ notification: Notification) {
            previewLayer.removeFromSuperlayer()
        }

        @MainActor
        @objc
        func didReceiveSessionDidEndUpdates(_ notification: Notification) {
            Task.delayed(milliseconds: 300) { @MainActor in
                blurView.animate(\.alpha, to: 0, duration: 0.5)
            }
        }

        @MainActor
        @objc
        func didReceiveSessionWillBeginUpdates(_ notification: Notification) {
            blurView.animate(\.alpha, to: 1, duration: 0.25)
        }

        @MainActor
        @objc
        func didReceiveWillEnterForegroundNotification(_ notification: Notification) {
            overlayView.alpha = 1
            overlayView.animate(\.alpha, to: 0, duration: 0.25, delay: 0.8)
        }

        @MainActor
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
                selector: #selector(didReceiveDeviceDidChangeFocusPoint(_:)),
                name: VideoDevice.deviceDidChangeFocusPoint,
                object: nil
            )

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(didReceiveDeviceWillChangeFocusPoint(_:)),
                name: VideoDevice.deviceWillChangeFocusPoint,
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

        private func configureSessionObservers() {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(didReceiveSessionDidEndUpdates(_:)),
                name: AVCaptureSession.didEndUpdates,
                object: nil
            )

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(didReceiveSessionWillBeginUpdates(_:)),
                name: AVCaptureSession.willBeginUpdates,
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

private final class FocusIndicatorView: UIView {
    // MARK: - Private methods

    private var fadePropertyAnimator: UIViewPropertyAnimator?
    private var showAnimation: UIViewPropertyAnimator?

    // MARK: - Initializers

    init() {
        let image = UIImage(named: "tap-to-focus", in: .module, with: nil)
        let imageView = UIImageView(image: image)

        imageView.translatesAutoresizingMaskIntoConstraints = false

        super.init(frame: .zero)

        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Instance methods

    /// Fades the view to the specified alpha value with an optional delay.
    ///
    /// This method animates the view's alpha property to the target value using a
    /// smooth ease-in curve. Any existing fade animation is stopped before starting
    /// the new animation to prevent conflicts. The animation can be delayed by
    /// specifying a delay parameter.
    ///
    /// - Parameters:
    ///   - alpha: The target alpha value to fade to.
    ///   - delay: The delay in seconds before starting the animation (default: 0.5)
    func fade(to alpha: CGFloat, delay: TimeInterval = 0.5) {
        let fadeOutAnimation = { [weak self] in
            self?.fadePropertyAnimator?.stopAnimation(true)
            self?.fadePropertyAnimator = self?.animate(\.alpha, to: alpha, duration: 0.25, delay: delay)
        }

        if let showAnimation, showAnimation.isRunning {
            showAnimation.addCompletion { _ in
                fadeOutAnimation()
            }
        } else {
            fadeOutAnimation()
        }
    }

    /// Shows the view with a scale and fade animation.
    ///
    /// This method animates the view from a scaled state (2.5x) to its normal size
    /// while simultaneously fading it in from transparent to fully opaque. The animation
    /// uses a 0.25 second duration with the default easing curve.
    func show() {
        fadePropertyAnimator?.stopAnimation(true)
        showAnimation?.stopAnimation(true)

        transform = .identity.scaledBy(x: 2.5, y: 2.5)
        showAnimation = UIViewPropertyAnimator(duration: 0.25, curve: .linear) { [weak self] in
            self?.alpha = 1
            self?.transform = .identity
        }

        showAnimation?.startAnimation()
    }
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

        let propertyViewAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeInOut) { [weak self] in
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
