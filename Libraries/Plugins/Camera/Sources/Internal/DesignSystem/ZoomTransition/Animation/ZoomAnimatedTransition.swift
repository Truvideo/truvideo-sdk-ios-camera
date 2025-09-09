import UIKit

/// A custom animated transition that zooms a selected media item from a gallery into a full-screen preview,
/// and vice versa.
///
/// Handles both presentation and dismissal animations for `MediaPreviewPageViewController`.
class ZoomAnimatedTransition: NSObject, UIViewControllerAnimatedTransitioning {
    // MARK: - Properties

    /// Duration of the animation in seconds.
    let duration = 0.3

    // MARK: - Private Properties

    private let isPresenting: Bool
    private let originFrame: CGRect
    private let originImage: UIImage
    private weak var galleryViewController: GalleryGridViewController?

    // MARK: - Initializer

    /// Initializes a zoom animated transition.
    ///
    /// - Parameters:
    ///   - isPresenting: True if presenting the media preview, false if dismissing.
    ///   - originFrame: The frame of the originating cell in window coordinates.
    ///   - originImage: The image to animate.
    ///   - galleryViewController: The gallery containing the media cells.
    init(
        isPresenting: Bool,
        originFrame: CGRect,
        originImage: UIImage,
        galleryViewController: GalleryGridViewController
    ) {
        self.isPresenting = isPresenting
        self.originFrame = originFrame
        self.originImage = originImage
        self.galleryViewController = galleryViewController
    }

    // MARK: - UIViewControllerAnimatedTransitioning

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval { duration }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting {
            animatePresentation(using: transitionContext)
        } else {
            animateDismissal(using: transitionContext)
        }
    }

    // MARK: - Instance Methods

    /// Hides or shows the image in a gallery cell at the specified index.
    private func hideCellImage(in gallery: GalleryGridViewController, at index: Int, hidden: Bool) {
        let ip = IndexPath(item: index, section: 0)
        if let cell = gallery.collectionView.cellForItem(at: ip) as? ImageCellView {
            cell.imageView.isHidden = hidden
        }
    }

    /// Returns the frame of the destination cell in the gallery for dismissal animation.
    private func destinationFrame(for index: Int, in gallery: GalleryGridViewController, container: UIView) -> CGRect? {
        let indexPath = IndexPath(item: index, section: 0)
        guard let cell = gallery.collectionView.cellForItem(at: indexPath) as? ImageCellView else {
            return nil
        }
        cell.imageView.isHidden = true
        return cell.imageView.convert(cell.imageView.bounds, to: container)
    }

    /// Calculates a frame that fits the image within the container while preserving aspect ratio.
    private func aspectFitFrame(for image: UIImage, in containerBounds: CGRect) -> CGRect {
        let imageRatio = image.size.width / image.size.height
        let containerRatio = containerBounds.width / containerBounds.height
        if imageRatio > containerRatio {
            let width = containerBounds.width
            let height = width / imageRatio
            return CGRect(x: 0, y: (containerBounds.height - height) / 2, width: width, height: height)
        } else {
            let height = containerBounds.height
            let width = height * imageRatio
            return CGRect(x: (containerBounds.width - width) / 2, y: 0, width: width, height: height)
        }
    }

    // MARK: - Presentation

    private func animatePresentation(using transitionContext: UIViewControllerContextTransitioning) {
        guard let viewController = transitionContext.viewController(forKey: .to) as? MediaPreviewPageViewController,
            let gallery = galleryViewController
        else {
            transitionContext.completeTransition(false)
            return
        }

        let container = transitionContext.containerView
        let backgroundView = UIView(frame: container.bounds)
        let snapshot = UIImageView(image: originImage)

        backgroundView.backgroundColor = .black
        backgroundView.alpha = 0
        container.addSubview(backgroundView)
        snapshot.contentMode = .scaleAspectFill
        snapshot.frame = container.convert(originFrame, from: nil)
        container.addSubview(snapshot)
        viewController.view.frame = container.bounds
        viewController.view.layoutIfNeeded()
        container.addSubview(viewController.view)
        viewController.view.alpha = 0

        if let sel = gallery.selectedIndex {
            hideCellImage(in: gallery, at: sel, hidden: true)
        }

        UIView.animate(withDuration: duration) {
            backgroundView.alpha = 1
            snapshot.frame = self.aspectFitFrame(for: self.originImage, in: container.bounds)
        } completion: { _ in
            viewController.view.alpha = 1
            snapshot.removeFromSuperview()
            backgroundView.removeFromSuperview()

            if let sel = gallery.selectedIndex {
                self.hideCellImage(in: gallery, at: sel, hidden: false)
            }

            transitionContext.completeTransition(true)
        }
    }

    private func animateDismissal(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let detailViewController = transitionContext.viewController(forKey: .from)
                as? MediaPreviewPageViewController,
            let gallery = galleryViewController
        else {
            transitionContext.completeTransition(false)
            return
        }

        let container = transitionContext.containerView
        var snapshotImage: UIImage?
        var startView: UIView?

        if let currentImageVC = detailViewController.viewControllers?.first as? PhotoViewController {
            snapshotImage = currentImageVC.imageView.image
            startView = currentImageVC.imageView
            currentImageVC.imageView.isHidden = true
        } else if let currentVideoVC = detailViewController.viewControllers?.first as? ClipViewController {
            snapshotImage = currentVideoVC.clip.thumbnail
            startView = currentVideoVC.view
        }

        guard let image = snapshotImage, let fromView = startView else {
            transitionContext.completeTransition(false)
            return
        }

        let snapshot = UIImageView(image: image)
        snapshot.contentMode = .scaleAspectFill
        snapshot.clipsToBounds = true
        snapshot.frame = fromView.convert(fromView.bounds, to: container)
        container.addSubview(snapshot)

        detailViewController.view.isHidden = true

        let destIndex = detailViewController.currentIndex
        let destination = destinationFrame(for: destIndex, in: gallery, container: container) ?? gallery.selectedCellFrameInWindow ?? originFrame

        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut]) {
            snapshot.frame = destination
        } completion: { _ in
            if let destCell = gallery.collectionView.cellForItem(at: IndexPath(item: destIndex, section: 0))
                as? ImageCellView
            {
                destCell.imageView.isHidden = false
            }

            snapshot.removeFromSuperview()
            detailViewController.view.isHidden = false
            transitionContext.completeTransition(true)
        }
    }
}
