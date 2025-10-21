//
// Copyright © 2025 TruVideo. All rights reserved.
//

import UIKit

/// Provides the required information from the origin view (gallery).
protocol ZoomAnimatorOriginProvider: AnyObject {
    // MARK: - Properties

    /// The currently selected index in the gallery, if any.
    var selectedIndex: Int? { get }

    /// The frame of the selected cell converted into window coordinates.
    var selectedCellFrameInWindow: CGRect? { get }

    // MARK: - Instance Methods

    /// Returns the frame of the image at a given index, converted into the coordinate space of the provided container
    /// view.
    ///
    /// - Parameters:
    ///   - index: The index of the image.
    ///   - container: The container view used to convert the frame.
    /// - Returns: The converted frame if available, otherwise `nil`.
    func imageFrame(at index: Int, in container: UIView) -> CGRect?

    /// Hides or shows the image at the given index.
    ///
    /// - Parameters:
    ///   - index: The index of the image.
    ///   - hidden: A Boolean value indicating whether the image should be hidden.
    func hideImage(at index: Int, hidden: Bool)
}

/// Provides the required information from the destination view (detail).
protocol ZoomAnimatorDestinationProvider: AnyObject {
    // MARK: - Properties

    /// The index of the currently displayed media item.
    var currentIndex: Int { get }

    /// A snapshot image representing the current media item, if available.
    var snapshotImage: UIImage? { get }

    /// A snapshot view representing the current media item, if available.
    var snapshotView: UIView? { get }

    // MARK: - Instance Methods

    /// Prepares the destination view for dismissal.
    func prepareForDismiss()

    /// Hides or shows the destination view’s content.
    ///
    /// - Parameter hidden: A Boolean value indicating whether the content should be hidden.
    func hide(_ hidden: Bool)
}

/// A custom animated transition that zooms a selected media item from a gallery into a full-screen preview,
/// and vice versa.
///
/// This animator handles both the presentation and dismissal transitions.
class ZoomAnimatedTransition: NSObject, UIViewControllerAnimatedTransitioning {
    // MARK: - Properties

    /// Duration of the animation in seconds.
    let duration = 0.3

    // MARK: - Private Properties

    private let isPresenting: Bool
    private let originFrame: CGRect
    private let originImage: UIImage
    private weak var originProvider: ZoomAnimatorOriginProvider?

    // MARK: - Initializer

    /// Creates a new transition animator.
    ///
    /// - Parameters:
    ///   - isPresenting: A Boolean value indicating whether this is a presenting transition (`true`) or a dismissing
    /// transition (`false`).
    ///   - originFrame: The frame of the media item in the origin view.
    ///   - originImage: The image to be animated.
    ///   - originProvider: The origin provider that supplies frames and visibility updates.
    init(
        isPresenting: Bool,
        originFrame: CGRect,
        originImage: UIImage,
        originProvider: ZoomAnimatorOriginProvider
    ) {
        self.isPresenting = isPresenting
        self.originFrame = originFrame
        self.originImage = originImage
        self.originProvider = originProvider
    }

    // MARK: - UIViewControllerAnimatedTransitioning

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting {
            animatePresentation(using: transitionContext)
        } else {
            animateDismissal(using: transitionContext)
        }
    }

    // MARK: - Instance Methods

    /// Calculates a frame that fits the image within a given rect while preserving aspect ratio.
    private func aspectFitFrame(for image: UIImage, in rect: CGRect) -> CGRect {
        let imageRatio = image.size.width / image.size.height
        let rectRatio = rect.width / rect.height

        if imageRatio > rectRatio {
            let width = rect.width
            let height = width / imageRatio
            return CGRect(x: rect.minX, y: rect.minY + (rect.height - height) / 2, width: width, height: height)
        } else {
            let height = rect.height
            let width = height * imageRatio
            return CGRect(x: rect.minX + (rect.width - width) / 2, y: rect.minY, width: width, height: height)
        }
    }

    private func makeSnapshot(image: UIImage, frame: CGRect) -> UIImageView {
        let snapshot = UIImageView(image: image)
        snapshot.contentMode = .scaleAspectFill
        snapshot.clipsToBounds = true
        snapshot.frame = frame
        return snapshot
    }

    // MARK: - Presentation

    private func animatePresentation(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to),
              let origin = originProvider
        else {
            transitionContext.completeTransition(false)
            return
        }

        let container = transitionContext.containerView
        let backgroundView = UIView(frame: container.bounds)
        let originRect = container.convert(originFrame, from: nil)
        let snapshot = makeSnapshot(image: originImage, frame: originRect)

        backgroundView.backgroundColor = .black
        backgroundView.alpha = 0
        container.addSubview(backgroundView)
        container.addSubview(snapshot)
        toVC.view.frame = container.bounds
        toVC.view.alpha = 0
        container.addSubview(toVC.view)

        if let sel = origin.selectedIndex {
            origin.hideImage(at: sel, hidden: true)
        }

        UIView.animate(withDuration: duration) {
            backgroundView.alpha = 1
            snapshot.frame = self.aspectFitFrame(for: self.originImage, in: container.bounds)
        } completion: { _ in
            toVC.view.alpha = 1
            snapshot.removeFromSuperview()
            backgroundView.removeFromSuperview()

            if let sel = origin.selectedIndex {
                origin.hideImage(at: sel, hidden: false)
            }

            transitionContext.completeTransition(true)
        }
    }

    private func animateDismissal(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from) as? ZoomAnimatorDestinationProvider,
              let origin = originProvider
        else {
            transitionContext.completeTransition(false)
            return
        }

        let container = transitionContext.containerView

        guard let image = fromVC.snapshotImage else {
            transitionContext.completeTransition(false)
            return
        }

        let startFrame = aspectFitFrame(for: image, in: container.bounds)
        let snapshot = makeSnapshot(image: image, frame: startFrame)

        container.addSubview(snapshot)
        fromVC.prepareForDismiss()
        fromVC.hide(true)

        let destination =
            origin.imageFrame(at: fromVC.currentIndex, in: container)
            ?? origin.selectedCellFrameInWindow
            ?? originFrame

        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut]) {
            snapshot.frame = destination
        } completion: { _ in
            snapshot.removeFromSuperview()
            (fromVC as? UIViewController)?.view.isHidden = false
            transitionContext.completeTransition(true)
        }
    }
}
