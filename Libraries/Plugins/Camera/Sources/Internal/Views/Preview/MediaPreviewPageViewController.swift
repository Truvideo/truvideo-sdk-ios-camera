//
// Copyright © 2025 TruVideo. All rights reserved.
//

import UIKit

/// A delegate protocol that notifies about deletion events
/// in `MediaPreviewPageViewController`.
protocol MediaPreviewPageViewControllerDelegate: AnyObject {
    // MARK: - Instance Methods

    /// Called when the user deletes a media item at the specified index.
    ///
    /// - Parameters:
    ///   - vc: The preview page view controller sending the event.
    ///   - index: The index of the deleted media item.
    func mediaPreviewPageViewController(_ vc: MediaPreviewPageViewController, didDeleteAt index: Int)
}

/// A page view controller that displays a full-screen preview of media items (photos or clips).
///
/// Allows horizontal swiping between media items and provides a close button
/// to dismiss the preview. Tracks the currently visible media index.
final class MediaPreviewPageViewController: UIPageViewController {
    // MARK: - Private Properties

    private var medias: [Media]
    private var startIndex: Int
    private let theme = Theme.default

    // MARK: - Properties

    /// The index of the currently displayed media item.
    private(set) var currentIndex: Int

    /// The delegate notified when a media update.
    ///
    /// Marked `weak` to prevent retain cycles between the view controller
    /// and its delegate.
    weak var mediaDelegate: MediaPreviewPageViewControllerDelegate?

    // MARK: - Initializer

    /// Initializes a page view controller with the given media and start index.
    ///
    /// - Parameters:
    ///   - medias: The media items to display in the preview.
    ///   - startIndex: The initial index to display when the preview opens.
    init(medias: [Media], startIndex: Int) {
        self.medias = medias
        self.startIndex = startIndex
        self.currentIndex = startIndex

        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [.interPageSpacing: 40])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIPageViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self
        view.backgroundColor = .black

        setupButtons()

        if let viewController = mediaViewController(for: startIndex) {
            setViewControllers([viewController], direction: .forward, animated: false, completion: nil)
        }
    }

    // MARK: - Actions

    /// Dismisses the preview when the close button is tapped.
    @objc
    private func closeTapped() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    /// Deletes the current media item when the delete button is tapped.
    @objc
    private func deleteTapped() {
        guard currentIndex < medias.count else { return }

        mediaDelegate?.mediaPreviewPageViewController(self, didDeleteAt: currentIndex)
        medias.remove(at: currentIndex)

        if medias.isEmpty {
            presentingViewController?.dismiss(animated: false, completion: nil)
            return
        }

        let direction = currentIndex == 0 ? UIPageViewController.NavigationDirection.forward : .reverse
        currentIndex = max(0, min(currentIndex - 1, medias.count - 1))

        if let newViewController = mediaViewController(for: currentIndex) {
            setViewControllers([newViewController], direction: direction, animated: true, completion: nil)
        }
    }

    // MARK: - Private Methods

    private func setupButtons() {
        let buttonSize = theme.sizeTheme.x(10)
        let topSpacing = theme.spacingTheme.x(12.5)
        let closeButton = makeButton(systemName: "xmark", action: #selector(closeTapped))
        let deleteButton = makeButton(systemName: "trash", action: #selector(deleteTapped))

        view.addSubview(closeButton)
        view.addSubview(deleteButton)

        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: theme.spacingTheme.md),
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: topSpacing),
            closeButton.widthAnchor.constraint(equalToConstant: buttonSize),
            closeButton.heightAnchor.constraint(equalToConstant: buttonSize),

            deleteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -theme.spacingTheme.md),
            deleteButton.topAnchor.constraint(equalTo: view.topAnchor, constant: topSpacing),
            deleteButton.widthAnchor.constraint(equalToConstant: buttonSize),
            deleteButton.heightAnchor.constraint(equalToConstant: buttonSize),
        ])

        view.bringSubviewToFront(closeButton)
        view.bringSubviewToFront(deleteButton)
    }

    private func makeButton(systemName: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: systemName), for: .normal)
        button.backgroundColor = UIColor(theme.colorScheme.primary)
        button.layer.cornerRadius = theme.radiusTheme.xl
        button.tintColor = UIColor(theme.colorScheme.onPrimary)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    /// Returns a view controller configured to display the media at the given index.
    private func mediaViewController(for index: Int) -> UIViewController? {
        guard index >= 0 && index < medias.count else { return nil }

        let media = medias[index]

        switch media {
        case .clip(let clip):
            let viewController = ClipViewController(clip: clip)
            viewController.index = index

            return viewController

        case .photo(let photo):
            let viewController = PhotoViewController(photo: photo)
            viewController.index = index

            return viewController
        }
    }
}

extension MediaPreviewPageViewController: ZoomAnimatorDestinationProvider {
    // MARK: - ZoomAnimatorDestinationProvider

    var snapshotImage: UIImage? {
        if let current = viewControllers?.first as? PhotoViewController {
            return current.imageView.image
        } else if let current = viewControllers?.first as? ClipViewController {
            return current.imageView.image
        }

        return nil
    }

    var snapshotView: UIView? {
        if let current = viewControllers?.first as? PhotoViewController {
            return current.imageView
        } else if let current = viewControllers?.first as? ClipViewController {
            return current.view
        }

        return nil
    }

    func hide(_ hidden: Bool) {
        view.isHidden = hidden
    }

    func prepareForDismiss() {
        if let current = viewControllers?.first as? PhotoViewController {
            current.imageView.isHidden = true
        }
    }
}

extension MediaPreviewPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    // MARK: - UIPageViewControllerDataSource

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        let index: Int

        if let current = viewController as? PhotoViewController {
            index = current.index
        } else if let current = viewController as? ClipViewController {
            index = current.index
        } else {
            return nil
        }

        return mediaViewController(for: index - 1)
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        let index: Int

        if let current = viewController as? PhotoViewController {
            index = current.index
        } else if let current = viewController as? ClipViewController {
            index = current.index
        } else {
            return nil
        }

        return mediaViewController(for: index + 1)
    }

    // MARK: - UIPageViewControllerDelegate

    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if completed {
            if let current = viewControllers?.first as? PhotoViewController {
                currentIndex = current.index
            } else if let current = viewControllers?.first as? ClipViewController {
                currentIndex = current.index
            }
        }
    }
}
