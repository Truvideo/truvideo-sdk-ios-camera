//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI
import UIKit

/// A SwiftUI wrapper that hosts a `GalleryGridViewController`
///
/// Use this struct when embedding the UIKit-based gallery grid inside
/// a SwiftUI view hierarchy.
struct GalleryGrid: UIViewControllerRepresentable {
    /// The media items to be displayed in the grid.
    let medias: [Media]

    /// The theme configuration applied to the grid.
    let theme: Theme

    // MARK: - UIViewControllerRepresentable

    func makeUIViewController(context: Context) -> GalleryGridViewController {
        GalleryGridViewController(medias: medias, theme: theme)
    }

    func updateUIViewController(_ uiViewController: GalleryGridViewController, context: Context) {}
}

/// A view controller that manages a grid of media items using a `UICollectionView`.
///
/// Displays both photos and clips, supports custom transitions
/// to a full-screen preview, and adapts its layout to orientation changes.
class GalleryGridViewController: UIViewController {
    // MARK: - Private Properties

    private var medias: [Media]
    private let theme: Theme

    // MARK: - Properties

    /// The index of the currently selected item in the gallery.
    var selectedIndex: Int?

    /// The frame of the selected cell, in window coordinates,
    /// used for custom transition animations.
    var selectedCellFrameInWindow: CGRect?

    /// The thumbnail image of the selected media item,
    /// used for custom transition animations.
    var selectedThumbnail: UIImage?

    // MARK: - Computed Properties

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ImageCellView.self, forCellWithReuseIdentifier: ImageCellView.reuseId)
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

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            self.collectionView.collectionViewLayout.invalidateLayout()
        })
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
        guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ImageCellView.reuseId,
                for: indexPath
            ) as? ImageCellView else {
            // Return a default cell if casting fails to avoid a crash
            return UICollectionViewCell()
        }

        let media = medias[indexPath.item]
        cell.configure(with: media, theme: theme, parent: self)

        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let isLandscape = traitCollection.verticalSizeClass == .compact
        let columns: CGFloat = isLandscape ? 5 : 3
        let spacing: CGFloat = 2
        let totalSpacing = (columns - 1) * spacing
        let width = (view.bounds.width - totalSpacing) / columns
        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ImageCellView else { return }
        collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)

        selectedIndex = indexPath.item
        selectedThumbnail = medias[indexPath.item].thumbnail
        selectedCellFrameInWindow = cell.imageView.convert(cell.imageView.bounds, to: nil)

        let pageViewController = MediaPreviewPageViewController(medias: medias, startIndex: indexPath.item)
        pageViewController.modalPresentationStyle = .custom
        pageViewController.transitioningDelegate = self

        present(pageViewController, animated: true, completion: nil)
    }
}

extension GalleryGridViewController: UIViewControllerTransitioningDelegate {
    // MARK: - UIViewControllerTransitioningDelegate

    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        guard let originFrame = selectedCellFrameInWindow,
            let originImage = selectedThumbnail
        else { return nil }

        return ZoomAnimatedTransition(
            isPresenting: true,
            originFrame: originFrame,
            originImage: originImage,
            galleryViewController: self
        )
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let originFrame = selectedCellFrameInWindow,
            let originImage = selectedThumbnail
        else { return nil }

        return ZoomAnimatedTransition(
            isPresenting: false,
            originFrame: originFrame,
            originImage: originImage,
            galleryViewController: self
        )
    }
}
