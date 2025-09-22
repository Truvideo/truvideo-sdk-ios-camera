//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI
import UIKit

/// A delegate that notifies about updates in a `GalleryGridViewController`.
protocol GalleryGridViewControllerDelegate: AnyObject {
    /// Called when the media items have been updated in the gallery grid.
    ///
    /// - Parameters:
    ///   - viewController: The gallery grid view controller sending the update.
    ///   - medias: The updated list of media items.
    func galleryGridViewControllerDidUpdateMedias(_ viewController: GalleryGridViewController, medias: [Media])
}

/// A SwiftUI wrapper that hosts a `GalleryGridViewController`
///
/// Use this struct when embedding the UIKit-based gallery grid inside
/// a SwiftUI view hierarchy.
struct GalleryGrid: UIViewControllerRepresentable {
    // MARK: - Binding Properties

    /// The media items to be displayed in the grid.
    @Binding var medias: [Media]

    /// A Boolean value that controls whether the gallery is presented.
    @Binding var isPresented: Bool

    // MARK: - Properties

    /// The theme configuration applied to the grid.
    let theme: Theme

    // MARK: - UIViewControllerRepresentable

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> GalleryGridViewController {
        let viewController = GalleryGridViewController(medias: medias, theme: theme)
        viewController.deleteDelegate = context.coordinator
        return viewController
    }

    func updateUIViewController(_ uiViewController: GalleryGridViewController, context: Context) {
        uiViewController.updateMedias(medias)
    }

    // MARK: - Coordinator

    /// A coordinator that acts as the delegate between `GalleryGrid`
    /// and its underlying `GalleryGridViewController`.
    class Coordinator: NSObject, GalleryGridViewControllerDelegate {
        // MARK: - Properties

        var parent: GalleryGrid

        // MARK: - Initializer

        init(_ parent: GalleryGrid) {
            self.parent = parent
        }

        // MARK: - GalleryGridViewControllerDelegate

        func galleryGridViewControllerDidUpdateMedias(_ vc: GalleryGridViewController, medias: [Media]) {
            parent.medias = medias
            if medias.isEmpty {
                parent.isPresented = false
            }
        }
    }
}

/// A view controller that manages a grid of media items using a `UICollectionView`.
///
/// Displays both photos and clips, supports custom transitions
/// to a full-screen preview, and adapts its layout to orientation changes.
final class GalleryGridViewController: UIViewController {
    // MARK: - Private Properties

    private var medias: [Media]
    private let theme: Theme

    // MARK: - Properties

    /// The delegate that receives updates from this gallery grid view controller.
    ///
    /// Implementers are informed about changes to the media list (e.g. deletions).
    /// Marked `weak` to avoid retain cycles between the view controller and its owner.
    weak var deleteDelegate: GalleryGridViewControllerDelegate?

    /// The index of the currently selected item in the gallery.
    var selectedIndex: Int?

    /// The frame of the selected cell, in window coordinates,
    /// used for custom transition animations.
    var selectedCellFrameInWindow: CGRect?

    /// The thumbnail image of the selected media item,
    /// used for custom transition animations.
    var selectedThumbnail: UIImage?

    // MARK: - Computed Properties

    /// The collection view that displays the gallery grid.
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1

        collectionView.register(
            ImageCollectionViewCell.self,
            forCellWithReuseIdentifier: ImageCollectionViewCell.reuseIdentifier
        )

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    // MARK: - Initializer

    /// Creates a new gallery grid view controller with the given media and theme.
    ///
    /// - Parameters:
    ///   - medias: The array of media items to display in the grid.
    ///   - theme: The theme used to configure cell appearance.
    init(medias: [Media], theme: Theme) {
        self.medias = medias
        self.theme = theme

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        view.addSubview(collectionView)

        collectionView.frame = view.bounds
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate { _ in
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }

    // MARK: - Instance Methods

    /// Updates the media items displayed in the grid.
    ///
    /// - Parameter newMedias: The updated list of media items.
    func updateMedias(_ newMedias: [Media]) {
        self.medias = newMedias
        collectionView.reloadData()
    }

    /// Deletes the media item at the specified index.
    ///
    /// - Parameter index: The index of the item to delete.
    func deleteMedia(at index: Int) {
        guard index < medias.count else { return }
        medias.remove(at: index)
        collectionView.reloadData()
        deleteDelegate?.galleryGridViewControllerDidUpdateMedias(self, medias: medias)
    }
}

extension GalleryGridViewController: ZoomAnimatorOriginProvider {
    // MARK: - ZoomAnimatorOriginProvider

    func imageFrame(at index: Int, in container: UIView) -> CGRect? {
        let indexPath = IndexPath(item: index, section: 0)
        guard
            let cell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell
        else {
            return nil
        }
        return cell.imageView.convert(cell.imageView.bounds, to: container)
    }

    func hideImage(at index: Int, hidden: Bool) {
        let indexPath = IndexPath(item: index, section: 0)
        if let cell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell {
            cell.imageView.isHidden = hidden
        }
    }
}

extension GalleryGridViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        medias.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ImageCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? ImageCollectionViewCell
        else {
            return UICollectionViewCell()
        }

        cell.configure(with: medias[indexPath.item], theme: theme, parent: self)

        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let columns: CGFloat = traitCollection.verticalSizeClass == .compact ? 5 : 3
        let spacing: CGFloat = 2
        let totalSpacing = (columns - 1) * spacing
        let width = (view.bounds.width - totalSpacing) / columns

        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell else { return }

        collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)

        selectedIndex = indexPath.item
        selectedThumbnail = cell.imageView.image
        selectedCellFrameInWindow = cell.imageView.convert(cell.imageView.bounds, to: nil)

        let pageViewController = MediaPreviewPageViewController(medias: medias, startIndex: indexPath.item)
        pageViewController.mediaDelegate = self
        pageViewController.modalPresentationStyle = .custom
        pageViewController.transitioningDelegate = self

        present(pageViewController, animated: true, completion: nil)
    }
}

extension GalleryGridViewController: MediaPreviewPageViewControllerDelegate {
    // MARK: - MediaPreviewPageViewControllerDelegate

    func mediaPreviewPageViewController(_ vc: MediaPreviewPageViewController, didDeleteAt index: Int) {
        deleteMedia(at: index)
    }
}

extension GalleryGridViewController: UIViewControllerTransitioningDelegate {
    // MARK: - UIViewControllerTransitioningDelegate

    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        guard let originFrame = selectedCellFrameInWindow, let originImage = selectedThumbnail else {
            return nil
        }

        return ZoomAnimatedTransition(
            isPresenting: true,
            originFrame: originFrame,
            originImage: originImage,
            originProvider: self
        )
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let originFrame = selectedCellFrameInWindow, let originImage = selectedThumbnail else {
            return nil
        }

        return ZoomAnimatedTransition(
            isPresenting: false,
            originFrame: originFrame,
            originImage: originImage,
            originProvider: self
        )
    }
}
