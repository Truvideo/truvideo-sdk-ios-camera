//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI
import UIKit

/// A view controller that displays a single photo.
///
/// Used inside `MediaPreviewPageViewController` for full-screen photo preview.
final class PhotoViewController: UIViewController {
    // MARK: - Properties

    /// The image to display in this view controller.
    var image: UIImage?

    /// The image view used to present the photo.
    let imageView = UIImageView()

    /// The index of the photo in the media array.
    var index: Int = 0

    // MARK: - Initializer

    /// Initializes the view controller with an optional image.
    ///
    /// - Parameter image: The image to display. Defaults to `nil`.
    init(image: UIImage? = nil) {
        self.image = image

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        imageView.frame = view.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(imageView)
    }
}
