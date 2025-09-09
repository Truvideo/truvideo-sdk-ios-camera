import UIKit

/// A page view controller that displays a full-screen preview of media items (photos or clips).
///
/// Allows horizontal swiping between media items and provides a close button
/// to dismiss the preview. Tracks the currently visible media index.
class MediaPreviewPageViewController: UIPageViewController {
    // MARK: - Private Properties

    private var medias: [Media]
    private var startIndex: Int

    // MARK: - Properties

    /// The index of the currently displayed media item.
    public private(set) var currentIndex: Int

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

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UIPageViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        view.backgroundColor = .black

        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        closeButton.tintColor = .white
        closeButton.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        closeButton.layer.cornerRadius = 20
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.frame = CGRect(x: 16, y: 50, width: 40, height: 40)
        view.addSubview(closeButton)

        if let startViewController = mediaViewController(for: startIndex) {
            setViewControllers([startViewController], direction: .forward, animated: false, completion: nil)
        }

        view.bringSubviewToFront(closeButton)
    }

    // MARK: - Actions

    /// Dismisses the preview when the close button is tapped.
    @objc private func closeTapped() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    // MARK: - Private Methods

    /// Returns a view controller configured to display the media at the given index.
    ///
    /// - Parameter index: The index of the media to display.
    /// - Returns: A `UIViewController` displaying the media, or `nil` if the index is out of bounds.
    private func mediaViewController(for index: Int) -> UIViewController? {
        guard index >= 0 && index < medias.count else { return nil }

        let media = medias[index]

        switch media {
        case let .photo(pic):
            let viewController = PhotoViewController(image: pic.image)
            viewController.index = index
            return viewController
        case let .clip(video):
            let viewController = ClipViewController(clip: video)
            viewController.index = index
            return viewController
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
